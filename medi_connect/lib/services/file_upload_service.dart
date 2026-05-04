import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class FileUploadService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Upload profile picture
  Future<UploadResult> uploadProfilePicture(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/profile-picture'),
      );

      request.headers.addAll(await _getHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UploadResult.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to upload profile picture: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }

  // Upload medical record
  Future<UploadResult> uploadMedicalRecord({
    required File file,
    required String recordType, // lab_report, prescription, xray, etc.
    String? description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/medical-record'),
      );

      request.headers.addAll(await _getHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['recordType'] = recordType;
      if (description != null) {
        request.fields['description'] = description;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UploadResult.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to upload medical record: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading medical record: $e');
    }
  }

  // Upload prescription
  Future<UploadResult> uploadPrescription({
    required File file,
    required String prescriptionId,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/prescription'),
      );

      request.headers.addAll(await _getHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['prescriptionId'] = prescriptionId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UploadResult.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to upload prescription: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading prescription: $e');
    }
  }

  // Upload doctor document (for doctor verification)
  Future<UploadResult> uploadDoctorDocument({
    required File file,
    required String documentType, // license, certificate, id, etc.
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/doctor-document'),
      );

      request.headers.addAll(await _getHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['documentType'] = documentType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UploadResult.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to upload doctor document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading doctor document: $e');
    }
  }

  // Delete uploaded file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/upload/file'),
        headers: {
          'Content-Type': 'application/json',
          ...await _getHeaders(),
        },
        body: jsonEncode({'fileUrl': fileUrl}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }
}

class UploadResult {
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;

  UploadResult({
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      fileUrl: json['fileUrl'] ?? json['url'] ?? '',
      fileName: json['fileName'] ?? json['name'] ?? '',
      fileType: json['fileType'] ?? json['type'] ?? '',
      fileSize: json['fileSize'] ?? json['size'] ?? 0,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }
}
