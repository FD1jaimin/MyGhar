
import 'package:cloud_firestore/cloud_firestore.dart';

class Amenity {
  final String? uid;
  final String? id;
  final String? name;
  final String? username;
  final String? image;
  final String? amount;
  final String? body;
  final int? datePublished;
  final dynamic from;
  final dynamic to;
  final String? upi;
  final String? type;
  final String? status;
  final dynamic createdOn;

  // final String profImage;

  const Amenity({
    this.uid,
    this.id,
    this.name,
    this.username,
    this.image,
    this.amount,
    this.upi,
    this.body,
    this.datePublished,
    this.createdOn,
    this.from,
    this.type,
    this.to,

    this.status,
  });

  static Amenity fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Amenity(
      uid: snapshot["uid"],
      id: snapshot["id"],
      name: snapshot["name"],
      username: snapshot["username"],
      datePublished: snapshot["datePublished"],
      amount: snapshot["amount"],
      body: snapshot["body"],
      image: snapshot["image"],
      type:snapshot['type'],
      upi:snapshot['upi'],
      status: snapshot["status"]??"",
      createdOn: snapshot["createdOn"] == null ? DateTime.now() : snapshot["createdOn"].toDate(),
      from: snapshot["from"] == null ? DateTime.now() : snapshot["from"].toDate(),
      to: snapshot["to"] == null ? DateTime.now() : snapshot["to"].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "username": username,
        "id":id,
        "datePublished": datePublished,
        "amount": amount,
        'body': body,
        "createdOn": createdOn,
        "from": from,
        "to":to,
        "image":image,
        'upi':upi,
        "status": status,
        'type': type,
      };
}
