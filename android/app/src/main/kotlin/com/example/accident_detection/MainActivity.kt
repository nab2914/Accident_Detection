package com.example.accident_detection

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sendSms"
    private val SMS_PERMISSION_CODE = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phone")
                val message = call.argument<String>("message")

                if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                    != PackageManager.PERMISSION_GRANTED
                ) {
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), SMS_PERMISSION_CODE)
                    result.error("PERMISSION_DENIED", "SMS permission denied", null)
                } else {
                    fetchLocationAndSendSms(phoneNumber, message, result)
                }
            } else {
                result.notImplemented()
            }
        }
    }
private var userCancelled = false // Flag to check if the user canceled the process

private fun fetchLocationAndSendSms(phoneNumber: String?, message: String?, result: MethodChannel.Result) {
    val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
    val timeoutHandler = Handler(Looper.getMainLooper())
    var locationRetrieved = false

    try {
        fusedLocationClient.lastLocation.addOnSuccessListener { location: android.location.Location? ->
            if (!locationRetrieved && !userCancelled) { // Check if user has canceled
                locationRetrieved = true
                timeoutHandler.removeCallbacksAndMessages(null) // Cancel timeout

                if (location != null) {
                    val locationUrl = "https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}"
                    val finalMessage = "${message ?: "We've Detected an Accident!"} Current location: $locationUrl"
                    sendSms(phoneNumber, finalMessage, result)
                } else {
                    sendSms(phoneNumber, "${message ?: "We've Detected an Accident!"} Location not available.", result)
                }
            }
        }

        // Add a timeout to avoid blocking indefinitely
        timeoutHandler.postDelayed({
            if (!locationRetrieved && !userCancelled) { // Check if user has canceled
                sendSms(phoneNumber, "${message ?: "We've Detected an Accident!"} Location retrieval timed out.", result)
            }
        }, 10000) // 10 seconds timeout
    } catch (e: Exception) {
        result.error("LOCATION_FAILED", e.message, null)
    }
}

private fun sendSms(phoneNumber: String?, message: String?, result: MethodChannel.Result) {
    if (userCancelled) {
        result.success("SMS sending canceled by the user.")
        return
    }
    try {
        val smsManager: SmsManager = SmsManager.getDefault()
        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        result.success("SMS Sent Successfully")
    } catch (e: Exception) {
        result.error("SMS_FAILED", e.message, null)
    }
}

// Method to cancel the process (to be called when "I'm Okay" is pressed)
fun cancelEmergencySms() {
    userCancelled = true
}

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted
            } else {
                // Permission denied
            }
        }
    }
}
