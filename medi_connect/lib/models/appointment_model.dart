import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, approved, completed, cancelled, rescheduled }

enum AppointmentType { clinicVisit, online }

extension AppointmentStatusExt on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Approved';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  static AppointmentStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return AppointmentStatus.approved;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      default:
        return AppointmentStatus.pending;
    }
  }
}

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String patientId;
  final String patientName;
  final DateTime dateTime;
  final AppointmentStatus status;
  final AppointmentType type;
  final double amount;
  final String? notes;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientId,
    required this.patientName,
    required this.dateTime,
    required this.status,
    required this.type,
    required this.amount,
    this.notes,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
  });

  bool get isUpcoming =>
      status == AppointmentStatus.pending ||
      status == AppointmentStatus.approved;

  bool get isPast =>
      status == AppointmentStatus.completed ||
      status == AppointmentStatus.cancelled;

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: AppointmentStatusExt.fromString(data['status'] ?? 'Pending'),
      type: data['type'] == 'Online'
          ? AppointmentType.online
          : AppointmentType.clinicVisit,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'],
      cancellationReason: data['cancellationReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientId': patientId,
      'patientName': patientName,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status.label,
      'type': type == AppointmentType.online ? 'Online' : 'Clinic Visit',
      'amount': amount,
      if (notes != null) 'notes': notes,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppointmentModel copyWith({
    AppointmentStatus? status,
    DateTime? dateTime,
    String? notes,
    String? cancellationReason,
  }) {
    return AppointmentModel(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      patientId: patientId,
      patientName: patientName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      type: type,
      amount: amount,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
