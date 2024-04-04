// ignore_for_file: empty_catches, duplicate_ignore, prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:urbannest/core/constants.dart';
import 'dart:convert';

import 'package:urbannest/core/firestore_methods.dart';
import 'package:uuid/uuid.dart';

class NotificationMethods {
  Future<void> sendNotificationTopics(
      {String? to, String? body, String? title, String? type}) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAj8eZ-qU:APA91bH-tBqWWhcF_wXCq6Ro_UsWDDI48uNHGZ38gTEiWWJuojM9RQnQYdyPK7-cD4dpMBfhyXzFlO-sp3jcEM6KZxKnN7EheCZnaP7cypCtZBuyc-PF9WWr45TPti1GwguLwJ9a0r1w',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title!,
              'body': body,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'type': type,
              'uid': Constants.userId,
            },
            'to': to,
          },
        ),
      );

      if (response.statusCode == 200) {
        if (to!.contains('guard')) {
          FireStoreMethods()
              .sendGuardNotification(title: title, body: body, type: type);
        } else if (to.contains('admin')) {
          FireStoreMethods()
              .sendAdminNotification(title: title, body: body, type: type);
        } else if (to.contains('member')) {
          FireStoreMethods()
              .sendMemberNotification(title: title, body: body, type: type);
        } else {
          FireStoreMethods()
              .sendUserNotification(title: title, body: body, type: type);
        }
      } else {
        Fluttertoast.showToast(msg: "Please Try again.");
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> sendGuardAskNotification(
      {String? imageUrl,
      String? name,
      String? count,
      String? targetId,
      String? targetUID}) async {
    try {

        String notificationId = const Uuid().v1();
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAj8eZ-qU:APA91bH-tBqWWhcF_wXCq6Ro_UsWDDI48uNHGZ38gTEiWWJuojM9RQnQYdyPK7-cD4dpMBfhyXzFlO-sp3jcEM6KZxKnN7EheCZnaP7cypCtZBuyc-PF9WWr45TPti1GwguLwJ9a0r1w',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body':
                  "$name wants to visit you, should we allow them to enter?"+ "\n"+"visitor count : $count",
              'title': 'New Visitor arrived',
              "image": imageUrl,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': notificationId,
              'status': 'done',
              "imageUrl": imageUrl,
              'type': 'guardAsk',
              'uid': Constants.userId,
              'token': Constants.FCM
            },
            'to': targetId,
          },
        ),
      );

      if (response.statusCode == 200) {
        // Store the notification in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUID)
            .collection('notifications')
            .doc(notificationId)
            .set({
          'title': 'New Visitor arrived',
          'image': imageUrl,
          'id': notificationId,
          'token': Constants.FCM,
          'type': 'guardAsk',
          'uid': Constants.userId,
          'body':
              "$name wants to visit you, should we allow them to enter?"+"\n"+"visitor count : $count",
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        Fluttertoast.showToast(msg: "Please try again");
      }
    } catch (e) {}
  }

  Future<void> sendGuardDeliveryAskNotification(
      {
      String? targetId,
      String? targetUID}) async {
    try {

        String notificationId = const Uuid().v1();
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAj8eZ-qU:APA91bH-tBqWWhcF_wXCq6Ro_UsWDDI48uNHGZ38gTEiWWJuojM9RQnQYdyPK7-cD4dpMBfhyXzFlO-sp3jcEM6KZxKnN7EheCZnaP7cypCtZBuyc-PF9WWr45TPti1GwguLwJ9a0r1w',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body':
                  "There's a new delivery at the gate. Should we allow them to enter?",
              'title': 'New Delivery arrived',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': notificationId,
              'status': 'done',
              'type': 'guardDeliveryAsk',
              'uid': Constants.userId,
              'token': Constants.FCM
            },
            'to': targetId,
          },
        ),
      );

      if (response.statusCode == 200) {
        // Store the notification in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUID)
            .collection('notifications')
            .doc(notificationId)
            .set({
          'title': 'New Delivery arrived',
          'id': notificationId,
          'token': Constants.FCM,
              'type': 'guardAsk',
              'uid': Constants.userId,
          'body':
              "There's a new delivery at the gate. Should we allow them to enter?",
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        Fluttertoast.showToast(msg: "Please try again");
      }
    } catch (e) {}
  }

  Future<void> sendNotificationIndividual(
      {String? targetId, String? body, String? title, String? type,String? targetUID}) async {
    
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAj8eZ-qU:APA91bH-tBqWWhcF_wXCq6Ro_UsWDDI48uNHGZ38gTEiWWJuojM9RQnQYdyPK7-cD4dpMBfhyXzFlO-sp3jcEM6KZxKnN7EheCZnaP7cypCtZBuyc-PF9WWr45TPti1GwguLwJ9a0r1w',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'type': type,
              'uid': Constants.userId,
              'token': Constants.FCM,
            },
            // 'topic': "all",
            'to': targetId,
          },
        ),
      );

      // Check if the request was successful (status code 200) or handle errors
      if (response.statusCode == 200) {
       FireStoreMethods().sendIndividualNotification(body: body,title: title,type: type,id: targetUID);
        print('success');
      } else {}
    } catch (e) {}
  }
}
