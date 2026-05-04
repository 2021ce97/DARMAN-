import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  final _faqs = const [
    {'q': 'How do I book an appointment?', 'a': 'Navigate to the Home screen, tap on a doctor card, select your preferred date and time, and tap "Book Appointment".'},
    {'q': 'Can I cancel or reschedule?', 'a': 'Yes! Go to My Appointments, select the appointment, and choose "Reschedule" or "Cancel". Cancellations are free up to 24 hours before.'},
    {'q': 'How are my health records secured?', 'a': 'All records are encrypted end-to-end using AES-256 encryption and stored in a secure digital vault accessible only by you.'},
    {'q': 'What payment methods are accepted?', 'a': 'We accept credit/debit cards, Apple Pay, Google Pay, and select mobile wallets.'},
    {'q': 'Can I video consult with a doctor?', 'a': 'Yes! Many doctors on HealthLink offer video consultations. Look for the "Video Available" badge on their profile.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Help & Support'), backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Support Options
          Row(children: [
            Expanded(child: _SupportCard(icon: Icons.chat_bubble_outline_rounded, label: 'Live Chat', color: AppColors.primaryLight, iconColor: AppColors.primary, onTap: () {})),
            const SizedBox(width: 12),
            Expanded(child: _SupportCard(icon: Icons.phone_outlined, label: 'Call Us', color: const Color(0xFFFFEDE6), iconColor: AppColors.secondary, onTap: () {})),
            const SizedBox(width: 12),
            Expanded(child: _SupportCard(icon: Icons.email_outlined, label: 'Email', color: const Color(0xFFE3F2FD), iconColor: Colors.blue, onTap: () {})),
          ]),
          const SizedBox(height: 24),

          Text('Frequently Asked Questions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...(_faqs.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Container(
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3))]),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(f['q']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.textHint,
                  children: [Text(f['a']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5))],
                ),
              ),
            ),
          ))).toList(),
          const SizedBox(height: 24),

          // Contact Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              const Text('Still need help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('Our support team is available 24/7 to assist you.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Text('Contact Support', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor;
  final VoidCallback onTap;
  const _SupportCard({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3))]),
      child: Column(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 24)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    ),
  );
}
