import 'package:flutter/material.dart';

/// Error types for storage operations
enum StorageErrorType { initialization, migration, load, save, unknown }

/// Represents a storage error with details
class StorageError {
  final StorageErrorType type;
  final String message;
  final dynamic originalError;
  final DateTime occurredAt;

  StorageError({
    required this.type,
    required this.message,
    this.originalError,
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  @override
  String toString() => 'StorageError($type): $message';

  /// User-friendly error message
  String get userMessage {
    switch (type) {
      case StorageErrorType.initialization:
        return 'Failed to initialize data storage. Please restart the app.';
      case StorageErrorType.migration:
        return 'Failed to migrate data. Some data may not be available.';
      case StorageErrorType.load:
        return 'Failed to load data. Starting with empty data.';
      case StorageErrorType.save:
        return 'Failed to save data. Please try again.';
      case StorageErrorType.unknown:
        return 'An unexpected error occurred.';
    }
  }
}

/// Global error notification service
///
/// Use this service to show error messages to users via SnackBar
class ErrorNotifier extends ChangeNotifier {
  StorageError? _lastError;
  final List<StorageError> _errorHistory = [];

  /// The most recent error, if any
  StorageError? get lastError => _lastError;

  /// Whether there's an unhandled error
  bool get hasError => _lastError != null;

  /// History of all errors in this session
  List<StorageError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Report a new error
  void reportError(StorageError error) {
    _lastError = error;
    _errorHistory.add(error);
    debugPrint('ErrorNotifier: ${error.toString()}');
    notifyListeners();
  }

  /// Clear the current error (after user has seen it)
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Clear all error history
  void clearHistory() {
    _errorHistory.clear();
    _lastError = null;
    notifyListeners();
  }

  /// Show error SnackBar in the given context
  static void showErrorSnackBar(BuildContext context, StorageError error) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.userMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }
}
