import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import 'auth_service.dart';
import 'doctor_service.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Ref _ref;

  ReviewService(this._ref);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Submit a review for a doctor. Recalculates the doctor's average rating.
  Future<void> submitReview({
    required String doctorId,
    required String appointmentId,
    required double rating,
    required String comment,
  }) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw Exception('Not authenticated');

    // Prevent duplicate reviews for the same appointment
    final existing = await _db
        .collection('reviews')
        .where('appointmentId', isEqualTo: appointmentId)
        .where('patientId', isEqualTo: user.uid)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('You have already reviewed this appointment.');
    }

    await _db.collection('reviews').add({
      'doctorId': doctorId,
      'patientId': user.uid,
      'patientName': user.displayName ?? 'Patient',
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Recalculate doctor's average rating
    await _ref.read(doctorServiceProvider).recalculateRating(doctorId);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream of reviews for a specific doctor.
  Stream<List<ReviewModel>> watchDoctorReviews(String doctorId) {
    return _db
        .collection('reviews')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
  }

  /// Check if the current user has already reviewed a specific appointment.
  Future<bool> hasReviewed(String appointmentId) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return false;

    final snap = await _db
        .collection('reviews')
        .where('appointmentId', isEqualTo: appointmentId)
        .where('patientId', isEqualTo: user.uid)
        .get();
    return snap.docs.isNotEmpty;
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final reviewServiceProvider =
    Provider<ReviewService>((ref) => ReviewService(ref));

final doctorReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, doctorId) {
  return ref.watch(reviewServiceProvider).watchDoctorReviews(doctorId);
});
