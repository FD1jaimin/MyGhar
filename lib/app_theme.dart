// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  
  static final lightTheme = ThemeData(
    useMaterial3: true,
    dialogBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: AppTheme.lightBackgroundColor,
    primaryColor: AppTheme.appColor,
    textTheme: AppTheme.textTheme,
    
  );

  static Color appColor = HexColorNew("#030a0c");
  static Color lightBackgroundColor = const Color(0xffF1F9FC);
  static Color darkBackgroundColor = HexColorNew("#151419");
  static Color lightAppColor = HexColorNew("#efefef");
  static Color buttonBackgroundColor = HexColorNew("#ffeeef");
  static Color buttonIconColor = HexColorNew("#c8bbbb");
  static Color buttonColor = const Color(0xff132137);
  static Color backgroundOverlayColor = const Color(0xffE0EEEF);
  static Color secondaryAppColor = HexColorNew("#bc46f9");
  static Color progressbarBack = HexColorNew('#87A0E5');

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color.fromARGB(255, 8, 10, 11);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Poppins';

  static const TextTheme textTheme = TextTheme(
    headline1: heading,
    headline2: subheading,
    headline4: heading2,
    headline5: heading3,
    bodyText1: smallText,
    caption: smallText,
  );

  static const TextStyle heading = TextStyle(
      color: AppTheme.darkerText,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.fade,
      fontSize: 30,
      height: 1.2,
      letterSpacing: -0.2,
      fontFamily: fontName);
      
  static const TextStyle heading2 = TextStyle(
      color: AppTheme.darkerText,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.fade,
      fontSize: 18,
      letterSpacing: -0.2,
      fontFamily: fontName);


  static const TextStyle heading3 = TextStyle(
      color: AppTheme.darkerText,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      decorationThickness: 0.1,
      fontFamily: fontName);

  static const TextStyle subheading = TextStyle(
      color: AppTheme.darkerText,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.fade,
      fontSize: 24,
      letterSpacing: -0.2,
      fontFamily: fontName);


  static const TextStyle subheading2 = TextStyle(
      color: AppTheme.darkerText,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.fade,
      fontSize: 20,
      letterSpacing: -0.2,
      height: 1.1,
      fontFamily: fontName);

  static const TextStyle subheading3 = TextStyle(
      color: AppTheme.darkerText,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.fade,
      fontSize: 14,
      fontFamily: fontName);

  static const TextStyle smallText = TextStyle(
      color: AppTheme.lightText,
      fontWeight: FontWeight.w200,
      fontSize: 12,
      fontFamily: fontName);
      
}

class HexColorNew extends Color {
  HexColorNew(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}