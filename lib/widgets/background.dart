import 'package:flutter/material.dart';
import 'package:urbannest/app_theme.dart';

class CustomCloudBackground extends StatelessWidget {
  const CustomCloudBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [HexColorNew("#c0eaf8"), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Image.asset("assets/bg.png"),
      ],
    );
  }
}