import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validationRegEx;
  final bool obscureText;
  final void Function(String?) onSave;

  const CustomFormField({
    required this.hintText,
    required this.height,
    required this.validationRegEx,
    this.obscureText = false,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSave,
        obscureText: obscureText,
        validator: (value) {
          if (value != null && validationRegEx.hasMatch(value)){
            return null;
          }
          else{
            return "Enter a valid ${hintText.toLowerCase()}";
          }
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
      ),
    );
  }
}
