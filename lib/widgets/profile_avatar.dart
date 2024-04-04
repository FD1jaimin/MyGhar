
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:urbannest/models/user.dart';

import '../app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.uid,
    this.data,
    this.height = 50,
    this.width = 50,
  });

  final String uid;
  final UserData? data;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: data == null
                            ? AppTheme.lightBackgroundColor
                            : (data!.type == "user" || data!.type == "member")
                                ? AppTheme.lightBackgroundColor
                                : data!.type == "admin"
                                    ? AppTheme.appColor
                                    : data!.type =='guard'? const Color.fromARGB(255, 30, 99, 160) :AppTheme.lightBackgroundColor ,
                        width: 2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(0, 0),
                          blurRadius: 8,
                          color: AppTheme.appColor.withOpacity(0.08))
                    ],
                  ),

                  width: width,
                  height: height, //'images/glimpselogo.png'),
                  child: data == null || data!.imageUrl == ""
                      ? Lottie.asset("assets/profile.json")
                      : Image.network(
                          data!.imageUrl,
                          fit: BoxFit.cover,
                        ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: data == null
                            ? AppTheme.lightBackgroundColor
                            : (data!.type == "user" || data!.type == "member")
                                ? AppTheme.lightBackgroundColor
                                : data!.type == "admin"
                                    ? AppTheme.appColor
                                    : data!.type == "guard" ? const Color.fromARGB(255, 30, 99, 160): AppTheme.lightBackgroundColor,
                        width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(0, 0),
                            blurRadius: 8,
                            color: AppTheme.appColor.withOpacity(0.08))
                      ],
                    ),

                    width: width,
                    height: height, //'images/glimpselogo.png'),
                    child: data == null || data!.imageUrl == ""
                        ? Lottie.asset("assets/profile.json")
                        : Image.network(
                            data!.imageUrl,
                            fit: BoxFit.cover,
                          ), //,
                  ),
                );
              }
            }),
        data != null && data!.type == "guard"
            ? Positioned(
                bottom: 0,
                right: 4,
                child: buildEditIcon(AppTheme.appColor),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget buildEditIcon(Color color) => GestureDetector(
        child: const Icon(
          Icons.shield,
          color: Color.fromARGB(255, 30, 99, 160),
          size: 20,
        ),
      );
}
