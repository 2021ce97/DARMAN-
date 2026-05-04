import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String name;
  final String dosage;
  final String duration;
  final String instructions;

  Medicine({
    required this.name,
    required this.dosage,
    required this.duration,
    this.instructions = '',
  });

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      duration: map['duration'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

class PrescriptionModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String appointmentId;
  final String diagnosis;
  final List<Medicine> medicines;
  final String? notes;
  final DateTime createdAt;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.diagnosis,
    required this.medicines,
    this.notes,
    required this.createdAt,
  });

  factory PrescriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrescriptionModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      medicines: (data['medicines'] as List? ?? [])
          .map((m) => Medicine.fromMap(m as Map<String, dynamic>))
          .toList(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'diagnosis': diagnosis,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      if (notes != null) 'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
