import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/appointment_model.dart';
import '../providers/auth_provider.dart';
import '../services/booking_service.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(patientAppointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Pending'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: appointmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (appointments) {
          final upcoming = appointments.where((a) =>
              a.status == AppointmentStatus.approved && a.isUpcoming).toList();
          final pending = appointments.where((a) =>
              a.status == AppointmentStatus.pending).toList();
          final past = appointments.where((a) =>
              a.status == AppointmentStatus.completed ||
              a.status == AppointmentStatus.cancelled ||
              (!a.isUpcoming && a.status == AppointmentStatus.rescheduled)).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _AppointmentList(appointments: upcoming, emptyMessage: 'No upcoming appointments', emptyIcon: Icons.event_available_rounded),
              _AppointmentList(appointments: pending, emptyMessage: 'No pending requests', emptyIcon: Icons.pending_actions_rounded),
              _AppointmentList(appointments: past, emptyMessage: 'No past appointments', emptyIcon: Icons.history_rounded),
            ],
          );
        },
      ),
    );
  }
}

// ─── List widget ──────────────────────────────────────────────────────────────

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String emptyMessage;
  final IconData emptyIcon;
  const _AppointmentList({
    required this.appointments,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 72, color: AppColors.outline),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Book a doctor to see your schedule',
                style: TextStyle(color: AppColors.textHint, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _AppointmentCard(appointment: appointments[i]),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _AppointmentCard extends ConsumerStatefulWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  @override
  ConsumerState<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends ConsumerState<_AppointmentCard> {
  bool _isActing = false;

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.approved:
        return AppColors.primary;
      case AppointmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.completed:
        return const Color(0xFF10B981);
      case AppointmentStatus.rescheduled:
        return Colors.orange;
    }
  }

  Future<void> _cancel() async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this appointment?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Appointment',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isActing = true);
    try {
      await ref.read(bookingServiceProvider).cancelAppointment(
            widget.appointment.id,
            reason: reasonCtrl.text.trim().isEmpty
                ? null
                : reasonCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  Future<void> _reschedule() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null || !mounted) return;

    final newDt = DateTime(
        picked.year, picked.month, picked.day, time.hour, time.minute);

    setState(() => _isActing = true);
    try {
      await ref.read(bookingServiceProvider).rescheduleAppointment(
            widget.appointment.id,
            newDt,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rescheduled ✓'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  void _joinConsultation() {
    final appt = widget.appointment;
    final user = ref.read(authStateProvider).value;
    context.push('/video_consultation', extra: {
      'consultationId': appt.id,
      'doctorName': appt.doctorName,
      'doctorSpecialty': appt.doctorSpecialty,
      'userId': user?.uid ?? '',
      'role': 'patient',
    });
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;
    final isUpcoming = appt.isUpcoming &&
        (appt.status == AppointmentStatus.approved ||
            appt.status == AppointmentStatus.pending);
    final isOnline = appt.type == AppointmentType.online;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.doctorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            isOnline
                                ? Icons.videocam_rounded
                                : Icons.local_hospital_rounded,
                            size: 13,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'Online' : 'Clinic Visit',
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(appt.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appt.status.label,
                    style: TextStyle(
                      color: _statusColor(appt.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Date/time row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded,
                    size: 15, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM dd, yyyy').format(appt.dateTime),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.access_time_rounded,
                    size: 15, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  DateFormat('hh:mm a').format(appt.dateTime),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${appt.amount.toStringAsFixed(0)} AFN',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons for upcoming/pending
          if (isUpcoming) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _isActing
                  ? const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _cancel,
                            icon: const Icon(Icons.close_rounded, size: 15),
                            label: const Text('Cancel',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reschedule
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _reschedule,
                            icon: const Icon(Icons.calendar_month_rounded,
                                size: 15),
                            label: const Text('Reschedule',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        // Join (online approved only)
                        if (isOnline &&
                            appt.status == AppointmentStatus.approved) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _joinConsultation,
                              icon: const Icon(Icons.videocam_rounded,
                                  size: 15),
                              label: const Text('Join',
                                  style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
