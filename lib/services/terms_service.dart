import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage Terms and Conditions acceptance state.
/// 
/// Stores user's acceptance in SharedPreferences.
class TermsService {
  static const String _termsAcceptedKey = 'terms_accepted';

  /// Check if user has already accepted terms.
  Future<bool> isTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  /// Save user's acceptance of terms.
  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, true);
  }

  /// Reset terms acceptance (for testing/debugging).
  Future<void> resetTermsAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_termsAcceptedKey);
  }
}
