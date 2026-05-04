import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  appointmentConfirmed,
  appointmentReminder,
  appointmentCancelled,
  prescriptionReady,
  general,
}

extension NotificationTypeExt on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.appointmentConfirmed:
        return 'appointment_confirmed';
      case NotificationType.appointmentReminder:
        return 'appointment_reminder';
      case NotificationType.appointmentCancelled:
        return 'appointment_cancelled';
      case NotificationType.prescriptionReady:
        return 'prescription_ready';
      case NotificationType.general:
        return 'general';
    }
  }

  static NotificationType fromString(String s) {
    switch (s) {
      case 'appointment_confirmed':
        return NotificationType.appointmentConfirmed;
      case 'appointment_reminder':
        return NotificationType.appointmentReminder;
      case 'appointment_cancelled':
        return NotificationType.appointmentCancelled;
      case 'prescription_ready':
        return NotificationType.prescriptionReady;
      default:
        return NotificationType.general;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? referenceId; // appointmentId, prescriptionId, etc.
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationTypeExt.fromString(data['type'] ?? 'general'),
      isRead: data['isRead'] ?? false,
      referenceId: data['referenceId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.label,
      'isRead': isRead,
      if (referenceId != null) 'referenceId': referenceId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
