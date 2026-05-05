class ApiConfig {
  // ── Environment Detection ─────────────────────────────────────────────────
  // Change this to 'production' when deploying
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'development');

  // ── URLs ──────────────────────────────────────────────────────────────────
  
  /// Production URL — your deployed backend on Render.com
  static const String productionUrl = 'https://darman-api.onrender.com/api/v1';
  
  /// Local development
  static const String localUrl = 'http://localhost:3000/api/v1';
  
  /// Android emulator
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000/api/v1';
  
  /// Physical device on same WiFi (your computer's IP)
  static const String physicalDeviceUrl = 'http://192.168.1.12:3000/api/v1';

  /// Active base URL — change _env to 'production' for live deployment
  static String get baseUrl {
    if (_env == 'production') return productionUrl;
    return localUrl;
  }

  // ── Endpoints ─────────────────────────────────────────────────────────────
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
