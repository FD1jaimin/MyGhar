
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:textfield_datepicker/textfield_datepicker.dart';

import '../app_theme.dart';

class CustomTextfieldDatePicker extends StatelessWidget {
  const CustomTextfieldDatePicker({
    super.key,
    required this.date,
    this.hint,
    required this.icon,
  });

  final TextEditingController date;
  final String? hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextfieldDatePicker(
      cupertinoDatePickerBackgroundColor: Colors.white,
      cupertinoDatePickerMaximumDate: DateTime(2099),
      cupertinoDatePickerMaximumYear: 2099,
      cupertinoDatePickerMinimumYear: DateTime.now().year,
      cupertinoDatePickerMinimumDate: DateTime.now(),
      cupertinoDateInitialDateTime: DateTime.now(),
      materialDatePickerFirstDate: DateTime.now(),
      materialDatePickerInitialDate: DateTime.now(),
      materialDatePickerLastDate: DateTime(2099),
      preferredDateFormat:
          DateFormat.yMMMEd(), //DateFormat("yyyy-MM-dd hh:mm:ss"),
      textfieldDatePickerController: date,
      style: AppTheme.subheading3,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintStyle: AppTheme
            .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        hintText: hint ?? "",
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 18),

        errorStyle: AppTheme.smallText.copyWith(
          fontSize: 10,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(105, 110, 116,
                1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 105, 110,
                116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(231, 236, 243, 1),
            width: 2,
          ),
        ),
        // focusColor: MyColors.resolveCompanyCOlour(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(171, 177, 186, 1),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.appColor,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(231, 236, 243, 1),
            width: 2,
          ),
        ),

        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 26, right: 16),
          child: IconTheme(
            data: IconThemeData(color: AppTheme.appColor.withOpacity(0.8)),
            child: Icon(icon),
          ),
        ),
      ),
    );
  }
}
