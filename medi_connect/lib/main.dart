import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/role_provider.dart';
import 'screens/main_scaffold.dart';
import 'screens/doctor_listing_screen.dart';
import 'screens/doctor_profile_screen.dart';
import 'models/doctor_model.dart';
import 'models/appointment_model.dart';
import 'screens/booking_summary_screen.dart';
import 'screens/health_records_screen.dart';
import 'screens/help_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/symptom_checker_screen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/prescription_list_screen.dart';
import 'screens/video_consultation_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/health_dashboard_screen.dart';
import 'screens/medication_reminders_screen.dart';
import 'screens/lab_tests_screen.dart';
import 'screens/pharmacy_screen.dart';
import 'screens/chat_screen.dart';
import 'services/auth_service.dart';
// Doctor screens
import 'screens/doctor/doctor_scaffold.dart';
import 'screens/doctor/doctor_appointment_detail_screen.dart';
import 'screens/doctor/write_prescription_screen.dart';
import 'screens/doctor/doctor_register_screen.dart';
// Admin screens
import 'screens/admin/admin_dashboard_screen.dart';
// FCM
import 'services/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── FCM: initialize push notifications ─────────────────────────────────
  try {
    await FCMService().initialize();
    // Save FCM token to current user's Firestore doc (if already logged in)
    final user = FirebaseAuth.instance.currentUser;
    final token = FCMService().fcmToken;
    if (user != null && token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }
  } catch (e) {
    debugPrint('FCM init error (non-fatal): $e');
  }

  runApp(const ProviderScope(child: MediConnectApp()));
}

class MediConnectApp extends ConsumerWidget {
  const MediConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);

    final userRoleAsync = ref.watch(userRoleProvider);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authState.value != null;
        final loc = state.matchedLocation;
        final isAuthPath = loc == '/login' ||
            loc == '/register' ||
            loc == '/register-doctor';

        if (!isLoggedIn && !isAuthPath) return '/login';
        if (isLoggedIn && isAuthPath) {
          // Role-based redirect after login
          final role = userRoleAsync.value ?? UserRole.patient;
          if (role.isDoctor) return '/doctor';
          if (role.isAdmin) return '/admin';
          return '/';
        }
        return null;
      },
      routes: [
        // ── Main tabs ──────────────────────────────────────────────────────
        GoRoute(path: '/', builder: (_, _) => const MainScaffold(initialIndex: 0)),
        GoRoute(path: '/appointments', builder: (_, __) => const MainScaffold(initialIndex: 2)),
        GoRoute(path: '/profile', builder: (_, __) => const MainScaffold(initialIndex: 3)),
        GoRoute(path: '/search', builder: (_, __) => const MainScaffold(initialIndex: 1)),

        // ── Auth ───────────────────────────────────────────────────────────
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreenApi()),

        // ── Doctors ────────────────────────────────────────────────────────
        GoRoute(path: '/doctors', builder: (_, __) => const DoctorListingScreen()),
        GoRoute(
          path: '/doctor_profile',
          builder: (_, state) => DoctorProfileScreen(doctor: state.extra as DoctorModel),
        ),

        // ── Booking & Payment ──────────────────────────────────────────────
        GoRoute(path: '/booking_summary', builder: (_, __) => const BookingSummaryScreen()),
        GoRoute(
          path: '/payment',
          builder: (_, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            return PaymentScreen(
              bookingId: args['bookingId'] ?? '',
              amount: (args['amount'] ?? 0).toDouble(),
              doctorName: args['doctorName'] ?? 'Doctor',
            );
          },
        ),

        // ── Health Records ─────────────────────────────────────────────────
        GoRoute(path: '/health_records', builder: (_, __) => const HealthRecordsScreen()),
        GoRoute(path: '/health_dashboard', builder: (_, __) => const HealthDashboardScreen()),

        // ── Prescriptions ──────────────────────────────────────────────────
        GoRoute(path: '/prescriptions', builder: (_, __) => const PrescriptionListScreen()),

        // ── Medications ────────────────────────────────────────────────────
        GoRoute(path: '/medication_reminders', builder: (_, __) => const MedicationRemindersScreen()),

        // ── Lab Tests ──────────────────────────────────────────────────────
        GoRoute(path: '/lab_tests', builder: (_, __) => const LabTestsScreen()),

        // ── Pharmacy ───────────────────────────────────────────────────────
        GoRoute(path: '/pharmacy', builder: (_, __) => const PharmacyScreen()),

        // ── AI & Symptom Checker ───────────────────────────────────────────
        GoRoute(path: '/ai_chat', builder: (_, __) => const AIChatbotScreen()),
        GoRoute(path: '/symptom_checker', builder: (_, __) => const SymptomCheckerScreen()),

        // ── Chat ───────────────────────────────────────────────────────────
        GoRoute(
          path: '/chat',
          builder: (_, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            return ChatScreen(
              doctorId: args['doctorId'],
              doctorName: args['doctorName'],
              doctorSpecialty: args['doctorSpecialty'],
              doctorImageUrl: args['doctorImageUrl'],
              isAIChat: args['isAIChat'] ?? false,
            );
          },
        ),

        // ── Video Consultation ─────────────────────────────────────────────
        GoRoute(
          path: '/video_consultation',
          builder: (_, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            return VideoConsultationScreen(
              consultationId: args['consultationId'] ?? '',
              doctorName: args['doctorName'] ?? 'Doctor',
              doctorSpecialty: args['doctorSpecialty'] ?? '',
              doctorImageUrl: args['doctorImageUrl'],
              userId: args['userId'] ?? '',
              role: args['role'] ?? 'patient',
            );
          },
        ),

        // ── Notifications ──────────────────────────────────────────────────
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),

        // ── Help ───────────────────────────────────────────────────────────
        GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),

        // ── Doctor Registration ────────────────────────────────────────────
        GoRoute(
          path: '/register-doctor',
          builder: (_, __) => const DoctorRegisterScreen(),
        ),

        // ── Doctor Shell (tabs) ───────────────────────────────────────────
        GoRoute(
          path: '/doctor',
          builder: (_, __) => const DoctorScaffold(initialIndex: 0),
        ),
        GoRoute(
          path: '/doctor/appointments',
          builder: (_, __) => const DoctorScaffold(initialIndex: 1),
        ),
        GoRoute(
          path: '/doctor/patients',
          builder: (_, __) => const DoctorScaffold(initialIndex: 2),
        ),
        GoRoute(
          path: '/doctor/profile',
          builder: (_, __) => const DoctorScaffold(initialIndex: 3),
        ),

        // ── Doctor Detail Screens ─────────────────────────────────────────
        GoRoute(
          path: '/doctor/appointment-detail',
          builder: (_, state) {
            final appt = state.extra as AppointmentModel;
            return DoctorAppointmentDetailScreen(appointment: appt);
          },
        ),
        GoRoute(
          path: '/doctor/write-prescription',
          builder: (_, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            return WritePrescriptionScreen(
              patientName: args['patientName'],
              patientId: args['patientId'],
              appointmentId: args['appointmentId'],
            );
          },
        ),

        // ── Admin ─────────────────────────────────────────────────────────
        GoRoute(
          path: '/admin',
          builder: (_, __) => const AdminDashboardScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'HealthLink — DARMAN',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
