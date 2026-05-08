import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class DoctorProfileEditScreen extends ConsumerStatefulWidget {
  const DoctorProfileEditScreen({super.key});

  @override
  ConsumerState<DoctorProfileEditScreen> createState() =>
      _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState
    extends ConsumerState<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  bool _isAvailableOnline = false;
  List<String> _availableDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  String _workStart = '09:00';
  String _workEnd = '17:00';

  final _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specialtyCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    _hospitalCtrl.dispose();
    _cityCtrl.dispose();
    _feeCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .get();

      if (doc.exists) {
        final d = doc.data()!;
        _nameCtrl.text = d['name'] ?? d['fullName'] ?? '';
        _specialtyCtrl.text = d['specialty'] ?? '';
        _bioCtrl.text = d['bio'] ?? '';
        _phoneCtrl.text = d['phone'] ?? '';
        _hospitalCtrl.text = d['hospital'] ?? '';
        _cityCtrl.text = d['city'] ?? '';
        _feeCtrl.text = '${d['fee'] ?? 500}';
        _expCtrl.text = '${d['experienceYears'] ?? 0}';
        _isAvailableOnline = d['isAvailableOnline'] ?? false;
        _availableDays = List<String>.from(
            d['availableDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
        _workStart = d['workingHoursStart'] ?? '09:00';
        _workEnd = d['workingHoursEnd'] ?? '17:00';
      } else {
        // Prefill name from Firebase Auth
        final user = ref.read(authStateProvider).value;
        _nameCtrl.text = user?.displayName ?? '';
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'hospital': _hospitalCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'fee': double.tryParse(_feeCtrl.text) ?? 500,
        'experienceYears': int.tryParse(_expCtrl.text) ?? 0,
        'isAvailableOnline': _isAvailableOnline,
        'availableDays': _availableDays,
        'workingHoursStart': _workStart,
        'workingHoursEnd': _workEnd,
        'role': 'doctor',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      // Also update users collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameCtrl.text.trim(),
        'role': 'doctor',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully ✓'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar header
              _buildAvatarHeader(user?.displayName ?? 'Doctor', user?.email),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Info Card
                    _SectionCard(
                      title: 'Personal Information',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _buildField('Full Name', _nameCtrl,
                            hint: 'Dr. Ahmad Karimi',
                            validator: (v) => (v?.isEmpty ?? true)
                                ? 'Name is required'
                                : null),
                        _buildField('Specialty', _specialtyCtrl,
                            hint: 'Cardiologist',
                            validator: (v) => (v?.isEmpty ?? true)
                                ? 'Specialty is required'
                                : null),
                        _buildField('Phone Number', _phoneCtrl,
                            hint: '+93 700 000 000',
                            keyboardType: TextInputType.phone),
                        _buildField('Hospital / Clinic', _hospitalCtrl,
                            hint: 'Wazir Akbar Khan Hospital'),
                        _buildField('City', _cityCtrl, hint: 'Kabul'),
                        _buildField('Bio', _bioCtrl,
                            hint: 'Write a short bio...',
                            maxLines: 3),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Professional Info Card
                    _SectionCard(
                      title: 'Professional Details',
                      icon: Icons.work_outline_rounded,
                      children: [
                        _buildField(
                          'Consultation Fee (AFN)',
                          _feeCtrl,
                          hint: '500',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return null;
                            if (double.tryParse(v!) == null) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        _buildField(
                          'Years of Experience',
                          _expCtrl,
                          hint: '5',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Availability Card
                    _SectionCard(
                      title: 'Availability',
                      icon: Icons.schedule_rounded,
                      children: [
                        // Online toggle
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'Available for Online Consultation',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            subtitle: const Text(
                              'Patients can book video calls',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textHint),
                            ),
                            value: _isAvailableOnline,
                            onChanged: (v) =>
                                setState(() => _isAvailableOnline = v),
                            activeColor: AppColors.primary,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Available days
                        const Text(
                          'Working Days',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allDays.map((day) {
                            final selected = _availableDays.contains(day);
                            return FilterChip(
                              label: Text(day),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _availableDays.add(day);
                                  } else {
                                    _availableDays.remove(day);
                                  }
                                });
                              },
                              selectedColor: AppColors.primaryLight,
                              checkmarkColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Working hours
                        const Text(
                          'Working Hours',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _TimePickerTile(
                                label: 'From',
                                value: _workStart,
                                onChanged: (v) =>
                                    setState(() => _workStart = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TimePickerTile(
                                label: 'To',
                                value: _workEnd,
                                onChanged: (v) =>
                                    setState(() => _workEnd = v),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarHeader(String name, String? email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D8A79), AppColors.primary],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white24,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'D',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dr. $name',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          if (email != null) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🩺 Doctor',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
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
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ─── Time Picker Tile ─────────────────────────────────────────────────────────

class _TimePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TimePickerTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final parts = value.split(':');
        final initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );
        if (picked != null) {
          onChanged(
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
