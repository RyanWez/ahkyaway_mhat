import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../services/notification_service.dart';
import '../../../services/notification_settings_service.dart';
import '../../../widgets/app_card.dart';

/// Notification settings card for the settings screen
class NotificationSettingsCard extends StatefulWidget {
  final bool isDark;

  const NotificationSettingsCard({super.key, required this.isDark});

  @override
  State<NotificationSettingsCard> createState() =>
      _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationSettingsService>(
      builder: (context, settings, _) {
        return Column(
          children: [
            // Enable notifications toggle
            AppCard(
              isDark: widget.isDark,
              onTap: () => _toggleEnabled(settings),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: settings.isEnabled
                          ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: settings.isEnabled
                          ? const Color(0xFF6366F1)
                          : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'settings.notifications'.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: widget.isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'settings.notifications_desc'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark
                                ? Colors.grey[500]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Toggle switch
                  _AnimatedToggleSwitch(
                    value: settings.isEnabled,
                    onChanged: (_) => _toggleEnabled(settings),
                  ),
                ],
              ),
            ),

            // Reminder days dropdown (only shown if enabled)
            if (settings.isEnabled) ...[
              const SizedBox(height: 12),
              AppCard(
                isDark: widget.isDark,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFFFF9800),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'settings.remind_before'.tr(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'settings.remind_before_desc'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Dropdown
                    _ReminderDaysDropdown(
                      isDark: widget.isDark,
                      value: settings.reminderDaysBefore,
                      onChanged: (days) => settings.setReminderDays(days),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _toggleEnabled(NotificationSettingsService settings) async {
    final newValue = !settings.isEnabled;

    // Request permission if enabling
    if (newValue) {
      final notificationService = context.read<NotificationService>();
      final hasPermission = await notificationService.requestPermission();

      if (!hasPermission && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings.notification_permission_denied'.tr()),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }
    }

    await settings.setEnabled(newValue);
  }
}

/// Custom animated toggle switch
class _AnimatedToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedToggleSwitch({required this.value, required this.onChanged});

  static const double _width = 70;
  static const double _height = 36;
  static const double _thumbSize = 30;
  static const double _thumbPadding = 3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_height / 2),
          color: value ? const Color(0xFF6366F1) : const Color(0xFFB8C4BB),
          boxShadow: [
            BoxShadow(
              color: value
                  ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ON text
            Positioned(
              left: 10,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                opacity: value ? 1.0 : 0.0,
                child: const Text(
                  'ON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // OFF text
            Positioned(
              right: 10,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                opacity: value ? 0.0 : 1.0,
                child: const Text(
                  'OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: value ? _width - _thumbSize - _thumbPadding : _thumbPadding,
              top: _thumbPadding,
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown for selecting reminder days
class _ReminderDaysDropdown extends StatelessWidget {
  final bool isDark;
  final int value;
  final ValueChanged<int> onChanged;

  const _ReminderDaysDropdown({
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white70 : Colors.grey[700],
            size: 20,
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          dropdownColor: isDark ? const Color(0xFF2D2D3E) : Colors.white,
          items: NotificationSettingsService.reminderDayOptions.map((days) {
            return DropdownMenuItem<int>(
              value: days,
              child: Text(_getDaysLabel(days)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }

  String _getDaysLabel(int days) {
    switch (days) {
      case 1:
        return '1 day';
      case 3:
        return '3 days';
      case 7:
        return '1 week';
      default:
        return '$days days';
    }
  }
}
