import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviewCount;
  final String? availability;
  final bool isCompact;
  final VoidCallback? onTap;
  final Color avatarBg;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.hospital,
    this.rating = 4.9,
    this.reviewCount = 120,
    this.availability,
    this.isCompact = false,
    this.onTap,
    this.avatarBg = const Color(0xFFE0F5F3),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: isCompact ? 52 : 64,
              height: isCompact ? 52 : 64,
              decoration: BoxDecoration(
                color: avatarBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person, color: AppColors.primary, size: isCompact ? 28 : 36),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('$specialty • $hospital', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                      const SizedBox(width: 4),
                      Text('$rating', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(width: 4),
                      Text('($reviewCount)', style: Theme.of(context).textTheme.bodySmall),
                      if (availability != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(availability!, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
