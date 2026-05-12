import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment_model.dart';
import 'auth_service.dart';

class PaymentService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create payment intent
  Future<PaymentIntent> createPayment({
    required String bookingId,
    required double amount,
    String currency = 'AFN',
    String paymentMethod = 'hesabpay',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.payments}/create-intent'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'bookingId': bookingId,
          'amount': amount,
          'currency': currency,
          'method': paymentMethod,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentIntent.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to create payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  // Confirm payment
  Future<Payment> confirmPayment({
    required String orderId,
    String? transactionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.payments}/$orderId/confirm'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'paymentMethod': 'hesabpay',
          'transactionId': transactionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to confirm payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error confirming payment: $e');
    }
  }

  // Get payment status
  Future<Payment> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.payments}/$paymentId/status'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to get payment status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting payment status: $e');
    }
  }

  // Get user's payment history
  Future<List<Payment>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.payments}/history'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> payments = data['data'] ?? data['payments'] ?? [];
        return payments.map((json) => Payment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get payment history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting payment history: $e');
    }
  }

  // Request refund
  Future<Payment> requestRefund({
    required String paymentId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.payments}/$paymentId/refund'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to request refund: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error requesting refund: $e');
    }
  }
}
