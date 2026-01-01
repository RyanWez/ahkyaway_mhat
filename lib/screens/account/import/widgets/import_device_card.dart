import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Card for importing from device storage
class ImportDeviceCard extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDark;

  const ImportDeviceCard({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        decoration: AppTheme.cardDecoration(isDark),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryDark,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.folder_open_rounded,
                      color: AppTheme.primaryDark,
                      size: 26,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import from Device',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a backup file from your device',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
