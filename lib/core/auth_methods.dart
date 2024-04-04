import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:urbannest/models/user.dart' as model;
import 'package:velocity_x/velocity_x.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<model.UserData> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.UserData.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    String bio = "",
    bool isgreen = false,
    // Uint8List file,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty
          // || bio.isNotEmpty
          ) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // model.UserData _user = model.UserData(
        //   firstName: username,
        //   uid: cred.user!.uid,
        //   email: email,
        //   imageUrl: "",
        // );
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        await _firestore.collection("users").doc(cred.user!.uid).set({
          "uid": cred.user!.uid,
          "email": email,
          'createdAt': FieldValue.serverTimestamp(),
          'firstName': username,
          'imageUrl': '',
          'lastName': '',
          'lastSeen': FieldValue.serverTimestamp(),
          'metadata': null,
          'role': null,
          'updatedAt': FieldValue.serverTimestamp(),
          'token': fcmToken,
          'type': 'user',
          'isResident': true,
          'societyId': '',
          'societyCode': '',
          'societyName': '',
          'block': '',
          'house': '',
          'address': '',
          'newMessage': [],
          'blockedUser': [],
          'searchName': username.toLowerCase().removeAllWhiteSpace()
        });
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
