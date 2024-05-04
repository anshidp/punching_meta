import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:punching_machine/ReportPage/dailyAttendence.dart';
import 'package:punching_machine/model/userdata.dart';
import 'package:punching_machine/utils/utils.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

var search = StateProvider((ref) => "");

class _ReportPageState extends ConsumerState<ReportPage> {
  List months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  void dataAdding() {
    String userId = ref.read(userProvider).id ?? "";

    DateTime startYear = DateTime(2024, 1, 1);
    DateTime endYear = DateTime(2024, 12, 31);

    for (DateTime currentDate = startYear;
        currentDate.isBefore(endYear) || currentDate.isAtSameMomentAs(endYear);
        currentDate = currentDate.add(const Duration(days: 1))) {
      String formattedDate = DateFormat("dd-MM-yyyy").format(currentDate);
      String monthName = DateFormat('MMMM').format(currentDate);

      print(formattedDate);
      String punchTime = DateFormat("h:mm a").format(DateTime.now());
      DateTime punchInDate = parseTime(punchTime);
      Map<String, dynamic> attendance = {};

      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("attendance")
          .doc(monthName) // Use monthName as the document ID for each month
          .set({"monthName": monthName}, SetOptions(merge: true)).then((_) {
        // Add attendance data to the "days" subcollection
        FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("attendance")
            .doc(monthName)
            .collection("days")
            .doc(formattedDate)
            .set({"attendance": attendance});
      }).catchError((error) {
        print("Error adding attendance data: $error");
      });
    }
  }

  int workingDaysCount = 0;
  int leaves = 0;

  List<double> totalsalary = List.filled(12, 0);
  List<int> totalworkingdays = List.filled(12, 0);
  List<int> totalLeave = List.filled(12, 0);
  // List<double> totalsa = List.filled(12, 0);

