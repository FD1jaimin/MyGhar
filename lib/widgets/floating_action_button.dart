
import 'package:flutter/material.dart';
import 'package:urbannest/app_theme.dart';

class CustomFloatingActionButton extends StatelessWidget {
   const CustomFloatingActionButton({
    super.key,
    required this.onTap,
  });
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      backgroundColor: AppTheme.buttonColor,
      foregroundColor: Colors.white,
      onPressed: onTap,
      child: const Icon(Icons.add),
    );
  }

  
}