import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class WritePrescriptionScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? patientId;
  final String? appointmentId;

  const WritePrescriptionScreen({
    super.key,
    this.patientName,
    this.patientId,
    this.appointmentId,
  });

  @override
  ConsumerState<WritePrescriptionScreen> createState() =>
      _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState
    extends ConsumerState<WritePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Header fields
  final _patientNameCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Medication list
  final List<_MedEntry> _medications = [_MedEntry()];

  // Duration options
  String _duration = '7 days';
  static const _durations = [
    '3 days',
    '5 days',
    '7 days',
    '10 days',
    '14 days',
    '1 month',
    '3 months',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.patientName != null) {
      _patientNameCtrl.text = widget.patientName!;
    }
  }

  @override
  void dispose() {
    _patientNameCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    for (final m in _medications) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medications.every((m) => m.nameCtrl.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one medication'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final doctorUser = ref.read(authStateProvider).value;

      final prescriptionData = {
        'doctorId': doctorUser?.uid ?? '',
        'doctorName': doctorUser?.displayName ?? 'Doctor',
        'patientId': widget.patientId ?? '',
        'patientName': _patientNameCtrl.text.trim(),
        'diagnosis': _diagnosisCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'duration': _duration,
        'medications': _medications
            .where((m) => m.nameCtrl.text.isNotEmpty)
            .map((m) => {
                  'name': m.nameCtrl.text.trim(),
                  'dosage': m.dosageCtrl.text.trim(),
                  'frequency': m.frequency,
                  'instructions': m.instructionsCtrl.text.trim(),
                })
            .toList(),
        'appointmentId': widget.appointmentId ?? '',
        'issuedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      await FirebaseFirestore.instance
          .collection('prescriptions')
          .add(prescriptionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription saved successfully ✓'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Write Prescription'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Prescription header
            _PrescriptionHeader(
              doctorName: user?.displayName ?? 'Doctor',
              date: DateFormat('MMMM d, yyyy').format(DateTime.now()),
            ),
            const SizedBox(height: 16),

            // Patient info
            _buildCard(
              title: 'Patient',
              icon: Icons.person_outlined,
              child: _buildField(
                label: 'Patient Name',
                ctrl: _patientNameCtrl,
                hint: 'Full name of patient',
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Patient name is required' : null,
              ),
            ),
            const SizedBox(height: 12),

            // Diagnosis
            _buildCard(
              title: 'Diagnosis',
              icon: Icons.medical_information_outlined,
              child: Column(
                children: [
                  _buildField(
                    label: 'Diagnosis / Condition',
                    ctrl: _diagnosisCtrl,
                    hint: 'e.g., Upper Respiratory Infection',
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Diagnosis is required' : null,
                  ),
                  const SizedBox(height: 8),
                  // Duration picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Treatment Duration',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _durations.map((d) {
                          final selected = d == _duration;
                          return GestureDetector(
                            onTap: () => setState(() => _duration = d),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.outline,
                                ),
                              ),
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Medications
            Container(
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
                  Row(
                    children: [
                      const Icon(Icons.medication_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Medications',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _medications.add(_MedEntry())),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add',
                            style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.divider, height: 1),
                  ...List.generate(_medications.length, (i) {
                    return _MedicationEntryWidget(
                      entry: _medications[i],
                      index: i,
                      canDelete: _medications.length > 1,
                      onDelete: () =>
                          setState(() => _medications.removeAt(i)),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Additional Notes
            _buildCard(
              title: 'Additional Notes',
              icon: Icons.notes_rounded,
              child: _buildField(
                label: 'Instructions for Patient',
                ctrl: _notesCtrl,
                hint:
                    'e.g., Rest well, drink plenty of fluids, avoid cold foods...',
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save Prescription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    String? hint,
    int maxLines = 1,
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ─── Prescription Header ──────────────────────────────────────────────────────

class _PrescriptionHeader extends StatelessWidget {
  final String doctorName;
  final String date;
  const _PrescriptionHeader(
      {required this.doctorName, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D8A79), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services_rounded,
              color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DARMAN — Prescription',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Dr. $doctorName • $date',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Medication Entry ─────────────────────────────────────────────────────────

class _MedEntry {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController dosageCtrl = TextEditingController();
  final TextEditingController instructionsCtrl = TextEditingController();
  String frequency = 'Once daily';

  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    instructionsCtrl.dispose();
  }
}

class _MedicationEntryWidget extends StatefulWidget {
  final _MedEntry entry;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;

  const _MedicationEntryWidget({
    required this.entry,
    required this.index,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  State<_MedicationEntryWidget> createState() => _MedicationEntryWidgetState();
}

class _MedicationEntryWidgetState extends State<_MedicationEntryWidget> {
  static const _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Every 6 hours',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
    'Before meals',
    'After meals',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Medication',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (widget.canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 18),
                  onPressed: widget.onDelete,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 10),
          _SmallField(
              hint: 'Medicine name (e.g., Amoxicillin)',
              ctrl: widget.entry.nameCtrl),
          const SizedBox(height: 8),
          _SmallField(
              hint: 'Dosage (e.g., 500mg)', ctrl: widget.entry.dosageCtrl),
          const SizedBox(height: 8),
          // Frequency dropdown
          DropdownButtonFormField<String>(
            value: widget.entry.frequency,
            decoration: InputDecoration(
              hintText: 'Frequency',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
            ),
            items: _frequencies
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => widget.entry.frequency = v);
            },
          ),
          const SizedBox(height: 8),
          _SmallField(
              hint: 'Special instructions (optional)',
              ctrl: widget.entry.instructionsCtrl),
        ],
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  const _SmallField({required this.hint, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
