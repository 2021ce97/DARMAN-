import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_model.dart';
import 'api_client.dart';

// ─── Legacy alias kept for backward compatibility with existing screens ───────
typedef Doctor = DoctorModel;

class DoctorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ApiClient _apiClient = ApiClient();

  // ── Read from Backend API ─────────────────────────────────────────────────

  /// Fetch all verified doctors from backend
  Future<List<DoctorModel>> getVerifiedDoctorsFromApi({
    String? specialty,
    String? province,
    String? city,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (specialty != null) queryParams['specialty'] = specialty;
      if (province != null) queryParams['province'] = province;
      if (city != null) queryParams['city'] = city;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final response = await _apiClient.get('/doctors', queryParams: queryParams);
      
      if (response.success && response.data != null) {
        final List<dynamic> doctorsJson = response.data is List 
            ? response.data 
            : [];
        return doctorsJson.map((json) => DoctorModel.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching doctors from API: $e');
      return [];
    }
  }

  /// Fetch single doctor by ID from backend
  Future<DoctorModel?> getDoctorByIdFromApi(String id) async {
    try {
      final response = await _apiClient.get('/doctors/$id');
      
      if (response.success && response.data != null) {
        return DoctorModel.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching doctor from API: $e');
      return null;
    }
  }

  /// Get doctor availability from backend
  Future<Map<String, dynamic>?> getDoctorAvailability(String doctorId, String date) async {
    try {
      final response = await _apiClient.get(
        '/doctors/$doctorId/availability',
        queryParams: {'date': date},
      );
      
      if (response.success && response.data != null) {
        return response.data;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching availability from API: $e');
      return null;
    }
  }

  /// Get specialties list from backend
  Future<List<String>> getSpecialtiesFromApi() async {
    try {
      final response = await _apiClient.get('/doctors/meta/specialties');
      
      if (response.success && response.data != null) {
        return List<String>.from(response.data);
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching specialties from API: $e');
      return [];
    }
  }

  // ── Legacy Firestore Methods (for backward compatibility) ────────────────

  /// Stream of all verified doctors.
  Stream<List<DoctorModel>> getVerifiedDoctors() {
    return _db
        .collection('doctors')
        .where('status', isEqualTo: 'Verified')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DoctorModel.fromFirestore).toList());
  }

  /// Stream of all doctors (admin use).
  Stream<List<DoctorModel>> getAllDoctors() {
    return _db
        .collection('doctors')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DoctorModel.fromFirestore).toList());
  }

  /// Stream of verified doctors filtered by specialty.
  Stream<List<DoctorModel>> getDoctorsBySpecialty(String specialty) {
    return _db
        .collection('doctors')
        .where('status', isEqualTo: 'Verified')
        .where('specialty', isEqualTo: specialty)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DoctorModel.fromFirestore).toList());
  }

  /// One-time fetch of a single doctor by ID.
  Future<DoctorModel?> getDoctorById(String id) async {
    // Try API first, fallback to Firestore
    final apiDoctor = await getDoctorByIdFromApi(id);
    if (apiDoctor != null) return apiDoctor;

    final doc = await _db.collection('doctors').doc(id).get();
    return doc.exists ? DoctorModel.fromFirestore(doc) : null;
  }

  /// Search doctors by name or specialty (client-side filter on verified set).
  Stream<List<DoctorModel>> searchDoctors(String query) {
    final q = query.toLowerCase().trim();
    return getVerifiedDoctors().map((doctors) => doctors
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.specialty.toLowerCase().contains(q) ||
            (d.hospital ?? '').toLowerCase().contains(q) ||
            d.city.toLowerCase().contains(q))
        .toList());
  }

  /// Top-rated doctors (limit).
  Stream<List<DoctorModel>> getTopDoctors({int limit = 10}) {
    return _db
        .collection('doctors')
        .where('status', isEqualTo: 'Verified')
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(DoctorModel.fromFirestore).toList());
  }

  /// Doctors available online.
  Stream<List<DoctorModel>> getOnlineDoctors() {
    return _db
        .collection('doctors')
        .where('status', isEqualTo: 'Verified')
        .where('isAvailableOnline', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DoctorModel.fromFirestore).toList());
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Register a new doctor via backend API
  Future<Map<String, dynamic>> registerDoctorViaApi(Map<String, dynamic> doctorData) async {
    try {
      final response = await _apiClient.post('/doctors/profile', body: doctorData);
      
      if (response.success) {
        return {
          'success': true,
          'data': response.data,
          'message': response.message ?? 'Doctor registered successfully',
        };
      }
      
      return {
        'success': false,
        'error': response.error ?? 'Failed to register doctor',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update doctor availability via backend API
  Future<Map<String, dynamic>> updateDoctorAvailability(
    String doctorId,
    String date,
    List<Map<String, dynamic>> slots,
  ) async {
    try {
      final response = await _apiClient.put(
        '/doctors/$doctorId/availability',
        body: {
          'date': date,
          'slots': slots,
        },
      );
      
      if (response.success) {
        return {
          'success': true,
          'message': response.message ?? 'Availability updated successfully',
        };
      }
      
      return {
        'success': false,
        'error': response.error ?? 'Failed to update availability',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Register a new doctor (Firestore - legacy).
  Future<String> registerDoctor(DoctorModel doctor) async {
    final ref = await _db.collection('doctors').add(doctor.toMap());
    return ref.id;
  }

  /// Update doctor status (admin).
  Future<void> updateDoctorStatus(String doctorId, String status) async {
    await _db.collection('doctors').doc(doctorId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update doctor profile fields.
  Future<void> updateDoctorProfile(
      String doctorId, Map<String, dynamic> fields) async {
    await _db.collection('doctors').doc(doctorId).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Recalculate and persist the doctor's average rating.
  /// Called after a new review is submitted.
  Future<void> recalculateRating(String doctorId) async {
    final reviews = await _db
        .collection('reviews')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    if (reviews.docs.isEmpty) return;

    final total = reviews.docs
        .map((d) => (d['rating'] as num).toDouble())
        .reduce((a, b) => a + b);
    final avg = total / reviews.docs.length;

    await _db.collection('doctors').doc(doctorId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': reviews.docs.length,
    });
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final doctorServiceProvider = Provider((ref) => DoctorService());

final verifiedDoctorsProvider = StreamProvider<List<DoctorModel>>((ref) {
  return ref.watch(doctorServiceProvider).getVerifiedDoctors();
});

final topDoctorsProvider = StreamProvider<List<DoctorModel>>((ref) {
  return ref.watch(doctorServiceProvider).getTopDoctors(limit: 10);
});

final onlineDoctorsProvider = StreamProvider<List<DoctorModel>>((ref) {
  return ref.watch(doctorServiceProvider).getOnlineDoctors();
});

/// Parameterized provider for specialty-filtered doctors.
final doctorsBySpecialtyProvider =
    StreamProvider.family<List<DoctorModel>, String>((ref, specialty) {
  if (specialty == 'All') {
    return ref.watch(doctorServiceProvider).getVerifiedDoctors();
  }
  return ref.watch(doctorServiceProvider).getDoctorsBySpecialty(specialty);
});

/// Parameterized provider for search results.
final doctorSearchProvider =
    StreamProvider.family<List<DoctorModel>, String>((ref, query) {
  if (query.trim().isEmpty) {
    return ref.watch(doctorServiceProvider).getVerifiedDoctors();
  }
  return ref.watch(doctorServiceProvider).searchDoctors(query);
});

/// Future provider for doctors from API
final doctorsFromApiProvider = FutureProvider.autoDispose<List<DoctorModel>>((ref) async {
  final service = ref.watch(doctorServiceProvider);
  return await service.getVerifiedDoctorsFromApi();
});

/// Future provider for specialties from API
final specialtiesFromApiProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(doctorServiceProvider);
  return await service.getSpecialtiesFromApi();
});



