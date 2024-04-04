
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.values,
    this.value,
    this.hint,
    required this.selectedValue,
  });

  final List<String> values;
  final String? hint;
  final String? value;
  final TextEditingController selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(171, 177, 186, 1),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(171, 177, 186, 1),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(171, 177, 186, 1),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromRGBO(171, 177, 186, 1),
            width: 2,
          ),
        ),
      ),
      value: value,
      hint: Text(
        hint!,
        style: AppTheme.smallText,
      ),
      items: values
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: AppTheme.subheading3),
              ))
          .toList(),
      validator: (value) {
        // if (value == null) {
        // return 'Please select number of people';
        // }
        return null;
      },
      onChanged: (value) {
        selectedValue.text = value.toString();
        // setState(() {});
        //Do something when selected item is changed.
      },
      onSaved: (value) {
        selectedValue.text = value.toString();
        // setState(() {});
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppTheme.lightText,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}