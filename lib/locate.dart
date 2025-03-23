import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

Future<Map<String, dynamic>?> fetchNearestEmergencyContact(double userLat, double userLng) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('localities')
        .get();

    double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
      const double R = 6371; // Radius of the Earth in kilometers
      double dLat = (lat2 - lat1) * pi / 180;
      double dLon = (lon2 - lon1) * pi / 180;
      double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
          sin(dLon / 2) * sin(dLon / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return R * c; // Distance in kilometers
    }

    Map<String, dynamic>? nearestContact;
    double minDistance = double.infinity;

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> locality = doc.data() as Map<String, dynamic>;
      double localityLat = locality['latitude'];
      double localityLng = locality['longitude'];
      double distance = calculateDistance(userLat, userLng, localityLat, localityLng);

      if (distance < minDistance) {
        minDistance = distance;
        nearestContact = locality['emergencyContact'];
      }
    }

    return nearestContact;
  } catch (e) {
    print("Error fetching nearest emergency contact: $e");
    return null;
  }
}
