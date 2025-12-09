import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class LanguageOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;
  final String? flagEmoji; // Optional flag emoji (e.g., "🇺🇸", "🇲🇲")

  const LanguageOptionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.locale,
    required this.isSelected,
    required this.onTap,
    this.flagEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Theme.of(context);
    final isDark = themeProvider.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryDark.withValues(alpha: 0.15)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: flagEmoji != null
                  ? Center(
                      child: Text(
                        flagEmoji!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Apple Color Emoji',
                          fontFamilyFallback: [
                            'Noto Color Emoji',
                            'Segoe UI Emoji', 
                            'Android Emoji',
                          ],
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: isSelected
                          ? AppTheme.primaryDark
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryDark
                      : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
