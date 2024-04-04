
import 'package:flutter/material.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/widgets/back_button.dart';

class CreateTopBar extends StatelessWidget {
  const CreateTopBar({
    required this.title,
    super.key,
  });

  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 0, bottom: 12, left: 24, right: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomBackButton(),
          Padding(
            padding: const EdgeInsets.only(top: 16.8, left: 16),
            child: Text(
              title,
              style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
            ),
          ),
        ],
      )
    );
  }
}