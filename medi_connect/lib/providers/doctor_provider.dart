import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/doctor_model.dart';
import '../services/doctor_service.dart';

// Re-export existing providers
export '../services/doctor_service.dart'
    show
        doctorServiceProvider,
        verifiedDoctorsProvider,
        topDoctorsProvider,
        onlineDoctorsProvider,
        doctorsBySpecialtyProvider,
        doctorSearchProvider,
        doctorsFromApiProvider,
        specialtiesFromApiProvider;

// Selected specialty filter
final selectedSpecialtyProvider = StateProvider<String>((ref) => 'All');

// Selected province filter
final selectedProvinceProvider = StateProvider<String?>((ref) => null);

// Search query
final doctorSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered doctors based on all active filters
final filteredDoctorsProvider = FutureProvider.autoDispose<List<DoctorModel>>((ref) async {
  final specialty = ref.watch(selectedSpecialtyProvider);
  final province = ref.watch(selectedProvinceProvider);
  final service = ref.watch(doctorServiceProvider);

  return service.getVerifiedDoctorsFromApi(
    specialty: specialty == 'All' ? null : specialty,
    province: province,
  );
});

// Selected doctor for detail view
final selectedDoctorProvider = StateProvider<DoctorModel?>((ref) => null);

// Doctor availability for a specific date
final doctorAvailabilityProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, ({String doctorId, String date})>((ref, args) async {
  final service = ref.watch(doctorServiceProvider);
  return service.getDoctorAvailability(args.doctorId, args.date);
});
