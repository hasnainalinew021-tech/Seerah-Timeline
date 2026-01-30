import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isLoading;
  final bool isCompact;
  final double? fontSize;
  final double? iconSize;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.label = 'Save',
    this.icon = Icons.check,
    this.backgroundColor = const Color.fromARGB(255, 15, 200, 184),
    this.isLoading = false,
    this.isCompact = false,
    this.fontSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonIconSize = iconSize ?? (isCompact ? 16 : 20);
    final double textSize = fontSize ?? (isCompact ? 14 : 16);
    final EdgeInsets buttonPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: buttonPadding,
            elevation: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: buttonIconSize,
                  height: buttonIconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(icon, color: Colors.white, size: buttonIconSize),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: textSize),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
