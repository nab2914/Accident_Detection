import 'package:flutter/services.dart';

const platform = MethodChannel('sendSms');

Future<void> sendEmergencySms() async {
  try {
    final result = await platform.invokeMethod('sendSms', {
      'phone': '+919061931671',
    });
    print(result);
  } catch (e) {
    print("Error: $e");
  }
}
