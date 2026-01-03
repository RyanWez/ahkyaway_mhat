import 'package:flutter/material.dart';

/// Configuration for paginated lists
class PaginationConfig {
  /// Number of items to load per page
  final int pageSize;

  /// Threshold for triggering load more (pixels from bottom)
  final double loadMoreThreshold;

  const PaginationConfig({this.pageSize = 20, this.loadMoreThreshold = 200});
}

/// Mixin that provides pagination state management for StatefulWidgets
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with PaginatedListMixin {
///   @override
///   int get pageSize => 20;
///
///   @override
///   Widget build(BuildContext context) {
///     final items = allItems.take(displayCount).toList();
///     return NotificationListener<ScrollNotification>(
///       onNotification: handleScrollNotification,
///       child: ListView.builder(...),
///     );
///   }
/// }
/// ```
mixin PaginatedListMixin<T extends StatefulWidget> on State<T> {
  /// Number of items to display (increases as user scrolls)
  int _displayCount = 20;

  /// Whether currently loading more items
  bool _isLoadingMore = false;

  /// Override to customize page size
  int get pageSize => 20;

  /// Override to customize load threshold
  double get loadMoreThreshold => 200;

  /// Current number of items being displayed
  int get displayCount => _displayCount;

  /// Whether loading more items
  bool get isLoadingMore => _isLoadingMore;

  /// Check if there are more items to load
  bool hasMoreItems(int totalCount) => _displayCount < totalCount;

  /// Handle scroll notification to trigger loading more
  bool handleScrollNotification(
    ScrollNotification notification,
    int totalCount,
  ) {
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      final remaining = metrics.maxScrollExtent - metrics.pixels;

      if (remaining < loadMoreThreshold &&
          hasMoreItems(totalCount) &&
          !_isLoadingMore) {
        loadMore(totalCount);
        return true;
      }
    }
    return false;
  }

  /// Load more items
  void loadMore(int totalCount) {
    if (_isLoadingMore || !hasMoreItems(totalCount)) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate async loading with small delay for smooth UX
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _displayCount = (_displayCount + pageSize).clamp(0, totalCount);
          _isLoadingMore = false;
        });
      }
    });
  }

  /// Reset pagination (e.g., when search query changes)
  void resetPagination() {
    setState(() {
      _displayCount = pageSize;
      _isLoadingMore = false;
    });
  }

  /// Build a "Load More" indicator widget
  Widget buildLoadMoreIndicator({bool show = true}) {
    if (!show) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// A simplified pagination controller for cases where mixin doesn't fit
class PaginationController extends ChangeNotifier {
  int _displayCount;
  bool _isLoadingMore = false;
  final int pageSize;

  PaginationController({this.pageSize = 20}) : _displayCount = pageSize;

  int get displayCount => _displayCount;
  bool get isLoadingMore => _isLoadingMore;

  bool hasMore(int totalCount) => _displayCount < totalCount;

  void loadMore(int totalCount) {
    if (_isLoadingMore || !hasMore(totalCount)) return;

    _isLoadingMore = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 100), () {
      _displayCount = (_displayCount + pageSize).clamp(0, totalCount);
      _isLoadingMore = false;
      notifyListeners();
    });
  }

  void reset() {
    _displayCount = pageSize;
    _isLoadingMore = false;
    notifyListeners();
  }
}
