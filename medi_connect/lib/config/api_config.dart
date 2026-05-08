import 'app_config.dart';

/// Unified API + service configuration for DARMAN.
/// All services should import THIS file — not AppConfig directly — 
/// so there's one single source of truth.
class ApiConfig {
  // ── Environment Detection ─────────────────────────────────────────────────
  static const bool isProduction = AppConfig.isProduction;
  static const String _env =
      String.fromEnvironment('ENV', defaultValue: 'development');

  // ── Backend REST API URLs ─────────────────────────────────────────────────

  /// Production URL — live backend on Render/Railway/VPS
  static const String productionUrl = 'https://darman-api.onrender.com/api/v1';

  /// Local development
  static const String localUrl = 'http://localhost:3000/api/v1';

  /// Android emulator points to host machine
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000/api/v1';

  /// Physical device on same WiFi (update to your machine's LAN IP)
  static const String physicalDeviceUrl = 'http://192.168.1.12:3000/api/v1';

  /// Override with compile-time define: `--dart-define=API_BASE=https://...`
  static const String _apiBaseFromDefine =
      String.fromEnvironment('API_BASE', defaultValue: '');

  /// Active base URL — priority: API_BASE define → PRODUCTION flag → local
  static String get baseUrl {
    if (_apiBaseFromDefine.isNotEmpty) return _apiBaseFromDefine;
    if (isProduction || _env == 'production') return productionUrl;
    return localUrl;
  }

  // ── Gemini AI ─────────────────────────────────────────────────────────────
  static String get geminiApiKey => AppConfig.geminiApiKey;
  static String get geminiModel => AppConfig.geminiModel;
  static bool get isGeminiAvailable => AppConfig.isGeminiConfigured;

  // ── Agora Video ───────────────────────────────────────────────────────────
  static String get agoraAppId => AppConfig.agoraAppId;
  static String get agoraTokenServerUrl => AppConfig.agoraTokenServerUrl;
  static bool get isAgoraAvailable => AppConfig.isAgoraConfigured;

  // ── HesabPay ──────────────────────────────────────────────────────────────
  static String get hesabPayMerchantId => AppConfig.hesabPayMerchantId;
  static String get hesabPayApiKey => AppConfig.hesabPayApiKey;
  static String get hesabPayBaseUrl => AppConfig.hesabPayBaseUrl;
  static bool get isHesabPayAvailable => AppConfig.isHesabPayConfigured;

  // ── REST Endpoints ────────────────────────────────────────────────────────
  static const String auth = '/auth';
  static const String doctors = '/doctors';
  static const String bookings = '/bookings';
  static const String hospitals = '/hospitals';
  static const String labs = '/labs';
  static const String pharmacies = '/pharmacies';
  static const String search = '/search';
  static const String emr = '/emr';
  static const String payments = '/payments';
  static const String notifications = '/notifications';
  static const String ai = '/ai';
  static const String prescriptions = '/prescriptions';
  static const String consultations = '/consultations';
  static const String upload = '/upload';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
