import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  /// ✅ Request Location Permission & Get Current Location
  static Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// ✅ Get City Name from coordinates
  /// ✅ Get City Name from coordinates
  static Future<String> _getCityName(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return "Hyderabad"; // fallback city

    final place = placemarks.first;

    // Priority: subLocality > street > name > locality
    String cityName = place.subLocality?.isNotEmpty == true
        ? place.subLocality!
        : place.street?.isNotEmpty == true
            ? place.street!
            : place.name?.isNotEmpty == true
                ? place.name!
                : place.locality?.isNotEmpty == true
                    ? place.locality!
                    : "Hyderabad"; // final fallback

    return cityName;
  }

  /// ✅ Get and Save Location + City Name in SharedPreferences
  static Future<void> fetchAndStoreLocation() async {
    try {
      Position position = await _determinePosition();
      String cityName = await _getCityName(position);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      await prefs.setString('cityName', cityName);

      

      print("📍 Location saved: ${position.latitude}, ${position.longitude}");
      print("🏙 City saved: $cityName");
    } catch (e) {
      print("⚠️ Location error: $e");
    }
  }
}
