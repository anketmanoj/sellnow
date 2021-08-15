import 'package:flutter/foundation.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'dart:core';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  late double latitude;
  late double longitude;
  bool permissionGranted = false;
  var selectedAddress;
  bool loading = false;

  Future<void> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position != null) {
      this.latitude = position.latitude;
      this.longitude = position.longitude;
      final coordinates = Coordinates(this.latitude, this.longitude);
      final addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      this.selectedAddress = addresses.first;
      this.permissionGranted = true;
      notifyListeners();
    } else {
      print('Permissions now granted by user');
    }
  }

  void onCameraMove(CameraPosition cameraPosition) async {
    this.latitude = cameraPosition.target.latitude;
    this.longitude = cameraPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    final coordinates = Coordinates(this.latitude, this.longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    this.selectedAddress = addresses.first;
    print(
        "here! ${selectedAddress.featureName} : ${selectedAddress.addressLine}");
  }

  Future<void> savedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', this.latitude);
    prefs.setDouble('longitude', this.longitude);
    prefs.setString('address', this.selectedAddress.addressLine);
    prefs.setString('location', this.selectedAddress.featureName);
  }
}
