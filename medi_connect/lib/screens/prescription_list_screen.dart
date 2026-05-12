import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../theme/app_colors.dart';
import '../widgets/prescription_card.dart';
import 'prescription_detail_screen.dart';

class PrescriptionListScreen extends StatefulWidget {
  const PrescriptionListScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'This Month', 'Last 3 Months', 'This Year'];

  // Mock prescriptions for UI demonstration
  final List<PrescriptionModel> _mockPrescriptions = [
    PrescriptionModel(
      id: 'rx001',
      patientId: 'p1',
      patientName: 'Ahmad Karimi',
      doctorId: 'd1',
      doctorName: 'Dr. Fatima Ahmadi',
      appointmentId: 'apt001',
      diagnosis: 'Upper Respiratory Tract Infection',
      medicines: [
        Medicine(name: 'Amoxicillin', dosage: '500mg', duration: '7 days', instructions: 'Take after meals'),
        Medicine(name: 'Paracetamol', dosage: '500mg', duration: '3 days', instructions: 'Take when needed for fever'),
        Medicine(name: 'Vitamin C', dosage: '1000mg', duration: '14 days', instructions: 'Take once daily'),
      ],
      notes: 'Rest well and drink plenty of fluids. Follow up in 1 week if symptoms persist.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PrescriptionModel(
      id: 'rx002',
      patientId: 'p1',
      patientName: 'Ahmad Karimi',
      doctorId: 'd2',
      doctorName: 'Dr. Mohammad Hassan',
      appointmentId: 'apt002',
      diagnosis: 'Hypertension - Follow-up',
      medicines: [
        Medicine(name: 'Amlodipine', dosage: '5mg', duration: '30 days', instructions: 'Take once daily in the morning'),
        Medicine(name: 'Losartan', dosage: '50mg', duration: '30 days', instructions: 'Take once daily'),
      ],
      notes: 'Monitor blood pressure daily. Reduce salt intake.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    PrescriptionModel(
      id: 'rx003',
      patientId: 'p1',
      patientName: 'Ahmad Karimi',
      doctorId: 'd3',
      doctorName: 'Dr. Laila Noori',
      appointmentId: 'apt003',
      diagnosis: 'Vitamin D Deficiency',
      medicines: [
        Medicine(name: 'Vitamin D3', dosage: '50,000 IU', duration: '8 weeks', instructions: 'Take once weekly'),
        Medicine(name: 'Calcium Carbonate', dosage: '500mg', duration: '60 days', instructions: 'Take twice daily with meals'),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  List<PrescriptionModel> get _filteredPrescriptions {
    var list = _mockPrescriptions;

    // Apply date filter
    final now = DateTime.now();
    if (_selectedFilter == 'This Month') {
      list = list.where((p) =>
        p.createdAt.year == now.year && p.createdAt.month == now.month
      ).toList();
    } else if (_selectedFilter == 'Last 3 Months') {
      final cutoff = now.subtract(const Duration(days: 90));
      list = list.where((p) => p.createdAt.isAfter(cutoff)).toList();
    } else if (_selectedFilter == 'This Year') {
      list = list.where((p) => p.createdAt.year == now.year).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
        p.doctorName.toLowerCase().contains(q) ||
        p.diagnosis.toLowerCase().contains(q) ||
        p.medicines.any((m) => m.name.toLowerCase().contains(q))
      ).toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prescriptions = _filteredPrescriptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Prescriptions'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by doctor, diagnosis, or medicine...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Filter chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${prescriptions.length} prescription${prescriptions.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Prescription list
          Expanded(
            child: prescriptions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription = prescriptions[index];
                      return PrescriptionCard(
                        prescription: prescription,
                        onTap: () => _openDetail(prescription),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 72,
            color: AppColors.outline,
          ),
          const SizedBox(height: 16),
          const Text(
            'No prescriptions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Your prescriptions will appear here',
            style: const TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  void _openDetail(PrescriptionModel prescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionDetailScreen(prescription: prescription),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Prescriptions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._filters.map((filter) => RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _selectedFilter = v!);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
