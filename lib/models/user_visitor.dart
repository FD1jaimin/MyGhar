
import 'package:cloud_firestore/cloud_firestore.dart';

class UserVisitor {
  final String? uid;
  final String? username;
  final String? house;
  final String? block;
  final String? guestName;
  final int? datePublished;
  final dynamic visitDate;
  final String? count;
  final String? guestId;

  // final String profImage;

  const UserVisitor({
    this.uid,
    this.guestId,
    this.username,
    this.house,
    this.block,
    this.guestName,
    this.datePublished,
    this.visitDate,
    this.count,
  });

  static UserVisitor fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserVisitor(
      uid: snapshot["uid"],
      guestId: snapshot["guestId"],
      username: snapshot["username"],
      datePublished: snapshot["datePublished"],
      house: snapshot["house"],
      block: snapshot["block"],
      guestName: snapshot["guestName"],
      visitDate: snapshot["visitDate"],
      count: snapshot['count'],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "guestId":guestId,
        "datePublished": datePublished,
        "house": house,
        'block':block,
        'guestName': guestName,
        "visitDate": visitDate,
        "count": count,
      };
}
