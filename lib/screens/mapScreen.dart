import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sell_now/providers/auth_provider.dart';
import 'package:sell_now/providers/locationProvider.dart';
import 'package:sell_now/screens/loginScreen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  static const String id = "map-screen";

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng currentLocation;
  late GoogleMapController _mapController;
  bool _locating = false;
  bool _loggedIn = false;
  User? _user;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _loggedIn = true;
        _user = FirebaseAuth.instance.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    final _auth = Provider.of<AuthProvider>(context);
    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
    });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: currentLocation, zoom: 14.4746),
                zoomControlsEnabled: false,
                minMaxZoomPreference: MinMaxZoomPreference(1.5, 20.0),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                mapToolbarEnabled: true,
                onCameraMove: (CameraPosition position) {
                  setState(() {
                    _locating = true;
                  });
                  locationData.onCameraMove(position);
                },
                onMapCreated: onCreated,
                onCameraIdle: () {
                  setState(() {
                    _locating = false;
                  });
                  locationData.getMoveCamera();
                },
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _locating ? LinearProgressIndicator() : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton.icon(
                          icon: Icon(Icons.location_on),
                          onPressed: () {},
                          label: Flexible(
                            child: Text(
                              _locating
                                  ? "loading..."
                                  : locationData.selectedAddress.featureName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _locating
                              ? "loading..."
                              : locationData.selectedAddress.addressLine,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: AbsorbPointer(
                          absorbing: _locating ? true : false,
                          child: InkWell(
                            onTap: () {
                              if (_loggedIn == false) {
                                Navigator.pushNamed(context, LoginScreen.id);
                              } else {
                                _auth.updateUser(
                                  id: _user?.uid,
                                  number: _user?.phoneNumber,
                                  latitude: locationData.latitude,
                                  longitude: locationData.longitude,
                                  address:
                                      locationData.selectedAddress.addressline,
                                );
                              }
                            },
                            child: Container(
                              height: 40,
                              color: _locating ? Colors.grey : Colors.blue,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text(
                                    "Confirm Location".toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  child: Image.asset(
                    'assets/marker.png',
                    color: Colors.deepOrangeAccent,
                  ),
                  margin: EdgeInsets.only(bottom: 35),
                  height: 35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
