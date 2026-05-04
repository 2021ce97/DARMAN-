import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Re-export auth state
export '../services/auth_service.dart' show authStateProvider, authServiceProvider;

// Current user UID
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

// Is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

// User display name
final userDisplayNameProvider = Provider<String>((ref) {
  return ref.watch(authStateProvider).value?.displayName ?? 'User';
});

// User email
final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.email;
});