  getdata() async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(ref.read(userProvider).id)
        .collection("attendance")
        .get();
    for (var i in data.docs) {
      // totalsalary.fillRange(0, 12, 0);
      // totalsalary.add(double.tryParse(i["totalSalary"].toString()) ?? 0);
      int index = months.indexWhere((element) => element == i.id);
      totalsalary[months.indexWhere((element) => element == i.id)] =
          double.tryParse(i["totalSalary"].toString()) ?? 0;
      totalworkingdays[index] = (i["workingdays"] ?? 0);

      totalLeave[index] = (i["totalleave"] ?? 0);
    }
    setState(() {});
  }

  Stream<Map<String, List<MonthlyData>>> listenToMonthlyDataChange() {
    print(ref.read(userProvider).id);
    workingDaysCount = 0;
    leaves = 0;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(ref.read(userProvider).id)
        .collection("attendence")
        .snapshots()
        .asyncMap((querySnapshot) async {
      Map<String, List<MonthlyData>> monthlyDataMap = {};

      for (QueryDocumentSnapshot monthDoc in querySnapshot.docs) {
        String month = monthDoc.id;
        List<MonthlyData> monthlydataList = [];

        QuerySnapshot dayQuerySnapshot =
            await monthDoc.reference.collection("days").get();

        for (QueryDocumentSnapshot dayDoc in dayQuerySnapshot.docs) {
          String date = dayDoc.id;
          String punchedIn = dayDoc["attendence"]["punchIn"] ?? "N/A";
          String punchedOut = dayDoc["attendence"]["punchOut"] ?? "N/A";
          // List search = dayDoc["search"] ?? [];

          monthlydataList.add(MonthlyData(
            date: date,
            punchedIn: punchedIn,
            punchedOut: punchedOut,
            search: [],
          ));
        }

        monthlyDataMap[month] = monthlydataList;
      }

      return monthlyDataMap;
    });
  }

  double monthlysalary = 10000;
  double fullDaySalary = 333;
  double halfdaySalary = 166.666667;
  double caluculateSalary(List<MonthlyData> monthlyData) {
    double totalsalary = 0;
    for (var i in monthlyData) {
      print(specialDays.containsKey(i.date));
      print("salary $totalsalary");
      DateTime parse = DateFormat("dd-MM-yyyy").parse(i.date);

      if (i.punchedIn != "N/A" && i.punchedOut != "N/A" ||
          parse.weekday == DateTime.sunday ||
          specialDays.containsKey(i.date)) {
        print("work first if");
        // print("0");
        DateTime punchin = parseTime(i.punchedIn);
        // print("1");
        DateTime punchout = parseTime(i.punchedOut);
        //print("2");
        double workingHour =
            punchout.difference(punchin).inHours.abs().toDouble();

        workingHour = workingHour >= 0 ? workingHour : 0;

        if (workingHour >= 8 ||
            parse.weekday == DateTime.sunday ||
            specialDays.containsKey(i.date)) {
          //print("if work");
          totalsalary = totalsalary + fullDaySalary;
        } else {
          print("work first else");
          //print("else work");
          if (totalsalary <= 0) {
            totalsalary += halfdaySalary;
          } else {
            totalsalary - halfdaySalary;
          }
          //print("6");
        }
      } else if (i.punchedIn == "N/A" &&
          i.punchedOut == "N/A" &&
          parse.weekday != DateTime.sunday &&
          DateTime.now().isAfter(parse)) {
        print(parse);
        print("print work else if");
        // print("isbefore ${DateTime.now().isBefore(parse)}");
        // print("date $parse");
        // print("else");
        (totalsalary - fullDaySalary);
        print("total $totalsalary");
      } else {
        print("work last else");
        //print("last");
        //totalsalary - halfdaySalary;
      }
    }
    return totalsalary;
  }

  dataAdd() {
    DateTime startDate = DateTime(2024, 1, 1);
    DateTime endDate = DateTime(2024, 1, 31);

    int numberOfDays = endDate.difference(startDate).inDays;
    for (int i = 0; i <= numberOfDays; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String doc = DateFormat("dd-MM-yyyy").format(currentDate);

      print(doc);
      String punchTime = DateFormat("h:mm a").format(DateTime.now());
      DateTime punchInDate = parseTime(punchTime);
      Map attendence = {"punchIn": punchTime};
      FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userProvider).id)
          .collection("attendence")
          .doc(doc)
          .update({"search": setSearchParam(doc)});
    }
    // DateTime now = DateTime.now();
  }

  @override
  void initState() {
    print("init");
    getdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //getMonths();
    //copyFirebase();
    //dataAdding();
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
            child: ListView.builder(
                itemCount: months.length,
                //months?.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DailyAttendenceReport(
                                    docName: months[index],
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Container(
                        width: 700,
                        height: 130,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 2,
                                color: Colors.grey.shade500,
                                spreadRadius: 1,
                                offset: const Offset(1, 0.3)),
                            // BoxShadow(blurRadius: 3, color: Colors.black45,offset: Offset(0.3, 0.4))
                          ],
                          borderRadius: BorderRadius.circular(13),
                          gradient: const LinearGradient(colors: [
                            Color.fromARGB(255, 35, 45, 101),
                            Color.fromARGB(255, 102, 198, 163)
                          ]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                months[index],
                                //format,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    color: Color.fromARGB(255, 214, 212, 217)),
                              ),
                              Text(
                                "Total Working days : ${totalworkingdays[index]}",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                "Total Salary : ${totalsalary[index].floorToDouble()}",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                "Total Leaves : ${totalLeave[index]}",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }))
      ]),
    );
  }
}

class MonthlyData {
  final String date;
  final String punchedIn;
  final String punchedOut;
  String? time;
  int? workingCount;
  List? search;

  MonthlyData(
      {required this.date,
      required this.punchedIn,
      required this.punchedOut,
      this.workingCount,
      this.search,
      this.time});
}
