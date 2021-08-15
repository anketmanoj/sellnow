import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sell_now/providers/locationProvider.dart';
import 'package:sell_now/screens/mapScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  String? _location = '';
  String? _address = '';

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? address = prefs.getString('address');

    setState(() {
      _location = location;
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: false,
      elevation: 0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    _location == null ? "Address not selected" : _location!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
            Flexible(
              child: Text(
                _address!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
