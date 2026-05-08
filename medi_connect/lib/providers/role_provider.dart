import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// ─── User Role ────────────────────────────────────────────────────────────────

enum UserRole { patient, doctor, admin, unknown }

extension UserRoleExt on UserRole {
  bool get isDoctor => this == UserRole.doctor;
  bool get isPatient => this == UserRole.patient;
  bool get isAdmin => this == UserRole.admin;
  bool get isUnknown => this == UserRole.unknown;
}

// ─── User State: combines role + ban status ────────────────────────────────────

class UserState {
  final UserRole role;
  final bool isBanned;

  const UserState({required this.role, this.isBanned = false});

  static const loading = UserState(role: UserRole.unknown);
  static const guest = UserState(role: UserRole.unknown);
}

// ─── Provider: fetch role + ban status from Firestore ─────────────────────────

final userStateProvider = FutureProvider<UserState>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return UserState.guest;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return const UserState(role: UserRole.patient);

    final data = doc.data()!;
    final rawRole = data['role'] as String? ?? 'patient';
    final isBanned = data['isBanned'] == true;

    UserRole role;
    switch (rawRole.toLowerCase()) {
      case 'doctor':
        role = UserRole.doctor;
        break;
      case 'admin':
        role = UserRole.admin;
        break;
      default:
        role = UserRole.patient;
    }

    return UserState(role: role, isBanned: isBanned);
  } catch (_) {
    return const UserState(role: UserRole.patient);
  }
});

// ─── Legacy: role-only provider (kept for backwards compat with GoRouter) ─────

final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final state = await ref.watch(userStateProvider.future);
  return state.role;
});
