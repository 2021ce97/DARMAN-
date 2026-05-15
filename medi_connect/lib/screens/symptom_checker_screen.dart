import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final List<String> _selectedSymptoms = [];
  String? _result;

  final Map<String, List<String>> _symptomsMap = {
    'Common Symptoms': ['Fever', 'Cough', 'Headache', 'Sore Throat', 'Fatigue'],
    'Digestive': ['Stomach Pain', 'Nausea', 'Diarrhea', 'Loss of Appetite'],
    'Respiratory': ['Shortness of Breath', 'Chest Pain', 'Congestion'],
    'Skin & Body': ['Rash', 'Itching', 'Muscle Pain', 'Joint Pain'],
  };

  void _analyzeSymptoms() {
    // This is a Triage Assistant, not a diagnostic tool.
    // It recommends the correct DOCTOR SPECIALTY based on symptoms.
    if (_selectedSymptoms.isEmpty) return;

    String recommendation = "";
    if (_selectedSymptoms.any((s) => ['Chest Pain', 'Shortness of Breath'].contains(s))) {
      recommendation = "URGENT: Please visit a Cardiologist or Emergency Room immediately.";
    } else if (_selectedSymptoms.any((s) => ['Fever', 'Cough', 'Sore Throat'].contains(s))) {
      recommendation = "Recommendation: Consult a General Physician or Pulmonologist.";
    } else if (_selectedSymptoms.any((s) => ['Stomach Pain', 'Nausea'].contains(s))) {
      recommendation = "Recommendation: Consult a Gastroenterologist.";
    } else if (_selectedSymptoms.any((s) => ['Rash', 'Itching'].contains(s))) {
      recommendation = "Recommendation: Consult a Dermatologist.";
    } else {
      recommendation = "Recommendation: Consult a General Physician for a full checkup.";
    }

    setState(() {
      _result = recommendation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('AI Symptom Assistant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This tool helps you find the right specialist. It is NOT a medical diagnosis.',
                      style: TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('What symptoms are you experiencing?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Select all that apply to receive a recommendation.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            ..._symptomsMap.entries.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: entry.value.map((symptom) {
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return FilterChip(
                      label: Text(symptom),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          val ? _selectedSymptoms.add(symptom) : _selectedSymptoms.remove(symptom);
                          _result = null;
                        });
                      },
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3))),
                    );
                  }).toList(),
                ),
              ],
            )),

            if (_result != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _result!.contains('URGENT') ? AppColors.error.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _result!.contains('URGENT') ? AppColors.error.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(_result!.contains('URGENT') ? Icons.warning_rounded : Icons.check_circle_rounded, color: _result!.contains('URGENT') ? AppColors.error : AppColors.primary, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      _result!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _result!.contains('URGENT') ? AppColors.error : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Find Recommended Doctors',
                      onPressed: () {
                        // Extract specialty from result
                        String specialty = '';
                        if (_result!.contains('Cardiologist')) {
                          specialty = 'Cardiologist';
                        } else if (_result!.contains('General Physician')) specialty = 'General Physician';
                        else if (_result!.contains('Gastroenterologist')) specialty = 'Gastroenterologist';
                        else if (_result!.contains('Dermatologist')) specialty = 'Dermatologist';
                        else if (_result!.contains('Pulmonologist')) specialty = 'Pulmonologist';

                        // Navigate to doctor listing with specialty filter
                        context.push('/doctors', extra: {'specialty': specialty});
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _result == null ? Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
        child: PrimaryButton(
          label: 'Analyze Symptoms',
          onPressed: _selectedSymptoms.isEmpty ? null : _analyzeSymptoms,
        ),
      ) : null,
    );
  }
}
