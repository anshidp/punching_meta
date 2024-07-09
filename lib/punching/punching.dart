import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:punching_machine/Notification/notification.dart';
import 'package:punching_machine/model/attendenceModel.dart';
import 'package:punching_machine/utils/utils.dart';

abstract class Attendence {
  Future<void> punchIn(
      BuildContext context, String currentUserId, String monthDoc);
  Future<void> punchOut(String currentUserId, String monthDoc);
  Future<void> setlocation();
}

class DailyAttendence extends Attendence {
  DateTime punchInDate = DateTime.now();
  @override
  Future<void> punchIn(
      BuildContext context, String currentUserId, String monthDoc) async {
    String doc = DateFormat("dd-MM-yyyy").format(DateTime.now());

    final data = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("attendance")
        .doc(monthDoc)
        .collection("days")
        .doc(doc)
        .get();

    if (data["attendance"].isEmpty) {
      print("currentUserId $currentUserId");
      DateTime now = DateTime.now();
      String punchTime = DateFormat("h:mm a").format(now);
      punchInDate = parseTime(punchTime);
      print("punchTime $doc");
      Map attendence = {"punchIn": punchTime};
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("attendance")
          .doc(monthDoc)
          .collection("days")
          .doc(doc)
          .set({"attendance": attendence, "search": setSearchParam(doc)}).then(
              (value) {
        showCupertinoSnackBar(
            context: context,
            message: 'PunchIn successfully added',
            color: CupertinoColors.activeGreen);
        Navigator.pop(context);
      });
    } else {
      punchInDate = parseTime(data["attendance"]["punchIn"]);

      // ignore: use_build_context_synchronously
      showCupertinoSnackBar(
          context: context,
          message: 'You already punched',
          color: CupertinoColors.systemRed);
      Navigator.pop(context);
    }
  }

  @override
  Future<AttendenceModel> punchOut(
      String currentUserId, String monthDoc) async {
    DateTime now = DateTime.now();
    String doc = DateFormat("dd-MM-yyyy").format(now);
    print("userId $currentUserId");
    print("monthDoc $monthDoc");
    print("doc $doc");
    final data = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("attendance")
        .doc(monthDoc)
        .collection("days")
        .doc(doc)
        .get();

    if (data.exists) {
      return AttendenceModel.fromJson(data.data()!);
    } else {
      print("data not exist");
      return throw Exception();
    }
  }

  @override
  Future<void> setlocation() async {
    Position? location;

    LocationPermission permission = await Geolocator.requestPermission();

    location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    final locationSnapshot = await FirebaseFirestore.instance
        .collection("officeLocation")
        .doc("location")
        .get();

    if (!locationSnapshot.exists) {
      FirebaseFirestore.instance
          .collection("officeLocation")
          .doc("location")
          .set(
              {"latitude": location.latitude, "longitude": location.longitude});
    }

    if (location == LocationPermission.whileInUse ||
        permission == LocationPermission.whileInUse) {
      Geolocator.getPositionStream().listen((position) async {
        double officelatitude = locationSnapshot["latitude"].toDouble();
        double officelongitude = locationSnapshot["longitude"].toDouble();

        double distancemeters = Geolocator.distanceBetween(position.latitude,
            position.longitude, officelatitude, officelongitude);

        String meter = "";
        String kilomiter = "";

        if (distancemeters < 1000) {
          meter = "${distancemeters.toStringAsFixed(2)}m";
        } else {
          // kilomiter=  distancemeters / 1000;
        }

        if (distancemeters <= 1) {
          AttendenceNotificationsSettings().showNotification(
              title: "Punch In",
              body: "You have reached your office.",
              payload: "Punch in now!");
        } else if (distancemeters > 30 && distancemeters < 20) {
          AttendenceNotificationsSettings().showNotification(
              title: "Punch Out",
              body: "You have left your office.",
              payload: "Punch out now!");
        }
      });
    }
  }

  List<DateTime> getAllDaysInMonth(int month, int year) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);

    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    List<DateTime> allDays = [];
    for (DateTime day = firstDayOfMonth;
        day.isBefore(lastDayOfMonth);
        day = day.add(const Duration(days: 1))) {
      allDays.add(day);
    }

    return allDays;
  }

  Future<int> getonTimepercentage(String userid) async {
    try {
      final punchIn = await FirebaseFirestore.instance
          .collection("users")
          .doc(userid)
          .collection("attendance")
          .doc(DateFormat('MMMM').format(DateTime(DateTime.now().year, 1, 1)))
          .collection("days")
          .get();

      if (punchIn.docs.isNotEmpty) {
        final punchdata = punchIn.docs
            .map((e) => e['attendance']['punchIn'])
            .where((element) => element != null)
            .toList();

        return punchdata.length;
      }
      return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }
}
