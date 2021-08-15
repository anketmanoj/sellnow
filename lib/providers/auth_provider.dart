import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sell_now/screens/home_screen.dart';
import 'package:sell_now/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  late String smsOtp;
  late String verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String error = '';
  UserServices _userServices = UserServices();
  bool loading = false;

  Future<void> verifyPhone(
      {BuildContext? context,
      String? number,
      double? latitude,
      double? longitude,
      String? address}) async {
    this.loading = true;
    notifyListeners();
    final verificationCompleted = (PhoneAuthCredential credential) async {
      this.loading = false;
      notifyListeners();
      await _auth.signInWithCredential(credential);
    };

    final verificationFailed = (FirebaseAuthException e) {
      this.loading = false;
      notifyListeners();

      this.error = e.toString();
      notifyListeners();
      print('The provided phone number is not valid.');
    };

    final PhoneCodeSent smsOtpSend = (String verId, int? resendToken) async {
      this.verificationId = verId;

      // dialog to enter recieved OTP sms

      smsOtpDialog(
          context: context,
          number: number,
          address: address!,
          latitude: latitude,
          longitude: longitude);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number!,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool?> smsOtpDialog({
    BuildContext? context,
    String? number,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return showDialog<bool>(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Text("Verification Code"),
              SizedBox(
                height: 6,
              ),
              Text(
                "Enter the 6 Digit OTP recieved by SMS",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          content: Container(
            height: 85,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (value) {
                this.smsOtp = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  PhoneAuthCredential phoneAuthCredential =
                      PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: smsOtp);

                  final User? user =
                      (await _auth.signInWithCredential(phoneAuthCredential))
                          .user;

                  // create user data in firestore after user successfully registered
                  _createUser(
                    id: user!.uid,
                    number: user.phoneNumber,
                    address: address,
                    latitude: latitude,
                    longitude: longitude,
                  );
                  // test

                  // Navigate to Home page after login
                  if (user != null) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, HomeScreen.id);
                  } else {
                    print("Log in Failed ");
                  }
                } catch (e) {
                  this.error = e.toString();
                  notifyListeners();
                  print(e.toString());
                  Navigator.pop(context);
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _createUser(
      {String? id,
      String? number,
      double? latitude,
      double? longitude,
      String? address}) {
    _userServices.createUserData({
      'id': id,
      'number': number,
      'location': GeoPoint(latitude!, longitude!),
      'address': address,
    });
  }

  void updateUser(
      {String? id,
      String? number,
      double? latitude,
      double? longitude,
      String? address}) {
    _userServices.updateUserData({
      'id': id,
      'number': number,
      'location': GeoPoint(latitude!, longitude!),
      'address': address,
    });
  }
}
