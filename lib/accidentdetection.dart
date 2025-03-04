import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class DetectAccidentPage extends StatefulWidget {
  @override
  _DetectAccidentPageState createState() => _DetectAccidentPageState();
}

class _DetectAccidentPageState extends State<DetectAccidentPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  bool accidentDetected = false;
  Timer? countdownTimer;
  int countdownSeconds = 10; // Countdown duration in seconds
  String? accidentDetails; // To store details of the accident

  @override
  void initState() {
    super.initState();
    listenForAccidents();
  }

  void listenForAccidents() {
    database.child('accidents').onChildAdded.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          accidentDetected = true;
          accidentDetails = event.snapshot.value.toString();
        });
        startCountdown();
      }
    });
  }

  void startCountdown() {
  final targetTime = DateTime.now().add(Duration(seconds: countdownSeconds));
  countdownTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    setState(() {
      final remaining = targetTime.difference(DateTime.now()).inSeconds;
      if (remaining > 0) {
        countdownSeconds = remaining;
      } else {
        timer.cancel();
        handleEmergencyCall();
      }
    });
  });
}


void handleEmergencyCall() async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: '+919061931671',
  );

  try {
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  } catch (e) {
    print('Error launching $launchUri: $e');
  }

  setState(() {
    accidentDetected = false;
    countdownSeconds = 10; // Reset countdown
  });
}

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accident Detection'),
      ),
      body: accidentDetected
          ? Center(
              child: Card(
                margin: EdgeInsets.all(16),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Accident Detected!',
                        style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Calling emergency services in: $countdownSeconds seconds',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            accidentDetected = false;
                            countdownSeconds = 10; // Reset countdown
                            countdownTimer?.cancel();
                          });
                        },
                        style: ElevatedButton.styleFrom(iconColor: Colors.green),
                        child: Text("I'm Okay"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Monitoring for accidents...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }
}