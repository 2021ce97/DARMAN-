import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final _uniquePatientsProvider = StreamProvider<List<_PatientSummary>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('appointments')
      .where('doctorId', isEqualTo: uid)
      .orderBy('dateTime', descending: true)
      .snapshots()
      .map((snap) {
    final seen = <String>{};
    final patients = <_PatientSummary>[];

    for (final doc in snap.docs) {
      final appt = AppointmentModel.fromFirestore(doc);
      if (!seen.contains(appt.patientId)) {
        seen.add(appt.patientId);

        // Count total appointments for this patient
        final patientAppts = snap.docs
            .map(AppointmentModel.fromFirestore)
            .where((a) => a.patientId == appt.patientId)
            .toList();

        patients.add(_PatientSummary(
          id: appt.patientId,
          name: appt.patientName,
          lastVisit: appt.dateTime,
          totalVisits: patientAppts.length,
          lastStatus: appt.status,
        ));
      }
    }
    return patients;
  });
});

// ─── Patient Summary ──────────────────────────────────────────────────────────

class _PatientSummary {
  final String id;
  final String name;
  final DateTime lastVisit;
  final int totalVisits;
  final AppointmentStatus lastStatus;

  const _PatientSummary({
    required this.id,
    required this.name,
    required this.lastVisit,
    required this.totalVisits,
    required this.lastStatus,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DoctorPatientsScreen extends ConsumerStatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  ConsumerState<DoctorPatientsScreen> createState() =>
      _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState
    extends ConsumerState<DoctorPatientsScreen> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(_uniquePatientsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search patient by name...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.textHint),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Content
          Expanded(
            child: patientsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (patients) {
                final filtered = _searchQuery.isEmpty
                    ? patients
                    : patients
                        .where((p) => p.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return _buildEmpty(_searchQuery.isNotEmpty);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} patient${filtered.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _PatientCard(patient: filtered[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.people_outline_rounded,
            size: 72,
            color: AppColors.outline,
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'No patients found' : 'No patients yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'Try a different name'
                : 'Patients who book with you will appear here',
            style: const TextStyle(fontSize: 13, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Patient Card ─────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final _PatientSummary patient;
  const _PatientCard({required this.patient});

  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    AppColors.primary,
  ];

  Color get _avatarColor =>
      _colors[patient.name.codeUnitAt(0) % _colors.length];

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
          onTap: () => _showPatientDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _avatarColor.withOpacity(0.15),
                  child: Text(
                    patient.name.isNotEmpty
                        ? patient.name[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      color: _avatarColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            'Last visit: ${DateFormat('MMM d, yyyy').format(patient.lastVisit)}',
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
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${patient.totalVisits} visit${patient.totalVisits != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.outline, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPatientDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PatientDetailSheet(patient: patient),
    );
  }
}

// ─── Patient Detail Sheet ─────────────────────────────────────────────────────

class _PatientDetailSheet extends StatelessWidget {
  final _PatientSummary patient;
  const _PatientDetailSheet({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Patient ID: ${patient.id.substring(0, 8)}...',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Total Visits',
              value: '${patient.totalVisits}'),
          const SizedBox(height: 12),
          _InfoRow(
              icon: Icons.access_time_rounded,
              label: 'Last Visit',
              value:
                  DateFormat('MMMM d, yyyy').format(patient.lastVisit)),
          const SizedBox(height: 12),
          _InfoRow(
              icon: Icons.info_outline_rounded,
              label: 'Last Status',
              value: patient.lastStatus.label),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/doctor/write-prescription',
                    extra: {'patientName': patient.name, 'patientId': patient.id});
              },
              icon: const Icon(Icons.receipt_long_rounded),
              label: const Text('Write Prescription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
