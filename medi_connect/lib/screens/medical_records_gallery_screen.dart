import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/file_card.dart';
import 'file_upload_screen.dart';

enum RecordCategory { all, labReports, prescriptions, imaging, other }

class MedicalRecord {
  final String id;
  final String name;
  final String category;
  final String fileType; // 'pdf', 'image'
  final String? thumbnailUrl;
  final int fileSizeKb;
  final DateTime uploadedAt;
  final String? sharedWith;

  const MedicalRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.fileType,
    this.thumbnailUrl,
    required this.fileSizeKb,
    required this.uploadedAt,
    this.sharedWith,
  });
}

class MedicalRecordsGalleryScreen extends StatefulWidget {
  const MedicalRecordsGalleryScreen({super.key});

  @override
  State<MedicalRecordsGalleryScreen> createState() =>
      _MedicalRecordsGalleryScreenState();
}

class _MedicalRecordsGalleryScreenState
    extends State<MedicalRecordsGalleryScreen> {
  RecordCategory _selectedCategory = RecordCategory.all;
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<MedicalRecord> _records = [
    MedicalRecord(
      id: 'r1',
      name: 'Blood Test Report - CBC',
      category: 'Lab Reports',
      fileType: 'pdf',
      fileSizeKb: 245,
      uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
      sharedWith: 'Dr. Fatima Ahmadi',
    ),
    MedicalRecord(
      id: 'r2',
      name: 'Chest X-Ray',
      category: 'Imaging',
      fileType: 'image',
      fileSizeKb: 1240,
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    MedicalRecord(
      id: 'r3',
      name: 'Prescription - Dr. Hassan',
      category: 'Prescriptions',
      fileType: 'pdf',
      fileSizeKb: 89,
      uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
      sharedWith: 'Dr. Mohammad Hassan',
    ),
    MedicalRecord(
      id: 'r4',
      name: 'Ultrasound Report',
      category: 'Imaging',
      fileType: 'pdf',
      fileSizeKb: 512,
      uploadedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    MedicalRecord(
      id: 'r5',
      name: 'Thyroid Function Test',
      category: 'Lab Reports',
      fileType: 'pdf',
      fileSizeKb: 178,
      uploadedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    MedicalRecord(
      id: 'r6',
      name: 'Vaccination Certificate',
      category: 'Other',
      fileType: 'image',
      fileSizeKb: 320,
      uploadedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  List<MedicalRecord> get _filteredRecords {
    var list = _records;

    if (_selectedCategory != RecordCategory.all) {
      final categoryName = _categoryName(_selectedCategory);
      list = list.where((r) => r.category == categoryName).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) => r.name.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  String _categoryName(RecordCategory cat) {
    switch (cat) {
      case RecordCategory.labReports:
        return 'Lab Reports';
      case RecordCategory.prescriptions:
        return 'Prescriptions';
      case RecordCategory.imaging:
        return 'Imaging';
      case RecordCategory.other:
        return 'Other';
      default:
        return 'All';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadRecord,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search records...',
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

          // Category tabs
          Container(
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: RecordCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final label = cat == RecordCategory.all
                      ? 'All'
                      : _categoryName(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${records.length} file${records.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Records
          Expanded(
            child: records.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildGridView(records)
                    : _buildListView(records),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<MedicalRecord> records) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) => FileCard(
        record: records[index],
        isGrid: true,
        onTap: () => _viewRecord(records[index]),
        onDelete: () => _deleteRecord(records[index]),
        onShare: () => _shareRecord(records[index]),
      ),
    );
  }

  Widget _buildListView(List<MedicalRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) => FileCard(
        record: records[index],
        isGrid: false,
        onTap: () => _viewRecord(records[index]),
        onDelete: () => _deleteRecord(records[index]),
        onShare: () => _shareRecord(records[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 72, color: AppColors.outline),
          const SizedBox(height: 16),
          const Text(
            'No records found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your medical records to keep them organized',
            style: TextStyle(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _uploadRecord,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _uploadRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FileUploadScreen()),
    ).then((result) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _viewRecord(MedicalRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${record.name}...')),
    );
  }

  void _deleteRecord(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Delete "${record.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _records.removeWhere((r) => r.id == record.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareRecord(MedicalRecord record) {
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
            Text(
              'Share "${record.name}"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primary),
              title: const Text('Share with Doctor'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shared with your doctor')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: const Text('Copy Share Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: AppColors.primary),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
