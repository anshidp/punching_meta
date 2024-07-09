import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:punching_machine/ReportPage/reportPage.dart';
import 'package:punching_machine/model/userdata.dart';
import 'package:punching_machine/utils/utils.dart';

class DailyAttendenceReport extends ConsumerStatefulWidget {
  String docName;

  DailyAttendenceReport({
    super.key,
    // required this.monthlyData,
    required this.docName,
  });

  @override
  ConsumerState<DailyAttendenceReport> createState() =>
      _DailyAttendenceReportState();
}

Map specialDays = {
  "25-12-2024": "Christmas", // Christmas
  "01-01-2024": "New Year", // New Year
  "14-04-2024": "Vishu", // Vishu
  "15-09-2024": "Onam", // Onam
};

Map<String, dynamic> monthconvert = {
  "January": 1,
  "February": 2,
  "March": 3,
  "April": 4,
  "May": 5,
  "June": 6,
  "July": 7,
  "August": 8,
  "September": 9,
  "October": 10,
  "November": 11,
  "December": 12,
};

class _DailyAttendenceReportState extends ConsumerState<DailyAttendenceReport> {
  String text = "";

  replaceData() async {
    final data = await FirebaseFirestore.instance
        .collection("users")
        .doc(ref.read(userProvider).id)
        .collection("attendence")
        .get();

    for (var i in data.docs) {
      DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userProvider).id)
          .collection("attendence")
          .doc(i
              .id) // Assuming the document ID in 'days' is the same as in 'attendance'
          .get();

