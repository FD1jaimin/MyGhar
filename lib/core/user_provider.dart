// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:google_sign_in_ios/google_sign_in_ios.dart';
import 'package:urbannest/core/auth_methods.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:urbannest/models/user.dart';

import '../main.dart';
import 'constants.dart';

class UserProvider with ChangeNotifier {
   UserData? _user;

   GoogleSignInAccount? _googleuser;
  final googleSignIn = GoogleSignIn();
  final AuthMethods _authMethods = AuthMethods();

  UserData? get getUser => _user;
  GoogleSignInAccount? get user => _googleuser;

  Future googleLogin(BuildContext context) async {
    final googleuser = await googleSignIn.signIn();
    if (googleuser == null) return;
    _googleuser = googleuser;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: LoadingAnimationWidget.waveDots(
                  color: Colors.white, size: 40),
            ));
    final googleAuth = await googleuser.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    await FirebaseAuth.instance.signInWithCredential(credential);
    notifyListeners();

    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  Future<void> refreshUser() async {
    UserData user = await _authMethods.getUserDetails();
    _user = user;
    // print(_user!.token);
    // assignTopics();
    notifyListeners();
  }

   
  // }
}