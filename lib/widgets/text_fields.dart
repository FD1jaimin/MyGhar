// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:urbannest/app_theme.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, 
     this.icon,
    this.hint = "",
    this.isForm = false,
    this.obsecure = false,
    required this.validator,
    // this.onSaved,
    required this.textController,
    this.focusNode,
    this.suffix,
    this.readOnly = false,
    // this.initialValue = "",
    this.onChanged,
    this.onTap,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.expands = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
  });
  // final FormFieldSetter<String> onSaved;
  final Icon? icon;
  final bool isForm;
  final FocusNode? focusNode;
  final String hint;
  final Widget? suffix;
  final bool obsecure, readOnly;
  final FormFieldValidator<String> validator;
  final TextEditingController textController;
  final TextInputType keyboardType;
  final  onChanged;
  final int? maxLength;
  final TextAlign textAlign;
  final onTap;
  // final String initialValue;
  final int maxLines, minLines;
  final bool autofocus;
  final bool expands;

  @override
  Widget build(BuildContext context) {
    BorderRadius r =
        isForm ? BorderRadius.circular(16) : BorderRadius.circular(30);
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: key,
      onTap: onTap,
      keyboardType: keyboardType,
      focusNode: focusNode,
      // onSaved: onSaved,
      validator: validator,
      autofocus: autofocus,
      obscureText: obsecure,
      maxLength: maxLength,
      readOnly: readOnly,
      textAlign: textAlign,
      // initialValue: initialValue,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      expands: expands,
      style: AppTheme.subheading3,
      decoration: InputDecoration(
          hintStyle: AppTheme
              .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
          hintText: hint,
          contentPadding: isForm
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 20)
              : const EdgeInsets.only(left:24,top: 24,bottom: 24,right: 12),
          errorStyle: AppTheme.smallText.copyWith(
            fontSize: 10,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: r,
            borderSide: const BorderSide(
              color: Color.fromRGBO(105, 110, 116,
                  1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: r,
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 105, 110,
                  116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: r,
            borderSide: const BorderSide(
              color: Color.fromRGBO(231, 236, 243, 1),
              width: 2,
            ),
          ),
          // focusColor: MyColors.resolveCompanyCOlour(),
          enabledBorder: OutlineInputBorder(
            borderRadius: r,
            borderSide: const BorderSide(
              color: Color.fromRGBO(171, 177, 186, 1),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: r,
            borderSide: BorderSide(
              color: AppTheme.appColor,
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: r,
            borderSide: const BorderSide(
              color: Color.fromRGBO(231, 236, 243, 1),
              width: 2,
            ),
          ),
          suffixIcon:  suffix ?? null,
              
          prefixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 26, right: 16),
                  child: IconTheme(
                    data: IconThemeData(
                        color: AppTheme.appColor.withOpacity(0.8)),
                    child: icon!,
                  ),
                )
              : null),
      controller: textController,
    );
  }
}
