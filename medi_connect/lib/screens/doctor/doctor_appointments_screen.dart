import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _doctorScheduleProvider =
    StreamProvider<List<AppointmentModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('appointments')
      .where('doctorId', isEqualTo: uid)
      .orderBy('dateTime')
      .snapshots()
      .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class DoctorAppointmentsScreen extends ConsumerStatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  ConsumerState<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends ConsumerState<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();

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
    final apptAsync = ref.watch(_doctorScheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: apptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (appts) => Column(
          children: [
            _WeekStrip(
              selected: _selectedDay,
              onSelect: (d) => setState(() => _selectedDay = d),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AppointmentList(
                    appointments: _filterToday(appts),
                    emptyMessage: 'No appointments today',
                  ),
                  _AppointmentList(
                    appointments: _filterUpcoming(appts),
                    emptyMessage: 'No upcoming appointments',
                  ),
                  _AppointmentList(
                    appointments: _filterPast(appts),
                    emptyMessage: 'No past appointments',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AppointmentModel> _filterToday(List<AppointmentModel> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return all.where((a) {
      final d = DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day);
      return d == today;
    }).toList();
  }

  List<AppointmentModel> _filterUpcoming(List<AppointmentModel> all) {
    return all
        .where((a) =>
            a.dateTime.isAfter(DateTime.now()) &&
            (a.status == AppointmentStatus.pending ||
                a.status == AppointmentStatus.approved))
        .toList();
  }

  List<AppointmentModel> _filterPast(List<AppointmentModel> all) {
    return all
        .where((a) =>
            a.status == AppointmentStatus.completed ||
            a.status == AppointmentStatus.cancelled)
        .toList();
  }
}

// ─── Week Strip ───────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _WeekStrip({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
        7, (i) => DateTime.now().subtract(Duration(days: 3 - i)));

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: days.map((day) {
          final isSelected = DateFormat('yyyyMMdd').format(day) ==
              DateFormat('yyyyMMdd').format(selected);
          final isToday = DateFormat('yyyyMMdd').format(day) ==
              DateFormat('yyyyMMdd').format(DateTime.now());

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(day).substring(0, 1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white70
                            : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                    if (isToday && !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Appointment List ─────────────────────────────────────────────────────────

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String emptyMessage;

  const _AppointmentList({
    required this.appointments,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 64, color: AppColors.outline),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, i) =>
          _ScheduleCard(appt: appointments[i]),
    );
  }
}

// ─── Schedule Card ────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final AppointmentModel appt;
  const _ScheduleCard({required this.appt});

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
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () =>
              context.push('/doctor/appointment-detail', extra: appt),
          child: Row(
            children: [
              // Time column
              Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('hh:mm').format(appt.dateTime),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _statusColor,
                      ),
                    ),
                    Text(
                      DateFormat('a').format(appt.dateTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: _statusColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            appt.type == AppointmentType.online
                                ? Icons.videocam_outlined
                                : Icons.local_hospital_outlined,
                            size: 13,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appt.type == AppointmentType.online
                                ? 'Online Consultation'
                                : 'Clinic Visit',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                      if (appt.notes != null && appt.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          appt.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
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
                    const SizedBox(height: 6),
                    Text(
                      '${appt.amount.toStringAsFixed(0)} AFN',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
