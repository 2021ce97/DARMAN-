import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch the current user's profile from Firestore.
  Stream<UserModel?> watchCurrentUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Fetch any user by UID (one-time read).
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  /// Update the current user's profile fields.
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bloodType,
    double? weight,
    double? height,
    String? allergies,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (bloodType != null) updates['bloodType'] = bloodType;
    if (weight != null) updates['weight'] = weight;
    if (height != null) updates['height'] = height;
    if (allergies != null) updates['allergies'] = allergies;
    if (dateOfBirth != null) {
      updates['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
    }
    if (gender != null) updates['gender'] = gender;

    await _db.collection('users').doc(uid).update(updates);

    // Also update Firebase Auth display name if name changed
    if (name != null) {
      await _auth.currentUser?.updateDisplayName(name);
    }
  }

  /// Update profile photo URL after upload.
  Future<void> updatePhotoUrl(String photoUrl) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _db.collection('users').doc(uid).update({'photoUrl': photoUrl});
    await _auth.currentUser?.updatePhotoURL(photoUrl);
  }

  /// Get appointment count for the current user.
  Future<int> getAppointmentCount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;
    final snap = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Get unique doctor count for the current user.
  Future<int> getUniqueDoctorCount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;
    final snap = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .get();
    final doctorIds = snap.docs.map((d) => d['doctorId'] as String).toSet();
    return doctorIds.length;
  }

  /// Get prescription count for the current user.
  Future<int> getPrescriptionCount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;
    final snap = await _db
        .collection('prescriptions')
        .where('patientId', isEqualTo: uid)
        .count()
        .get();
    return snap.count ?? 0;
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final userServiceProvider = Provider((ref) => UserService());

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(userServiceProvider).watchCurrentUser();
});

/// Provides a map of { appointments, doctors, records } counts for the profile.
final profileStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final svc = ref.watch(userServiceProvider);
  final results = await Future.wait([
    svc.getAppointmentCount(),
    svc.getUniqueDoctorCount(),
    svc.getPrescriptionCount(),
  ]);
  return {
    'appointments': results[0],
    'doctors': results[1],
    'records': results[2],
  };
});
