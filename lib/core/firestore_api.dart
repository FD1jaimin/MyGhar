// ignore_for_file: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/notification_method.dart';
import 'package:uuid/uuid.dart';

import '../views/notification_screen.dart';
import 'constants.dart';

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', "High Importance Notifications",
      description: 'This channel is used for important notification',
      importance: Importance.defaultImportance);
  final _localNotificaitons = FlutterLocalNotificationsPlugin();
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    Get.to(() => const NotificationPage());
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotificaitons.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
        handleMessage(message);
      },
    );
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    FirebaseMessaging.onBackgroundMessage(handleAppMessage);
    FirebaseMessaging.onMessage.listen(handleAppMessage);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    if (Platform.isIOS){

      await Future.delayed(Duration(seconds: 1)).then((value) async {
        Constants.FCM = await _firebaseMessaging.getToken();
      });
    }else{
      Constants.FCM = await _firebaseMessaging.getToken();
    }
    print("TOKKEEEEN " + Constants.FCM.toString());
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
     if (Platform.isAndroid) await initPushNotifications();
    // await initLocalNotifications();
  }
}

Future<void> handleAppMessage(RemoteMessage message) async {
  String? title = message.notification!.title;
  String? body = message.notification!.body;
  Map<String, dynamic>? payload = message.data;
  if (payload['type'] == 'guardAsk') {
    NotificationService.showNotification(
        title: title!,
        category: NotificationCategory.Alarm,
        body: body!,
        bigPicture: payload['imageUrl'],
        payload: {
          'uid': payload['uid'],
          'token': payload["token"],
          'id': payload['id'] ?? '',
        },
        notificationLayout: NotificationLayout.BigPicture,
        actionButtons: [
          NotificationActionButton(
            key: "Allow",
            label: "Allow",
            color: Colors.green,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: "Don't Allow",
            label: "Don't Allow",
            color: Colors.red,
            autoDismissible: true,
          ),
        ]);
  } else if (payload['type'] == 'guardDeliveryAsk') {
    NotificationService.showNotification(
        title: title!,
        category: NotificationCategory.Alarm,
        body: body!,
        payload: {
          'uid': payload['uid'],
          'token': payload["token"],
          'id': payload['id'] ?? '',
        },
        notificationLayout: NotificationLayout.Default,
        actionButtons: [
          NotificationActionButton(
            key: "Allow Entry",
            label: "Allow Entry",
            color: Colors.green[400],
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: "Collect at Gate",
            label: "Collect at Gate",
            color: Colors.blue[400],
            autoDismissible: true,
          ),
        ]);
  } else {
    NotificationService.showNotification(title: title!, body: body!);
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  String? title = message.notification!.title;
  String? body = message.notification!.body;
  Map<String, dynamic>? payload = message.data;
}

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint(
        'helloooooooooooooooooooooooooo---------------------------------------onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint(
        'helloooooooooooooooooooooooooo---------------------------------------onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint(
        'helloooooooooooooooooooooooooo---------------------------------------onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final payload = receivedAction.payload ?? {};
    if (receivedAction.buttonKeyPressed == 'Allow') {
      String body = "Please kindly allow the guest In." +
          "\n" +
          "For: ${Constants.userData.firstName}" +
          "\n" +
          "At :${Constants.userData.house}, ${Constants.userData.block}";
      String title = "Approved Entry ✅";
      await NotificationMethods().sendNotificationIndividual(
          body: body, title: title, targetId: payload['token'], type: "normal");
      await FireStoreMethods().sendIndividualNotification(
          type: 'normal', body: body, title: title, id: payload['uid']);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .collection('notifications')
          .doc(payload['id'])
          .delete();
    } else if (receivedAction.buttonKeyPressed == "Don't Allow") {
      String body = "Don't Allow the visitor In." +
          "\n" +
          "For: ${Constants.userData.firstName} " +
          "\n" +
          "At :${Constants.userData.house}, ${Constants.userData.block}";
      String title = "Abort Entry ❌";
      await NotificationMethods().sendNotificationIndividual(
          body: body, title: title, targetId: payload['token'], type: "normal");
      await FireStoreMethods().sendIndividualNotification(
          type: 'normal', body: body, title: title, id: payload['uid']);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .collection('notifications')
          .doc(payload['id'])
          .delete();
    }else if (receivedAction.buttonKeyPressed == "Allow Entry") {
      String body = "Allow the delivery In." +
          "\n" +
          "For: ${Constants.userData.firstName} " +
          "\n" +
          "At :${Constants.userData.house}, ${Constants.userData.block}";
      String title = "Allow Entry ✅";
      await NotificationMethods().sendNotificationIndividual(
          body: body, title: title, targetId: payload['token'], type: "normal");
      await FireStoreMethods().sendIndividualNotification(
          type: 'normal', body: body, title: title, id: payload['uid']);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .collection('notifications')
          .doc(payload['id'])
          .delete();
    }else if (receivedAction.buttonKeyPressed == "Collect at Gate") {
      String body = "Collect Delivery at Gate." +
          "\n" +
          "For: ${Constants.userData.firstName} " +
          "\n" +
          "At :${Constants.userData.house}, ${Constants.userData.block}";
      String title = "Collect at Gate 📦";
      await NotificationMethods().sendNotificationIndividual(
          body: body, title: title, targetId: payload['token'], type: "normal");
      await FireStoreMethods().sendIndividualNotification(
          type: 'normal', body: body, title: title, id: payload['uid']);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .collection('notifications')
          .doc(payload['id'])
          .delete();
    } else {
      Get.to(() => const NotificationPage());
      // Fluttertoast.showToast(msg: "");
    }
    // if (payload["navigate"] == "true") {
    // MainApp.navigatorKey.currentState?.push(
    //   MaterialPageRoute(
    //     builder: (_) => const SecondScreen(),
    //   ),
    // );
    // }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }
}
