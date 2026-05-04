import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/doctor_card.dart';
import '../services/doctor_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  int _selectedFilter = 0;

  final _filters = [
    'All',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedics',
    'General',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use search query if present, otherwise filter by specialty
    final selectedSpecialty = _filters[_selectedFilter];
    final provider = _query.trim().isNotEmpty
        ? doctorSearchProvider(_query.trim())
        : doctorsBySpecialtyProvider(selectedSpecialty);

    final doctorsAsync = ref.watch(provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Doctors'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: AppColors.surface,
            child: TextField(
              controller: _ctrl,
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search doctor, specialty, hospital...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.textHint),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Specialty filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ChoiceChip(
                label: Text(_filters[i]),
                selected: _selectedFilter == i,
                onSelected: (_) => setState(() {
                  _selectedFilter = i;
                  _query = '';
                  _ctrl.clear();
                }),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _selectedFilter == i
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                backgroundColor: AppColors.surfaceVariant,
                side: BorderSide.none,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Results
          Expanded(
            child: doctorsAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 60,
                            color: AppColors.textHint.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('No results found',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Try a different search term',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
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
                      rating: d.rating > 0 ? d.rating : 4.8,
                      reviewCount: d.reviewCount > 0 ? d.reviewCount : 0,
                      availability: 'Available Today',
                      onTap: () => context.push('/doctor_profile', extra: d),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
