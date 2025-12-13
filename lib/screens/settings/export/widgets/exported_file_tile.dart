import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/backup_service.dart';
import '../../../../theme/app_theme.dart';

/// Tile showing an exported file with share and delete actions
class ExportedFileTile extends StatelessWidget {
  final BackupFile backupFile;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final bool isDark;

  const ExportedFileTile({
    super.key,
    required this.backupFile,
    required this.onShare,
    required this.onDelete,
    required this.isDark,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  String _getDisplayName() {
    // Shorten the filename for display
    final name = backupFile.filename.replaceAll('.json', '');
    if (name.length > 25) {
      return '${name.substring(0, 25)}...';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.description_rounded,
                color: AppTheme.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDisplayName(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${backupFile.formattedSize} • ${_formatDate(backupFile.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onShare,
              icon: Icon(
                Icons.share_rounded,
                color: AppTheme.primaryDark,
                size: 20,
              ),
              tooltip: 'Share',
              splashRadius: 20,
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red[400],
                size: 20,
              ),
              tooltip: 'Delete',
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
