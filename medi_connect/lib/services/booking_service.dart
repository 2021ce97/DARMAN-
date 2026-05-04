import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment_model.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';
import 'notification_service.dart';

// ─── Legacy alias kept for backward compatibility with existing screens ───────
typedef Appointment = AppointmentModel;

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Ref _ref;

  BookingService(this._ref);

  // ── Create ────────────────────────────────────────────────────────────────

  /// Book a new appointment. Returns the new document ID.
  Future<String> createAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime dateTime,
    required AppointmentType type,
    required double amount,
    String? notes,
  }) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw Exception('User must be logged in to book');

    // Check for slot conflicts
    final conflict = await _checkSlotConflict(doctorId, dateTime);
    if (conflict) {
      throw Exception(
          'This time slot is already booked. Please choose another.');
    }

    final ref = await _db.collection('appointments').add({
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientId': user.uid,
      'patientName': user.displayName ?? 'Patient',
      'dateTime': Timestamp.fromDate(dateTime),
      'status': AppointmentStatus.pending.label,
      'type': type == AppointmentType.online ? 'Online' : 'Clinic Visit',
      'amount': amount,
      if (notes != null) 'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Send confirmation notification
    await _ref.read(notificationServiceProvider).sendNotification(
          userId: user.uid,
          title: 'Appointment Booked',
          body:
              'Your appointment with $doctorName on ${_formatDate(dateTime)} is confirmed.',
          type: NotificationType.appointmentConfirmed,
          referenceId: ref.id,
        );

    return ref.id;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream of the current patient's appointments, newest first.
  Stream<List<AppointmentModel>> getPatientAppointments() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return Stream.value([]);

    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());
  }

  /// Stream of upcoming appointments only.
  Stream<List<AppointmentModel>> getUpcomingAppointments() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return Stream.value([]);

    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .where('status', whereIn: [
          AppointmentStatus.pending.label,
          AppointmentStatus.approved.label,
        ])
        .orderBy('dateTime')
        .snapshots()
        .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());
  }

  /// Stream of past (completed/cancelled) appointments.
  Stream<List<AppointmentModel>> getPastAppointments() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return Stream.value([]);

    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .where('status', whereIn: [
          AppointmentStatus.completed.label,
          AppointmentStatus.cancelled.label,
        ])
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());
  }

  /// Stream of a doctor's appointments (for doctor dashboard).
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());
  }

  /// Fetch a single appointment by ID.
  Future<AppointmentModel?> getAppointmentById(String id) async {
    final doc = await _db.collection('appointments').doc(id).get();
    return doc.exists ? AppointmentModel.fromFirestore(doc) : null;
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Cancel an appointment.
  Future<void> cancelAppointment(String appointmentId,
      {String? reason}) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw Exception('Not authenticated');

    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.cancelled.label,
      if (reason != null) 'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _ref.read(notificationServiceProvider).sendNotification(
          userId: user.uid,
          title: 'Appointment Cancelled',
          body: 'Your appointment has been cancelled.',
          type: NotificationType.appointmentCancelled,
          referenceId: appointmentId,
        );
  }

  /// Reschedule an appointment to a new date/time.
  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newDateTime) async {
    final appt = await getAppointmentById(appointmentId);
    if (appt == null) throw Exception('Appointment not found');

    final conflict = await _checkSlotConflict(appt.doctorId, newDateTime,
        excludeId: appointmentId);
    if (conflict) {
      throw Exception(
          'This time slot is already booked. Please choose another.');
    }

    await _db.collection('appointments').doc(appointmentId).update({
      'dateTime': Timestamp.fromDate(newDateTime),
      'status': AppointmentStatus.rescheduled.label,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark appointment as completed (doctor/admin).
  Future<void> completeAppointment(String appointmentId) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.completed.label,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Approve appointment (doctor/admin).
  Future<void> approveAppointment(String appointmentId) async {
    final doc =
        await _db.collection('appointments').doc(appointmentId).get();
    if (!doc.exists) throw Exception('Appointment not found');

    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.approved.label,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final data = doc.data() as Map<String, dynamic>;
    await _ref.read(notificationServiceProvider).sendNotification(
          userId: data['patientId'],
          title: 'Appointment Approved',
          body:
              'Your appointment with ${data['doctorName']} has been approved.',
          type: NotificationType.appointmentConfirmed,
          referenceId: appointmentId,
        );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns true if the doctor already has a booking within 30 min of [dateTime].
  Future<bool> _checkSlotConflict(String doctorId, DateTime dateTime,
      {String? excludeId}) async {
    final window = const Duration(minutes: 30);
    final start = Timestamp.fromDate(dateTime.subtract(window));
    final end = Timestamp.fromDate(dateTime.add(window));

    final snap = await _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status',
            whereIn: [AppointmentStatus.pending.label, AppointmentStatus.approved.label])
        .where('dateTime', isGreaterThan: start)
        .where('dateTime', isLessThan: end)
        .get();

    if (excludeId != null) {
      return snap.docs.any((d) => d.id != excludeId);
    }
    return snap.docs.isNotEmpty;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final bookingServiceProvider =
    Provider<BookingService>((ref) => BookingService(ref));

final patientAppointmentsProvider =
    StreamProvider<List<AppointmentModel>>((ref) {
  return ref.watch(bookingServiceProvider).getPatientAppointments();
});

final upcomingAppointmentsProvider =
    StreamProvider<List<AppointmentModel>>((ref) {
  return ref.watch(bookingServiceProvider).getUpcomingAppointments();
});

final pastAppointmentsProvider =
    StreamProvider<List<AppointmentModel>>((ref) {
  return ref.watch(bookingServiceProvider).getPastAppointments();
});
