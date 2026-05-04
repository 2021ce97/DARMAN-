import 'package:flutter/foundation.dart';

/// Analytics service for tracking user events.
/// Uses Firebase Analytics when available, falls back to debug logging.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Screen views
  Future<void> logScreenView(String screenName) async {
    debugPrint('[Analytics] Screen: $screenName');
  }

  // Auth events
  Future<void> logLogin(String method) async {
    debugPrint('[Analytics] Login: $method');
  }

  Future<void> logSignUp(String method) async {
    debugPrint('[Analytics] SignUp: $method');
  }

  // Doctor events
  Future<void> logDoctorView(String doctorId, String specialty) async {
    debugPrint('[Analytics] DoctorView: $doctorId ($specialty)');
  }

  Future<void> logDoctorSearch(String query) async {
    debugPrint('[Analytics] DoctorSearch: $query');
  }

  // Booking events
  Future<void> logBookingStarted(String doctorId) async {
    debugPrint('[Analytics] BookingStarted: $doctorId');
  }

  Future<void> logBookingCompleted(String bookingId, double amount) async {
    debugPrint('[Analytics] BookingCompleted: $bookingId, $amount AFN');
  }

  Future<void> logBookingCancelled(String bookingId) async {
    debugPrint('[Analytics] BookingCancelled: $bookingId');
  }

  // Payment events
  Future<void> logPaymentInitiated(double amount, String method) async {
    debugPrint('[Analytics] PaymentInitiated: $amount AFN via $method');
  }

  Future<void> logPaymentCompleted(double amount, String method) async {
    debugPrint('[Analytics] PaymentCompleted: $amount AFN via $method');
  }

  // AI events
  Future<void> logAIChatMessage() async {
    debugPrint('[Analytics] AIChatMessage');
  }

  Future<void> logSymptomCheck(List<String> symptoms) async {
    debugPrint('[Analytics] SymptomCheck: ${symptoms.join(', ')}');
  }

  // Video consultation events
  Future<void> logVideoConsultationStarted(String consultationId) async {
    debugPrint('[Analytics] VideoConsultationStarted: $consultationId');
  }

  Future<void> logVideoConsultationEnded(String consultationId, int durationSeconds) async {
    debugPrint('[Analytics] VideoConsultationEnded: $consultationId, ${durationSeconds}s');
  }

  // Custom event
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    debugPrint('[Analytics] Event: $name, params: $parameters');
  }
}
