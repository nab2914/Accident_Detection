import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'currentlocation.dart';
import 'automatemge.dart';

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


/*
SmsSender smsSender = SmsSender();

void sendMessage() {
  smsSender.sendSms("+919061931671", "Hello, this is an automated SMS.");
}
*/
/*
void sendEmergencySMS() async {
  String message = Uri.encodeComponent('Accident detected!');
  String recipient = "+919061931671";

  // Create the SMS URI
  Uri smsUri = Uri.parse('sms:$recipient?body=$message');

  try {
    // Check if the URI can be launched
    if (await canLaunchUrl(smsUri)) {
      // Launch the SMS application
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      print("SMS intent sent successfully to $recipient");
    } else {
      print("Could not launch SMS URI");
    }
  } catch (e) {
    print("Error sending SMS: $e");
  }
}
*/
/*
void sendEmergencySMS() async {
  // Replace this with your logic to fetch the current location
  String location = await _fetchCurrentLocation(); // Assuming this function gets the location
  String message = Uri.encodeComponent('Accident detected! Current Location: $location');
  String recipient = "+919061931671";

  // Create the SMS URI
  Uri smsUri = Uri.parse('sms:$recipient?body=$message');

  try {
    // Check if the URI can be launched
    if (await canLaunchUrl(smsUri)) {
      // Launch the SMS application
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      print("SMS intent sent successfully to $recipient with location");
    } else {
      print("Could not launch SMS URI");
    }
  } catch (e) {
    print("Error sending SMS: $e");
  }
}
*/

/*
void sendEmergencySMS() async {
  String recipient = "+919061931671";
  String message;

  try {
    // Fetch the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Create a Google Maps URL with the location
    String locationUrl =
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

    // Prepare the SMS message
    message = Uri.encodeComponent(
        'Accident detected! Current location: $locationUrl');
  } catch (e) {
    // Fallback message if location fetching fails
    message = Uri.encodeComponent(
        'Accident detected! Location could not be fetched.');
    print("Error fetching location: $e");
  }

  // Create the SMS URI
  Uri smsUri = Uri.parse('sms:$recipient?body=$message');

  try {
    // Check if the URI can be launched
    if (await canLaunchUrl(smsUri)) {
      // Launch the SMS application
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      print("SMS intent sent successfully to $recipient");
    } else {
      print("Could not launch SMS URI");
    }
  } catch (e) {
    print("Error sending SMS: $e");
  }
}


// Helper function to request SMS permissions
Future<bool> requestSMSPermissions() async {
  var status = await Permission.sms.status;
  if (!status.isGranted) {
    status = await Permission.sms.request();
  }
  return status.isGranted;
}

*/
Future<void> sendEmergencySms() async {
    try {
      const platform = MethodChannel('sendSms');
      final result = await platform.invokeMethod('sendSms', {
        'phone': '+919061931671',
      });
      debugPrint(result);
    } catch (e) {
      debugPrint("Error sending SMS: $e");
    }
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
          sendEmergencySms();

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
