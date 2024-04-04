import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/auth_wrapper.dart';
import 'package:urbannest/widgets/text_fields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  //TextEditingController forgotPasswordController = TextEditingController();
  TextEditingController email = TextEditingController();

  String message = '';
  String errorMessage = '';
  String status = '';
  String userType = '';
  bool isChecked = false;
  String url = "";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [HexColorNew("#c0eaf8"), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
          ),
          Image.asset("assets/bg.png"),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text("Reset Password",
                          style: AppTheme.heading.copyWith(fontSize: 24)),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                    child: Text(
                        textAlign: TextAlign.center,
                        "Enter your email-id and we will send you instructions to reset your password.",
                        style: AppTheme.smallText),
                  ),

                  ///email
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 16),
                    child: CustomTextField(
                      // initialValue: "",
                      hint: "Email ID",
                      keyboardType: TextInputType.emailAddress,
                      icon: const Icon(CupertinoIcons.mail_solid),
                      obsecure: false,
                      autofocus: false,
                      validator: (value) {
                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = RegExp(pattern as String);

                        if ((value != null && value.trim().isEmpty) ||
                            value == null) {
                          return "Please enter your email";
                        } else if (!regex.hasMatch(value.trim())) {
                          return "Enter valid email address";
                        }

                        return null;
                      },
                      textController: email,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// btn submit
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: FutureBuilder<String>(
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            return Container(
                              height: 58,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: AppTheme.buttonColor,
                              ),
                              child: InkWell(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Submit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      // Icon(Icons.arrow_forward_rounded,
                                      //     color: Colors.white),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  var forgotEmail = email.text.trim();

                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                            email: forgotEmail)
                                        .then((value) => {
                                              
                                              Fluttertoast.showToast(
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  msg:
                                                      "Password reset link send in your Registered email"),
                                              Get.offAll(
                                                  () =>  const AuthWrapper()),
                                            });
                                  } on FirebaseAuthException catch (e) {
                                    if (kDebugMode) {
                                      print("Error $e");
                                    }
                                  }
                                },
                              ),
                            );
                          }
                        },
                        future: null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}