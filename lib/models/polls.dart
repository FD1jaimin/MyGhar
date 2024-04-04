// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String? id;
  final String? question;
  final String? endDate;
  final String? uid;
  final options;
  final dynamic createdOn;

  const Poll({
    this.id,
    this.question,
    this.endDate,
    this.uid,
    this.createdOn,
    this.options,
  });

  static Poll fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Poll(
      id: snapshot["id"],
      question: snapshot["question"],
      endDate: snapshot["endDate"],
      uid: snapshot["uid"],
      options: snapshot["options"],
      createdOn: snapshot["createdOn"] == null
          ? DateTime.now()
          : snapshot["createdOn"].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "endDate": endDate,
        "question": question,
        'uid': uid,
        'options': options,
        "createdOn": createdOn,
      };
}
