import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Maintenance {
  final String? creatorId;
  final String? maintenanceId;
  final String? creatorName;
  final String? creatorNumber;
  final dynamic dueDate;
  final String? amount;
  final String? note;
  final String? upi;
  final String? transactionId;
  final List? isPaidArray;
  final int? totalFund;
  final dynamic createdOn;

  const Maintenance({
    this.creatorId,
    this.maintenanceId,
    this.creatorName,
    this.creatorNumber,
    this.dueDate,
    this.amount,
    this.note,
    this.upi,
    this.transactionId,
    this.isPaidArray,
    this.createdOn,
    this.totalFund,
  });

  static Maintenance fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Maintenance(
      creatorId: snapshot["creatorId"],
      maintenanceId: snapshot["maintenanceId"],
      creatorName: snapshot["creatorName"],
      creatorNumber: snapshot["creatorNumber"],
      dueDate: snapshot["dueDate"].toDate(),
      note: snapshot["note"],
      upi: snapshot["upi"],
      transactionId: snapshot["transactionId"],
      amount: snapshot["amount"],

      totalFund: snapshot["totalFund"],
      isPaidArray: snapshot["isPaidArray"],
      createdOn: snapshot["createdOn"] == null
          ? DateTime.now()
          : snapshot["createdOn"].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        "creatorId": creatorId,
        "maintenanceId": maintenanceId,
        "creatorNumber": creatorNumber,
        "creatorName": creatorName,
        'dueDate': dueDate,
        'amount': amount,
        'note': note,
        'totalFund':totalFund,
        'upi': upi,
        'transactionId': transactionId,
        "createdOn": createdOn,
        "isPaidArray": isPaidArray
      };
}