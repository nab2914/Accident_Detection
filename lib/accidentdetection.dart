import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';


 class DetectAccidentPage extends StatefulWidget {
  @override
  _DetectAccidentPageState createState() => _DetectAccidentPageState();
}

class _DetectAccidentPageState extends State<DetectAccidentPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  bool accidentDetected = false;
  Timer? countdownTimer;
  int countdownSeconds = 10;
  String? accidentDetails;
  String? lastAccidentKey;
  bool isInitialDataLoaded = false;
  bool smsSent = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _listenForAccidents();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    await [Permission.sms, Permission.location].request();
  }
void _listenForAccidents() {
  final DatabaseReference accidentRef = database.child("accidents/acceleration");

  accidentRef.onChildAdded.listen((event) {
    if (event.snapshot.exists) {
      final accidentKey = event.snapshot.key;
      final accidentData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (accidentData == null || !accidentData.containsKey('timestamp') || !accidentData.containsKey('value')) {
        print("Invalid accident data.");
        return;
      }

      final String timestampString = accidentData['timestamp'] as String;
      final double? value = double.tryParse(accidentData['value'].toString());

      if (value == null || (isInitialDataLoaded && accidentKey == lastAccidentKey)) {
        return;
      }

      if (isInitialDataLoaded) {
        setState(() {
          accidentDetected = true; // Switch to accident timer page
          accidentDetails = "Value: $value\nTime: $timestampString";
          lastAccidentKey = accidentKey;
        });

        print("Accident detected: $accidentDetails");
        _startCountdown();
      }
    }
  });

  // Ensure the initial data load doesn't interfere
  accidentRef.once().then((_) {
    setState(() {
      isInitialDataLoaded = true;
    });
    print("Initial accident data loaded.");
  }).catchError((error) {
    print("Error loading initial data: $error");
  });
}



void _startCountdown() async {
  print("Countdown started"); // Debug log
  smsSent = false;
  countdownTimer?.cancel();
  countdownSeconds = 10;

  // Play the alarm sound
  final player = AudioPlayer();
  try {
    print("Attempting to play sound"); // Debug log
    await player.play(AssetSource('alarm_sound.mp3'));
    print("Sound played successfully"); // Debug log
  } catch (e) {
    print("Error playing sound: $e");
  }

  countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (countdownSeconds > 0) {
        countdownSeconds--;
        print("Countdown: $countdownSeconds"); // Debug log
      } else {
        timer.cancel();
        if (!smsSent) {
          _sendEmergencySms();
          smsSent = true;
          print("SMS sent"); // Debug log
        }
      }
    });
  });
}



  Future<void> _sendEmergencySms() async {
    const platform = MethodChannel('sendSms');
    try {
      final result = await platform.invokeMethod('sendSms', {
        'phone': '<emergency_contact>',
        'message': "Accident detected at $accidentDetails",
      });
      print("SMS sent: $result");
    } catch (e) {
      print("Error sending SMS: $e");
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Accident Detection'),
    ),
    body: accidentDetected
        ? _buildAccidentTimerPage() // Show the accident timer page
        : _buildMonitoringPage(),   // Show the monitoring screen
  );
}

Widget _buildAccidentTimerPage() {
  return Center(
    child: Card(
      margin: const EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Accident Detected!',
              style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              countdownSeconds > 0
                  ? 'Sending SMS in $countdownSeconds seconds'
                  : 'SMS Sent!',
              style: TextStyle(
                fontSize: 16,
                color: countdownSeconds > 0 ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  accidentDetected = false;
                  countdownTimer?.cancel();
                  countdownSeconds = 20; // Reset countdown
                });
                print("User marked safe.");
              },
              child: const Text("I'm Okay"),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMonitoringPage() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          'Monitoring for accidents...',
          style: TextStyle(fontSize: 18),
        ),
      ],
    ),
  );
}

}

