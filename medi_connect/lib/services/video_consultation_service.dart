import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class VideoConsultationService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generate video token for consultation
  Future<VideoToken> generateToken({
    required String consultationId,
    required String userId,
    required String role, // 'patient' or 'doctor'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/consultation/$consultationId/video/token'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': userId,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoToken.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to generate video token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating video token: $e');
    }
  }

  // Start video consultation
  Future<VideoSession> startConsultation(String consultationId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/consultation/$consultationId/video/start'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoSession.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to start consultation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error starting consultation: $e');
    }
  }

  // End video consultation
  Future<void> endConsultation(String consultationId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/consultation/$consultationId/video/end'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to end consultation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error ending consultation: $e');
    }
  }

  // Get consultation status
  Future<ConsultationStatus> getConsultationStatus(String consultationId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/consultation/$consultationId/status'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ConsultationStatus.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to get consultation status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting consultation status: $e');
    }
  }
}

class VideoToken {
  final String token;
  final String channelName;
  final String appId;
  final int uid;
  final DateTime expiresAt;

  VideoToken({
    required this.token,
    required this.channelName,
    required this.appId,
    required this.uid,
    required this.expiresAt,
  });

  factory VideoToken.fromJson(Map<String, dynamic> json) {
    return VideoToken(
      token: json['token'] ?? '',
      channelName: json['channelName'] ?? json['channel'] ?? '',
      appId: json['appId'] ?? '',
      uid: json['uid'] ?? 0,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(Duration(hours: 1)),
    );
  }
}

class VideoSession {
  final String sessionId;
  final String channelName;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int duration; // in seconds

  VideoSession({
    required this.sessionId,
    required this.channelName,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.duration = 0,
  });

  factory VideoSession.fromJson(Map<String, dynamic> json) {
    return VideoSession(
      sessionId: json['sessionId'] ?? json['id'] ?? '',
      channelName: json['channelName'] ?? json['channel'] ?? '',
      status: json['status'] ?? 'active',
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : DateTime.now(),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      duration: json['duration'] ?? 0,
    );
  }
}

class ConsultationStatus {
  final String status; // scheduled, in_progress, completed, cancelled
  final bool isVideoActive;
  final DateTime? scheduledTime;
  final DateTime? startedAt;
  final DateTime? endedAt;

  ConsultationStatus({
    required this.status,
    required this.isVideoActive,
    this.scheduledTime,
    this.startedAt,
    this.endedAt,
  });

  factory ConsultationStatus.fromJson(Map<String, dynamic> json) {
    return ConsultationStatus(
      status: json['status'] ?? 'scheduled',
      isVideoActive: json['isVideoActive'] ?? false,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    );
  }
}
