import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Updated LoginRegisterPage
class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  LoginRegisterPageState createState() => LoginRegisterPageState();
}

class LoginRegisterPageState extends State<LoginRegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushNamed(context, '/monitoring');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.lightBlueAccent,
              child: Icon(
                Icons.shield,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome To SafeGuard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: Colors.black54),
                hintText: "Email",
                filled: true,
                fillColor: Colors.lightBlue.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                hintText: "Password",
                filled: true,
                fillColor: Colors.lightBlue.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            // ... (keep the existing UI elements)

            // Modified Create Account button
            ElevatedButton(
              onPressed: () {
                // Navigate directly to registration page
                Navigator.pushNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
