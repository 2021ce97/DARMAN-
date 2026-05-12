import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_model.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class BookingSummaryScreen extends StatelessWidget {
  final AppointmentModel? appointment;

  const BookingSummaryScreen({super.key, this.appointment});

  @override
  Widget build(BuildContext context) {
    // If no appointment is passed, show a fallback or use the latest one from provider
    // For now, we'll assume it's passed or use mock if null (to avoid breaking)
    final appt = appointment ?? AppointmentModel(
      id: 'mock',
      doctorId: 'd1',
      doctorName: 'Dr. James Wilson',
      doctorSpecialty: 'Cardiologist',
      patientId: 'p1',
      patientName: 'John Doe',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      status: AppointmentStatus.pending,
      type: AppointmentType.clinicVisit,
      amount: 55.0,
      createdAt: DateTime.now(),
    );

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
                Text(appt.doctorName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${appt.doctorSpecialty} • Clinic', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Row(children: const [Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14), SizedBox(width: 4), Text('4.9  (128 reviews)', style: TextStyle(fontSize: 12, color: AppColors.textHint))]),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Appointment Details
          _Card(child: Column(children: [
            _Row(icon: Icons.calendar_today_rounded, label: 'Date', value: _formatDate(appt.dateTime)),
            const Divider(height: 20, color: AppColors.divider),
            _Row(icon: Icons.access_time_rounded, label: 'Time', value: _formatTime(appt.dateTime)),
            const Divider(height: 20, color: AppColors.divider),
            _Row(icon: Icons.location_on_rounded, label: 'Type', value: appt.type == AppointmentType.online ? 'Online Consultation' : 'Clinic Visit'),
          ])),
          const SizedBox(height: 16),

          // Patient Details
          Text('Patient Details', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          _Card(child: Column(children: [
            _DetailRow(label: 'Full Name', value: appt.patientName),
            const Divider(height: 16, color: AppColors.divider),
            _DetailRow(label: 'Reason', value: appt.notes ?? 'General Checkup'),
          ])),
          const SizedBox(height: 16),

          // Payment Summary
          Text('Payment Summary', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          _Card(child: Column(children: [
            _DetailRow(label: 'Consultation Fee', value: '${appt.amount.toStringAsFixed(2)} AFN'),
            const SizedBox(height: 8),
            const _DetailRow(label: 'Platform Fee', value: '50.00 AFN'),
            const Divider(height: 20, color: AppColors.divider),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text('${(appt.amount + 50).toStringAsFixed(2)} AFN', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
        child: PrimaryButton(label: 'Confirm & Pay  ${(appt.amount + 50).toStringAsFixed(2)} AFN', onPressed: () => _showConfirmDialog(context, appt)),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  void _showConfirmDialog(BuildContext context, AppointmentModel appt) {
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
          Text('Your appointment with ${appt.doctorName} has been booked successfully.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
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