/*
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // For date and time parsing


class DetectAccidentPage extends StatefulWidget {
  @override
  _DetectAccidentPageState createState() => _DetectAccidentPageState();
}

class _DetectAccidentPageState extends State<DetectAccidentPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  bool accidentDetected = false;
  Timer? countdownTimer;
  int countdownSeconds = 10;
  String? accidentDetails;

Future<void> checkAndRequestPermissions() async {
  if (await Permission.sms.isDenied) {
    await Permission.sms.request();
  }
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }
}
  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
    listenForAccidents();
  }

String? lastAccidentKey;

void listenForAccidents() {
  final DatabaseReference database = FirebaseDatabase.instance.ref("accidents/acceleration");

  // Variables to track the last accident
  String? lastAccidentKey;
  int? lastAccidentTimestamp; // Timestamp in seconds
  const int minTimeGap = 30; // Minimum time gap in seconds
  bool isInitialDataLoaded = false; // Flag to handle pre-existing data

  // Helper function to convert HH:mm:ss to seconds
  int parseTimestampToSeconds(String timestamp) {
    final format = DateFormat("HH:mm:ss");
    final time = format.parse(timestamp);
    return time.hour * 3600 + time.minute * 60 + time.second;
  }

  // Listen for new accidents in the database
  database.onChildAdded.listen((event) {
    if (event.snapshot.exists) {
      final accidentKey = event.snapshot.key;
      final accidentData = event.snapshot.value as Map<dynamic, dynamic>;

      final String timestampString = accidentData['timestamp'] as String;
      final double? value = double.tryParse(accidentData['value'].toString());

      if (!isInitialDataLoaded) {
        // Log initial data but don't act on it
        print("Skipping pre-existing accident: $accidentKey");
        return;
      }

      if (value != null) {
        final int currentTimestamp = parseTimestampToSeconds(timestampString);

        if (accidentKey != lastAccidentKey) {
          // Check the time gap between the last accident and the current one
          if (lastAccidentTimestamp == null ||
              currentTimestamp - lastAccidentTimestamp! >= minTimeGap) {
            // Update the last accident information
            lastAccidentKey = accidentKey;
            lastAccidentTimestamp = currentTimestamp;

            // Perform UI updates or actions
            setState(() {
              accidentDetected = true;
              accidentDetails = "Accident detected!\nValue: $value\nTime: $timestampString";
            });

            print("Accident detected: $accidentDetails");

            // Start a countdown to reset the UI or perform any other action
            startCountdown();
          } else {
            print("Accident ignored due to time gap restriction.");
          }
        }
      } else {
        print("Invalid accident value.");
      }
    }
  });

  // Set the flag after loading the initial data
  database.once().then((snapshot) {
  print("Initial data loaded. Listening for new accidents...");
  setState(() {
    isInitialDataLoaded = true; // Update state after loading initial data
  });
}).catchError((error) {
  print("Error loading initial data: $error");
});

}



 bool smsSent = false;

void sendEmergencySms() async {
  if (smsSent) {
    debugPrint("SMS already sent, skipping...");
    return;
  }
  try {
    const platform = MethodChannel('sendSms');
    final result = await platform.invokeMethod('sendSms', {

    });
    smsSent = true; 
    debugPrint(result);
  } catch (e) {
    debugPrint("Error sending SMS: $e");
  }
}

void startCountdown() {
  smsSent = false; // Reset smsSent whenever a new countdown starts
  final targetTime = DateTime.now().add(Duration(seconds: countdownSeconds));
  countdownTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    setState(() {
      final now = DateTime.now();
      final remainingMillis = targetTime.difference(now).inMilliseconds;

      if (remainingMillis > 0) {
        countdownSeconds = (remainingMillis / 1000).ceil();
      } else {
        timer.cancel();
        if (!smsSent) {
          sendEmergencySms();
          smsSent = true;
        }
      }
    });
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
                      countdownSeconds > 1
                          ? 'Sending Text message in: $countdownSeconds seconds'
                          : 'Message Sent!',
                      style: TextStyle(
                        fontSize: 16,
                        color: countdownSeconds > 1 ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      SizedBox(height: 30),
                     ElevatedButton(
                        onPressed: () {
                          setState(() {
                            accidentDetected = false;
                            smsSent = true; // Prevent SMS from being sent
                            countdownSeconds = 10; // Reset countdown
                            countdownTimer?.cancel(); // Stop the timer
                          });

                          // Call the cancelEmergencySms method in the platform channel
                          const platform = MethodChannel('sendSms');
                          try {
                            platform.invokeMethod('cancelEmergencySms'); // Notify MainActivity
                          } catch (e) {
                            debugPrint("Error canceling SMS: $e");
                          }
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
*/