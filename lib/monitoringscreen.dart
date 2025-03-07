import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'currentlocation.dart';
import 'accidentdetection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'report.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Add this for StreamSubscription

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}
class _MonitoringPageState extends State<MonitoringPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  String systemStatus = "Checking...";
  bool isMonitoring = false;

  @override
 void initState() {
  super.initState();
  startMonitoring();
}
  void startMonitoring() 
  {
    final DatabaseReference accelerationRef = FirebaseDatabase.instance.ref('accidents/acceleration');
    final DatabaseReference gyroscopeRef = FirebaseDatabase.instance.ref('accidents/gyroscope');

    // Listen for new child nodes under 'acceleration'
    accelerationRef.onChildAdded.listen((DatabaseEvent event) {
    final newValue = event.snapshot.value;
    if (newValue != null) {
      print("New acceleration data: $newValue");
      // Add logic to detect an accident if necessary
            navigateToAccidentDetectionPage();
    }
  });

  // Listen for new child nodes under 'gyroscope'
  gyroscopeRef.onChildAdded.listen((DatabaseEvent event) {
    final newValue = event.snapshot.value;
    if (newValue != null) {
      print("New gyroscope data: $newValue");
      // Add logic to detect an accident if necessary
        navigateToAccidentDetectionPage();
    }
  });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        systemStatus = "Active";
        isMonitoring = true;
      });
    });
  }

  void navigateToAccidentDetectionPage() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DetectAccidentPage()),
  );
}
  void stopMonitoring() {
    setState(() {
      systemStatus = "Inactive";
      isMonitoring = false;
    });
  }

Future<void> callServices(BuildContext context) async {
  const emergencyNumber = '+917994160886'; // Replace with the emergency number you need
  final uri = Uri.parse('tel:$emergencyNumber');

  if (await Permission.phone.request().isGranted) {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: $e')),
      );
    }
  } else {
    // Permission denied
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permission to make calls was denied')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Monitoring"),
        backgroundColor: Colors.lightBlueAccent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.lightBlue.shade100,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade300,
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('User'),
                onTap: () {
                  Navigator.pushNamed(context, '/user');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.lightBlue, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      LucideIcons.activity,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'System Monitoring',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $systemStatus',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: isMonitoring ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AccidentReportPage()),
          );
        }
      : null,
                icon: const Icon(LucideIcons.alertTriangle),
                label: const Text('Report Accident'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
  onPressed: () => callServices(context), // No need to check `isMonitoring` here unless required
  icon: const Icon(LucideIcons.phoneCall),
  label: const Text('Call Services'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    textStyle: const TextStyle(fontSize: 16),
  ),
),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LocationPage()),
                  );
                },
                icon: const Icon(LucideIcons.mapPin),
                label: const Text('Current Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isMonitoring ? stopMonitoring : startMonitoring,
                child: Text(isMonitoring ? "Stop Monitoring" : "Start Monitoring"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMonitoring ? Colors.orange : Colors.lightBlueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
