import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/student_register.dart';
import 'screens/student_dashboard.dart';
import 'screens/club_dashboard.dart';
import 'screens/college_admin_dashboard.dart';
import 'screens/super_admin_dashboard.dart';
import 'screens/student_email_verification_screen.dart';
import 'screens/create_club_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ClubVerseApp());
}

class ClubVerseApp extends StatelessWidget {
  const ClubVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'ClubVerse - Your College\'s Universe of Clubs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00695C),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const StudentRegisterScreen(),
          '/verify-email': (context) => const StudentEmailVerificationScreen(),
          '/student-dashboard': (context) => const StudentDashboard(),
          '/club-dashboard': (context) => const ClubDashboard(),
          '/college-admin-dashboard': (context) => const CollegeAdminDashboard(),
          '/super-admin-dashboard': (context) => const SuperAdminDashboard(),
          '/create-club': (context) => const CreateClubScreen(),
        },
      ),
    );
  }
}
