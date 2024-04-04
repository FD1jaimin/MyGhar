// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/views/blocked_user.dart';
import 'package:urbannest/views/chats/util.dart';
import 'package:urbannest/views/landing_page.dart';
import 'package:urbannest/views/privacyScreen.dart';
import 'package:urbannest/views/support_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'terms_screen.dart';
import 'user_guide_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(
                  top: 0, bottom: 12, left: 24, right: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomBackButton(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.8, left: 16),
                    child: Text(
                      "Settings",
                      style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ],
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: getMyCourseList(),
            ),
          ),
        ],
      )),
    );
  }

  Widget getMyCourseList() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: MyCourseList(),
    );
  }
}

class MyCourseList extends StatefulWidget {
  const MyCourseList({super.key});

  @override
  _MyCourseListState createState() => _MyCourseListState();
}

class _MyCourseListState extends State<MyCourseList>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<String> settings = [
    "User Guide",
    "Blocked user",
    "Get support",
    "Terms & conditions",
    "Privacy Policy",
    "Delete Account"
  ];

  privacy() async {
    String url = 'https://www.webinent.com/terms-conditions/';
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {}
  }

  List<dynamic> screens = [
    const UserGuideScreen(),
    const BlockedUserScreen(),
    const SupportScreen(),
    const TermsScreen(),
    const PrivacyScreen(),
  ];

  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData =
          FirebaseAuth.instance.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }

      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
    }
  }

  List<IconData> icons = [
    CupertinoIcons.videocam_circle,
    CupertinoIcons.lock,
    CupertinoIcons.question_circle,
    CupertinoIcons.square_list,
    CupertinoIcons.exclamationmark_shield,
    CupertinoIcons.delete,
  ];

  Future<void> deleteAccount() async {
    try {
      //delete user
      await FirebaseAuth.instance.currentUser?.delete();
      await FirebaseAuth.instance.signOut();

      var delete = await FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .delete();
      await Get.offAll(const RegstrationPage());
      FirebaseFirestore.instance.collection('posts').doc().get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      //go to sign up log in page

      // if (user != null) {
      //   await user.delete();
      //   print('User account deleted successfully.');
      // } else {
      //   print('No user signed in.');
      // }
    } catch (e) {
      print('Failed to delete user account: $e');
      // Handle error as needed
    }
  }

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: List<Widget>.generate(
          settings.length,
          (int index) {
            final int count = settings.length + 5;
            final Animation<double> animation =
                Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController!,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            animationController?.forward();
            return Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: AnimatedBuilder(
                animation: animationController!,
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                      opacity: animation,
                      child: Transform(
                        transform: Matrix4.translationValues(
                            0.0, 50 * (1.0 - animation.value), 0.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: AppTheme.lightText
                                              .withOpacity(0.2),
                                          shape: BoxShape.circle),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: Icon(
                                          icons[index],
                                          color: AppTheme.lightText,
                                        ),
                                      ),
                                    ),
                                    12.widthBox,
                                    Expanded(
                                      child: Text(
                                        settings[index],
                                        style: AppTheme.subheading2.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppTheme.lightText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ));
                },
              ).onTap(
                () {
                  if (settings.length - 1 == index) {
                    showDialog(
                      context: Get.context!,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          
                          title: const Text('Delete your Account?',
                            style: AppTheme.subheading2),
                          content: const Text(
                              '''If you select Delete we will delete your account on our server.\n
Your app data will also be deleted and you won't be able to retrieve it.''',
                              style: AppTheme.smallText),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                deleteAccount();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.to(screens[index]);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
