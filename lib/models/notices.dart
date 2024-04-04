
import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String? uid;
  final String? noticeId;
  final String? username;
  final String? title;
  final String? body;
  final int? datePublished;
  final dynamic createdOn;
  final dynamic expiry;
  final String? societyId;

  // final String profImage;

  const Notice({
    this.uid,
    this.noticeId,
    this.username,
    this.title,
    this.body,
    this.datePublished,
    this.createdOn,
    this.expiry,
    this.societyId,
  });

  static Notice fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Notice(
      uid: snapshot["uid"],
      noticeId: snapshot["noticeId"],
      username: snapshot["username"],
      datePublished: snapshot["datePublished"],
      title: snapshot["title"],
      body: snapshot["body"],
      createdOn: snapshot["createdOn"] == null ? DateTime.now() : snapshot["createdOn"].toDate(),
      expiry: snapshot["expiry"] == null ? DateTime.now() : snapshot["expiry"].toDate(),
      societyId: snapshot["societyId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "noticeId":noticeId,
        "datePublished": datePublished,
        "title": title,
        'body': body,
        "createdOn": createdOn,
        "expiry": expiry,
        'societyId': societyId,
      };
}
