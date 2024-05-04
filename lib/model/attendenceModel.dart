// ignore_for_file: public_member_api_docs, sort_constructors_first
class AttendenceModel {
  Map? attendence;
  // String? punchIn;
  // String? punchOut;
  // bool? isPunchIn;
  // String? date;
  AttendenceModel({
    this.attendence,
    // this.punchIn,
    // this.punchOut,
    // this.isPunchIn,
    // this.date,
  });

  AttendenceModel.fromJson(Map<String, dynamic> json) {
    attendence = json["attendance"];
    // punchIn = json["punchIn"];
    // punchOut = json["punchOut"];
    // isPunchIn = json["isPunchIn"];
    // date = json["date"];
  }

  Map<String, dynamic> tojson() {
    Map<String, dynamic> data = {};
    data["attendance"] = attendence;
    // data["punchOut"] = punchOut;
    // data["isPunchIn"] = isPunchIn;
    return data;
  }
}
