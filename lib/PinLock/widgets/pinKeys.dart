import 'package:flutter/material.dart';

class PinKeys extends StatefulWidget {
  void Function(String) checkpin;
  final String activeKey;
  PinKeys({super.key, required this.checkpin, required this.activeKey});

  @override
  State<PinKeys> createState() => _PinKeysState();
}

class _PinKeysState extends State<PinKeys> {
  List<List<String>> keys = [
    ["1", "2", "3"],
    ["4", "5", "6"],
    ["7", "8", "9"],
    ["0"]
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: keys.map((keys) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: keys.map((key) {
                return buildKey(key);
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildKey(
    String text,
  ) {
    return AnimatedContainer(
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 350),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          maximumSize: const Size(100, 90),
          foregroundColor:
              widget.activeKey == text ? Colors.white : Colors.black,
          backgroundColor: widget.activeKey != text
              ? const Color(
                  0xffEAF3FF,
                )
              : const Color(0xff0355c7),
          elevation: 5,
          shape: const CircleBorder(),
          //padding: const EdgeInsets.all(25),
        ),
        onPressed: () {
          widget.checkpin(text);
        },
        child: Center(
            child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: widget.activeKey == text ? Colors.white : Colors.black,
          ),
        )),
      ),
    );
  }
}
