import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
    this.color = Colors.black,
    this.textAlign = TextAlign.start,
    this.decoration = TextDecoration.none,
    this.maxLines,
    this.overflow,
    this.shadows,
    this.letterSpace,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final TextDecoration decoration;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpace;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      softWrap: true,
      style: GoogleFonts.poppins(
        decoration: decoration,
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
        shadows: shadows,
        letterSpacing: letterSpace,
      ),
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
