import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:punching_machine/model/userModel.dart';
import 'package:punching_machine/splashScreen/SplashScreen.dart';
import 'package:punching_machine/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

String currentUser = "";

// class Login_screen extends StatelessWidget {
//   const Login_screen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(26.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("Login Page"),
//             Myform(controller: employeeIdcontroller, text: "EmployeeId"),
//             Myform(controller: passwordcontroller, text: "Password"),
//             ElevatedButton(
//                 onPressed: () async {
//                   print("===========");
//                 },
//                 child: const Text("Login"))
//           ],
//         ),
//       ),
//     );
//   }
// }

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final employeeIdcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(),
            Container(
              padding: const EdgeInsets.only(left: 35, top: 130),
              child: const Text(
                'Welcome\nBack',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            controller: employeeIdcontroller,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                            controller: passwordcontroller,
                            style: const TextStyle(),
                            //obscureText: true,
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sign in',
                                style: TextStyle(
                                    fontSize: 27, fontWeight: FontWeight.w700),
                              ),
                              loading
                                  ? const CircularProgressIndicator()
                                  : CircleAvatar(
                                      radius: 30,
                                      backgroundColor: const Color(0xff4c505b),
                                      child: IconButton(
                                          color: Colors.white,
                                          onPressed: () async {
                                            setState(() {
                                              loading = true;
                                            });
                                            final login =
                                                await FirebaseFirestore.instance
                                                    .collection("users")
                                                    .where(
                                                        "id",
                                                        isEqualTo:
                                                            employeeIdcontroller
                                                                .text)
                                                    .where("delete",
                                                        isEqualTo: false)
                                                    .get();
                                            if (login.docs.isEmpty) {
                                              setState(() {
                                                loading = false;
                                              });
                                              // ignore: use_build_context_synchronously
                                              return showCupertinoSnackBar(
                                                  context: context,
                                                  message:
                                                      "user does not exist",
                                                  color: Colors.red);
                                            } else {
                                              final model = Usermodel.fromJson(
                                                  login.docs[0].data());
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString(
                                                  "userid", model.id ?? "");
                                              currentUser = model.id ?? "";
                                              if (model.id !=
                                                  employeeIdcontroller.text) {
                                                // ignore: use_build_context_synchronously
                                                return showCupertinoSnackBar(
                                                    context: context,
                                                    message:
                                                        "please enter valid employerId",
                                                    color: Colors.red);
                                              } else if (login.docs[0]
                                                      ["password"] !=
                                                  passwordcontroller.text) {
                                                    setState(() {
                                                loading = false;
                                              });
                                                // ignore: use_build_context_synchronously
                                                return showCupertinoSnackBar(
                                                    context: context,
                                                    message:
                                                        "password is incorrect",
                                                    color: Colors.red);
                                              }
                                              // ignore: use_build_context_synchronously
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SplashScreen()),
                                                  (route) => false);
                                            }
                                            
                                            setState(() {
                                              loading = false;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                          )),
                                    )
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
