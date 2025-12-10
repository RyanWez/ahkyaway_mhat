import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// GitHub Update Service for checking and notifying app updates
class GitHubUpdateService {
  // TODO: Replace with your actual GitHub username and repo name
  static const String _owner = 'RyanWez';
  static const String _repo = 'ahkyaway_mhat-releases';
  
  static const String _apiUrl = 
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  /// Check for updates and show dialog if available
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final updateInfo = await _getLatestRelease();
      if (updateInfo == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final latestVersion = updateInfo['version'];
      final downloadUrl = updateInfo['downloadUrl'];
      final releaseNotes = updateInfo['releaseNotes'];

      // Compare versions
      if (_isNewerVersion(currentVersion, latestVersion)) {
        if (context.mounted) {
          _showUpdateDialog(
            context,
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            downloadUrl: downloadUrl,
            releaseNotes: releaseNotes,
          );
        }
      }
    } catch (e) {
      // Silently fail - don't interrupt user experience
      debugPrint('Update check failed: $e');
    }
  }

  /// Fetch latest release info from GitHub API
  static Future<Map<String, dynamic>?> _getLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract version from tag (remove 'v' prefix if present)
        String version = data['tag_name'] ?? '';
        if (version.startsWith('v')) {
          version = version.substring(1);
        }

        // Find APK download URL from assets
        String? downloadUrl;
        final assets = data['assets'] as List?;
        if (assets != null) {
          for (var asset in assets) {
            final name = asset['name'] as String? ?? '';
            if (name.endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'];
              break;
            }
          }
        }

        return {
          'version': version,
          'downloadUrl': downloadUrl ?? data['html_url'],
          'releaseNotes': data['body'] ?? '',
        };
      }
    } catch (e) {
      debugPrint('Failed to fetch release: $e');
    }
    return null;
  }

  /// Compare version strings (e.g., "1.0.4" vs "1.0.5")
  static bool _isNewerVersion(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (currentParts.length < 3) currentParts.add(0);
      while (latestParts.length < 3) latestParts.add(0);

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
    } catch (e) {
      debugPrint('Version comparison failed: $e');
    }
    return false;
  }

  /// Show update dialog
  static void _showUpdateDialog(
    BuildContext context, {
    required String currentVersion,
    required String latestVersion,
    required String downloadUrl,
    required String releaseNotes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpdateDialog(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
      ),
    );
  }
}

/// Beautiful Update Dialog Widget
class UpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;

  const UpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Update Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Update ရရှိနိုင်ပါပြီ!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            
            // Version info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'v$currentVersion → v$latestVersion',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Release notes (if available)
            if (releaseNotes.isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(
                    releaseNotes,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Buttons
            Row(
              children: [
                // Later button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'နောက်မှ',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Update button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final uri = Uri.parse(downloadUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Update လုပ်ရန်',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
