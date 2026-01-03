import 'package:easy_localization/easy_localization.dart';

/// Types of cloud-related errors
enum CloudErrorType {
  networkTimeout,
  authExpired,
  authCancelled,
  quotaExceeded,
  serverError,
  invalidData,
  unknown,
}

/// Custom exception for cloud operations with user-friendly messages
class CloudException implements Exception {
  final CloudErrorType type;
  final String message;
  final String userMessageKey;
  final dynamic originalError;

  CloudException({
    required this.type,
    required this.message,
    required this.userMessageKey,
    this.originalError,
  });

  /// Get translated user-friendly message
  String get userMessage => userMessageKey.tr();

  /// Factory to create CloudException from various error types
  factory CloudException.fromException(dynamic e) {
    final errorString = e.toString().toLowerCase();

    if (errorString.contains('timeout') ||
        errorString.contains('timed out') ||
        errorString.contains('connection closed')) {
      return CloudException(
        type: CloudErrorType.networkTimeout,
        message: e.toString(),
        userMessageKey: 'cloud.error_timeout',
        originalError: e,
      );
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('unauthenticated') ||
        errorString.contains('token expired') ||
        errorString.contains('invalid_grant')) {
      return CloudException(
        type: CloudErrorType.authExpired,
        message: e.toString(),
        userMessageKey: 'cloud.error_auth_expired',
        originalError: e,
      );
    }

    if (errorString.contains('cancelled') ||
        errorString.contains('canceled') ||
        errorString.contains('user denied')) {
      return CloudException(
        type: CloudErrorType.authCancelled,
        message: e.toString(),
        userMessageKey: 'cloud.error_auth_cancelled',
        originalError: e,
      );
    }

    if (errorString.contains('quota') ||
        errorString.contains('storage limit') ||
        errorString.contains('insufficient storage')) {
      return CloudException(
        type: CloudErrorType.quotaExceeded,
        message: e.toString(),
        userMessageKey: 'cloud.error_quota',
        originalError: e,
      );
    }

    if (errorString.contains('500') ||
        errorString.contains('503') ||
        errorString.contains('server error')) {
      return CloudException(
        type: CloudErrorType.serverError,
        message: e.toString(),
        userMessageKey: 'cloud.error_server',
        originalError: e,
      );
    }

    if (errorString.contains('json') ||
        errorString.contains('parse') ||
        errorString.contains('format')) {
      return CloudException(
        type: CloudErrorType.invalidData,
        message: e.toString(),
        userMessageKey: 'cloud.error_invalid_data',
        originalError: e,
      );
    }

    // Default unknown error
    return CloudException(
      type: CloudErrorType.unknown,
      message: e.toString(),
      userMessageKey: 'cloud.sync_error',
      originalError: e,
    );
  }

  @override
  String toString() => 'CloudException(type: $type, message: $message)';
}
