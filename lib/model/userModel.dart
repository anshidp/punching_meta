// ignore_for_file: public_member_api_docs, sort_constructors_first
class Usermodel {
  String? name;
  String? id;
  DateTime? createdDate;
  bool? delete;
  String? image;
  Usermodel({this.name, this.id, this.createdDate, this.delete, this.image});

  Usermodel.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    id = json["id"];
    createdDate =
        json["createdDate"] != null ? null : json["createdDate"].toDate();
    delete = json["delete"];
    image = json["image"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["name"] = name;
    map["id"] = id;
    map["createdDate"] = createdDate;
    map["delete"] = delete;
    map["image"] = image;
    return map;
  }
}
