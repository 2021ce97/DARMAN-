import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());

// Payment method selection
final selectedPaymentMethodProvider = StateProvider<String>((ref) => 'hesabpay');

// Payment history
final paymentHistoryProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  final service = ref.watch(paymentServiceProvider);
  return service.getPaymentHistory();
});

// Active payment intent
final activePaymentIntentProvider = StateProvider<PaymentIntent?>((ref) => null);

// Payment loading state
final paymentLoadingProvider = StateProvider<bool>((ref) => false);
