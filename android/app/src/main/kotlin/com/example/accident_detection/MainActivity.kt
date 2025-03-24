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
import com.google.firebase.database.*
import android.util.Log


class MainActivity : FlutterActivity() {
    private val CHANNEL = "sendSms"
    private val SMS_PERMISSION_CODE = 100
    private lateinit var database: DatabaseReference

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        database = FirebaseDatabase.getInstance().reference.child("emergency_contacts")

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phone")
                    val message = call.argument<String>("message")
                    if (phoneNumber != null && message != null) {
                        println("Phone number: $phoneNumber")
                        println("Message: $message")

                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                            == PackageManager.PERMISSION_GRANTED
                        ) {
                            try {
                                SmsManager.getDefault().sendTextMessage(phoneNumber, null, message, null, null)
                                result.success("SMS sent successfully!")
                            } catch (e: Exception) {
                                result.error("ERROR", "Failed to send SMS: ${e.localizedMessage}", null)
                            }
                        } else {
                            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), SMS_PERMISSION_CODE)
                            result.error("PERMISSION_DENIED", "SMS permission denied", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Phone number or message is missing", null)
                    }
                }

                "fetchNearestContact" -> {
                    fetchLocationAndFindNearestContact(result)
                }

                else -> result.notImplemented()
            }
        }
    }

private fun findNearestContact(userLat: Double, userLon: Double, result: MethodChannel.Result) {
    database.addListenerForSingleValueEvent(object : ValueEventListener {
        override fun onDataChange(snapshot: DataSnapshot) {
            var nearestContact: String? = null
            var shortestDistance = Double.MAX_VALUE // Initialize the shortest distance to a very large value

            // Iterate through emergency contacts in Firebase
            for (regionSnapshot in snapshot.children) {
                val contact = regionSnapshot.child("contact").getValue(String::class.java)
                val lat = regionSnapshot.child("latitude").getValue(Double::class.java)
                val lon = regionSnapshot.child("longitude").getValue(Double::class.java)
                val radiusKm = regionSnapshot.child("radius_km").getValue(Double::class.java) ?: Double.MAX_VALUE

                if (contact != null && lat != null && lon != null) {
                    val distance = calculateDistance(userLat, userLon, lat, lon)
                    if (distance < shortestDistance && distance <= radiusKm) {
                        shortestDistance = distance
                        nearestContact = contact
                    }
                }
            }

            if (nearestContact != null) {
                val message = """
                    Accident detected at Sensor: Acceleration
                    Location: https://www.google.com/maps/search/?api=1&query=$userLat,$userLon
                """.trimIndent()

                sendSms(nearestContact, message, result) // Send SMS to the nearest contact
            } else {
                result.error("NO_CONTACT_FOUND", "No emergency contacts within their respective radius", null)
            }
        }

        override fun onCancelled(error: DatabaseError) {
            result.error("FIREBASE_ERROR", error.message, null)
        }
    })
}



   private fun calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
    val earthRadius = 6371.0 // Earth's radius in kilometers

    val dLat = Math.toRadians(lat2 - lat1)
    val dLon = Math.toRadians(lon2 - lon1)

    val a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2)

    val c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return earthRadius * c // Distance in kilometers
}


    private fun fetchLocationAndFindNearestContact(result: MethodChannel.Result) {
        val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        fusedLocationClient.lastLocation.addOnSuccessListener { location ->
            if (location != null) {
                val userLatitude = location.latitude
                val userLongitude = location.longitude
                findNearestContact(userLatitude, userLongitude, result)
            } else {
                result.error("LOCATION_ERROR", "Failed to get current location", null)
            }
        }
    }

    private fun sendSms(phoneNumber: String, message: String, result: MethodChannel.Result) {

    if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
        try {
            println("Phone number: $phoneNumber")
            println("Message: $message")

            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
            result.success("SMS Sent Successfully")
        } catch (e: Exception) {
            result.error("SMS_FAILED", "Error sending SMS: ${e.message}", null)
        }
    } else {
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), SMS_PERMISSION_CODE)
        result.error("PERMISSION_DENIED", "SMS permission not granted", null)
    }
}

}
