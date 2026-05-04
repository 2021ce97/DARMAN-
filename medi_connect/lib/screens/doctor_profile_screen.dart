import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../services/doctor_service.dart';
import '../services/booking_service.dart';
import '../models/appointment_model.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  final Doctor doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  int _selectedDay = 1;
  int _selectedSlot = 0;
  bool _isBooking = false;

  final _days = [
    {'day': 'Sun', 'date': '26'},
    {'day': 'Mon', 'date': '27'},
    {'day': 'Tue', 'date': '28'},
    {'day': 'Wed', 'date': '29'},
    {'day': 'Thu', 'date': '30'},
  ];

  final _slots = ['09:00 AM', '10:00 AM', '11:30 AM', '01:00 PM', '02:30 PM', '04:00 PM'];

  Future<void> _handleBooking() async {
    setState(() => _isBooking = true);
    try {
      final selectedDate = DateTime.now().add(Duration(days: _selectedDay)); // Simple logic for demo
      final timeParts = _slots[_selectedSlot].split(' ');
      final timeStr = timeParts[0].split(':');
      int hour = int.parse(timeStr[0]);
      int minute = int.parse(timeStr[1]);
      if (timeParts[1] == 'PM' && hour != 12) hour += 12;
      
      final appointmentTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day,
        hour, minute,
      );

      await ref.read(bookingServiceProvider).createAppointment(
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        doctorSpecialty: widget.doctor.specialty,
        dateTime: appointmentTime,
        type: AppointmentType.clinicVisit,
        amount: widget.doctor.fee,
      );

      if (mounted) {
        context.push('/booking_summary');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 18),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.favorite_border_rounded, color: AppColors.secondary, size: 18),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: SafeArea(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 56),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.doctor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${widget.doctor.specialty} • ${widget.doctor.city}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _statChip('4.9 ★', 'Rating'),
                      const SizedBox(width: 16),
                      _statChip('128', 'Reviews'),
                      const SizedBox(width: 16),
                      _statChip('10 Yrs', 'Experience'),
                    ]),
                  ]),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(children: [
              // About
              _section(
                context,
                'About ${widget.doctor.name}',
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${widget.doctor.name} is a leading ${widget.doctor.specialty.toLowerCase()} at ${widget.doctor.city} Health Center with over 10 years of specialized experience. They are known for their patient-centered approach and high clinical standards.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ),

              // Working Hours
              _section(
                context,
                'Working Hours',
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Mon – Fri', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const SizedBox(height: 2),
                          Text('09:00 AM – 05:00 PM', style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Open', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Date Picker
              _section(
                context,
                'Select Date',
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _days.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        decoration: BoxDecoration(
                          color: _selectedDay == i ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: _selectedDay == i ? AppColors.primary.withValues(alpha: 0.3) : const Color(0x0A000000), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_days[i]['day']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _selectedDay == i ? Colors.white70 : AppColors.textHint)),
                          const SizedBox(height: 4),
                          Text(_days[i]['date']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _selectedDay == i ? Colors.white : AppColors.textPrimary)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),

              // Time Slots
              _section(
                context,
                'Available Time Slots',
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 10, runSpacing: 10,
                    children: List.generate(_slots.length, (i) => GestureDetector(
                      onTap: () => setState(() => _selectedSlot = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedSlot == i ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedSlot == i ? AppColors.primary : AppColors.outline.withValues(alpha: 0.5)),
                        ),
                        child: Text(_slots[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _selectedSlot == i ? Colors.white : AppColors.textPrimary)),
                      ),
                    )),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Consultation Fee', style: Theme.of(context).textTheme.bodySmall),
            Text(widget.doctor.feeFormatted, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
          const SizedBox(width: 24),
          Expanded(
            child: PrimaryButton(
              label: _isBooking ? 'Processing...' : 'Book Appointment', 
              onPressed: _isBooking ? null : _handleBooking,
            )
          ),
        ]),
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ]),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        child,
      ]),
    );
  }
}
