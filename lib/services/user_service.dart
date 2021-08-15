import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell_now/models/user_model.dart';

class UserServices {
  String collection = 'user';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new user
  Future<void> createUserData(Map<String, dynamic> values) async {
    String id = values['id'];
    await _firestore.collection(collection).doc(id).set(values);
  }

  // update user data
  Future<void> updateUserData(Map<String, dynamic> values) async {
    String id = values['id'];
    await _firestore.collection(collection).doc(id).update(values);
  }

  // get userData by user id

  Future<void> getUserById(String id) async {
    await _firestore.collection(collection).doc(id).get().then((doc) {
      if (doc.data() == null) {
        return null;
      }

      return UserModel.fromSnapshot(doc);
    });
  }
}
