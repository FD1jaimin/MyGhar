// import 'dart:convert';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:urbannest/core/notification_method.dart';
// import 'package:uuid/uuid.dart';

// import '../views/notification_screen.dart';
// import 'constants.dart';

// class FirebaseAPI {
//   final _firebaseMessaging = FirebaseMessaging.instance;
  
//   final _androidChannel = const AndroidNotificationChannel(
//       'high_importance_channel', "High Importance Notifications",
//       description: 'This channel is used for important notification',
//       importance: Importance.defaultImportance);
//   final _localNotificaitons = FlutterLocalNotificationsPlugin();
//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;
//     Get.to(() => const NotificationPage());
//   }
    
//   Future initLocalNotifications()async{
//     const iOS = DarwinInitializationSettings();
//     const android = AndroidInitializationSettings('@drawable/ic_launcher');
//     const settings = InitializationSettings(android: android,iOS: iOS);

//     await _localNotificaitons.initialize(settings,onDidReceiveNotificationResponse: (payload){
//       final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
//       handleMessage(message);
//     },);
//   }

//   Future initPushNotifications() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//             alert: true, badge: true, sound: true);
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    
//      FirebaseMessaging.onBackgroundMessage(handleAppMessage);
//     FirebaseMessaging.onMessage.listen(handleAppMessage);
//   }

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     Constants.FCM = await _firebaseMessaging.getToken();
//     print("TOKKEEEEN "+ Constants.FCM.toString());
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//     await initPushNotifications();
//     await initLocalNotifications();
//   }
// }



// Future<void> handleAppMessage(RemoteMessage message) async {
//   String? title = message.notification!.title;
//   String? body = message.notification!.body;
//   Map<String, dynamic>? payload = message.data;
//   if (payload['type'] == 'alert') {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 1,
//         channelKey: "channel",
//         color: Colors.white,
//         title: title,
//         body: body,
//         category: NotificationCategory.Alarm,
//         wakeUpScreen: true,
//         fullScreenIntent: true,
//         autoDismissible: false,
//         backgroundColor: Colors.white,
//       ),
//     );
//   } else if (payload['type'] == 'guardAsk') {
//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 2,
//           channelKey: "channel",
//           color: Colors.white,
//           title: title,
//           body: body,
//           category: NotificationCategory.Alarm,
//           wakeUpScreen: true,
//           fullScreenIntent: true,
//           autoDismissible: false,
//           backgroundColor: Colors.white,
//           bigPicture: payload["imageUrl"],
//           notificationLayout: NotificationLayout.BigPicture,
//         ),
//         actionButtons: [
//           NotificationActionButton(
//             key: "Allow",
//             label: "Allow",
//             color: Colors.green,
//             autoDismissible: true,
//           ),
//           NotificationActionButton(
//             key: "Don't Allow",
//             label: "Don't Allow",
//             color: Colors.red,
//             autoDismissible: true,
//           ),
//         ]);
//    await AwesomeNotifications().setListeners(
//       onActionReceivedMethod: (receivedAction) async {
//         if (receivedAction.buttonKeyPressed == 'Allow') {
//           await NotificationMethods().sendNotificationIndividual(
//               body:
//                   "Please kindly allow the guest In./nFor: ${Constants.userData.firstName} \nAt :${Constants.userData.house}, ${Constants.userData.block}",
//               title: "Approved Entry",
//               targetId: payload['uid'],
//               type: "normal");
//         } else if (receivedAction.buttonKeyPressed == "Don't Allow") {
//           await NotificationMethods().sendNotificationIndividual(
//               body:
//                   "Please kindly allow the guest In./nFor: ${Constants.userData.firstName} \nAt :${Constants.userData.house}, ${Constants.userData.block}",
//               title: "Approved Entry",
//               targetId: payload['uid'],
//               type: "normal");
//         } else {
//           Fluttertoast.showToast(msg: "Ahh..");
//         }
//         //return receivedAction.buttonKeyPressed;
//       },
//     );
//   } else {
//      await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 3,
//         channelKey: "channel",
//         color: Colors.white,
//         title: title,
//         body: body,
//         category: NotificationCategory.Event,
//         wakeUpScreen: true,
//         fullScreenIntent: true,
//         autoDismissible: false,
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
  
// }

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   String? title = message.notification!.title;
//   String? body = message.notification!.body;
//   Map<String, dynamic>? payload = message.data;
//   if (payload['type'] == 'alert') {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 1,
//         channelKey: "channel",
//         color: Colors.white,
//         title: title,
//         body: body,
//         category: NotificationCategory.Alarm,
//         wakeUpScreen: true,
//         fullScreenIntent: true,
//         autoDismissible: false,
//         backgroundColor: Colors.white,
//       ),
//     );
//   } else if (payload['type'] == 'guardAsk') {
//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 2,
//           channelKey: "channel",
//           color: Colors.white,
//           title: title,
//           body: body,
//           category: NotificationCategory.Alarm,
//           wakeUpScreen: true,
//           fullScreenIntent: true,
//           autoDismissible: false,
//           backgroundColor: Colors.white,
//           bigPicture: payload["imageUrl"],
//           notificationLayout: NotificationLayout.BigPicture,
//         ),
//         actionButtons: [
//           NotificationActionButton(
//             key: "Allow",
//             label: "Allow",
//             color: Colors.green,
//             autoDismissible: true,
//           ),
//           NotificationActionButton(
//             key: "Don't Allow",
//             label: "Don't Allow",
//             color: Colors.red,
//             autoDismissible: true,
//           ),
//         ]);
//    await AwesomeNotifications().setListeners(
//       onActionReceivedMethod: (receivedAction) async {
//         if (receivedAction.buttonKeyPressed == 'Allow') {
//           await NotificationMethods().sendNotificationIndividual(
//               body:
//                   "Please kindly allow the guest In./nFor: ${Constants.userData.firstName} \nAt :${Constants.userData.house}, ${Constants.userData.block}",
//               title: "Approved Entry",
//               targetId: payload['uid'],
//               type: "normal");
//         } else if (receivedAction.buttonKeyPressed == "Don't Allow") {
//           await NotificationMethods().sendNotificationIndividual(
//               body:
//                   "Please kindly allow the guest In./nFor: ${Constants.userData.firstName} \nAt :${Constants.userData.house}, ${Constants.userData.block}",
//               title: "Approved Entry",
//               targetId: payload['uid'],
//               type: "normal");
//         } else {
//           Fluttertoast.showToast(msg: "Ahh..");
//         }
//         //return receivedAction.buttonKeyPressed;
//       },
//     );
//   } else {
//      await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 3,
//         channelKey: "channel",
//         color: Colors.white,
//         title: title,
//         body: body,
//         category: NotificationCategory.Event,
//         wakeUpScreen: true,
//         fullScreenIntent: true,
//         autoDismissible: false,
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
// }
