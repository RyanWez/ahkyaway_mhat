/// Application-wide constants
///
/// Centralized location for all magic numbers and configuration values.
/// Organized by category for easy maintenance.
library;

/// Storage and backup related constants
class StorageConstants {
  StorageConstants._();

  /// Maximum number of export files to keep
  static const int maxExportFiles = 10;

  /// Maximum sync log entries to retain
  static const int maxLogEntries = 50;
}

/// Sync and reminder related constants
class SyncConstants {
  SyncConstants._();

  /// Hours before showing sync reminder
  static const int syncReminderHours = 24;
}

/// Network and API related constants
class NetworkConstants {
  NetworkConstants._();

  /// Default API request timeout in seconds
  static const int apiTimeoutSeconds = 10;

  /// Maximum number of retry attempts
  static const int maxRetryAttempts = 3;

  /// Base delay for exponential backoff (in milliseconds)
  static const int retryBaseDelayMs = 1000;
}

/// UI and pagination related constants
class UIConstants {
  UIConstants._();

  /// Default page size for paginated lists
  static const int defaultPageSize = 20;

  /// Scroll threshold to trigger load more (pixels from bottom)
  static const double loadMoreThreshold = 200;

  /// Standard animation duration in milliseconds
  static const int standardAnimationMs = 300;

  /// Long animation duration in milliseconds
  static const int longAnimationMs = 800;
}

/// File size constants for formatting
class FileSizeConstants {
  FileSizeConstants._();

  /// Bytes per kilobyte
  static const int bytesPerKB = 1024;

  /// Bytes per megabyte
  static const int bytesPerMB = 1024 * 1024;
}
