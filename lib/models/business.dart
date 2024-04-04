import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  final String? businessid;
  final String? id;
  final String? name;
  final String? title;
  final String? link;
  final String? des;
  final String? number;
  final String? house;
  final String? image;
  final String? body;
  final String? status;
  final dynamic createdOn;
  final String? type;

  // final String profImage;

  const Business({
    this.businessid,
    this.id,
    this.name,
    this.title,
    this.link,
    this.des,
    this.number,
    this.house,
    this.image,
    this.body,
    this.createdOn,
    this.status,
    this.type,
  });

  static Business fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Business(
      businessid: snapshot["businessid"],
      id: snapshot["id"],
      name: snapshot["name"],
      title: snapshot["title"],
      des: snapshot["des"],
      link: snapshot["link"],
      number: snapshot["number"],
      house: snapshot["house"],
      body: snapshot["body"],
      image: snapshot["image"],
      status: snapshot["status"] ?? "",
      type:snapshot['type'] ??"",
      createdOn: snapshot["createdOn"] == null
          ? DateTime.now()
          : snapshot["createdOn"].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        "businessid": businessid,
        "name": name,
        "number": number,
        "title": title,
        "link": link,
        "des": des,
        "house": house,
        "id": id,
        'body': body,
        "createdOn": createdOn,
        "image": image,
        "status": status,
        'type': type,
      };
}