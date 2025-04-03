import 'package:flutter/material.dart';
import 'monitoringscreen.dart';
import 'login.dart';
import 'settings.dart';
import 'registerpage.dart';
import 'user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'accidentdetection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
firebase_auth.User? firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

void main() async {
  try{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  }catch(e){debugPrint('Initialization failed: $e');}
  try{
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://nvxbevntgnyfdwdohmih.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52eGJldm50Z255ZmR3ZG9obWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NTU5NDQsImV4cCI6MjA1OTIzMTk0NH0.sC_Pfj_aZK9ppTb-PeSp8ubx2XfjAOCSc-3lulhWRlE',
  );
  debugPrint("Supabase Initialized");}catch(e){debugPrint('Initialization failed: $e');}
  try{
  runApp(MyApp());
  debugPrint("app Initialized");}catch(e){debugPrint('Initialization failed: $e');}
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/monitoring': (context) => MonitoringPage(),
        '/settings': (context) => SettingsPage(),
        '/register': (context) => RegisterPage(),
        '/user': (context) => UserPage(),
        '/detect_accident': (context) => DetectAccidentPage(), 
      },
    );
  }
}
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator
        }

        // Redirect based on authentication state
        if (snapshot.hasData) {
          return MonitoringPage(); // User is logged in
        } else {
          return LoginRegisterPage(); // User is not logged in
        }
      },
    );
  }
}

