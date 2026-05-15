import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Persist a notification document for a user.
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? referenceId,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.label,
      'isRead': false,
      'referenceId': ?referenceId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications for the current user as read.
  Future<void> markAllRead() async {
    // Handled by the stream provider — no-op here
  }

  /// Mark all notifications for the current user as read.
  Future<void> markAllAsRead(String userId) async {
    final batch = _db.batch();
    final snap = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream of all notifications for a user, newest first.
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(NotificationModel.fromFirestore).toList());
  }

  /// Stream of unread notification count.
  Stream<int> watchUnreadCount(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationsProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(notificationServiceProvider)
      .watchNotifications(user.uid);
});

/// Provider returning raw maps for the notifications screen
final notificationsMapProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(notificationServiceProvider)
      .watchNotifications(user.uid)
      .map((list) => list.map((n) => {
        'id': n.id,
        'title': n.title,
        'message': n.body,
        'type': n.type.label,
        'read': n.isRead,
        'createdAt': n.createdAt.toIso8601String(),
      }).toList());
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(0);
  return ref
      .watch(notificationServiceProvider)
      .watchUnreadCount(user.uid);
});
