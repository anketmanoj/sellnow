import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sell_now/providers/auth_provider.dart';
import 'package:sell_now/providers/locationProvider.dart';
import 'package:sell_now/screens/mapScreen.dart';
import 'package:sell_now/screens/onboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key? key}) : super(key: key);
  static const String id = 'welcome-screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    bool _validPhoneNumber = false;
    var _phoneNumberController = TextEditingController();

    void showBottomSheet(context) {
      showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter myState) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible:
                          auth.error.toString() == "Invalid OTP" ? true : false,
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              auth.error,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "LOGIN",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Enter your phone number to proceed",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: _phoneNumberController,
                      maxLength: 9,
                      onChanged: (value) {
                        if (value.length == 9) {
                          myState(() {
                            _validPhoneNumber = true;
                          });
                        } else {
                          myState(() {
                            _validPhoneNumber = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixText: "+971",
                        hintText: "5x xxx xxxx",
                        labelText: "Mobile Number",
                      ),
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: _validPhoneNumber ? false : true,
                            child: ElevatedButton(
                              onPressed: () {
                                myState(() {
                                  auth.loading = true;
                                });
                                String number =
                                    '+971${_phoneNumberController.text}';

                                auth
                                    .verifyPhone(
                                  context: context,
                                  number: number,
                                  address: null,
                                  latitude: null,
                                  longitude: null,
                                )
                                    .then((value) {
                                  _phoneNumberController.clear();
                                });
                              },
                              child: auth.loading == false
                                  ? Text(
                                      _validPhoneNumber
                                          ? "Continue"
                                          : "Enter Phone Number",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : Container(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 50,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Skip",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: OnBoardScreen(),
                ),
                Text(
                  "Ready to order from stores close to you?",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      locationData.loading = true;
                    });
                    await locationData.getCurrentPosition();
                    if (locationData.permissionGranted == true) {
                      Navigator.pushReplacementNamed(context, MapScreen.id);
                      setState(() {
                        locationData.loading = false;
                      });
                    } else {
                      print('permission not allowed by user');
                    }
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an Account?",
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: " Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
