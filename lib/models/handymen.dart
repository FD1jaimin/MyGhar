import 'package:cloud_firestore/cloud_firestore.dart';

class Handymen {
  final String? id;
  final String? name;
  final String? number;
  final String? image;
  final String? type;
  final bool? inHouse;
  final dynamic createdOn;

  const Handymen({
    this.id,
    this.name,
    this.number,
    this.image,
    this.type,
    this.createdOn,
    this.inHouse,
  });

  static Handymen fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Handymen(
      id: snapshot["id"],
      name: snapshot["name"],
      number: snapshot["number"],
      image: snapshot["image"],
      type: snapshot["type"],
      inHouse: snapshot["inHouse"],
      createdOn: snapshot["createdOn"] == null
          ? DateTime.now()
          : snapshot["createdOn"].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "number": number,
        "name": name,
        'type': type,
        'inHouse': inHouse,
      "createdOn": createdOn,
      "image": image,
      };
}