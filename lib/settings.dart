import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _auth.currentUser!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.lightBlueAccent,
      ),
      body: ListView(
        children: [
          // Manage Account 
          ExpansionTile(
            leading: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
            title: Text('Manage Account', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            children: [
              ListTile(
                title: Text('Change Password', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                onTap: _changePassword,
              ),
              ListTile(
                title: Text('Delete Account', style: TextStyle(color: Colors.red)),
                onTap: _deleteAccount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}