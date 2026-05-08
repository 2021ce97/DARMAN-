import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

// ─── Stats summary model ──────────────────────────────────────────────────────

class _DashboardStats {
  final int todayCount;
  final int pendingCount;
  final int totalPatients;
  final double totalEarnings;
  const _DashboardStats({
    required this.todayCount,
    required this.pendingCount,
    required this.totalPatients,
    required this.totalEarnings,
  });
}

// ─── Providers ────────────────────────────────────────────────────────────────

final _doctorApptsProvider =
    StreamProvider<List<AppointmentModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('appointments')
      .where('doctorId', isEqualTo: uid)
      .orderBy('dateTime', descending: true)
      .snapshots()
      .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final apptAsync = ref.watch(_doctorApptsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context, user),
          SliverToBoxAdapter(
            child: apptAsync.when(
              loading: () => _buildLoadingBody(),
              error: (e, _) => _buildErrorBody(e),
              data: (appts) => _buildBody(context, ref, appts, user),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildSliverHeader(BuildContext context, User? user) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final name = user?.displayName ?? 'Doctor';

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D8A79), AppColors.primary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white24,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'D',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Dr. $name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _NotificationBell(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<AppointmentModel> appts,
    User? user,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayAppts = appts
        .where((a) {
          final d = DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day);
          return d == today;
        })
        .toList();
    final pending =
        appts.where((a) => a.status == AppointmentStatus.pending).toList();
    final patientIds = appts.map((a) => a.patientId).toSet();
    final earnings =
        appts.where((a) => a.status == AppointmentStatus.completed).fold<double>(
              0,
              (sum, a) => sum + a.amount,
            );

    final stats = _DashboardStats(
      todayCount: todayAppts.length,
      pendingCount: pending.length,
      totalPatients: patientIds.length,
      totalEarnings: earnings,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatsGrid(stats: stats),
          const SizedBox(height: 24),
          _QuickActions(
            onScheduleTap: () => context.go('/doctor/appointments'),
            onPatientsTap: () => context.go('/doctor/patients'),
            onPrescribeTap: () => context.go('/doctor/write-prescription'),
            onVideoTap: () => context.go('/doctor/appointments'),
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: "Today's Appointments",
            count: todayAppts.length,
            onSeeAll: () => context.go('/doctor/appointments'),
          ),
          const SizedBox(height: 12),
          if (todayAppts.isEmpty)
            _EmptyState(
              icon: Icons.event_available_rounded,
              message: 'No appointments today',
              subtitle: 'Enjoy your free day!',
            )
          else
            ...todayAppts.take(3).map((a) => _AppointmentCard(appt: a, ref: ref)),
          const SizedBox(height: 24),
          if (pending.isNotEmpty) ...[
            _SectionHeader(
              title: 'Pending Requests',
              count: pending.length,
              onSeeAll: () => context.go('/doctor/appointments'),
            ),
            const SizedBox(height: 12),
            ...pending.take(3).map((a) => _AppointmentCard(appt: a, ref: ref, showActions: true)),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLoadingBody() => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _buildErrorBody(Object e) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text('Error loading data: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
      );
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final _DashboardStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Icons.calendar_today_rounded,
          color: AppColors.primary,
          label: "Today's Patients",
          value: '${stats.todayCount}',
        ),
        _StatCard(
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFFF59E0B),
          label: 'Pending Requests',
          value: '${stats.pendingCount}',
        ),
        _StatCard(
          icon: Icons.people_rounded,
          color: const Color(0xFF6366F1),
          label: 'Total Patients',
          value: '${stats.totalPatients}',
        ),
        _StatCard(
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF10B981),
          label: 'Total Earnings',
          value:
              '${NumberFormat.compact().format(stats.totalEarnings)} AFN',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
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
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final VoidCallback onScheduleTap;
  final VoidCallback onPatientsTap;
  final VoidCallback onPrescribeTap;
  final VoidCallback onVideoTap;

  const _QuickActions({
    required this.onScheduleTap,
    required this.onPatientsTap,
    required this.onPrescribeTap,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.calendar_month_rounded, 'label': 'Schedule', 'color': AppColors.primary, 'onTap': onScheduleTap},
      {'icon': Icons.people_rounded, 'label': 'Patients', 'color': const Color(0xFF6366F1), 'onTap': onPatientsTap},
      {'icon': Icons.receipt_long_rounded, 'label': 'Prescribe', 'color': const Color(0xFF10B981), 'onTap': onPrescribeTap},
      {'icon': Icons.videocam_rounded, 'label': 'Video Call', 'color': const Color(0xFFF59E0B), 'onTap': onVideoTap},
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: a['onTap'] as VoidCallback,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (a['color'] as Color).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(a['icon'] as IconData,
                        color: a['color'] as Color, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a['label'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (count > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('See all',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appt;
  final WidgetRef ref;
  final bool showActions;

  const _AppointmentCard({
    required this.appt,
    required this.ref,
    this.showActions = false,
  });

  Color get _statusColor {
    switch (appt.status) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/doctor/appointment-detail', extra: appt),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _PatientAvatar(name: appt.patientName),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt.patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 12, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d • hh:mm a')
                                    .format(appt.dateTime),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            appt.status.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              appt.type == AppointmentType.online
                                  ? Icons.videocam_rounded
                                  : Icons.local_hospital_rounded,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              appt.type == AppointmentType.online
                                  ? 'Online'
                                  : 'Clinic',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (showActions &&
                    appt.status == AppointmentStatus.pending) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _decline(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approve(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appt.id)
          .update({
        'status': AppointmentStatus.approved.label,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment approved ✓'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _decline(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appt.id)
          .update({
        'status': AppointmentStatus.cancelled.label,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

// ─── Patient Avatar ───────────────────────────────────────────────────────────

class _PatientAvatar extends StatelessWidget {
  final String name;
  const _PatientAvatar({required this.name});

  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    AppColors.primary,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[name.codeUnitAt(0) % _colors.length];
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withOpacity(0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.outline),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }
}

// ─── Notification Bell ────────────────────────────────────────────────────────

class _NotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
      onPressed: () => context.push('/notifications'),
    );
  }
}
