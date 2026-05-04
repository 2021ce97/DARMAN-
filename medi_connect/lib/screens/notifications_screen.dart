import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsMapProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationServiceProvider).markAllRead(),
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 72, color: AppColors.outline),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('You\'ll see appointment reminders and updates here', style: TextStyle(color: AppColors.textHint), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationTile({required this.notification});

  IconData get _icon {
    switch (notification['type']) {
      case 'appointment': return Icons.calendar_today_rounded;
      case 'prescription': return Icons.medication_rounded;
      case 'payment': return Icons.payment_rounded;
      case 'consultation': return Icons.video_call_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color get _iconColor {
    switch (notification['type']) {
      case 'appointment': return AppColors.primary;
      case 'prescription': return Colors.green;
      case 'payment': return Colors.orange;
      case 'consultation': return Colors.purple;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification['read'] == true;

    return Container(
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_icon, color: _iconColor, size: 22),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notification['message'] ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification['createdAt']),
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ),
        trailing: isRead ? null : Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
