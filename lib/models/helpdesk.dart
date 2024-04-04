import 'package:cloud_firestore/cloud_firestore.dart';

class HelpDesk {
  final String? uid;
  final String? id;
  final String? name;
  final String? title;
  final String? des;
  final String? number;
  final String? username;
  final String? image;
  final String? body;
  final int? datePublished;
  final String?status;
  final dynamic createdOn;
  final String? token;

  // final String profImage;

  const HelpDesk({
    this.uid,
    this.id,
    this.name,
    this.title,
    this.des,
    this.number,
    this.username,
    this.image,
    this.body,
    this.datePublished,
    this.createdOn,
    this.status,
    this.token,
  });

  static HelpDesk fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return HelpDesk(
      uid: snapshot["uid"],
      id: snapshot["id"],
      name: snapshot["name"],
      title: snapshot["title"],
      des: snapshot["des"],
      number: snapshot["number"],
      username: snapshot["username"],
      datePublished: snapshot["datePublished"],
      body: snapshot["body"],
      image: snapshot["image"],
      status: snapshot["status"] ?? "",
      createdOn: snapshot["createdOn"] == null
          ? DateTime.now()
          : snapshot["createdOn"].toDate(),
          token:snapshot["token"] ?? ""
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "number": number,
        "title": title,
        "des": des,
        "username": username,
        "id": id,
        "datePublished": datePublished,
        'body': body,
        "createdOn": createdOn,
        "image": image,
        "status": status,
        "token": token,
      };
}