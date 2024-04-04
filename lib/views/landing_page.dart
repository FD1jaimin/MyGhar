// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/auth_methods.dart';
import 'package:urbannest/core/user_provider.dart';
import 'package:urbannest/views/forgot_password.dart';
import 'package:velocity_x/velocity_x.dart';
import '../main.dart';
import '../widgets/background.dart';
import '../widgets/text_fields.dart';

class RegstrationPage extends StatefulWidget {
  const RegstrationPage({super.key});

  @override
  _RegstrationPageState createState() => _RegstrationPageState();
}

class _RegstrationPageState extends State<RegstrationPage>
    with TickerProviderStateMixin {
  final signUpFormKey = GlobalKey<FormState>();
  final signInFormKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  late PageController pageController;
  late AnimationController animationController;
  bool _isPasswordVisible = false;
  late AnimationController bgController;

  Color left = Colors.black;
  Color right = Colors.white;

  bool page = false;
  bool isgreen = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    bgController.forward().whenCompleteOrCancel(() {
      bgController.forward(from: 0.3).whenCompleteOrCancel(() {
        bgController.forward(from: 0.3).whenCompleteOrCancel(() {
          bgController.forward(from: 0.3);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          const CustomCloudBackground(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Lottie.asset(
              'assets/city_bg.json',
              controller: bgController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 36, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("Get Along ...",
                        style: AppTheme.heading.copyWith(fontSize: 24)),
                    _buildLoginToggle(),
                    _buildTabViews(context),
                  ],
                ),
                8.heightBox,
                _buildDivider(),
                20.heightBox,
                _buildGoogleButton(context),
                16.heightBox,
                _buildContinueButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  var isLoading = false.obs;
  Container _buildContinueButton() {
    return Container(
      height: 58,
      width: 188,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: AppTheme.buttonColor,
      ),
      child: InkWell(
        onTap: () async {
          if (isLoading.value == false) {
            isLoading.value = true;

            if (page == false) {
              await signUp();
            } else {
              await signIn();
            }
          }
          isLoading.value = false;
        },
        child: Obx(() {
          return Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Center(
              child: isLoading.value
                  ? LoadingAnimationWidget.waveDots(
                      color: Colors.white, size: 40)
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  SizedBox _buildTabViews(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 335,
      child: PageView(
        controller: pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) {
          if (i == 0) {
            setState(() {
              page = false;
              right = Colors.white;
              left = Colors.black;
            });
          } else if (i == 1) {
            setState(() {
              page = true;
              right = Colors.black;
              left = Colors.white;
            });
          }
        },
        children: <Widget>[
          _buildSignUp(context),
          _buildSignIn(context),
        ],
      ),
    );
  }

  GestureDetector _buildLoginToggle() {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          left: 34,
          right: 34,
        ),
        child: RichText(
          text: TextSpan(
            style: AppTheme.smallText,
            text: page == false
                ? "Already have an account?"
                : "Don't have an account?",
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    page == false
                        ? pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.decelerate)
                        : pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.decelerate);
                  },
                text: page == false ? "  Login here  " : "  Sign Up  ",
                style: AppTheme.smallText.copyWith(
                    fontWeight: FontWeight.bold, color: AppTheme.appColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(231, 236, 243, 1),
                  Color.fromARGB(255, 212, 218, 225),
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          width: 100.0,
          height: 1.0,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: Text(
            "Or",
            style: AppTheme.smallText,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 212, 218, 225),
                  Color.fromRGBO(231, 236, 243, 1),
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          width: 100.0,
          height: 1.0,
        ),
      ],
    );
  }

  GestureDetector _buildGoogleButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: AppTheme.lightAppColor.withOpacity(0),
              offset: const Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(80),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: AppTheme.darkBackgroundColor.withOpacity(0.3),
            width: 1.8,
          ),
        ),
        alignment: const AlignmentDirectional(-0.0, 0),
        child: Image.asset(
          "assets/g_logo.png",
          height: 40,
        ),
      ),
      onTap: () {
        final provider = Provider.of<UserProvider>(context, listen: false);
        provider.googleLogin(context);
      },
    );
  }

  Future signIn() async {
    final isValid = signInFormKey.currentState!.validate();
    if (!isValid){
      Fluttertoast.showToast(msg: 'Fill all the details');
     return;
    }
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => Center(
    //           child: LoadingAnimationWidget.waveDots(
    //               color: Colors.white, size: 40),
    //         ));
    try {
      String res = await AuthMethods()
          .loginUser(email: email.text.trim(), password: password.text.trim());

      if (res.contains("user-not-found")) {
        Fluttertoast.showToast(msg: "User not found");
      } else if (res.contains("[firebase_auth/wrong-password]")) {
        Fluttertoast.showToast(msg: "Enter valid password");
      } else if (res.contains("[firebase_auth/wrong-password]")) {
        Fluttertoast.showToast(msg: "Enter valid password");
      } else if (res.contains("[firebase_auth/invalid-credential]")) {
        Fluttertoast.showToast(msg: "Invalid credential");
      } else {
        null;
      }
    } on FirebaseAuthException {
      Fluttertoast.showToast(msg: "Something went wrong");
    }

    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  Future signUp() async {
    final isValid = signUpFormKey.currentState?.validate();
    if (!isValid!) return;

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => Center(
    //           child: LoadingAnimationWidget.waveDots(
    //               color: Colors.white, size: 40),
    //         ));
    try {
      String res = await AuthMethods().signUpUser(
        email: email.text.trim(),
        password: password.text.trim(),
        username: name.text.trim(),
        isgreen: isgreen,
        // bio: bio.text,
      );
      if (res.contains("user-not-found")) {
        Fluttertoast.showToast(msg: "User not found");
      } else if (res.contains("[firebase_auth/wrong-password]")) {
        Fluttertoast.showToast(msg: "Enter valid password");
      } else if (res.contains("[firebase_auth/wrong-password]")) {
        Fluttertoast.showToast(msg: "Enter valid password");
      } else if (res.contains("[firebase_auth/invalid-credential]")) {
        Fluttertoast.showToast(msg: "Invalid credential");
      } else if (res.contains('[firebase_auth/email-already-in-use]')) {
        Fluttertoast.showToast(msg: "Email already in use, please sign In");
      } else {
        null;
      }
      Get.back();
      // ignore: empty_catches
    } on FirebaseAuthException {}

    // await FirebaseChatCore.instance.createUserInFirestore(
    //     types.User(
    //       firstName: name.text.trim(),
    //       id: FirebaseAuth.instance.currentUser!.uid,
    //       imageUrl: '',
    //       lastName: '',
    //     ),
    //   );

    // Get.offAll(SocietySelectScreen());
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  Widget _buildSignIn(BuildContext context) {
    return Form(
        key: signInFormKey,
        child: Container(
          padding: const EdgeInsets.only(top: 23.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 300.0,
                child: Column(
                  children: <Widget>[
                    CustomTextField(
                      hint: "Email ID",
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
                    12.heightBox,
                    //Password
                    CustomTextField(
                      hint: "Password",
                      icon: const Icon(CupertinoIcons.lock_fill),
                      obsecure: !_isPasswordVisible,
                      autofocus: false,
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.lightText)
                            .onTap(() {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        }),
                      ),
                      validator: (value) {
                        Pattern pattern =
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                        RegExp regex = RegExp(pattern as String);
                        if (value != null && value.isEmpty || value == null) {
                          return "Please enter the password";
                        } else if (!regex.hasMatch(value.trim())) {
                          return "Needs Upper,Lower, special & >8 characters";
                        }

                        return null;
                      },
                      textController: password,
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),

                    ///forgot password
                    GestureDetector(
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            'forgot password?',
                            style: AppTheme.smallText.copyWith(
                                decoration: TextDecoration.underline,
                                color: AppTheme.lightText),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      onTap: () {
                        Get.to(const ForgotPasswordScreen());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSignUp(BuildContext context) {
    return Form(
        key: signUpFormKey,
        child: Container(
          padding: const EdgeInsets.only(top: 23.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    CustomTextField(
                      hint: "Name",
                      icon: const Icon(CupertinoIcons.person_solid),
                      obsecure: false,
                      autofocus: false,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return "Please enter your name";
                        } else if (value!.length < 3) {
                          return "Name must be longer than 2 characters";
                        }

                        return null;
                      },
                      textController: name,
                    ),
                    12.heightBox,
                    //Email ID
                    CustomTextField(
                      hint: "Email ID",
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
                    12.heightBox,
                    //Password
                    CustomTextField(
                      hint: "Password",
                      icon: const Icon(CupertinoIcons.lock_fill),
                      obsecure: !_isPasswordVisible,
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.lightText)
                            .onTap(() {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        }),
                      ),
                      autofocus: false,
                      validator: (value) {
                        Pattern pattern =
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                        RegExp regex = RegExp(pattern as String);
                        if (value != null && value.isEmpty || value == null) {
                          return "Please enter the password";
                        } else if (!regex.hasMatch(value.trim())) {
                          return "Needs Upper,Lower, special & >8 characters";
                        }

                        return null;
                      },
                      textController: password,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
