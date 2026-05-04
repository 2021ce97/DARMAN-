import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message_model.dart';
import 'auth_service.dart';

class AIChatService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Send chat message
  Future<ChatMessage> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/chat'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatMessage.fromJson({
          'content': data['response'] ?? data['message'] ?? '',
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Check symptoms
  Future<SymptomCheckResult> checkSymptoms({
    required List<String> symptoms,
    int? age,
    String? gender,
    List<String>? medicalHistory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/symptom-checker'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'symptoms': symptoms,
          'age': age,
          'gender': gender,
          'medicalHistory': medicalHistory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SymptomCheckResult.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to check symptoms: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error checking symptoms: $e');
    }
  }

  // Get health advice
  Future<String> getHealthAdvice({
    required String topic,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/health-advice'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'topic': topic,
          'context': context,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['advice'] ?? data['response'] ?? '';
      } else {
        throw Exception('Failed to get health advice: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting health advice: $e');
    }
  }

  // Get chat history
  Future<List<ChatMessage>> getChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ai/chat/history'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> messages = data['data'] ?? data['messages'] ?? [];
        return messages.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        // Return empty list if no history
        return [];
      }
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }
}
