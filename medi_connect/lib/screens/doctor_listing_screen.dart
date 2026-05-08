import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/doctor_card.dart';
import '../services/doctor_service.dart';

class DoctorListingScreen extends ConsumerStatefulWidget {
  const DoctorListingScreen({super.key});
  @override
  ConsumerState<DoctorListingScreen> createState() => _DoctorListingScreenState();
}

class _DoctorListingScreenState extends ConsumerState<DoctorListingScreen> {
  int _sort = 0;
  final _sortOptions = ['Rating', 'Experience', 'Availability'];

  @override
  Widget build(BuildContext context) {
    final doctorsAsyncValue = ref.watch(verifiedDoctorsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Top Doctors'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {})],
      ),
      body: Column(children: [
        // Sort Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.surface,
          child: Row(children: [
            const Text('Sort by:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(width: 10),
            ..._sortOptions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _sort = e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _sort == e.key ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _sort == e.key ? Colors.white : AppColors.textSecondary)),
                ),
              ),
            )),
          ]),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(
          child: doctorsAsyncValue.when(
            data: (doctors) {
              if (doctors.isEmpty) {
                return const Center(
                  child: Text('No verified doctors found.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final d = doctors[i];
                  return DoctorCard(
                    name: d.name,
                    specialty: d.specialty,
                    hospital: d.hospital ?? d.city,
                    rating: d.rating,
                    reviewCount: d.reviewCount,
                    availability: d.isAvailableOnline ? 'Online Available' : 'Clinic Only',
                    onTap: () => context.push('/doctor_profile', extra: d),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ]),
    );
  }
}
