import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/doctor_card.dart';
import '../widgets/section_header.dart';
import '../services/doctor_service.dart';
import '../services/auth_service.dart';

class HomeScreenApi extends ConsumerStatefulWidget {
  const HomeScreenApi({super.key});
  @override
  ConsumerState<HomeScreenApi> createState() => _HomeScreenApiState();
}

class _HomeScreenApiState extends ConsumerState<HomeScreenApi> {
  int _selectedCategory = 0;
  final _categories = ['All', 'Cardiologist', 'Dermatologist', 'Pediatrician', 'Neurologist', 'Orthopedic'];

  @override
  Widget build(BuildContext context) {
    // Use Firestore stream — live updates from doctors collection
    final doctorsAsyncValue = ref.watch(verifiedDoctorsProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 20,
              ),
              decoration: const BoxDecoration(color: AppColors.surface),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good Morning,', style: Theme.of(context).textTheme.bodyMedium),
                          authState.when(
                            data: (user) => Text(
                              user?.displayName ?? 'HealthLink User 👋',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            loading: () => const Text('Loading...'),
                            error: (_, _) => const Text('User 👋'),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textHint),
                          const SizedBox(width: 10),
                          Text(
                            'Search doctor, specialty, clinic...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Promo Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Find Your Doctor',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Book appointments with verified doctors across Afghanistan',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.push('/doctors'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text('Browse Doctors'),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.medical_services, color: Colors.white, size: 80),
                  ],
                ),
              ),
            ),
          ),

          // Quick Services Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Services',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [
                      _QuickServiceTile(
                        icon: Icons.health_and_safety_rounded,
                        label: 'Symptom\nChecker',
                        color: const Color(0xFFE53935),
                        onTap: () => context.push('/symptom_checker'),
                      ),
                      _QuickServiceTile(
                        icon: Icons.smart_toy_rounded,
                        label: 'AI Health\nAssistant',
                        color: const Color(0xFF7C4DFF),
                        onTap: () => context.push('/ai_chat'),
                      ),
                      _QuickServiceTile(
                        icon: Icons.local_hospital_rounded,
                        label: 'Find\nDoctors',
                        color: AppColors.primary,
                        onTap: () => context.push('/doctors'),
                      ),
                      _QuickServiceTile(
                        icon: Icons.calendar_month_rounded,
                        label: 'My\nAppointments',
                        color: const Color(0xFFFF9800),
                        onTap: () => context.push('/appointments'),
                      ),
                      _QuickServiceTile(
                        icon: Icons.folder_shared_rounded,
                        label: 'Health\nRecords',
                        color: const Color(0xFF00BFA5),
                        onTap: () => context.push('/health_records'),
                      ),
                      _QuickServiceTile(
                        icon: Icons.receipt_long_rounded,
                        label: 'My\nPrescriptions',
                        color: const Color(0xFF5C6BC0),
                        onTap: () => context.push('/prescriptions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = index);
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Section Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SectionHeader(title: 'Top Doctors'),
            ),
          ),

          // Doctors List from API
          doctorsAsyncValue.when(
            data: (doctors) {
              // Filter by selected category
              final filteredDoctors = _selectedCategory == 0
                  ? doctors
                  : doctors.where((d) => d.specialty
                      .toLowerCase()
                      .contains(_categories[_selectedCategory].toLowerCase())).toList();

              if (filteredDoctors.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.medical_services_outlined, size: 64, color: AppColors.textHint),
                          SizedBox(height: 16),
                          Text(
                            'No doctors found',
                            style: TextStyle(fontSize: 16, color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doctor = filteredDoctors[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DoctorCard(
                          name: doctor.name,
                          specialty: doctor.specialty,
                          hospital: doctor.hospital ?? '',
                          rating: doctor.rating,
                          reviewCount: doctor.reviewCount,
                          onTap: () => context.push('/doctor_profile', extra: doctor),
                        ),
                      );
                    },
                    childCount: filteredDoctors.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading doctors',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(verifiedDoctorsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickServiceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
