import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sell_now/providers/auth_provider.dart';
import 'package:sell_now/providers/locationProvider.dart';
import 'package:sell_now/screens/mapScreen.dart';
import 'package:sell_now/screens/welcomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _location = '';
  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');

    setState(() {
      _location = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: Container(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: TextButton(
          onPressed: () {
            locationData.getCurrentPosition();
            if (locationData.permissionGranted == true) {
              Navigator.pushNamed(context, MapScreen.id);
            } else {
              print("Permission not granted");
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _location == null ? "Address not selected" : _location!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                auth.error = '';
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushNamed(context, WelcomeScreen.id);
                });
              },
              child: Text("Sign Out"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, WelcomeScreen.id);
              },
              child: Text("Home Screen"),
            ),
          ],
        ),
      ),
    );
  }
}
