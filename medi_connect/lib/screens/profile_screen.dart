import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) => CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 28,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.white),
                        onPressed: () => _showEditProfileSheet(context, ref, user),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Stack(children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: user?.photoUrl != null
                          ? ClipOval(
                              child: Image.network(user!.photoUrl!,
                                  fit: BoxFit.cover))
                          : const Icon(Icons.person_rounded,
                              color: Colors.white, size: 52),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'HealthLink User',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  statsAsync.when(
                    data: (stats) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(
                            '${stats['appointments']}', 'Appointments'),
                        _vDivider(),
                        _StatBadge('${stats['doctors']}', 'Doctors'),
                        _vDivider(),
                        _StatBadge('${stats['records']}', 'Records'),
                      ],
                    ),
                    loading: () => const SizedBox(
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ]),
              ),
            ),

            // Health Info Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Health Info',
                            style: Theme.of(context).textTheme.titleSmall),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HealthInfo(
                          'Blood Type',
                          user?.bloodType ?? '—',
                          Icons.water_drop_rounded,
                          const Color(0xFFFFEDE6),
                          AppColors.secondary,
                        ),
                        _HealthInfo(
                          'Weight',
                          user?.weight != null
                              ? '${user!.weight!.toStringAsFixed(0)} kg'
                              : '—',
                          Icons.monitor_weight_rounded,
                          AppColors.primaryLight,
                          AppColors.primary,
                        ),
                        _HealthInfo(
                          'Height',
                          user?.height != null
                              ? '${user!.height!.toStringAsFixed(0)} cm'
                              : '—',
                          Icons.straighten_rounded,
                          const Color(0xFFE3F2FD),
                          Colors.blue,
                        ),
                        _HealthInfo(
                          'Allergies',
                          user?.allergies ?? 'None',
                          Icons.warning_amber_rounded,
                          const Color(0xFFFFF8E1),
                          Colors.orange,
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),

            // Menu Items
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(children: [
                  _MenuSection('Account', [
                    _MenuItem(Icons.person_outline_rounded, 'Personal Information',
                        () => _showEditProfileSheet(context, ref, user)),
                    _MenuItem(Icons.credit_card_rounded, 'Payment Methods', () {}),
                    _MenuItem(Icons.notifications_outlined, 'Notifications', () {}),
                    _MenuItem(Icons.language_rounded, 'Language', () {}),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection('Health', [
                    _MenuItem(Icons.folder_open_rounded, 'My Health Records',
                        () => context.push('/health_records')),
                    _MenuItem(Icons.monitor_heart_rounded, 'Health Dashboard',
                        () => context.push('/health_dashboard')),
                    _MenuItem(Icons.calendar_today_rounded, 'My Appointments',
                        () => context.go('/appointments')),
                    _MenuItem(Icons.medication_rounded, 'My Prescriptions',
                        () => context.push('/prescriptions')),
                    _MenuItem(Icons.alarm_rounded, 'Medication Reminders',
                        () => context.push('/medication_reminders')),
                    _MenuItem(Icons.biotech_rounded, 'Lab Tests',
                        () => context.push('/lab_tests')),
                    _MenuItem(Icons.local_pharmacy_rounded, 'Pharmacy',
                        () => context.push('/pharmacy')),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection('AI & Tools', [
                    _MenuItem(Icons.smart_toy_outlined, 'AI Health Assistant',
                        () => context.push('/ai_chat')),
                    _MenuItem(Icons.search_rounded, 'Symptom Checker',
                        () => context.push('/symptom_checker')),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection('Preferences', [
                    _MenuItem(Icons.notifications_outlined, 'Notifications',
                        () => context.push('/notifications')),
                    _MenuItem(Icons.dark_mode_outlined, 'Dark Mode',
                        () => ref.read(themeProvider.notifier).toggle()),
                    _MenuItem(Icons.language_rounded, 'Language', () {}),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection('Support', [
                    _MenuItem(Icons.help_outline_rounded, 'Help & Support',
                        () => context.push('/help')),
                    _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
                    _MenuItem(Icons.info_outline_rounded, 'About HealthLink', () {}),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAD6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: AppColors.error, size: 20),
                      ),
                      title: const Text('Sign Out',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600)),
                      onTap: () => _confirmSignOut(context, ref),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textHint),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _vDivider() => Container(
      height: 30,
      width: 1,
      color: Colors.white30,
      margin: const EdgeInsets.symmetric(horizontal: 20));

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authServiceProvider).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, dynamic user) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final bloodCtrl = TextEditingController(text: user?.bloodType ?? '');
    final weightCtrl = TextEditingController(
        text: user?.weight?.toStringAsFixed(0) ?? '');
    final heightCtrl = TextEditingController(
        text: user?.height?.toStringAsFixed(0) ?? '');
    final allergyCtrl =
        TextEditingController(text: user?.allergies ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Edit Profile',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                _buildField('Full Name', nameCtrl, Icons.person_outline),
                const SizedBox(height: 12),
                _buildField('Phone', phoneCtrl, Icons.phone_outlined,
                    type: TextInputType.phone),
                const SizedBox(height: 12),
                _buildField('Blood Type', bloodCtrl,
                    Icons.water_drop_outlined),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: _buildField('Weight (kg)', weightCtrl,
                        Icons.monitor_weight_outlined,
                        type: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Height (cm)', heightCtrl,
                        Icons.straighten_rounded,
                        type: TextInputType.number),
                  ),
                ]),
                const SizedBox(height: 12),
                _buildField(
                    'Allergies', allergyCtrl, Icons.warning_amber_outlined),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(userServiceProvider).updateProfile(
                              name: nameCtrl.text.trim().isNotEmpty
                                  ? nameCtrl.text.trim()
                                  : null,
                              phone: phoneCtrl.text.trim().isNotEmpty
                                  ? phoneCtrl.text.trim()
                                  : null,
                              bloodType: bloodCtrl.text.trim().isNotEmpty
                                  ? bloodCtrl.text.trim()
                                  : null,
                              weight: weightCtrl.text.trim().isNotEmpty
                                  ? double.tryParse(weightCtrl.text.trim())
                                  : null,
                              height: heightCtrl.text.trim().isNotEmpty
                                  ? double.tryParse(heightCtrl.text.trim())
                                  : null,
                              allergies: allergyCtrl.text.trim().isNotEmpty
                                  ? allergyCtrl.text.trim()
                                  : null,
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  const _StatBadge(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ]);
}

class _HealthInfo extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, fg;
  const _HealthInfo(this.label, this.value, this.icon, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: fg, size: 22),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ]);
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _MenuSection(this.title, this.items);
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4))
            ],
          ),
          child: Column(children: items),
        ),
      ]);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: Theme.of(context).textTheme.labelLarge),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 18),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
}
