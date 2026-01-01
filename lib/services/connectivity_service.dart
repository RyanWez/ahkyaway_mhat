import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/app_toast.dart';

/// Service to monitor network connectivity and show status toasts
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOnline = true;
  bool _initialized = false;
  BuildContext? _context;

  /// Initialize connectivity monitoring
  void init(BuildContext context) {
    if (_initialized) return;
    _initialized = true;
    _context = context;

    // Check initial status (don't show toast on init)
    _checkInitialConnectivity();

    // Listen for changes
    _subscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  /// Check initial connectivity without showing toast
  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _wasOnline = _isConnected(results);
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOnline = _isConnected(results);

    // Only show toast if status actually changed
    if (isOnline != _wasOnline) {
      final ctx = _context;
      if (ctx != null && ctx.mounted) {
        if (isOnline) {
          AppToast.showOnline(ctx, 'Online');
        } else {
          AppToast.showOffline(ctx, 'Offline');
        }
      }
      _wasOnline = isOnline;
    }
  }

  /// Check if device is currently connected to the internet
  Future<bool> checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    return _isConnected(results);
  }

  /// Check if any connection is available
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }

  /// Dispose subscription
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
    _context = null;
  }
}
