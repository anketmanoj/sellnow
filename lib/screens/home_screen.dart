import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sell_now/providers/auth_provider.dart';
import 'package:sell_now/screens/welcomeScreen.dart';
import 'package:sell_now/widgets/image_slider.dart';
import 'package:sell_now/widgets/myAppbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(112),
        child: MyAppBar(),
      ),
      body: Center(
        child: Column(
          children: [
            ImageSlider(),
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
