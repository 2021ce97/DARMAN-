import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription_model.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class PrescriptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Ref _ref;

  PrescriptionService(this._ref);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Create a prescription (called by doctor after consultation).
  Future<String> createPrescription({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String appointmentId,
    required String diagnosis,
    required List<Medicine> medicines,
    String? notes,
  }) async {
    final ref = await _db.collection('prescriptions').add({
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'diagnosis': diagnosis,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      if (notes != null) 'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify patient
    await _ref.read(notificationServiceProvider).sendNotification(
          userId: patientId,
          title: 'Prescription Ready',
          body: 'Dr. $doctorName has issued a prescription for you.',
          type: NotificationType.prescriptionReady,
          referenceId: ref.id,
        );

    return ref.id;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream of prescriptions for the current patient.
  Stream<List<PrescriptionModel>> watchPatientPrescriptions() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return Stream.value([]);

    return _db
        .collection('prescriptions')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PrescriptionModel.fromFirestore).toList());
  }

  /// Stream of prescriptions issued by a specific doctor.
  Stream<List<PrescriptionModel>> watchDoctorPrescriptions(String doctorId) {
    return _db
        .collection('prescriptions')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PrescriptionModel.fromFirestore).toList());
  }

  /// Fetch a single prescription by ID.
  Future<PrescriptionModel?> getPrescriptionById(String id) async {
    final doc = await _db.collection('prescriptions').doc(id).get();
    return doc.exists ? PrescriptionModel.fromFirestore(doc) : null;
  }

  /// Fetch prescriptions linked to a specific appointment.
  Future<List<PrescriptionModel>> getPrescriptionsForAppointment(
      String appointmentId) async {
    final snap = await _db
        .collection('prescriptions')
        .where('appointmentId', isEqualTo: appointmentId)
        .get();
    return snap.docs.map(PrescriptionModel.fromFirestore).toList();
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final prescriptionServiceProvider =
    Provider<PrescriptionService>((ref) => PrescriptionService(ref));

final patientPrescriptionsProvider =
    StreamProvider<List<PrescriptionModel>>((ref) {
  return ref.watch(prescriptionServiceProvider).watchPatientPrescriptions();
});
