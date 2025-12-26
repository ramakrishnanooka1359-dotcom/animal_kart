import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    // 1️⃣ Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // 2️⃣ Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    // 3️⃣ Get location using LocationSettings instead of desiredAccuracy
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, // same as before
      distanceFilter: 0,               // optional: minimum distance (meters) before update
    );

    return await Geolocator.getCurrentPosition(locationSettings: locationSettings);
  }
}
