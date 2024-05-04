import 'package:flutter/material.dart';

class Myform extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  const Myform({super.key,required this.controller,required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF6F6F6F)),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey)),
            hintText: text),
      ),
    );
  }
}
