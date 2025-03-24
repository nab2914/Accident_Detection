import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';


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
  final DatabaseReference accelerationRef = database.child("accidents/acceleration");
  final DatabaseReference gyroscopeRef = database.child("accidents/gyroscope");

  void handleAccidentEvent(DatabaseEvent event, String sensorType) {
    if (event.snapshot.exists && isInitialDataLoaded) {
      final accidentKey = event.snapshot.key;
      final accidentData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (accidentData == null || 
          !accidentData.containsKey('timestamp') || 
          !accidentData.containsKey('value')) {
        print("Invalid $sensorType accident data.");
        return;
      }

      final String timestampString = accidentData['timestamp'] as String;
      final double? value = double.tryParse(accidentData['value'].toString());

      if (value == null || accidentKey == lastAccidentKey) {
        return;
      }

      setState(() {
        accidentDetected = true; // Switch to accident timer page
        accidentDetails = "Sensor: $sensorType\nValue: $value\nTime: $timestampString";
        lastAccidentKey = accidentKey;
      });

      print("Accident detected from $sensorType: $accidentDetails");
      _startCountdown();
    }
  }

  accelerationRef.onChildAdded.listen((event) => handleAccidentEvent(event, "Acceleration"));
  gyroscopeRef.onChildAdded.listen((event) => handleAccidentEvent(event, "Gyroscope"));

  // Ensure the initial data load doesn't trigger accident detection
  Future.wait([accelerationRef.once(), gyroscopeRef.once()]).then((_) {
    setState(() {
      isInitialDataLoaded = true;
    });
    print("Initial accident data loaded.");
  }).catchError((error) {
    print("Error loading initial data: $error");
  });
}


/*
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
*/
void _startCountdown() async {
  print("Countdown started");
  smsSent = false;
  countdownTimer?.cancel();
  countdownSeconds = 10;

  // Play the alarm sound
  final player = AudioPlayer();
  try {
    print("Attempting to play sound");
    await player.play(AssetSource('alarm_sound.mp3'));
    print("Sound played successfully");
  } catch (e) {
    print("Error playing sound: $e");
  }

  countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (countdownSeconds > 0) {
        countdownSeconds--;
        print("Countdown: $countdownSeconds");
      } else {
        timer.cancel();
        if (!smsSent) {
          smsSent = true;
          _sendEmergencySms();
          print("SMS sent");
          mapLocationToFirebase(); // Send location data to Firebase
        }
      }
    });
  });
}


Future<void> mapLocationToFirebase() async {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("user_locations");

  try {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Get current location
      Position position = await Geolocator.getCurrentPosition();

      // Push location to Firebase
      await dbRef.push().set({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": DateTime.now().toIso8601String(),
      });

      print("Location added to Firebase!");
    } else {
      print("Location permission denied!");
    }
  } catch (e) {
    print("Error: $e");
  }
}




  Future<void> _sendEmergencySms() async {
  const platform = MethodChannel('sendSms');
  try {
    // Call the 'fetchNearestContact' method from MainActivity
    final result = await platform.invokeMethod('fetchNearestContact');
    
    print("Result from native: $result");
  } catch (e) {
    print("Error fetching and sending SMS: $e");
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
                  countdownSeconds = 10; // Reset countdown
                  smsSent = false;       // Reset SMS sent state
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
