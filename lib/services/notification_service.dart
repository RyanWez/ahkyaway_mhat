import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Core notification service - reusable for any notification type
///
/// This service provides platform-agnostic notification functionality.
/// Use specialized services (e.g., DueReminderService) for business logic.
///
/// Example:
/// ```dart
/// final service = NotificationService();
/// await service.init();
/// await service.showNotification(
///   id: 1,
///   title: 'Hello',
///   body: 'World',
/// );
/// ```
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _hasPermission = false;

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether notification permission is granted
  bool get hasPermission => _hasPermission;

  /// Initialize the notification service
  ///
  /// Call this once at app startup (e.g., in main.dart)
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Linux settings
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
    notifyListeners();
  }

  /// Request notification permission
  ///
  /// Returns true if permission is granted
  Future<bool> requestPermission() async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Not initialized');
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        _hasPermission =
            await androidPlugin?.requestNotificationsPermission() ?? false;
      } else if (Platform.isIOS || Platform.isMacOS) {
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        _hasPermission =
            await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      } else {
        // Desktop platforms don't require permission
        _hasPermission = true;
      }
    } catch (e) {
      debugPrint('NotificationService: Permission request failed: $e');
      _hasPermission = false;
    }

    notifyListeners();
    return _hasPermission;
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationDetails? customDetails,
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Not initialized');
      return;
    }

    final details = customDetails ?? _defaultNotificationDetails;
    await _plugin.show(id, title, body, details, payload: payload);
    debugPrint('NotificationService: Showed notification $id');
  }

  /// Schedule a notification for a future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationDetails? customDetails,
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Not initialized');
      return;
    }

    // Don't schedule for past dates
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('NotificationService: Cannot schedule for past date');
      return;
    }

    final details = customDetails ?? _defaultNotificationDetails;
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      // Try exact scheduling first (requires SCHEDULE_EXACT_ALARM on Android 12+)
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint(
        'NotificationService: Scheduled exact notification $id for $scheduledDate',
      );
    } catch (e) {
      // Fallback to inexact scheduling if exact alarm permission not granted
      debugPrint('NotificationService: Exact alarm failed, trying inexact: $e');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzDateTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        debugPrint(
          'NotificationService: Scheduled inexact notification $id for $scheduledDate',
        );
      } catch (e2) {
        debugPrint('NotificationService: Failed to schedule notification: $e2');
      }
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('NotificationService: Cancelled notification $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('NotificationService: Cancelled all notifications');
  }

  /// Get list of pending scheduled notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }

  /// Default notification appearance settings
  NotificationDetails get _defaultNotificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'ahkyaway_mhat_default',
        'AhKyaway Mhat Notifications',
        channelDescription: 'Default notification channel',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );
  }

  /// Notification channel for due date reminders
  NotificationDetails get dueReminderDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'ahkyaway_mhat_due_reminders',
        'Due Date Reminders',
        channelDescription: 'Notifications for upcoming debt due dates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF6366F1),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('NotificationService: Tapped notification ${response.id}');
    debugPrint('NotificationService: Payload: ${response.payload}');
    // TODO: Navigate based on payload
  }
}
