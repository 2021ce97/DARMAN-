import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  ConsumerState<DoctorRegisterScreen> createState() =>
      _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState
    extends ConsumerState<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _page = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Page 1
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Page 2
  final _specialtyCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  static const _specialties = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedic Surgeon',
    'Pediatrician',
    'Psychiatrist',
    'Ophthalmologist',
    'ENT Specialist',
    'Gynecologist',
    'Urologist',
    'Oncologist',
    'Radiologist',
    'Endocrinologist',
    'Pulmonologist',
    'Gastroenterologist',
    'Rheumatologist',
    'Dentist',
    'Other',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _specialtyCtrl.dispose();
    _regNoCtrl.dispose();
    _hospitalCtrl.dispose();
    _cityCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _page = 1);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create Firebase Auth user
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      await cred.user!.updateDisplayName(_nameCtrl.text.trim());

      final uid = cred.user!.uid;
      final now = FieldValue.serverTimestamp();

      final doctorData = {
        'uid': uid,
        'userId': uid, // Required by Firestore security rules
        'name': _nameCtrl.text.trim(),
        'fullName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'regNo': _regNoCtrl.text.trim(),
        'hospital': _hospitalCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'province': _cityCtrl.text.trim(),
        'experienceYears': int.tryParse(_expCtrl.text) ?? 0,
        'role': 'doctor',
        'status': 'Pending', // Admin must verify
        'rating': 0.0,
        'reviewCount': 0,
        'fee': 500.0,
        'availableDays': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        'workingHoursStart': '09:00',
        'workingHoursEnd': '17:00',
        'languages': ['Dari', 'Pashto'],
        'qualifications': [],
        'isAvailableOnline': false,
        'createdAt': now,
        'updatedAt': now,
      };

      // Save to doctors collection
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .set(doctorData);

      // Save to users collection with doctor role
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': 'doctor',
        'status': 'active',
        'createdAt': now,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.verified_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Registration Submitted'),
              ],
            ),
            content: const Text(
              'Your doctor profile has been submitted for verification. '
              'You can start using the app while the admin reviews your credentials.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/doctor');
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authErrorMessage(e.code)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Progress indicator
              _buildProgressBar(),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D8A79), AppColors.primary],
        ),
      ),
      child: Row(
        children: [
          if (_page == 1)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
                setState(() => _page = 0);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => context.go('/login'),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _page == 0 ? 'Create Doctor Account' : 'Professional Info',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _page == 0
                      ? 'Step 1 of 2 — Personal details'
                      : 'Step 2 of 2 — Credentials',
                  style:
                      TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.medical_services_rounded,
              color: Colors.white70, size: 28),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: _page == 0 ? 0.5 : 1.0,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldGroup(
            title: 'Account Details',
            children: [
              _buildFormField(
                label: 'Full Name',
                ctrl: _nameCtrl,
                hint: 'Dr. Ahmad Karimi',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
              ),
              _buildFormField(
                label: 'Email Address',
                ctrl: _emailCtrl,
                hint: 'doctor@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v?.contains('@') ?? false)
                    ? null
                    : 'Enter a valid email',
              ),
              _buildFormField(
                label: 'Phone Number',
                ctrl: _phoneCtrl,
                hint: '+93 700 000 000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Phone is required' : null,
              ),
              _buildFormField(
                label: 'Password',
                ctrl: _passwordCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (v) => (v?.length ?? 0) < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _nextPage,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue to Step 2'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'Already have an account? Sign in',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldGroup(
            title: 'Professional Credentials',
            children: [
              // Specialty dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical Specialty',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _specialtyCtrl.text.isEmpty
                        ? null
                        : _specialtyCtrl.text,
                    hint: const Text('Select specialty'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon: const Icon(Icons.medical_information_outlined,
                          color: AppColors.textHint),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.outline),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                    items: _specialties
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _specialtyCtrl.text = v;
                    },
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Select a specialty' : null,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
              _buildFormField(
                label: 'Medical Registration Number',
                ctrl: _regNoCtrl,
                hint: 'e.g., MED-12345-KBL',
                icon: Icons.badge_outlined,
                validator: (v) => (v?.trim().isEmpty ?? true)
                    ? 'Registration number is required'
                    : null,
              ),
              _buildFormField(
                label: 'Hospital / Clinic',
                ctrl: _hospitalCtrl,
                hint: 'Wazir Akbar Khan Hospital',
                icon: Icons.local_hospital_outlined,
              ),
              _buildFormField(
                label: 'City',
                ctrl: _cityCtrl,
                hint: 'Kabul',
                icon: Icons.location_city_outlined,
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'City is required' : null,
              ),
              _buildFormField(
                label: 'Years of Experience',
                ctrl: _expCtrl,
                hint: '5',
                icon: Icons.work_history_outlined,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFFF59E0B), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your account will be reviewed by admin before you can see patients.',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _register,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.how_to_reg_rounded),
              label:
                  Text(_isLoading ? 'Creating Account...' : 'Create Doctor Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController ctrl,
    String? hint,
    IconData? icon,
    bool isPassword = false,
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
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textHint, size: 20)
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
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
                horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _FieldGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FieldGroup({required this.title, required this.children});

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
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
