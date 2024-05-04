import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCupertinoSnackBar({
  required BuildContext context,
  required String message,
  required Color color
}) {
  final snack = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2));
  ScaffoldMessenger.of(context).showSnackBar(snack);
}


DateTime parseTime(String timeString) {
  List<String> timeParts = timeString.split(RegExp(r'[^0-9APMapm]'));

  if (timeParts.length >= 2) {
    int hours = int.tryParse(timeParts[0]) ?? 0;
    int minutes = int.tryParse(timeParts[1]) ?? 0;

    if (timeString.toLowerCase().contains('pm') && hours < 12) {
      hours += 12;
    } else if (timeString.toLowerCase().contains('am') && hours == 12) {
      hours = 0;
    }

    return DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hours, minutes);
  }

  return DateTime.now();
}
DateTime parseDate(String dateString) {
  List<String> dateParts = dateString.split("-");

  if (dateParts.length == 3) {
    int day = int.tryParse(dateParts[0]) ?? 1;
    int month = int.tryParse(dateParts[1]) ?? 1;
    int year = int.tryParse(dateParts[2]) ?? DateTime.now().year;

    return DateTime(year, month, day, 0, 0, 0, 0);
  }

  // Default to the current date if parsing fails
  return DateTime.now();
}

setSearchParam(String caseNumber) {
  List<String> caseSearchList = <String>[];
  String temp = "";

  List<String> nameSplits = caseNumber.split(" ");
  for (int i = 0; i < nameSplits.length; i++) {
    String name = "";

    for (int k = i; k < nameSplits.length; k++) {
      name = "$name${nameSplits[k]} ";
    }
    temp = "";

    for (int j = 0; j < name.length; j++) {
      temp = temp + name[j];
      caseSearchList.add(temp.toUpperCase());
    }
  }
  return caseSearchList;
}