import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import '../widgets/app_toast.dart';

/// GitHub Update Service for checking and notifying app updates
class GitHubUpdateService {
  static const String _owner = 'RyanWez';
  static const String _repo = 'ahkyaway_mhat-releases';

  static const String _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  /// Check for updates and show dialog if available
  /// [showManualResult] - If true, show messages even when no update or on error (for manual check from settings)
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool showManualResult = false,
  }) async {
    // Show checking toast for manual checks
    if (showManualResult && context.mounted) {
      AppToast.showChecking(context, 'Update စစ်ဆေးနေသည်...');
    }

    try {
      final updateInfo = await _getLatestRelease();
      
      // Dismiss the checking toast
      if (showManualResult) {
        AppToast.dismiss();
      }
      
      if (updateInfo == null) {
        if (showManualResult && context.mounted) {
          AppToast.showUpdateError(context, 'Update စစ်ဆေး၍မရပါ။ Internet ကို စစ်ဆေးပါ။');
        }
        return;
      }

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
      } else if (showManualResult && context.mounted) {
        // Only show "up to date" message for manual checks
        AppToast.showUpToDate(context, 'နောက်ဆုံး version (v$currentVersion) ဖြစ်ပါပြီ');
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
      // Dismiss the checking toast on error
      if (showManualResult) {
        AppToast.dismiss();
      }
      if (showManualResult && context.mounted) {
        AppToast.showUpdateError(context, 'Update စစ်ဆေး၍မရပါ');
      }
    }
  }


  /// Fetch latest release info from GitHub API
  static Future<Map<String, dynamic>?> _getLatestRelease() async {
    try {
      final response = await http
          .get(
            Uri.parse(_apiUrl),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract version from tag (remove 'v' prefix if present)
        String version = data['tag_name'] ?? '';
        if (version.startsWith('v')) {
          version = version.substring(1);
        }

        // Get device ABI to find the correct APK
        final deviceAbi = await _getDeviceAbi();
        
        // Find APK download URL from assets
        String? downloadUrl;
        String? fallbackUrl;
        final assets = data['assets'] as List?;
        if (assets != null) {
          for (var asset in assets) {
            final name = asset['name'] as String? ?? '';
            if (name.endsWith('.apk')) {
              // Check if this APK matches device ABI
              if (deviceAbi.isNotEmpty && name.contains(deviceAbi)) {
                downloadUrl = asset['browser_download_url'];
                break;
              }
              // Keep first APK as fallback
              fallbackUrl ??= asset['browser_download_url'];
            }
          }
        }

        return {
          'version': version,
          'downloadUrl': downloadUrl ?? fallbackUrl ?? data['html_url'],
          'releaseNotes': data['body'] ?? '',
        };
      }
    } catch (e) {
      debugPrint('Failed to fetch release: $e');
    }
    return null;
  }

  /// Get the device's supported ABI (CPU architecture)
  /// Returns: 'arm64-v8a', 'armeabi-v7a', 'x86_64', etc.
  static Future<String> _getDeviceAbi() async {
    if (!Platform.isAndroid) return '';
    
    try {
      // Use method channel to get supported ABIs from Android
      const platform = MethodChannel('com.example.ankyaway_mhat/device_info');
      final List<dynamic>? abis = await platform.invokeMethod('getSupportedAbis');
      if (abis != null && abis.isNotEmpty) {
        // Return the primary (most preferred) ABI
        return abis.first.toString();
      }
    } catch (e) {
      debugPrint('Failed to get device ABI: $e');
      // Fallback: Most modern Android phones are arm64-v8a
      return 'arm64-v8a';
    }
    return 'arm64-v8a';
  }

  /// Compare version strings (e.g., "1.0.4" vs "1.0.5")
  static bool _isNewerVersion(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (latestParts.length < 3) {
        latestParts.add(0);
      }

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Update Lottie Animation (Optimized for low-end devices)
              RepaintBoundary(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: DotLottieLoader.fromAsset(
                    'assets/animations/update.lottie',
                    frameBuilder: (context, dotLottie) {
                      if (dotLottie != null) {
                        return Lottie.memory(
                          dotLottie.animations.values.single,
                          fit: BoxFit.contain,
                          repeat: true,
                          frameRate: FrameRate(
                            30,
                          ), // Limit to 30fps for performance
                          renderCache: RenderCache
                              .raster, // Cache for better performance
                          filterQuality:
                              FilterQuality.low, // Reduce quality for speed
                        );
                      }
                      return Container(
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
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Update ရရှိနိုင်ပါပြီ!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Version info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                // Header for release notes
                Row(
                  children: [
                    Icon(
                      Icons.new_releases_rounded,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ပြောင်းလဲချက်များ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.85, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildFormattedNotes(releaseNotes, isDark),
                      ),
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parse markdown and build formatted release notes
  List<Widget> _buildFormattedNotes(String notes, bool isDark) {
    final List<Widget> widgets = [];
    final lines = notes.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check for header (## or #)
      if (trimmed.startsWith('##')) {
        final text = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
        );
      }
      // Check for list item (- or *)
      else if (trimmed.startsWith('-') || trimmed.startsWith('*')) {
        final text = trimmed.replaceFirst(RegExp(r'^[-*]\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Regular text
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              trimmed,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
