import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/firebase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/mock_providers.dart';
import 'providers/patient_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/cases_list_screen.dart';
import 'screens/new_case_screen.dart';
import 'screens/case_detail_screen.dart';
import 'screens/stl_upload_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/placeholder_screens.dart';
import 'screens/researcher_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait + portrait-up (medical app)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ── Firebase Initialization ────────────────────────────────────────────────
  // Only initializes when FirebaseConfig.useFirebase is true.
  // Set that flag after you've filled in FirebaseConfig and run flutter pub get.
  if (FirebaseConfig.useFirebase) {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: FirebaseConfig.webApiKey,
          authDomain: FirebaseConfig.webAuthDomain,
          projectId: FirebaseConfig.webProjectId,
          storageBucket: FirebaseConfig.webStorageBucket,
          messagingSenderId: FirebaseConfig.webMessagingSenderId,
          appId: FirebaseConfig.webAppId,
        ),
      );
    } catch (e) {
      // Gracefully degrade to mock mode if Firebase init fails
      debugPrint('Firebase init failed — running in demo mode: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth — uses Firebase when enabled, mock otherwise
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),

        // Case / STL / Analysis — still mock until backend is fully wired
        ChangeNotifierProvider(create: (_) => MockCaseProvider()),
        ChangeNotifierProvider(create: (_) => MockSTLFileProvider()),
        ChangeNotifierProvider(create: (_) => MockAnalysisProvider()),

        // Patient management — syncs doctor list from AuthProvider automatically
        ChangeNotifierProxyProvider<AuthProvider, PatientProvider>(
          create: (_) => PatientProvider(),
          update: (_, auth, patient) {
            patient!.syncDoctors(auth.registeredDoctors);
            return patient;
          },
        ),

        // Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'AI Orthodontic',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/dashboard': (_) => const DashboardScreen(),
              '/researcher': (_) => const ResearcherScreen(),
              '/cases': (_) => const CasesListScreen(),
              '/new-case': (_) => const NewCaseScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/stl-upload': (_) => const STLUploadScreen(),
              '/reports': (_) => const ReportsScreen(),
              '/attachment-detection': (_) =>
                  const AttachmentDetectionScreen(),
              '/predictability': (_) => const PredictabilityScreen(),
              '/risk-analysis': (_) => const RiskAnalysisScreen(),
              '/recommendations': (_) => const RecommendationsScreen(),
              '/validation': (_) => const ValidationScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/case-detail') {
                final caseId = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CaseDetailScreen(caseId: caseId ?? ''),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
