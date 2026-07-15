import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.letterSpacing,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
  });

  final String text;
  final VoidCallback onPressed;
  final double? letterSpacing;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Background color
          backgroundColor: backgroundColor ?? Colors.black87,
          // padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style:
                TextStyle(fontSize: fontSize ?? 18, letterSpacing: letterSpacing, color: textColor),
          ),
        ),
      ),
    );
  }
}
