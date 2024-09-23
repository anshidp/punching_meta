import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:punching_machine/PinLock/widgets/pinField.dart';
import 'package:punching_machine/PinLock/widgets/pinKeys.dart';
import 'package:punching_machine/model/userdata.dart';
import 'package:punching_machine/navbar/navpage.dart';
import 'package:punching_machine/utils/utils.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  List<String> pins = ["", "", "", ""];
  int currentIndex = 0;
  String activekey = "";

  void pincheck(String pin) {
    setState(() {
      if (currentIndex < 4) {
        pins[currentIndex] = pin;
        activekey = pin;
        currentIndex++;

        if (currentIndex == 4) {
          if (pins.join() == ref.read(userProvider).mpin) {
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (ctx) => const Navbar()),
                  (route) => false);
            }
          } else {
            setState(() {
              currentIndex = 0;
              activekey = "";
              pins = ["", "", "", ""];
            });
            return showCupertinoSnackBar(
                context: context,
                message: "Entered wrong pin",
                color: Colors.red);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 23),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter PIN code",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Please enter your PIN",
                style: TextStyle(color: Color(0xff797979), fontSize: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    List.generate(4, (index) => PinField(text: pins[index])),
              ),
              const SizedBox(
                height: 20,
              ),
              PinKeys(
                checkpin: pincheck,
                activeKey: activekey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
