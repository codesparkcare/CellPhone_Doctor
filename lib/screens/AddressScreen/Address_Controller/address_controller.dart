import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class SelectAddressController extends GetxController {
  GoogleMapController? mapController;

  LatLng centerLocation = const LatLng(13.0827, 80.2707); // default location
  String selectedAddress = "Fetching address...";
  bool showFullForm = false;

  bool isLoading = true;

  String selectedTag = "Home";
  bool? serviceEnabled;
  LocationPermission? permission;

  @override
  void onInit() {
    super.onInit();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    try {
      // 1. Check if location service is enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location is disabled, we can prompt but shouldn't halt indefinitely
        await Geolocator.openLocationSettings();
        // Check again after returning from settings
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      }

      if (serviceEnabled) {
        // 2. Check and request permission
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }

        // 3. Get exact location if we have permission
        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          Position? lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            centerLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
          }
          
          Position currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high
          );
          centerLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
        }
      }
    } catch (e) {
      print("Error fetching location: $e");
    }

    // Always stop loading and update map, even if location failed
    isLoading = false;
    update();

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(centerLocation, 16));
    }
    await _updateAddressFromLatLng(centerLocation);
  }

  Future<void> searchAddress(String query) async {
    try {
      if (query.isEmpty) return;
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);
        centerLocation = newPosition;
        if (mapController != null) {
          mapController!.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 16));
        }
        update();
      }
    } catch (e) {
      print("Error finding address: $e");
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(centerLocation, 16));
  }

  void onCameraMove(CameraPosition position) {
    centerLocation = position.target;
  }

  Future<void> onCameraIdle() async {
    await _updateAddressFromLatLng(centerLocation);
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        selectedAddress =
        "${place.name}, ${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        update();
      }
    } catch (e) {
      selectedAddress = "Unable to fetch address";
      print("error${e.toString()}");
      update();
    }
  }

  void toggleForm() {
    showFullForm = true;
    update();
  }

  String phoneNumber = "";
  String completeAddress = "";
  String landmark = "";
  String doorNumber = "";
  String areaName = "";

  void selectTag(String tag) {
    selectedTag = tag;
    update();
  }

  void updatePhoneNumber(String value) {
    phoneNumber = value;
  }

  void updateAddress(String value) {
    completeAddress = value;
  }

  void updateLandmark(String value) {
    landmark = value;
  }

  void updateDoorNumber(String value) {
    doorNumber = value;
  }

  void updateAreaName(String value) {
    areaName = value;
  }
}
