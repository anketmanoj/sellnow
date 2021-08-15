import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sell_now/providers/auth_provider.dart';
import 'package:sell_now/providers/locationProvider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String id = "login-screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _phoneNumberController = TextEditingController();
  bool _validPhoneNumber = false;
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: auth.error.toString() == "Invalid OTP" ? true : false,
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Enter your phone number to proceed",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(
                height: 50,
              ),
              TextField(
                controller: _phoneNumberController,
                maxLength: 9,
                onChanged: (value) {
                  if (value.length == 9) {
                    setState(() {
                      _validPhoneNumber = true;
                    });
                  } else {
                    setState(() {
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
                          setState(() {
                            auth.loading = true;
                          });
                          String number = '+971${_phoneNumberController.text}';
                          auth
                              .verifyPhone(
                            context: context,
                            number: number,
                            address: locationData.selectedAddress.addressLine,
                            latitude: locationData.latitude,
                            longitude: locationData.longitude,
                          )
                              .then((value) {
                            _phoneNumberController.clear();
                            setState(() {
                              auth.loading = false;
                            });
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
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
      ),
    );
  }
}
