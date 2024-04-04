import 'package:cloud_firestore/cloud_firestore.dart';

class Stores {
  final String? uid;
  final String? storeId;
  final String? username;
  final String? name;
  final String? type;
  final String? number;
  final String? address;
  final dynamic createdOn;
  final String? area;

  // final String profImage;

  const Stores({
    this.uid,
    this.storeId,
    this.username,
    this.name,
    this.type,
    this.number,
    this.address,
    this.area,
    this.createdOn,
  });

  static Stores fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Stores(
      uid: snapshot["uid"]??'',
      storeId: snapshot["storeId"]??'',
      username: snapshot["username"]??'',
      name: snapshot["name"]??'',
      type: snapshot["type"]??'',
      number: snapshot["number"]??'',
      address: snapshot["address"]??'',
      area: snapshot['area']??'',
      createdOn: snapshot["createdOn"] == null
          ? DateTime.now()
          : snapshot["createdOn"].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "storeId": storeId,
        "name": name,
        'type': type,
        'number': number,
        'address': address,
        "createdOn": createdOn,
        "area": area
      };
}