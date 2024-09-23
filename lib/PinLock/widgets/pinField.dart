import 'package:flutter/material.dart';

class PinField extends StatefulWidget {
  final String text;
  const PinField({super.key, required this.text});

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: Color(0xffEAF3FF),
            borderRadius: BorderRadius.all(Radius.circular(7))),
        child: Center(
            child: Text(
          widget.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        )),
      ),
    );
  }
}
