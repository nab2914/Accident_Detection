import 'package:flutter/material.dart';
import 'monitoringscreen.dart';
import 'login.dart';
import 'settings.dart';
import 'registerpage.dart';
import 'user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'accidentdetection.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  try{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  }catch(e){debugPrint('Initialization failed: $e');}
  runApp(MyApp());
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
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