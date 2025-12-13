import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';

/// Export button with last export info
class ExportButton extends StatelessWidget {
  final DateTime? lastExportDate;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;
  final bool isDark;

  const ExportButton({
    super.key,
    this.lastExportDate,
    required this.isLoading,
    this.isEnabled = true,
    required this.onPressed,
    required this.isDark,
  });

  String _formatLastExport() {
    if (lastExportDate == null) {
      return 'Never exported';
    }

    final now = DateTime.now();
    final diff = now.difference(lastExportDate!);

    if (diff.inDays == 0) {
      return 'Last: Today, ${DateFormat('h:mm a').format(lastExportDate!)}';
    } else if (diff.inDays == 1) {
      return 'Last: Yesterday';
    } else {
      return 'Last: ${DateFormat('MMM dd, yyyy').format(lastExportDate!)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canTap = isEnabled && !isLoading;

    return GestureDetector(
      onTap: canTap ? onPressed : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? [AppTheme.accentColor, AppTheme.primaryDark]
                  : [Colors.grey, Colors.grey[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppTheme.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnabled ? _formatLastExport() : 'No data to export',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
