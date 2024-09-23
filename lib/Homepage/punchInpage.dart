import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:punching_machine/Login/login_Screen.dart';
import 'package:punching_machine/Notification/notification.dart';
import 'package:punching_machine/PinLock/pinLockScreen.dart';
import 'package:punching_machine/model/dayswidget.dart';
import 'package:punching_machine/model/userdata.dart';
import 'package:punching_machine/punching/punching.dart';
import 'package:punching_machine/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slider_button/slider_button.dart';
import 'package:url_launcher/url_launcher.dart';

class PunchInPage extends ConsumerStatefulWidget {
  const PunchInPage({super.key});

  @override
  ConsumerState<PunchInPage> createState() => _PunchInPageState();
}

class _PunchInPageState extends ConsumerState<PunchInPage> {
  void _checkPermissionAndStartTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Geolocator.getPositionStream().listen((Position position) {
      _checkGeofence(position);
    });
  }

  void _checkGeofence(Position position) {
    double distance = Geolocator.distanceBetween(position.latitude,
        position.longitude, 10.986507990766448, 76.22348390294637);

    if (distance >= 7 && distance < 12) {
      _playAlarm();
    }
  }

  void _playAlarm() {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: DarwinNotificationDetails(
      sound: 'clock.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ));
    AttendenceNotificationsSettings().showNotification(
        id: 0, title: "Punch Reminder", body: "Don't forget to punch in!");
  }

  int totalattempteddays = 0;
  final progress = StateProvider<double>((ref) => 0);
  @override
  void initState() {
    super.initState();
    _checkPermissionAndStartTracking();
    // _playAlarm();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(progress.notifier).state = updateElapseTime();
      ref.read(remainingtimeProvider.notifier).state = getRemainingTime();
    });
    getTodayData();

    attempteddays();
    getCasualLeave();
    remainingTime = Duration.zero;
  }

  attempteddays() async {
    totalattempteddays =
        await attendence.getonTimepercentage(ref.read(userProvider).id ?? "");
    setState(() {});
  }

  String punchIn = "N/A";
  String punchOut = "N/A";
  DateTime? casualLeave;
  bool eligibleToCasualLeave = false;
  String workinghour = "";
  Duration totalDuration = Duration.zero;
  late Timer timer;
  late Duration remainingTime;
  final today = DateFormat("dd-MM-yyyy").format(DateTime.now());

  dataAdd() async {
    DateTime startDate = DateTime(2024, 1, 1);
    DateTime endDate = DateTime(2024, 1, 31);

    int numberOfDays = endDate.difference(startDate).inDays;
    for (int i = 0; i <= numberOfDays; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String doc = DateFormat("dd-MM-yyyy").format(currentDate);
      String monthName = DateFormat('MMMM').format(DateTime(2024, i, 1));

      String punchTime = DateFormat("h:mm a").format(DateTime.now());
      DateTime punchInDate = parseTime(punchTime);
      Map attendence = {"punchIn": punchTime};
      await FirebaseFirestore.instance
          .collection("users")
          .doc("FL151")
          .collection("attendance")
          .doc(monthName)
          .collection("Days")
          .doc(doc)
          .set({"attendence": {}});
    }

    // DateTime now = DateTime.now();
  }

  getCasualLeave() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ref.read(userProvider).id)
          .collection('attendance')
          .doc(monthName)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data!.containsKey("casualLeave")) {
          if (snapshot['casualLeave'] != null) {
            setState(() {
              casualLeave = snapshot['casualLeave'].toDate();
              eligibleToCasualLeave =
                  casualLeave!.difference(DateTime.now()).inDays >= 60;
            });
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getTodayData() async {
    final todayData = await FirebaseFirestore.instance
        .collection("users")
        .doc(ref.read(userProvider).id)
        .collection("attendance")
        .doc(monthName)
        .collection("days")
        .doc(today)
        .get();

    if (todayData.exists) {
      setState(() {
        punchIn = todayData["attendance"]["punchIn"] ?? "N/A";
        punchOut = todayData["attendance"]["punchOut"] ?? "N/A";
      });
      if (punchIn == "N/A" && punchOut == "N/A") {
        setState(() {
          totalDuration = Duration.zero;
          workinghour =
              " ${totalDuration.inHours.remainder(12)} hours ${totalDuration.inMinutes.remainder(60)} minutes";
        });
      } else {
        DateTime iN = parseTime(punchIn);
        DateTime out = parseTime(punchOut);
        setState(() {
          totalDuration = out.difference(iN);
          workinghour =
              " ${totalDuration.inHours.remainder(12)} hours ${totalDuration.inMinutes.remainder(60)} minutes";
        });
      }
    } else {
      dataAdd();
    }
  }

  void updateRemainTime() {
    DateTime iN = parseTime(punchIn);

    Duration difference = DateTime.now().difference(iN);

    Duration eightHour = const Duration(hours: 8);
    setState(() {
      if (difference < eightHour && punchOut == "N/A" && punchIn != "N/A") {
        remainingTime = eightHour - difference;
      } else {
        remainingTime = Duration.zero;
        timer.cancel();
      }
    });
  }

  double updateElapseTime() {
    DateTime iN = parseTime(punchIn);

    Duration difference = DateTime.now().difference(iN);

    Duration eightHour = const Duration(hours: 8);

    if (difference.isNegative) {
      return 0;
    } else if (difference >= eightHour) {
      return 1.0;
    } else {
      return difference.inSeconds / eightHour.inSeconds;
    }
  }

  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString();
    String minutes = (duration.inMinutes % 60).toString();
    String seconds = (duration.inSeconds % 60).toString();
    return '$hours hours $minutes minutes $seconds seconds';
  }

  Icon? icon;
  String getMessage() {
    DateTime iN = parseTime(punchIn);

    Duration difference = DateTime.now().difference(iN);

    Duration eightHour = const Duration(hours: 8);
    if (remainingTime == Duration.zero && difference >= eightHour) {
      icon = const Icon(
        Icons.check_box,
        color: Colors.green,
      );
      return '8 hours completed!';
    } else if (difference < eightHour && punchOut != "N/A" ||
        punchIn == "N/A" && punchOut == "N/A") {
      icon = const Icon(
        Icons.close_outlined,
        color: Colors.red,
      );
      return '8 hours Not completed!';
    } else {
      icon = null;
      return formatDuration(remainingTime);
    }
  }

  final remainingtimeProvider = StateProvider((ref) => "");
  String getRemainingTime() {
    DateTime punchInTime = parseTime(punchIn);
    DateTime endTime = punchInTime.add(const Duration(hours: 8));
    Duration remaining = endTime.difference(DateTime.now());

    if (remaining.isNegative) {
      return "00:00";
    } else {
      int hours = remaining.inHours;
      int minutes = remaining.inMinutes.remainder(60);
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
    }
  }

  void addCasulaleave(String doc) async {
    try {
      final today = DateTime.now();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.watch(userProvider).id)
          .collection("attendance")
          .doc(monthName)
          // .collection("days")
          // .doc(doc)
          .update({"casualLeave": today});
      if (context.mounted) {
        showCupertinoSnackBar(
            context: context,
            message: "Your CasualLeave successfully added",
            color: Colors.green);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  DailyAttendence attendence = DailyAttendence();
  String monthName = DateFormat('MMMM').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090B0F),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 60,
          ),
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Color(0xff16181D),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: topappbar(eligibleToCasualLeave),
              ),
              //! Days widget
              const DaysWidget(),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(ref.read(userProvider).id)
                      .collection("attendance")
                      .doc(monthName)
                      .collection("days")
                      .doc(ref.watch(selectedDateProvider).isEmpty
                          ? today
                          : ref.watch(selectedDateProvider))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var data = snapshot.data!;
                      punchIn = data["attendance"]["punchIn"] ?? "N/A";
                      punchOut = data["attendance"]["punchOut"] ?? "N/A";

                      bool ispunched = punchIn != "N/A";
                      bool ispunchOut = punchOut != "N/A";
                      if (punchIn == "N/A" || punchOut == "N/A") {
                        totalDuration = Duration.zero;
                        workinghour =
                            " ${totalDuration.inHours.remainder(12)} hours ${totalDuration.inMinutes.remainder(60)} minutes";
                      } else {
                        DateTime iN = parseTime(punchIn);
                        DateTime Out = parseTime(punchOut);

                        totalDuration = Out.difference(iN);
                        workinghour =
                            " ${totalDuration.inHours.remainder(12)} hours ${totalDuration.inMinutes.remainder(60)} minutes";
                      }
                      return Container(
                        decoration: const BoxDecoration(
                            color: Color(0xff090B0F),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        width: double.maxFinite,
                        height: 700,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              height: 350,
                              child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 4,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing: 10,
                                          childAspectRatio: 1.6,
                                          mainAxisSpacing: 10,
                                          crossAxisCount: 2),
                                  itemBuilder: (context, index) => checkincard(
                                      index: index,
                                      time: index == 0
                                          ? punchIn
                                          : index == 1
                                              ? punchOut
                                              : index == 2
                                                  ? workinghour
                                                  : totalattempteddays
                                                      .toString(),
                                      title: index == 0
                                          ? "Checked in"
                                          : index == 1
                                              ? "Checked out"
                                              : index == 2
                                                  ? "Working hour"
                                                  : "Total Working Days")),
                            ),

                            //! Casual Leave
                            if (casualLeave == null && eligibleToCasualLeave)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 18),
                                  child: GestureDetector(
                                    onTap: () {
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return CupertinoAlertDialog(
                                              title: const Text(""),
                                              content: const Text(
                                                  "Do you want Add casual Leave today?"),
                                              actions: [
                                                CupertinoDialogAction(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("No")),
                                                CupertinoDialogAction(
                                                    onPressed: () async {
                                                      String doc = DateFormat(
                                                              "dd-MM-yyyy")
                                                          .format(
                                                              DateTime.now());
                                                      addCasulaleave(doc);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Yes"))
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      width: 110,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xff16181D),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Casual Leave",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(),
                            Consumer(builder: (context, ref, child) {
                              ref.watch(remainingtimeProvider);
                              ref.watch(progress);
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: CircularProgressIndicator(
                                        backgroundColor:
                                            const Color(0xff16181D),
                                        strokeCap: StrokeCap.round,
                                        value: ref.read(progress),
                                        strokeWidth: 12,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                          Color(0xff4FFFCA),
                                        )),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        ref.read(remainingtimeProvider),
                                        style: const TextStyle(
                                            fontFamily: "Inter",
                                            fontSize: 35,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Text(
                                        "to work time",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Inter",
                                            fontSize: 15),
                                      )
                                    ],
                                  )
                                ],
                              );
                            }),
                            const SizedBox(
                              height: 30,
                            ),
                            ispunched && ispunchOut == false
                                ? Center(
                                    child: SliderButton(
                                        shimmer: false,
                                        backgroundColor:
                                            const Color(0xff16181D),
                                        action: () async {
                                          final attendenceData =
                                              await DailyAttendence().punchOut(
                                                  ref.watch(userProvider).id ??
                                                      "",
                                                  monthName);

                                          String doc = DateFormat("dd-MM-yyyy")
                                              .format(DateTime.now());

                                          DateTime punchInDate = parseTime(
                                              attendenceData
                                                      .attendence?["punchIn"] ??
                                                  "");

                                          var difference = DateTime.now()
                                              .difference(punchInDate);

                                          if (difference.inHours < 8 &&
                                              attendenceData.attendence!
                                                  .containsKey("punchOut")) {
                                            if (punchIn == "N/A") {
                                              showCupertinoSnackBar(
                                                  context: context,
                                                  message:
                                                      'You can punchout only by punching in',
                                                  color: CupertinoColors
                                                      .systemRed);
                                              return;
                                            }
                                            // ignore: use_build_context_synchronously
                                            showCupertinoDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return CupertinoAlertDialog(
                                                    title: const Text(""),
                                                    content: const Text(
                                                        "Do you want half day today?"),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("No")),
                                                      CupertinoDialogAction(
                                                          onPressed: () async {
                                                            String
                                                                punchOutTime =
                                                                DateFormat(
                                                                        "h:mm a")
                                                                    .format(DateTime
                                                                        .now());
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "users")
                                                                .doc(ref
                                                                    .read(
                                                                        userProvider)
                                                                    .id)
                                                                .collection(
                                                                    "attendance")
                                                                .doc(monthName)
                                                                .collection(
                                                                    "days")
                                                                .doc(doc)
                                                                .update({
                                                              "attendance.punchOut":
                                                                  punchOutTime
                                                            });
                                                            // ignore: use_build_context_synchronously
                                                            showCupertinoSnackBar(
                                                                context:
                                                                    context,
                                                                message:
                                                                    'Punchout successfully added',
                                                                color: CupertinoColors
                                                                    .activeGreen);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("Yes"))
                                                    ],
                                                  );
                                                });
                                          } else if (!attendenceData.attendence!
                                              .containsKey("punchOut")) {
                                            String punchOutTime =
                                                DateFormat("h:mm a")
                                                    .format(DateTime.now());

                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(ref.watch(userProvider).id)
                                                .collection("attendance")
                                                .doc(monthName)
                                                .collection("days")
                                                .doc(doc)
                                                .update({
                                              "attendance.punchOut":
                                                  punchOutTime
                                            });
                                            // ignore: use_build_context_synchronously
                                            showCupertinoSnackBar(
                                                context: context,
                                                message:
                                                    'Punchout successfully added',
                                                color: CupertinoColors
                                                    .activeGreen);
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            showCupertinoSnackBar(
                                                context: context,
                                                message:
                                                    'Your already Punchout today',
                                                color:
                                                    CupertinoColors.systemRed);
                                          }
                                          return null;
                                        },
                                        label: const Text(
                                          "Swipe to Check out",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17),
                                        ),
                                        icon: const CircleAvatar(
                                          radius: 44,
                                          backgroundColor: Color(0xff4FFFCA),
                                          child: Icon(Icons.arrow_forward),
                                        )))
                                : ispunched == false && ispunchOut == false
                                    ? Center(
                                        child: SliderButton(
                                            shimmer: false,
                                            backgroundColor:
                                                const Color(0xff16181D),
                                            action: () async {
                                              // final authenticate =
                                              //     await LocalAuth.authenticate();
                                              // if (authenticate) {
                                              //updateRemainTime();
                                              debugPrint(
                                                  "authentication success");
                                              // ignore: use_build_context_synchronously
                                              showCupertinoDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return CupertinoAlertDialog(
                                                      title: const Text(""),
                                                      content: const Text(
                                                          "Do you want punched in?"),
                                                      actions: [
                                                        CupertinoDialogAction(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "No")),
                                                        CupertinoDialogAction(
                                                            onPressed:
                                                                () async {
                                                              attendence.punchIn(
                                                                  context,
                                                                  ref
                                                                          .watch(
                                                                              userProvider)
                                                                          .id ??
                                                                      "",
                                                                  monthName);
                                                              // timer = Timer.periodic(
                                                              //     const Duration(
                                                              //         seconds: 1),
                                                              //     (timer) {
                                                              //   updateRemainTime();
                                                              // });

                                                              AttendenceNotificationsSettings()
                                                                  .schduleNotification();
                                                            },
                                                            child: const Text(
                                                                "Yes"))
                                                      ],
                                                    );
                                                  });
                                              //}
                                              // else {
                                              //   debugPrint("authentication failed");
                                              // }
                                              return true;
                                            },
                                            label: const Text(
                                              "Swipe to Check in",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 17),
                                            ),
                                            icon: const CircleAvatar(
                                              radius: 44,
                                              backgroundColor:
                                                  Color(0xff4FFFCA),
                                              child: Icon(Icons.arrow_forward),
                                            )))
                                    : const SizedBox()
                          ],
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget topappbar(bool casualLeave) {
    return Row(children: [
      CircleAvatar(
        backgroundImage: NetworkImage(ref.read(userProvider).image ?? ""),
        radius: 25,
        backgroundColor: Colors.black,
      ),
      const SizedBox(
        width: 20,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PinLockScreen()));
            },
            child: Text(
              ref.read(userProvider).name ?? "",
              style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          const Text(
            "Software Developer",
            style: TextStyle(
                fontFamily: "Poppins", fontSize: 13, color: Colors.white),
          ),
        ],
      ),
      if (casualLeave)
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
          child: InkWell(
            onTap: () {
              sendEmailTL();
            },
            child: const Text(
              "Request ClLeave",
              style: TextStyle(
                  fontFamily: "Poppins", fontSize: 14, color: Colors.white),
            ),
          ),
        )
    ]);
  }

  Widget checkincard(
      {required String time, required String title, required int index}) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: const BoxDecoration(
            color: Color(0xff16181D),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        width: 300,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 18, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time.toString(),
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize:
                            index == 0 || index == 1 || index == 3 ? 20 : 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
              index == 0 || index == 1 || index == 3
                  ? const Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ))
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userid");
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyLogin()),
        (route) => false);
  }

  void sendEmailTL() async {
    try {
      print("kk");
      String? encodeQueryParameters(Map<String, String> params) {
        return params.entries.map((MapEntry<String, String> e) {
          return '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}';
        }).join('&');
      }

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'tl@firstlogicmetalab.com',
        query: encodeQueryParameters(<String, String>{
          'subject': 'Casual Leave',
        }),
      );

      await launchUrl(emailLaunchUri);
    } catch (e) {
      print(e.toString());
    }
  }
}
