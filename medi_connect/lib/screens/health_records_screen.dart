import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Security Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1AAB97), Color(0xFF006B5D)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Secure Digital Vault', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('Your records are encrypted & private', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ])),
                const Icon(Icons.verified_rounded, color: Colors.white70),
              ]),
            ),
          ),

          // Upload Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                label: 'Upload New Record',
                icon: Icons.upload_rounded,
                onPressed: () => _showUploadDialog(context, user?.uid),
              ),
            ),
          ),

          if (user == null)
            const SliverFillRemaining(child: Center(child: Text('Please log in to view records')))
          else
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prescriptions')
                  .where('patientId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 80, color: AppColors.textHint.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          const Text('Your Vault is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Records from your doctors will appear here.', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
                        final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                        final isUserUpload = data['isUserUpload'] == true;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3))]
                            ),
                            child: Row(children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: isUserUpload ? const Color(0xFFE0F2FE) : const Color(0xFFFFEDE6),
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Icon(
                                  isUserUpload ? Icons.file_present_rounded : Icons.description_rounded,
                                  color: isUserUpload ? AppColors.primary : AppColors.secondary,
                                  size: 26
                                )
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  isUserUpload ? data['diagnosis'] : 'Prescription: ${data['diagnosis'] ?? 'Checkup'}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isUserUpload
                                    ? '${data['category'] ?? 'General'} • ${DateFormat('MMM dd, yyyy').format(date)}'
                                    : 'Dr. ${data['doctorName']} • ${DateFormat('MMM dd, yyyy').format(date)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textHint)
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isUserUpload ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Text(
                                    isUserUpload ? 'Self Uploaded' : 'Verified Prescription',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isUserUpload ? AppColors.primary : AppColors.textSecondary
                                    )
                                  )
                                ),
                              ])),
                              if (!isUserUpload)
                                IconButton(icon: const Icon(Icons.visibility_rounded, color: AppColors.primary), onPressed: () => _showPrescriptionDetails(context, data)),
                            ]),
                          ),
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    final titleController = TextEditingController();
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Health Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Record Title',
                hintText: 'e.g., Blood Test Report',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g., Lab Report, X-Ray',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.file_present_rounded, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Select File (PDF, Image)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;

              // In a real app, we would upload to Firebase Storage
              // Here we just save the metadata to prescriptions collection as a "user record"
              await FirebaseFirestore.instance.collection('prescriptions').add({
                'patientId': userId,
                'doctorName': 'Self Uploaded',
                'diagnosis': titleController.text,
                'category': typeController.text,
                'createdAt': FieldValue.serverTimestamp(),
                'medicines': [],
                'isUserUpload': true,
              });

              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Record uploaded successfully!')),
                );
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_rounded, color: AppColors.primary, size: 30),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Medical Prescription', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('By Dr. ${data['doctorName']}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text('DIAGNOSIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textHint)),
                  const SizedBox(height: 8),
                  Text(data['diagnosis'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  const Text('MEDICINES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textHint)),
                  const SizedBox(height: 12),
                  ...(data['medicines'] as List? ?? []).map((med) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Dosage: ${med['dosage']} | Duration: ${med['duration']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        if (med['instructions'] != null && med['instructions'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Note: ${med['instructions']}', style: TextStyle(color: Colors.orange[800], fontSize: 13, fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
