import 'dart:async';
import 'package:flutter/foundation.dart';
import 'app_constants.dart';

/// Result of a retry operation
class RetryResult<T> {
  final T? value;
  final bool success;
  final int attemptsMade;
  final Object? lastError;

  RetryResult._({
    this.value,
    required this.success,
    required this.attemptsMade,
    this.lastError,
  });

  factory RetryResult.success(T value, int attempts) =>
      RetryResult._(value: value, success: true, attemptsMade: attempts);

  factory RetryResult.failure(int attempts, Object error) =>
      RetryResult._(success: false, attemptsMade: attempts, lastError: error);
}

/// Retry configuration
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Base delay for exponential backoff (milliseconds)
  final int baseDelayMs;

  /// Maximum delay between retries (milliseconds)
  final int maxDelayMs;

  /// Function to determine if an error is retryable
  final bool Function(Object error)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = NetworkConstants.maxRetryAttempts,
    this.baseDelayMs = NetworkConstants.retryBaseDelayMs,
    this.maxDelayMs = 8000,
    this.shouldRetry,
  });

  /// Default configuration for network calls
  static const network = RetryConfig();

  /// Configuration for quick retries (lower delays)
  static const quick = RetryConfig(
    maxAttempts: 2,
    baseDelayMs: 500,
    maxDelayMs: 2000,
  );
}

/// Execute an async operation with exponential backoff retry
///
/// Example usage:
/// ```dart
/// final result = await retryWithBackoff(
///   () => apiCall(),
///   config: RetryConfig.network,
/// );
/// if (result.success) {
///   print('Success after ${result.attemptsMade} attempts');
/// } else {
///   print('Failed: ${result.lastError}');
/// }
/// ```
Future<RetryResult<T>> retryWithBackoff<T>(
  Future<T> Function() operation, {
  RetryConfig config = const RetryConfig(),
}) async {
  int attempts = 0;
  Object? lastError;

  while (attempts < config.maxAttempts) {
    attempts++;

    try {
      final result = await operation();
      return RetryResult.success(result, attempts);
    } catch (e) {
      lastError = e;
      debugPrint('Retry attempt $attempts failed: $e');

      // Check if we should retry
      if (config.shouldRetry != null && !config.shouldRetry!(e)) {
        debugPrint('Error is not retryable, stopping');
        break;
      }

      // Don't delay on last attempt
      if (attempts < config.maxAttempts) {
        // Exponential backoff: baseDelay * 2^(attempt-1)
        final delay = (config.baseDelayMs * (1 << (attempts - 1))).clamp(
          config.baseDelayMs,
          config.maxDelayMs,
        );
        debugPrint('Waiting ${delay}ms before retry...');
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  return RetryResult.failure(attempts, lastError ?? Exception('Unknown error'));
}

/// Simple retry wrapper that throws on failure
///
/// Example:
/// ```dart
/// final data = await retry(() => fetchData());
/// ```
Future<T> retry<T>(
  Future<T> Function() operation, {
  int maxAttempts = NetworkConstants.maxRetryAttempts,
}) async {
  final result = await retryWithBackoff(
    operation,
    config: RetryConfig(maxAttempts: maxAttempts),
  );

  if (result.success) {
    return result.value as T;
  }

  throw result.lastError ??
      Exception('Retry failed after ${result.attemptsMade} attempts');
}

/// Check if an error is likely a transient network error worth retrying
bool isTransientError(Object error) {
  final errorString = error.toString().toLowerCase();

  // Common transient error patterns
  return errorString.contains('timeout') ||
      errorString.contains('connection') ||
      errorString.contains('socket') ||
      errorString.contains('503') ||
      errorString.contains('502') ||
      errorString.contains('500') ||
      errorString.contains('temporarily unavailable');
}
