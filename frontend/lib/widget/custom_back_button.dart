import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.color
    });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      tooltip: 'Back', 
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: color ?? AppColors.primary,
      )
    );
  }
}