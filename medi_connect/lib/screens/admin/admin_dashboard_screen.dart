import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/fcm_service.dart';
import 'admin_users_tab.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _adminStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final db = FirebaseFirestore.instance;
  return Stream.fromFuture(Future.wait([
    db.collection('users').where('role', isEqualTo: 'patient').count().get(),
    db.collection('doctors').count().get(),
    db.collection('doctors').where('status', isEqualTo: 'Pending').count().get(),
    db.collection('appointments').count().get(),
  ])).map((results) => {
        'patients': results[0].count ?? 0,
        'doctors': results[1].count ?? 0,
        'pendingDoctors': results[2].count ?? 0,
        'appointments': results[3].count ?? 0,
      });
});

final _pendingDoctorsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('doctors')
      .where('status', isEqualTo: 'Pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList());
});

final _recentAppointmentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('appointments')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList());
});

// ─── Admin Dashboard ──────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(_adminStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded,
                color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Admin Panel'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.go('/login'),
            tooltip: 'Sign Out',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Doctors'),
            Tab(text: 'Appointments'),
            Tab(text: 'Users'),
            Tab(text: 'Health Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildOverviewTab(statsAsync),
          const _DoctorsManagementTab(),
          const _AppointmentsTab(),
          const AdminUsersTab(),
          const _AdminHealthRecordsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AsyncValue<Map<String, int>> statsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats grid
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (stats) => GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  label: 'Total Patients',
                  value: '${stats['patients'] ?? 0}',
                  icon: Icons.people_rounded,
                  color: const Color(0xFF6366F1),
                ),
                _StatCard(
                  label: 'Total Doctors',
                  value: '${stats['doctors'] ?? 0}',
                  icon: Icons.medical_services_rounded,
                  color: AppColors.primary,
                ),
                _StatCard(
                  label: 'Pending Verification',
                  value: '${stats['pendingDoctors'] ?? 0}',
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xFFF59E0B),
                  urgent: (stats['pendingDoctors'] ?? 0) > 0,
                ),
                _StatCard(
                  label: 'Total Appointments',
                  value: '${stats['appointments'] ?? 0}',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.how_to_reg_rounded,
                  label: 'Verify Doctors',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _tabs.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.calendar_today_rounded,
                  label: 'Appointments',
                  color: const Color(0xFF10B981),
                  onTap: () => _tabs.animateTo(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.people_rounded,
                  label: 'Manage Users',
                  color: const Color(0xFF6366F1),
                  onTap: () => _tabs.animateTo(3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent activity
          const Text(
            'Recent Activity',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, _) {
              final apptAsync = ref.watch(_recentAppointmentsProvider);
              return apptAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (appts) {
                  if (appts.isEmpty) {
                    return const Center(
                      child: Text('No recent appointments',
                          style: TextStyle(color: AppColors.textHint)),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appts.take(5).length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: AppColors.divider),
                    itemBuilder: (context, i) {
                      final appt = appts[i];
                      final ts = appt['createdAt'] as Timestamp?;
                      final date = ts != null
                          ? DateFormat('MMM d, HH:mm').format(ts.toDate())
                          : 'Unknown';
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary, size: 18),
                        ),
                        title: Text(
                          '${appt['patientName'] ?? 'Patient'} → Dr. ${appt['doctorName'] ?? 'Doctor'}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(date,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textHint)),
                        trailing: _StatusPill(appt['status'] as String? ?? ''),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Doctors Management Tab ───────────────────────────────────────────────────

class _DoctorsManagementTab extends ConsumerWidget {
  const _DoctorsManagementTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(_pendingDoctorsProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Pending Verification'),
                Tab(text: 'All Doctors'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pending
                pendingAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (doctors) {
                    if (doctors.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 64, color: AppColors.outline),
                            SizedBox(height: 16),
                            Text('No pending verifications',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: doctors.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _DoctorVerificationCard(doctor: doctors[i]),
                    );
                  },
                ),
                // All doctors
                Consumer(
                  builder: (context, ref, _) {
                    return _AllDoctorsList();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDoctorsList extends ConsumerWidget {
  const _AllDoctorsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = StreamProvider<List<Map<String, dynamic>>>((ref) {
      return FirebaseFirestore.instance
          .collection('doctors')
          .orderBy('name')
          .snapshots()
          .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
    });
    final allAsync = ref.watch(provider);
    return allAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (doctors) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final d = doctors[i];
          final status = d['status'] as String? ?? 'Unknown';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    (d['name'] as String? ?? 'D')[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${d['name'] ?? 'Unknown'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        '${d['specialty'] ?? ''} • ${d['city'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Doctor Verification Card ─────────────────────────────────────────────────

class _DoctorVerificationCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> doctor;
  const _DoctorVerificationCard({required this.doctor});

  @override
  ConsumerState<_DoctorVerificationCard> createState() =>
      _DoctorVerificationCardState();
}

class _DoctorVerificationCardState
    extends ConsumerState<_DoctorVerificationCard> {
  bool _isLoading = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      final id = widget.doctor['id'] as String;
      await FirebaseFirestore.instance.collection('doctors').doc(id).update({
        'status': status,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      // Notify the doctor
      final doctorUserId = widget.doctor['userId'] as String?;
      if (doctorUserId != null && doctorUserId.isNotEmpty) {
        final isApproved = status == 'Verified';
        final title = isApproved
            ? 'Verification Approved ✅'
            : 'Verification Rejected';
        final body = isApproved
            ? 'Congratulations! Your doctor profile has been verified. You can now accept appointments.'
            : 'Your doctor verification was not approved. Please contact support.';

        // In-app Firestore notification
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': doctorUserId,
          'title': title,
          'body': body,
          'type': 'general',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // FCM local notification (shows immediately on device)
        FCMService().showLocalNotification(
          title: title,
          body: body,
          payload: id,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Doctor ${status == 'Verified' ? 'approved ✓' : 'rejected'}'),
            backgroundColor: status == 'Verified'
                ? AppColors.primary
                : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  (d['name'] as String? ?? 'D')[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${d['name'] ?? 'Unknown'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Text(
                      d['specialty'] ?? 'Not specified',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.badge_outlined, label: 'Reg. No', value: d['regNo'] ?? 'N/A'),
          _InfoRow(icon: Icons.local_hospital_outlined, label: 'Hospital', value: d['hospital'] ?? 'N/A'),
          _InfoRow(icon: Icons.location_city_outlined, label: 'City', value: d['city'] ?? 'N/A'),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: d['email'] ?? 'N/A'),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus('Rejected'),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus('Verified'),
                    icon: const Icon(Icons.verified_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Appointments Tab ─────────────────────────────────────────────────────────

class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apptAsync = ref.watch(_recentAppointmentsProvider);
    return apptAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (appts) {
        if (appts.isEmpty) {
          return const Center(
            child: Text('No appointments found',
                style: TextStyle(color: AppColors.textHint)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: appts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final a = appts[i];
            final ts = a['dateTime'] as Timestamp?;
            final date = ts != null
                ? DateFormat('MMM d, yyyy • HH:mm').format(ts.toDate())
                : 'Unknown';
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${a['patientName'] ?? 'Patient'} → Dr. ${a['doctorName'] ?? 'Doctor'}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      _StatusPill(a['status'] as String? ?? ''),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(date,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint)),
                      const Spacer(),
                      Text(
                        '${a['amount'] ?? 0} AFN',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Admin Health Records Tab ──────────────────────────────────────────────────
class _AdminHealthRecordsTab extends ConsumerWidget {
  const _AdminHealthRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('prescriptions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No health records found'));
        }

        final records = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = records[i].data() as Map<String, dynamic>;
            final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final isUserUpload = data['isUserUpload'] == true;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    isUserUpload ? Icons.file_present_rounded : Icons.description_rounded,
                    color: isUserUpload ? AppColors.primary : AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUserUpload ? data['diagnosis'] : 'Rx: ${data['diagnosis']}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          isUserUpload
                              ? 'Uploaded by Patient • ${DateFormat('MMM d').format(date)}'
                              : 'By Dr. ${data['doctorName']} • ${DateFormat('MMM d').format(date)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(isUserUpload ? 'User Record' : 'Prescription'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool urgent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: urgent
            ? Border.all(color: const Color(0xFFF59E0B), width: 1.5)
            : null,
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
              Icon(icon, color: color, size: 22),
              if (urgent) ...[
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill(this.status);

  Color get _color {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.primary;
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return const Color(0xFF10B981);
      case 'verified':
        return AppColors.primary;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: _color, fontSize: 11, fontWeight: FontWeight.w700),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textHint),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
