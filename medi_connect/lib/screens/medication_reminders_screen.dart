import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../theme/app_colors.dart';

class MedicationItem {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final String frequency;
  final String duration;
  final bool isActive;
  final Color color;

  const MedicationItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.frequency,
    required this.duration,
    this.isActive = true,
    this.color = AppColors.primary,
  });
}

final medicationsProvider = StateProvider<List<MedicationItem>>((ref) => [
  MedicationItem(id: '1', name: 'Paracetamol', dosage: '500mg', times: ['8:00 AM', '2:00 PM', '9:00 PM'], frequency: '3x daily', duration: '5 days', color: Colors.orange),
  MedicationItem(id: '2', name: 'Vitamin D3', dosage: '1000 IU', times: ['12:00 PM'], frequency: 'Once daily', duration: '30 days', color: Colors.amber),
  MedicationItem(id: '3', name: 'Amlodipine', dosage: '5mg', times: ['9:00 PM'], frequency: 'Once daily', duration: 'Ongoing', color: AppColors.primary),
]);

class MedicationRemindersScreen extends ConsumerWidget {
  const MedicationRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medication Reminders'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicationSheet(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Medication', style: TextStyle(color: Colors.white)),
      ),
      body: medications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medications.length,
              itemBuilder: (context, index) => _MedicationCard(
                medication: medications[index],
                onDelete: () {
                  final updated = [...medications];
                  updated.removeAt(index);
                  ref.read(medicationsProvider.notifier).state = updated;
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medication_outlined, size: 72, color: AppColors.outline),
          const SizedBox(height: 16),
          const Text('No medications added', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Add your medications to get reminders', style: TextStyle(color: AppColors.textHint)),
        ],
      ),
    );
  }

  void _showAddMedicationSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Medication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dosageCtrl,
              decoration: InputDecoration(
                labelText: 'Dosage (e.g., 500mg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              decoration: InputDecoration(
                labelText: 'Duration (e.g., 7 days)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    final newMed = MedicationItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text,
                      dosage: dosageCtrl.text,
                      times: ['8:00 AM'],
                      frequency: 'Once daily',
                      duration: durationCtrl.text.isEmpty ? 'Ongoing' : durationCtrl.text,
                    );
                    ref.read(medicationsProvider.notifier).state = [
                      ...ref.read(medicationsProvider),
                      newMed,
                    ];
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Medication added'), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Medication', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final MedicationItem medication;
  final VoidCallback onDelete;

  const _MedicationCard({required this.medication, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: medication.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.medication_rounded, color: medication.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${medication.dosage} • ${medication.frequency}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: medication.times.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: medication.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 11, color: medication.color, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textHint),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

