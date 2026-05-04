import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
class BookingServiceApi {
  final ApiClient _apiClient = ApiClient();

  /// Create a new booking
  Future<Map<String, dynamic>> createBooking({
    required String doctorId,
    required String date,
    required String timeSlot,
    required String type, // 'in-person' or 'online'
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post('/bookings', body: {
        'doctorId': doctorId,
        'date': date,
        'timeSlot': timeSlot,
        'type': type,
        if (notes != null) 'notes': notes,
      });

      if (response.success) {
        return {
          'success': true,
          'data': response.data,
          'message': response.message ?? 'Booking created successfully',
        };
      }

      return {
        'success': false,
        'error': response.error ?? 'Failed to create booking',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get user's bookings
  Future<List<Map<String, dynamic>>> getMyBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '/bookings/my-bookings',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      return [];
    }
  }

  /// Get booking by ID
  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final response = await _apiClient.get('/bookings/$bookingId');

      if (response.success && response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching booking: $e');
      return null;
    }
  }

  /// Cancel booking
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final response = await _apiClient.put('/bookings/$bookingId/cancel');

      if (response.success) {
        return {
          'success': true,
          'message': response.message ?? 'Booking cancelled successfully',
        };
      }

      return {
        'success': false,
        'error': response.error ?? 'Failed to cancel booking',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final bookingServiceApiProvider = Provider((ref) => BookingServiceApi());

/// Future provider for user bookings
final myBookingsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(bookingServiceApiProvider);
  return await service.getMyBookings();
});

/// Future provider for booking by ID
final bookingByIdProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
  (ref, bookingId) async {
    final service = ref.watch(bookingServiceApiProvider);
    return await service.getBookingById(bookingId);
  },
);

