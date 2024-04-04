import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String? id;
  final String? name;
  final String? number;
  final String? vehicleNumber;
  final String? house;
  final String? block;
  final dynamic exitTime;
  final String? count;
  final dynamic createdOn;

  const Entry({
    this.id,
    this.name,
    this.number,
    this.house,
    this.block,
    this.vehicleNumber,
    this.count,
    this.createdOn,
    this.exitTime,
  });

  static Entry fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Entry(
      id: snapshot["id"],
      name: snapshot["name"],
      number: snapshot["number"],
      house: snapshot["house"],
      block: snapshot['block'],
      count: snapshot["count"],
      vehicleNumber: snapshot["vehicleNumber"],
      createdOn: snapshot["createdOn"] == null
          ? DateTime.now()
          : snapshot["createdOn"].toDate(),
          exitTime: snapshot["exitTime"] == null
          ? ""
          : snapshot["exitTime"].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "number": number,
        "name": name,
        'house':house,
        'block':block,
        "count":count,
        'vehicleNumber':vehicleNumber,
        "createdOn": createdOn,
        "exitTime":exitTime,
      };
}