import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import 'notification_service.dart';
import 'notification_settings_service.dart';

/// Service for managing due date reminders
///
/// This service handles the business logic for scheduling and canceling
/// notifications specific to debt due dates.
///
/// Example:
/// ```dart
/// final service = DueReminderService(
///   notificationService: notificationService,
///   settingsService: settingsService,
/// );
/// await service.scheduleReminder(debt);
/// ```
class DueReminderService {
  final NotificationService _notificationService;
  final NotificationSettingsService _settingsService;

  DueReminderService({
    required NotificationService notificationService,
    required NotificationSettingsService settingsService,
  }) : _notificationService = notificationService,
       _settingsService = settingsService;

  /// Schedule a reminder for a debt's due date
  ///
  /// The reminder is scheduled based on user's preference (1, 3, or 7 days before)
  Future<void> scheduleReminder(Debt debt, {String? customerName}) async {
    // Check if notifications are enabled
    if (!_settingsService.isEnabled) {
      debugPrint('DueReminderService: Notifications disabled, skipping');
      return;
    }

    // Check if debt is already completed
    if (debt.status == DebtStatus.completed) {
      debugPrint('DueReminderService: Debt already completed, skipping');
      return;
    }

    // Calculate reminder date
    final reminderDays = _settingsService.reminderDaysBefore;
    final reminderDate = debt.dueDate.subtract(Duration(days: reminderDays));

    // Don't schedule if reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) {
      debugPrint('DueReminderService: Reminder date in past, skipping');
      return;
    }

    // Generate unique notification ID from debt ID
    final notificationId = _generateNotificationId(debt.id);

    // Build notification content
    final title = 'အကြွေးပြန်ဆပ်ချိန်နီးပါပြီ';
    final body = customerName != null
        ? '$customerName - ${_formatAmount(debt.principal)} Ks'
        : '${_formatAmount(debt.principal)} Ks';

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: reminderDate,
      payload: 'debt:${debt.id}',
      customDetails: _notificationService.dueReminderDetails,
    );

    debugPrint(
      'DueReminderService: Scheduled reminder for debt ${debt.id} on $reminderDate',
    );
  }

  /// Cancel reminder for a specific debt
  Future<void> cancelReminder(String debtId) async {
    final notificationId = _generateNotificationId(debtId);
    await _notificationService.cancelNotification(notificationId);
    debugPrint('DueReminderService: Cancelled reminder for debt $debtId');
  }

  /// Reschedule all reminders (e.g., after settings change)
  ///
  /// Pass a map of debtId -> customerName for better notification content
  Future<void> rescheduleAllReminders(
    List<Debt> debts, {
    Map<String, String>? customerNames,
  }) async {
    // Cancel all existing reminders first
    for (final debt in debts) {
      await cancelReminder(debt.id);
    }

    // Reschedule active debts
    for (final debt in debts) {
      if (debt.status == DebtStatus.active && !debt.isDeleted) {
        await scheduleReminder(
          debt,
          customerName: customerNames?[debt.customerId],
        );
      }
    }

    debugPrint(
      'DueReminderService: Rescheduled reminders for ${debts.length} debts',
    );
  }

  /// Generate a consistent notification ID from debt ID
  ///
  /// Uses hashCode to convert String ID to int for notification system
  int _generateNotificationId(String debtId) {
    // Use a prefix to avoid collision with other notification types
    return 'due_$debtId'.hashCode.abs();
  }

  /// Format amount for display
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
