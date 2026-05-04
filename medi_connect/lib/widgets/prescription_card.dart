import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prescription_model.dart';
import '../theme/app_colors.dart';

class PrescriptionCard extends StatelessWidget {
  final PrescriptionModel prescription;
  final VoidCallback? onTap;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medication, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prescription.diagnosis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prescription.doctorName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(prescription.createdAt),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Medicines
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: prescription.medicines.take(3).map((med) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outline.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${med.name} ${med.dosage}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  );
                }).toList(),
              ),
              if (prescription.medicines.length > 3) ...[
                const SizedBox(height: 6),
                Text(
                  '+${prescription.medicines.length - 3} more medicines',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
