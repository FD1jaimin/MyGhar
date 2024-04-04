import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/models/user.dart' as model;
import 'package:urbannest/views/landing_page.dart';
import 'package:urbannest/views/navigation_wrapper.dart';
import 'package:urbannest/views/society_selection_screen.dart';
import 'package:urbannest/views/user_home_screen.dart';
import 'package:urbannest/widgets/background.dart';

import 'user_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // final UserData? user = Provider.of<UserProvider>(context).getUser;
    // Utils.setOnboardingStatus();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Something Went Wrong!"),
              );
            } else if (snapshot.hasData) {
              UserProvider userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.refreshUser();
              model.UserData? user = Provider.of<UserProvider>(context).getUser;
              if (user == null) {
                return Scaffold(
                  body: Stack(children: [
                    const CustomCloudBackground(),
                    
                    Center(
                      child: LoadingAnimationWidget.waveDots(
                          color: AppTheme.lightText, size: 40),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child:
                            Lottie.asset('assets/city_bg.json', reverse: true)),
                  ]),
                );
              } else if (user.societyId == '' || user.societyCode == null) {
                return const SocietySelectScreen();
              } else {
                if (user.type == 'admin' || user.type == 'member') {
                  return const NavigationWrapper();
                } else {
                  return const UserHomeScreen();
                }
              }
            } else {
              return const RegstrationPage();
            }
          }),
    );
  }
}
