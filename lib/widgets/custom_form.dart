import 'package:flutter/material.dart';

class CustomForm extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validationRegExp;
  final bool obscureText;
  final  void Function(String?) onSave;

  const CustomForm(
      {super.key,
      required this.hintText,
      required this.height,
      required this.validationRegExp,
      required this.onSave,
       this.obscureText =false,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSave,
        obscureText: obscureText,
        validator: (value) {
          if (value != null && validationRegExp.hasMatch(value)) {
            return null;
          }
            return "Enter a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
            hintText: hintText, border: const OutlineInputBorder()),
      ),
    );
  }
}
