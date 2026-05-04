import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Summary'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Doctor Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]),
            child: Row(children: [
              Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 36)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Dr. James Wilson', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Cardiologist • City Hospital', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Row(children: const [Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14), SizedBox(width: 4), Text('4.9  (128 reviews)', style: TextStyle(fontSize: 12, color: AppColors.textHint))]),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Appointment Details
          _Card(child: Column(children: [
            _Row(icon: Icons.calendar_today_rounded, label: 'Date', value: 'Monday, Oct 28, 2026'),
            const Divider(height: 20, color: AppColors.divider),
            _Row(icon: Icons.access_time_rounded, label: 'Time', value: '09:00 AM – 09:30 AM'),
            const Divider(height: 20, color: AppColors.divider),
            _Row(icon: Icons.location_on_rounded, label: 'Location', value: 'City Hospital, Cardiology Wing'),
          ])),
          const SizedBox(height: 16),

          // Patient Details
          Text('Patient Details', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          _Card(child: Column(children: [
            _DetailRow(label: 'Full Name', value: 'John Doe'),
            const Divider(height: 16, color: AppColors.divider),
            _DetailRow(label: 'Age', value: '32 Years'),
            const Divider(height: 16, color: AppColors.divider),
            _DetailRow(label: 'Reason', value: 'Chest pain & checkup'),
          ])),
          const SizedBox(height: 16),

          // Payment Summary
          Text('Payment Summary', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          _Card(child: Column(children: [
            _DetailRow(label: 'Consultation Fee', value: '\$50.00'),
            const SizedBox(height: 8),
            _DetailRow(label: 'Platform Fee', value: '\$2.00'),
            const SizedBox(height: 8),
            _DetailRow(label: 'Tax (6%)', value: '\$3.00'),
            const Divider(height: 20, color: AppColors.divider),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text('\$55.00', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ])),
          const SizedBox(height: 16),

          // Cancellation Policy
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Free cancellation up to 24 hours before the appointment. A fee may apply for late cancellations.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Color(0xFF78350F)))),
            ]),
          ),
          const SizedBox(height: 30),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))]),
        child: PrimaryButton(label: 'Confirm & Pay  \$55.00', onPressed: () => _showConfirmDialog(context)),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 40)),
          const SizedBox(height: 16),
          const Text('Booking Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Your appointment with Dr. James Wilson has been booked successfully.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { context.go('/'); }, child: const Text('Go to Home'))),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () { context.go('/appointments'); }, child: const Text('View Appointment'))),
        ]),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]), child: child);
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ]),
    ]);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      Text(value, style: Theme.of(context).textTheme.labelLarge),
    ]);
  }
}
