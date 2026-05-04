import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/lab_test_model.dart';
import '../theme/app_colors.dart';

final labTestsProvider = Provider<List<LabTest>>((ref) => [
  LabTest(id: 'lt1', name: 'Complete Blood Count (CBC)', category: 'Blood Tests', description: 'Measures different components of blood', price: 350, duration: '2 hours', reportTime: 'Same day', homeCollection: true, preparation: 'No special preparation needed', includes: ['RBC', 'WBC', 'Platelets', 'Hemoglobin']),
  LabTest(id: 'lt2', name: 'Blood Sugar (Fasting)', category: 'Blood Tests', description: 'Measures blood glucose levels', price: 150, duration: '1 hour', reportTime: 'Same day', homeCollection: true, preparation: 'Fast for 8-12 hours before test'),
  LabTest(id: 'lt3', name: 'Lipid Profile', category: 'Blood Tests', description: 'Measures cholesterol and triglycerides', price: 500, duration: '3 hours', reportTime: 'Same day', homeCollection: true, preparation: 'Fast for 12 hours before test', includes: ['Total Cholesterol', 'HDL', 'LDL', 'Triglycerides']),
  LabTest(id: 'lt4', name: 'Chest X-Ray', category: 'Radiology', description: 'Imaging of chest and lungs', price: 800, duration: '30 minutes', reportTime: '2-4 hours', homeCollection: false),
  LabTest(id: 'lt5', name: 'Abdominal Ultrasound', category: 'Radiology', description: 'Ultrasound imaging of abdominal organs', price: 1200, duration: '45 minutes', reportTime: 'Same day', homeCollection: false),
  LabTest(id: 'lt6', name: 'Urine Analysis', category: 'Urine Tests', description: 'Complete urine examination', price: 200, duration: '1 hour', reportTime: 'Same day', homeCollection: true),
  LabTest(id: 'lt7', name: 'Thyroid Function Test', category: 'Hormone Tests', description: 'Measures thyroid hormone levels', price: 600, duration: '4 hours', reportTime: 'Next day', homeCollection: true, preparation: 'No special preparation needed', includes: ['TSH', 'T3', 'T4']),
  LabTest(id: 'lt8', name: 'COVID-19 PCR Test', category: 'Infectious Disease', description: 'Detects COVID-19 virus', price: 1500, duration: '4-6 hours', reportTime: 'Same day', homeCollection: true),
]);

final selectedLabCategoryProvider = StateProvider<String>((ref) => 'All');
final labSearchQueryProvider = StateProvider<String>((ref) => '');

class LabTestsScreen extends ConsumerWidget {
  const LabTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTests = ref.watch(labTestsProvider);
    final selectedCategory = ref.watch(selectedLabCategoryProvider);
    final searchQuery = ref.watch(labSearchQueryProvider);

    final categories = ['All', ...{...allTests.map((t) => t.category)}];

    final filtered = allTests.where((t) {
      final matchCat = selectedCategory == 'All' || t.category == selectedCategory;
      final matchSearch = searchQuery.isEmpty ||
          t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lab Tests'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => ref.read(labSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search tests...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Categories
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => ref.read(selectedLabCategoryProvider.notifier).state = cat,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Tests list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _LabTestCard(test: filtered[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabTestCard extends StatelessWidget {
  final LabTest test;
  const _LabTestCard({required this.test});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(test.category, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                  ],
                ),
              ),
              Text('${test.price.toInt()} AFN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(Icons.timer_outlined, test.duration),
              const SizedBox(width: 8),
              _InfoChip(Icons.description_outlined, test.reportTime),
              if (test.homeCollection) ...[
                const SizedBox(width: 8),
                _InfoChip(Icons.home_outlined, 'Home collection', color: Colors.green),
              ],
            ],
          ),
          if (test.preparation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('⚠️ ${test.preparation}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking ${test.name}...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Book Test', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: c)),
        ],
      ),
    );
  }
}

