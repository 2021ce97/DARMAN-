import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/booking_service_api.dart';

// Re-export existing providers
export '../services/booking_service_api.dart'
    show bookingServiceApiProvider, myBookingsProvider, bookingByIdProvider;

// Booking form state
class BookingFormState {
  final String? doctorId;
  final String? date;
  final String? timeSlot;
  final String type;
  final String notes;
  final bool isLoading;
  final String? error;

  const BookingFormState({
    this.doctorId,
    this.date,
    this.timeSlot,
    this.type = 'in-person',
    this.notes = '',
    this.isLoading = false,
    this.error,
  });

  BookingFormState copyWith({
    String? doctorId,
    String? date,
    String? timeSlot,
    String? type,
    String? notes,
    bool? isLoading,
    String? error,
  }) {
    return BookingFormState(
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isValid => doctorId != null && date != null && timeSlot != null;
}

// Use Notifier instead of StateNotifier (Riverpod v3 compatible)
class BookingFormNotifier extends Notifier<BookingFormState> {
  @override
  BookingFormState build() => const BookingFormState();

  void setDoctor(String doctorId) => state = state.copyWith(doctorId: doctorId);
  void setDate(String date) => state = state.copyWith(date: date, timeSlot: null);
  void setTimeSlot(String slot) => state = state.copyWith(timeSlot: slot);
  void setType(String type) => state = state.copyWith(type: type);
  void setNotes(String notes) => state = state.copyWith(notes: notes);
  void reset() => state = const BookingFormState();

  Future<Map<String, dynamic>> submit() async {
    if (!state.isValid) {
      return {'success': false, 'error': 'Please fill all required fields'};
    }

    state = state.copyWith(isLoading: true, error: null);

    final service = ref.read(bookingServiceApiProvider);
    final result = await service.createBooking(
      doctorId: state.doctorId!,
      date: state.date!,
      timeSlot: state.timeSlot!,
      type: state.type,
      notes: state.notes.isEmpty ? null : state.notes,
    );

    state = state.copyWith(isLoading: false, error: result['error']);
    return result;
  }
}

final bookingFormProvider =
    NotifierProvider.autoDispose<BookingFormNotifier, BookingFormState>(
  BookingFormNotifier.new,
);

// Booking status filter
final bookingStatusFilterProvider = StateProvider<String?>((ref) => null);
