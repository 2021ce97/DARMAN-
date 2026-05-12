/// DARMAN – Centralized API Configuration
///
/// HOW TO USE IN PRODUCTION:
/// Replace the placeholder strings below with your real keys.
/// For security, consider using --dart-define at build time:
///
///   flutter run \
///     --dart-define=GEMINI_API_KEY=your_real_key \
///     --dart-define=AGORA_APP_ID=your_real_id \
///     --dart-define=HESABPAY_MERCHANT_ID=your_real_id
///
/// Then read them with String.fromEnvironment() as shown below.

class AppConfig {
  AppConfig._(); // prevent instantiation

  // ─── Environment ───────────────────────────────────────────────────────────
  static const bool isProduction =
      bool.fromEnvironment('PRODUCTION', defaultValue: false);

  // ─── Google Gemini AI ──────────────────────────────────────────────────────
  /// AI symptom checker & chatbot
  /// Get key at: https://aistudio.google.com/app/apikey
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'REPLACE_WITH_GEMINI_API_KEY', // ← replace for production
  );
  static const String geminiModel = 'gemini-1.5-flash';

  // ─── Agora (Video Consultation) ────────────────────────────────────────────
  /// Real-time video calls between patients and doctors
  /// Get credentials at: https://console.agora.io
  static const String agoraAppId = String.fromEnvironment(
    'AGORA_APP_ID',
    defaultValue: 'REPLACE_WITH_AGORA_APP_ID', // ← replace for production
  );

  /// Agora tokens should be generated server-side for production.
  /// Use a token server: https://github.com/AgoraIO-Community/token-builder
  /// Set to empty string '' to use agora without token (dev only)
  static const String agoraTokenServerUrl = String.fromEnvironment(
    'AGORA_TOKEN_SERVER',
    defaultValue: '', // ← set to your token server URL in production
  );

  // ─── HesabPay (Payment Gateway) ───────────────────────────────────────────
  /// Afghan payment gateway for appointment booking fees
  /// Docs: https://hesabpay.com/developers
  static const String hesabPayMerchantId = String.fromEnvironment(
    'HESABPAY_MERCHANT_ID',
    defaultValue: 'REPLACE_WITH_HESABPAY_MERCHANT_ID',
  );
  static const String hesabPayApiKey = String.fromEnvironment(
    'HESABPAY_API_KEY',
    defaultValue: 'REPLACE_WITH_HESABPAY_API_KEY',
  );
  static const String hesabPayBaseUrl = isProduction
      ? 'https://api.hesabpay.com/v1'
      : 'https://sandbox.hesabpay.com/v1'; // sandbox for dev

  // ─── Firebase Cloud Messaging (Server Key) ─────────────────────────────────
  /// Server key for sending FCM pushes via REST API (legacy)
  /// For production, use firebase-admin in Cloud Functions instead.
  /// Get from: Firebase Console → Project Settings → Cloud Messaging
  static const String fcmServerKey = String.fromEnvironment(
    'FCM_SERVER_KEY',
    defaultValue: 'REPLACE_WITH_FCM_SERVER_KEY',
  );

  // ─── Firebase App Check ───────────────────────────────────────────────────
  /// Web requires a reCAPTCHA v3 site key from Firebase App Check.
  /// Mobile providers can be activated without this value.
  static const String appCheckRecaptchaSiteKey = String.fromEnvironment(
    'APP_CHECK_RECAPTCHA_SITE_KEY',
    defaultValue: '',
  );

  // ─── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'DARMAN';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@darman.af';
  static const String privacyPolicyUrl = 'https://darman.af/privacy';
  static const String termsOfServiceUrl = 'https://darman.af/terms';

  // ─── Helpers ───────────────────────────────────────────────────────────────
  /// Returns true if the key has been replaced with a real value.
  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty && !geminiApiKey.startsWith('REPLACE_');
  static bool get isAgoraConfigured =>
      agoraAppId.isNotEmpty && !agoraAppId.startsWith('REPLACE_');
  static bool get isHesabPayConfigured =>
      hesabPayMerchantId.isNotEmpty && !hesabPayMerchantId.startsWith('REPLACE_');
  static bool get isAppCheckWebConfigured => appCheckRecaptchaSiteKey.isNotEmpty;
}
