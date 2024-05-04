import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:punching_machine/Login/login_Screen.dart';
import 'package:punching_machine/model/userModel.dart';
import 'package:punching_machine/model/userdata.dart';
import 'package:punching_machine/navbar/navpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

String currentUserId = "";

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("userid")) {
      var id = prefs.getString("userid");
      print("0");

      final data = await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: id)
          .get();
      if (data.docs.isNotEmpty) {
        final userdata = data.docs.first;

        final usermodel = Usermodel.fromJson(userdata.data());
        print("3");
        final notifier = ref.watch(userProvider.notifier);
        print("4");
        notifier.updateUser(usermodel);
        currentUserId = usermodel.id ?? "";
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Navbar()),
              (route) => false);
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyLogin()),
            (route) => false);
      }

      // ignore: use_build_context_synchronously
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyLogin()),
          (route) => false);
    }
  }

  @override
  void initState() {
    print("init work");
    checkLogin();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: SizedBox(
                  width: 200,
                  height: 150,
                  child: SvgPicture.asset("assets/splash.svg")))
        ],
      ),
    );
  }
}
