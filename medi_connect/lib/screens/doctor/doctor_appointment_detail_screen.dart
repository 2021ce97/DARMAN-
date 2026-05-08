import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class DoctorAppointmentDetailScreen extends ConsumerStatefulWidget {
  final AppointmentModel appointment;
  const DoctorAppointmentDetailScreen({super.key, required this.appointment});

  @override
  ConsumerState<DoctorAppointmentDetailScreen> createState() =>
      _DoctorAppointmentDetailScreenState();
}

class _DoctorAppointmentDetailScreenState
    extends ConsumerState<DoctorAppointmentDetailScreen> {
  bool _isUpdating = false;
  late AppointmentModel _appt;

  @override
  void initState() {
    super.initState();
    _appt = widget.appointment;
  }

  Future<void> _updateStatus(AppointmentStatus status, {String? reason}) async {
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(_appt.id)
          .update({
        'status': status.label,
        if (reason != null) 'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _appt = _appt.copyWith(status: status, cancellationReason: reason);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${status.label} ✓'),
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
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _StatusBanner(status: _appt.status),
            const SizedBox(height: 16),

            // Patient Info Card
            _InfoCard(
              title: 'Patient',
              icon: Icons.person_rounded,
              children: [
                _DetailRow(
                    label: 'Name', value: _appt.patientName),
                _DetailRow(
                    label: 'Patient ID',
                    value: _appt.patientId.substring(0, 12) + '...'),
              ],
            ),
            const SizedBox(height: 12),

            // Appointment Info Card
            _InfoCard(
              title: 'Appointment',
              icon: Icons.calendar_today_rounded,
              children: [
                _DetailRow(
                    label: 'Date & Time',
                    value: DateFormat('MMMM d, yyyy • hh:mm a')
                        .format(_appt.dateTime)),
                _DetailRow(
                    label: 'Type',
                    value: _appt.type == AppointmentType.online
                        ? '🎥 Online Consultation'
                        : '🏥 Clinic Visit'),
                _DetailRow(
                    label: 'Fee',
                    value:
                        '${_appt.amount.toStringAsFixed(0)} AFN'),
                if (_appt.notes != null && _appt.notes!.isNotEmpty)
                  _DetailRow(
                      label: 'Patient Notes', value: _appt.notes!),
              ],
            ),
            const SizedBox(height: 12),

            if (_appt.cancellationReason != null) ...[
              _InfoCard(
                title: 'Cancellation',
                icon: Icons.cancel_outlined,
                children: [
                  _DetailRow(
                      label: 'Reason',
                      value: _appt.cancellationReason!),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Actions
            if (_appt.status == AppointmentStatus.pending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUpdating
                          ? null
                          : () => _showDeclineDialog(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus(AppointmentStatus.approved),
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (_appt.status == AppointmentStatus.approved) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateStatus(AppointmentStatus.completed),
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_appt.type == AppointmentType.online)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/video_consultation',
                        extra: {
                          'consultationId': _appt.id,
                          'doctorName':
                              ref.read(authStateProvider).value?.displayName ??
                                  'Doctor',
                          'doctorSpecialty': 'Doctor',
                          'userId':
                              ref.read(authStateProvider).value?.uid ?? '',
                          'role': 'doctor',
                        }),
                    icon: const Icon(Icons.videocam_rounded),
                    label: const Text('Start Video Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/doctor/write-prescription',
                    extra: {
                      'patientName': _appt.patientName,
                      'patientId': _appt.patientId,
                      'appointmentId': _appt.id,
                    }),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Write Prescription'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeclineDialog() async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Appointment'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Reason for declining (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateStatus(AppointmentStatus.cancelled,
          reason: reasonCtrl.text.trim().isEmpty
              ? 'Declined by doctor'
              : reasonCtrl.text.trim());
    }
  }
}

// ─── Status Banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBanner({required this.status});

  Color get _color {
    switch (status) {
      case AppointmentStatus.approved:
        return AppColors.primary;
      case AppointmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AppointmentStatus.completed:
        return const Color(0xFF10B981);
      case AppointmentStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  IconData get _icon {
    switch (status) {
      case AppointmentStatus.approved:
        return Icons.check_circle_rounded;
      case AppointmentStatus.pending:
        return Icons.pending_rounded;
      case AppointmentStatus.completed:
        return Icons.done_all_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appointment Status',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textHint),
              ),
              Text(
                status.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
