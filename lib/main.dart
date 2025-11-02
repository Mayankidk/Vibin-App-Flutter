import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'theme_provider.dart';
import 'screens/login.dart';
import 'screens/home_screen.dart';
import 'notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:vibin/services/sync_service.dart'; // 👈 NEW: Import the sync service

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Initialize Notification Service
  await NotificationService.init();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await Hive.openBox('achievements');

  await Supabase.initialize(
    url: dotenv.env['SUPA_URL'] ?? '',
    anonKey: dotenv.env['ANON_KEY'] ?? '',
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: "VIBIN'",
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // 👇 Decide login or home based on FirebaseAuth
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final firebaseUser = snapshot.data;

          if (firebaseUser != null) {
            // ✅ Logged in to Firebase: Now wait for Supabase sync
            return FutureBuilder<void>(
              // CRITICAL: Call the synchronization function
              future: AuthSyncService().synchronizeSupabaseUser(firebaseUser),
              builder: (context, futureSnapshot) {
                // Show a loading indicator while the token exchange is happening
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                // Once sync is done (success or failure), proceed to the home screen
                return const HomeScreen();
              },
            );
          }
          return const WelcomePage(); // ❌ Not logged in
        },
      ),
    );
  }
}