      Map<String, dynamic> attendanceData = attendanceDoc['attendence'];
      List searching = attendanceDoc['search'];
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userProvider).id)
          .collection("attendance")
          .doc("month")
          .collection("days")
          .doc(i.id)
          .set({"attendance": attendanceData, "search": searching});
    }
  }

  int workingDaysCount = 0;
  int leaves = 0;
  int day = 0;
  Future<List<MonthlyData>> getData(String selectedMonth) async {
    day = 1;
    workingDaysCount = 0;
    leaves = 0;
    List<MonthlyData> monthlydataList = [];

    final attendenceref = FirebaseFirestore.instance
        .collection("users")
        .doc(ref.read(userProvider).id)
        .collection("attendance")
        .doc(widget.docName);

    final data = await FirebaseFirestore.instance
        .collection("users")
        .doc(ref.read(userProvider).id)
        .collection("attendance")
        .doc(widget.docName)
        .collection("days")
        .get();
    for (var data in data.docs) {
      DateTime now = DateTime.now();

      int currentMonth = now.year;

      String punchedIn = data["attendance"]["punchIn"] ?? "N/A";

      String punchedOut = data["attendance"]["punchOut"] ?? "N/A";
      DateTime currentDay = DateTime(now.year, currentMonth, day);

      DateTime days = DateFormat("dd-MM-yyyy").parse(data.id);

      //if (days.isBefore(DateTime.now())) {
      if (punchedIn != "N/A" && punchedIn != "N/A") {
        workingDaysCount++;
      }

      if (specialDays.containsKey(data.id) ||
          punchedIn == "N/A" &&
              punchedOut == "N/A" &&
              days.weekday == DateTime.sunday) {
        workingDaysCount++;
      }

      if (punchedIn == "N/A" &&
          punchedOut == "N/A" &&
          days.weekday != DateTime.sunday &&
          !specialDays.containsKey(data.id) &&
          days.isBefore(DateTime.now())) {
        leaves++;
      }

      day++;

      monthlydataList.add(MonthlyData(
          date: data.id,
          punchedIn: punchedIn,
          punchedOut: punchedOut,
          search: []));
    }
    await attendenceref.update({
      "workingdays": workingDaysCount,
      "totalleave": leaves,
    });
    return monthlydataList;
  }

  double salary = 0;

  double caluculateSalary(
    List<MonthlyData> monthlyData,
  ) {
    var month = monthconvert[widget.docName];
    int daysInMonth = DateTime(DateTime.now().year, month + 1, 0).day;
    double monthlysalary = 10000;
    double fullDaySalary = monthlysalary / daysInMonth;
    double halfdaySalary = fullDaySalary / 2;
    final attendenceref = FirebaseFirestore.instance
        .collection("users")
        .doc(ref.read(userProvider).id)
        .collection("attendance")
        .doc(widget.docName);
    double totalsalary = 0;
    leaves = 0;
    int index = 0;
    for (var i in monthlyData) {
      DateTime parse = DateFormat("dd-MM-yyyy").parse(i.date);
      if (i.punchedIn != "N/A" && i.punchedOut != "N/A" ||
          parse.weekday == DateTime.sunday ||
          specialDays.containsKey(i.date)) {
        DateTime punchin = parseTime(i.punchedIn);
        DateTime punchout = parseTime(i.punchedOut);
        double workingHour =
            punchout.difference(punchin).inHours.abs().toDouble();
        workingHour = workingHour >= 0 ? workingHour : 0;
        if (workingHour >= 8 ||
            parse.weekday == DateTime.sunday ||
            specialDays.containsKey(i.date)) {
          totalsalary = totalsalary + fullDaySalary;
          attendenceref.update({"totalSalary": totalsalary});
        } else {
          if (totalsalary <= 0) {
            totalsalary += halfdaySalary;
            attendenceref.update({"totalSalary": totalsalary});
          } else {
            totalsalary - halfdaySalary;
            attendenceref.update({"totalSalary": totalsalary});
          }
        }
      } else if (i.punchedIn == "N/A" &&
          i.punchedOut == "N/A" &&
          parse.weekday != DateTime.sunday &&
          DateTime.now().isAfter(parse)) {
        (totalsalary - fullDaySalary);
        attendenceref.update({"totalSalary": totalsalary});
      } else {}
      index++;
    }
    return totalsalary;
  }

  @override
  void initState() {
    //getData(widget.docName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //replaceData();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: TextFormField(
                onChanged: (data) {
                  setState(() {
                    text = data;
                  });
                },
                //controller: ,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  hintText: "Search Date",
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder(
                future: getData(widget.docName),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var monthlydata = snapshot.data;
                  double salary = caluculateSalary(monthlydata ?? []);
                  return ListView.builder(
                      itemCount: monthlydata?.length,
                      itemBuilder: (context, index) {
                        var searches = text.isEmpty
                            ? monthlydata
                            : monthlydata!
                                .where(
                                    (element) => element.search!.contains(text))
                                .toList();

                        if (index >= searches!.length) {
                          return const SizedBox();
                        }

                        return GestureDetector(
                          onTap: () {
                            _showMonthlyDetails(searches[index], context,
                                dayStatus(searches[index]));
                          },
                          child: Card(
                            color: const Color(0xff16181D),
                            child: ListTile(
                              title: Text(
                                searches[index].date,
                                style: const TextStyle(
                                    color: Colors.white, fontFamily: "Poppins"),
                              ),
                              trailing: Text(
                                dayStatus(searches[index]),
                                style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        dayColor(dayStatus(searches[index]))),
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  String dayStatus(MonthlyData data) {
    DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(data.date);
    if (data.punchedIn == "N/A" &&
        data.punchedOut == "N/A" &&
        parsedDate.weekday == DateTime.sunday) {
      return "Holiday";
    } else if (data.punchedIn == "N/A" &&
        data.punchedOut == "N/A" &&
        parsedDate.weekday != DateTime.sunday &&
        !specialDays.containsKey(data.date)) {
      return "Leave";
    } else if (data.punchedIn != "N/A" &&
        data.punchedOut == "N/A" &&
        parsedDate.weekday != DateTime.sunday) {
      return "HalfDay";
    } else if (specialDays.containsKey(data.date)) {
      return specialDays[data.date];
    } else {
      return "FullDay";
    }
  }

  Color dayColor(String text) {
    switch (text) {
      case "Leave":
        return Colors.red;
      case "Holiday":
        return Colors.purple;
      case "HalfDay":
        return Colors.deepOrange;
      case "FullDay":
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String calculateDuration(MonthlyData monthlyData) {
    Duration totalDuration = Duration.zero;

    try {
      if (monthlyData.punchedOut == "" || monthlyData.punchedOut == "N/A") {
        totalDuration = Duration.zero;
        monthlyData.time = "HalfDay";
      } else {
        DateTime punchIn = parseTime(monthlyData.punchedIn);
        DateTime punchOut = parseTime(monthlyData.punchedOut);

        totalDuration = punchOut.difference(punchIn);
        if (totalDuration.inHours > 4) {
          monthlyData.time = "FullDay";
        } else {
          monthlyData.time = "HalfDay";
        }
      }
    } catch (e) {
      // print(
      //     'Error parsing time string: ${monthlyData.punchedIn[2]} or ${monthlyData.punchedOut[1]}');
    }

    return "${totalDuration.inHours.remainder(12)} hours ${totalDuration.inMinutes.remainder(60)} minutes";
  }

  void _showMonthlyDetails(
      MonthlyData monthlyData, BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Monthly Punch Data'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildListTile('Date', monthlyData.date),
                _buildListTile('Punch In Times', monthlyData.punchedIn),
                _buildListTile('Punch Out Times', monthlyData.punchedOut),
                _buildListTile(
                    'Total Working Hour', calculateDuration(monthlyData)),
                _buildListTile('Status', status),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListTile(String title, String content) {
    return ListTile(
      title: Text(title),
      subtitle: Text(content),
    );
  }
}
