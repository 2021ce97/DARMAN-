import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'fcm_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ApiClient _apiClient = ApiClient();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Initialize auth state
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _apiClient.setAuthToken(token);
    }

    // Listen to auth state changes and update API client token
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        final token = await user.getIdToken();
        _apiClient.setAuthToken(token);
        await prefs.setString('auth_token', token ?? '');
      } else {
        _apiClient.setAuthToken(null);
        await prefs.remove('auth_token');
      }
    });
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signInWithEmail(
      String email, String password) async {
    try {
      // Sign in with Firebase Auth directly
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Get Firebase ID token
      final token = await credential.user?.getIdToken();

      if (token != null) {
        _apiClient.setAuthToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Try to sync with backend — but don't block login if it fails
        try {
          await _apiClient.post('/auth/verify-token', body: {'token': token});
        } catch (_) {
          // Backend sync failed — login still succeeds via Firebase Auth
        }
      }

      // Save FCM token to Firestore so we can send push notifications
      try {
        final fcmToken = FCMService().fcmToken;
        if (fcmToken != null && credential.user != null) {
          await _db
              .collection('users')
              .doc(credential.user!.uid)
              .set({'fcmToken': fcmToken}, SetOptions(merge: true));
        }
      } catch (_) {}

      return {'success': true, 'user': credential.user};
    } on Exception catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signUpWithEmail(
      String email, String password, String name, String phone) async {
    try {
      // Create Firebase Auth user directly (no backend dependency)
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Set display name
      await credential.user!.updateDisplayName(name);

      // Get Firebase ID token
      final token = await credential.user?.getIdToken();

      if (token != null) {
        _apiClient.setAuthToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }

      // Try to sync with backend — but don't block registration if it fails
      try {
        await _apiClient.post('/auth/register', body: {
          'email': email,
          'password': password,
          'fullName': name,
          'phone': phone,
          'role': 'patient',
        });
      } catch (_) {
        // Backend sync failed — registration still succeeds via Firebase Auth
      }

      // Also save user to Firestore if available
      try {
        await _db.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'fullName': name,
          'phone': phone,
          'role': 'patient',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Firestore not available yet — that's OK
      }

      // Save FCM token
      try {
        final fcmToken = FCMService().fcmToken;
        if (fcmToken != null && credential.user != null) {
          await _db
              .collection('users')
              .doc(credential.user!.uid)
              .set({'fcmToken': fcmToken}, SetOptions(merge: true));
        }
      } catch (_) {}

      return {'success': true, 'user': credential.user};
    } on Exception catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ── Get User Profile ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');
      
      if (response.success) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'error': response.error ?? 'Failed to get profile',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ── Update User Profile ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/auth/profile', body: updates);
      
      if (response.success) {
        return {
          'success': true,
          'message': response.message ?? 'Profile updated successfully',
        };
      }

      return {
        'success': false,
        'error': response.error ?? 'Failed to update profile',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    // Clear FCM token from Firestore
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _db
            .collection('users')
            .doc(uid)
            .set({'fcmToken': FieldValue.delete()}, SetOptions(merge: true));
      }
    } catch (_) {}

    await _auth.signOut();
    _apiClient.setAuthToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── Delete Account ────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Delete Firestore user document
    await _db.collection('users').doc(uid).delete();

    // Delete Firebase Auth account
    await _auth.currentUser?.delete();
    
    _apiClient.setAuthToken(null);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── Get Token ─────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> refreshToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken(true); // Force refresh
      if (token != null) {
        _apiClient.setAuthToken(token);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }
    }
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider =
    StreamProvider<User?>((ref) => ref.watch(authServiceProvider).authStateChanges);
