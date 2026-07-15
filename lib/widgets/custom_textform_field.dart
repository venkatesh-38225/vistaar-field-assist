import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.hintText,
    required this.onSaved,
    required this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText,
    this.autovalidateMode,
    this.textInputAction,
    this.prefixIcon,
    required this.controller,
    this.readOnly = false,
    this.inputFormatters,
    this.contentPadding,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
  });

  final String? hintText;
  final Function(String? value) onSaved;
  final IconButton? suffixIcon;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final String? Function(dynamic value) validator;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade300 : Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(1, 1),
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        focusNode: focusNode,
        readOnly: readOnly,
        controller: controller,
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        obscureText: obscureText ?? false,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          // labelText: labelText,
          hintText: hintText,
          contentPadding: contentPadding,
          labelStyle: const TextStyle(color: Colors.black87),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: readOnly ? Colors.grey.shade500 : Colors.black,
                width: 0.5),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
          suffixIcon: suffixIcon,
          // prefix: Icon(prefixIcon),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
