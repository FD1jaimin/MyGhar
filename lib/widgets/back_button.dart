import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../app_theme.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, 
    this.color = Colors.red,this.iconColor = Colors.transparent,}
  ) ;

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.8),
      child: GestureDetector(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color == Colors.red ? AppTheme.backgroundOverlayColor : color,
            boxShadow: const [
              // BoxShadow(
              //   blurRadius: 4,
              //   color: Color.fromARGB(8, 23, 23, 23),
              //   offset: Offset(0, 2),
              // )
            ],
            borderRadius: BorderRadius.circular(80),
            shape: BoxShape.rectangle,
            // border: Border.all(
            //   color: const Color.fromRGBO(57, 75, 123, 0.9),
            //   width: 1.8,
            // ),
          ),
          alignment: const AlignmentDirectional(-0.0, 0),
          child:  Icon(
            Icons.chevron_left_rounded,
            color: iconColor == Colors.transparent ? Colors.black87 : iconColor,
            size: 30,
          ),
        ),
        onTap: () {
          Get.back();
        },
      ),
    );
  }
}