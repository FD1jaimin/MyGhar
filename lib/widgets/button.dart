import 'package:flutter/material.dart';
import 'package:urbannest/app_theme.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {
        required this.onTap,
      required this.height,
      required this.width,
      required this.text,
      this.iconData,
      this.color,
      super.key});
  final Function() onTap;
  final double height;
  final double width;
  final String text;
  final IconData? iconData;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: color ?? AppTheme.buttonColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              text== ''? SizedBox():Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
               iconData == null  || text== '' ? 0.widthBox : 12.widthBox,
               iconData == null ?const SizedBox():
                Icon(iconData,color: Colors.white,),
            ],
          ),
        ),
      ),
    );
  }
}