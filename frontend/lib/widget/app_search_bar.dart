import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
class AppSearchBar extends StatelessWidget{
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: const Color.fromARGB(255, 69, 89, 99), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: AppColors.backgroundMint,
            width: 1.5
          )
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: AppColors.backgroundMint,
            width: 1.5
          )
          
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            width: 2,
            color: AppColors.primary
            )
        )
      ),
    );
  }
}