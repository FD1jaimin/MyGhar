// ignore_for_file: library_private_types_in_public_api, avoid_print, avoid_function_literals_in_foreach_calls, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/views/notice_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/constants.dart';
import '../core/notification_method.dart';
import '../widgets/text_fields.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // final CollectionReference notificationsCollection =
  //     FirebaseFirestore.instance.collection('notifications');
  bool result = false;
  BannerAd? bannerAd;
  List<String> deleteIds = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    for (int i = 0; i < deleteIds.length; i++) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .collection('notifications')
          .doc(deleteIds[i])
          .delete();
    }
    super.dispose();
  }

  Future<void> deleteCollection(String collectionPath) async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(collectionPath);

    final QuerySnapshot querySnapshot = await collectionReference.get();
    for (DocumentSnapshot doc in querySnapshot.docs) {
      doc.reference.delete();
    }
  }

  dynamic notifications;
  @override
  Widget build(BuildContext context) {
    // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 12, left: 24, right: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CustomBackButton(),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.8, left: 16),
                          child: Text(
                            "Notification",
                            style: AppTheme.subheading
                                .copyWith(letterSpacing: -0.3),
                          ),
                        ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 16.8, right: 16),
                    //   child: Column(
                    //     children: [
                    //       const Icon(
                    //         Icons.cancel,
                    //         color: Colors.black87,
                    //         size: 30,
                    //       ),
                    //       2.heightBox,
                    //       Text("Clear all",
                    //           style: AppTheme.smallText
                    //               .copyWith(color: Colors.black87)),
                    //     ],
                    //   ).onTap(() async {
                    //     final String collectionPath =
                    //         'users/${FirebaseAuth.instance.currentUser!.uid}/notifications';
                    //     await deleteCollection(collectionPath);
                    //   }),
                    // ),
                  ],
                )),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('notifications')
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: Text(
                        "No Notification available",
                        style: AppTheme.smallText,
                      ),
                    ));
                  } else {
                    List<dynamic> temp = [];
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      temp.add(snapshot.data!.docs[i]);
                    }
                    notifications = temp;
                    return notifications.isEmpty
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.only(bottom: 50),
                            child: Text(
                              "No Notification available",
                              style: AppTheme.smallText,
                            ),
                          ))
                        : Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final notification = snapshot.data!.docs[index]
                                    .data() as Map<String, dynamic>;

                                return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24, top: 6, bottom: 6),
                                    child: Dismissible(
                                      key: Key(index.toString()),
                                      onDismissed: (direction) async {
                                        try {
                                          notifications.removeAt(index);
                                          deleteIds.add(notification['id']);
                                        } catch (e) {}
                                      },
                                      // Show a red background as the item is swiped away.
                                      background: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red[400],
                                            borderRadius:
                                                BorderRadius.circular(32)),
                                      ),
                                      child:
                                          _buildNotificationTile(notification),
                                    ));
                              },
                            ),
                          );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    if (notification['type'] == "newuser") {
      return NewUserCard(
        notification: notification,
      );
    } else if (notification['type'] == "newextra") {
      return NewUserCard(
        notification: notification,
      );
    } else if (notification['type'] == "newBooking") {
      return NewBookingCard(
        notification: notification,
      );
    } else if (notification['type'] == "newMaintenance") {
      return NewMaintenanceCard(
        notification: notification,
      );
    }  else if (notification['type'] == "newAmenityPaid") {
      return NewAlreadyAmenities(
        notification: notification,
      );
    } 
    else if (notification['type'] == 'guardAsk') {
      return GuardAskCard(
        notification: notification,
      );
    }else if (notification['type'] == 'guardDeliveryAsk') {
      return GuardDeliveryAskCard(
        notification: notification,
      );
    } 
     else {
      return normalCard(notification: notification);
    }
  }
}

class NewMaintenanceCard extends StatelessWidget {
  NewMaintenanceCard({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification;
  TextEditingController amount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 12.heightBox,
          Text(notification['title'] ?? '', style: AppTheme.subheading2),
          4.heightBox,
          Text(
            notification['body'] ?? '',
            maxLines: 3,
            // overflow: TextOverflow.ellipsis,

            style: AppTheme.smallText,
          ),

          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              12.widthBox,
              CustomButton(
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('societies')
                      .doc(Constants.societyId)
                      .collection('maintenances')
                      .doc(notification['amenityId'])
                      .update({
                        
                    'isPaidArray':
                        FieldValue.arrayUnion([notification['house']])
                  });

                  FireStoreMethods().sendIndividualNotification(
                      id: notification['uid'],
                      title: 'Maintenance Paid',
                      body:
                          "Your maintenance  request has been approved. We appreciate your timely payment and cooperation in maintaining our community. Thank you!");
                  await FirebaseFirestore.instance
                      .collection('users')
                      .where("societyId", isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .get()
                      .then((data) => data.docs.forEach((doc) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                          }));
                },
                height: 60,
                width: 110,
                text: "Approve",
                color: Colors.green[400],
              ),
              12.widthBox,
              CustomButton(
                onTap: () async {
                  FirebaseFirestore.instance
                      .collection('users')
                      .where("societyId", isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .get()
                      .then((data) {
                    for (int i = 0; i < data.docs.length; i++) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(data.docs[i].data()['uid'])
                          .collection('notifications')
                          .doc(notification['id'])
                          .delete();
                    }
                  });
                  FireStoreMethods().sendIndividualNotification(
                      id: notification['uid'],
                      title: 'Maintenance Denied',
                      type: '',
                      body:
                          "Sorry, your maintenance request has been denied. Please review the payment details and resubmit if necessary. Thank you");
                },
                height: 60,
                width: 110,
                text: 'Decline',
                //iconData: CupertinoIcons.xmark,
                color: Colors.red[400],
              )
            ],
          )
        ]),
      ),
      // Add more UI elements as needed
    );
  }
}

class NewAlreadyAmenities extends StatelessWidget {
  NewAlreadyAmenities({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification;
  TextEditingController amount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 12.heightBox,
          Text(notification['title'] ?? '', style: AppTheme.subheading2),
          4.heightBox,
          Text(
            notification['body'] ?? '',
            maxLines: 3,
            // overflow: TextOverflow.ellipsis,

            style: AppTheme.smallText,
          ),

          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              12.widthBox,
              CustomButton(
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(notification['uid'])
                      .collection('amenities')
                      .doc(notification['amenityId'])
                      .update({
                    'status':
                        'Confirmed'});
                

                  FireStoreMethods().sendIndividualNotification(
                      id: notification['uid'],
                      title: 'Booking Confirmed',
                      body:
                          "Your booking request has been approved. We appreciate your timely payment and cooperation in maintaining our community. Thank you!");
                  await FirebaseFirestore.instance
                      .collection('users')
                      .where("societyId", isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .get()
                      .then((data) => data.docs.forEach((doc) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                          }));
                },
                height: 60,
                width: 110,
                text: "Approve",
                color: Colors.green[400],
              ),
              12.widthBox,
              CustomButton(
                onTap: () async {
                  FirebaseFirestore.instance
                      .collection('users')
                      .where("societyId", isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .get()
                      .then((data) {
                    for (int i = 0; i < data.docs.length; i++) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(data.docs[i].data()['uid'])
                          .collection('notifications')
                          .doc(notification['id'])
                          .delete();
                    }
                  });
                  FireStoreMethods().sendIndividualNotification(
                      id: notification['uid'],
                      title: 'Prepaid Denied',
                      type: '',
                      body:
                          "Sorry, your pre paid request for booking has been denied. Please review the payment details and resubmit if necessary. Thank you");
                },
                height: 60,
                width: 110,
                text: 'Decline',
                //iconData: CupertinoIcons.xmark,
                color: Colors.red[400],
              )
            ],
          )
        ]),
      ),
      // Add more UI elements as needed
    );
  }
}

class NewUserCard extends StatelessWidget {
  const NewUserCard({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 12.heightBox,
          Text(notification['title'] ?? '', style: AppTheme.subheading2),
          4.heightBox,
          Text(
            notification['body'] ?? '',
            maxLines: 5,
            style: AppTheme.smallText,
          ),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomButton(
                onTap: () async {
                  if (notification['type'] == "newextra") {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(notification['uid'])
                        .update({
                      'type': "extra",
                    });
                  } else {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(notification['uid'])
                        .update({
                      'type': "member",
                    });
                    FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(notification['societyGroupId'])
                        .update({
                      'userIds': FieldValue.arrayUnion([notification['uid']]),
                    });
                  }
                  await FirebaseFirestore.instance
                      .collection('users')
                      .where("societyId", isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .get()
                      .then((data) => data.docs.forEach((doc) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                          }));
                },
                height: 46,
                width: 116,
                text: "Approve",
                color: Colors.green[400],
              ),
              CustomButton(
                onTap: () async {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(notification['uid'])
                      .update({
                    'societyId': "",
                    'societyCode': "",
                    'societyName': "",
                    'block': "",
                    "sector": "",
                    "address": "",
                    "type": '',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .where("societyId", isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .get()
                      .then((data) => data.docs.forEach((doc) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                          }));
                },
                height: 46,
                width: 116,
                text: "Decline",
                color: Colors.red[400],
              )
            ],
          )
        ]),
      ),

      // Add more UI elements as needed
    );
  }
}


class GuardAskCard extends StatelessWidget {
  const GuardAskCard({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 12.heightBox,
          Text(notification['title'] ?? '', style: AppTheme.subheading2),
          4.heightBox,
          Text(
            notification['body'] ?? '',
            maxLines: 5,
            style: AppTheme.smallText,
          ),
          8.heightBox,
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            height: 250,
            width: 400,
            child: notification["image"] == null
                    ? const SizedBox()
                    : Image.network(notification["image"] ?? '',fit: BoxFit.fitWidth,),
          ),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomButton(
                onTap: () async {
                  String body = "Please kindly allow the guest In." +
                      "\n" +
                      "For: ${Constants.userData.firstName}" +
                      "\n" +
                      "At :${Constants.userData.house}, ${Constants.userData.block}";
                  String title = "Approved Entry ✅";
                  await NotificationMethods().sendNotificationIndividual(
                      body: body,
                      title: title,
                      targetId: notification['token'],
                      type: "normal");
                  await FireStoreMethods().sendIndividualNotification(
                      type: 'normal',
                      body: body,
                      title: title,
                      id: notification['uid']);

                  await FirebaseFirestore.instance
                                .collection('users')
                                .doc(Constants.userId)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                },
                height: 46,
                width: 116,
                text: "Approve",
                color: Colors.green[400],
              ),
              CustomButton(
                onTap: () async { String body = "Don't Allow the visitor In."+"\n"+"For: ${Constants.userData.firstName} "+"\n"+"At :${Constants.userData.house}, ${Constants.userData.block}";
      String title = "Abort Entry ❌";
          await NotificationMethods().sendNotificationIndividual(
              body: body,
              title: title,
              targetId: notification['token'],
              type: "normal");
              await FireStoreMethods().sendIndividualNotification(type: 'normal',body:body,title: title,id:  notification['uid']);
              await FirebaseFirestore.instance
                                .collection('users')
                                .doc(Constants.userId)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                },
                height: 46,
                width: 116,
                text: "Decline",
                color: Colors.red[400],
              )
            ],
          )
        ]),
      ),

      // Add more UI elements as needed
    );
  }
}



class GuardDeliveryAskCard extends StatelessWidget {
  const GuardDeliveryAskCard({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 12.heightBox,
          Text(notification['title'] ?? '', style: AppTheme.subheading2),
          4.heightBox,
          Text(
            notification['body'] ?? '',
            maxLines: 5,
            style: AppTheme.smallText,
          ),
          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomButton(
                onTap: () async {
                   String body = "Allow the delivery In." +
          "\n" +
          "For: ${Constants.userData.firstName} " +
          "\n" +
          "At :${Constants.userData.house}, ${Constants.userData.block}";
      String title = "Allow Entry ✅";
                  await NotificationMethods().sendNotificationIndividual(
                      body: body,
                      title: title,
                      targetId: notification['token'],
                      type: "normal");
                  await FireStoreMethods().sendIndividualNotification(
                      type: 'normal',
                      body: body,
                      title: title,
                      id: notification['uid']);

                  await FirebaseFirestore.instance
                                .collection('users')
                                .doc(Constants.userId)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                },
                height: 46,
                width: 116,
                text: "Approve Entry",
                color: Colors.green[400],
              ),
              CustomButton(
                onTap: () async { String body = "Collect Delivery at Gate." +
          "\n" +
          "For: ${Constants.userData.firstName} " +
          "\n" +
          "At :${Constants.userData.house}, ${Constants.userData.block}";
      String title = "Collect at Gate 📦";
          await NotificationMethods().sendNotificationIndividual(
              body: body,
              title: title,
              targetId: notification['token'],
              type: "normal");
              await FireStoreMethods().sendIndividualNotification(type: 'normal',body:body,title: title,id:  notification['uid']);
              await FirebaseFirestore.instance
                                .collection('users')
                                .doc(Constants.userId)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                },
                height: 46,
                width: 116,
                text: "Collect at gate",
                color: Colors.blue[400],
              )
            ],
          )
        ]),
      ),

      // Add more UI elements as needed
    );
  }
}


class NewBookingCard extends StatelessWidget {
  NewBookingCard({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification;
  TextEditingController amount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 12.heightBox,
          Text(notification['title'] ?? '', style: AppTheme.subheading2),
          4.heightBox,
          Text(
            notification['body'] ?? '',
            maxLines: 3,
            // overflow: TextOverflow.ellipsis,

            style: AppTheme.smallText,
          ),

          12.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 3,
                child: CustomTextField(
                    isForm: true,
                    icon: const Icon(Icons.currency_rupee_rounded),
                    keyboardType: TextInputType.number,
                    hint: "Price",
                    validator: (value) {
                      return null;
                    },
                    textController: amount),
              ),
              12.widthBox,
              CustomButton(
                onTap: () async {
                  if (amount.text == '') {
                    Fluttertoast.showToast(msg: 'Please enter the amount');
                  } else {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(notification['uid'])
                        .collection('amenities')
                        .doc(notification['amenityId'])
                        .update({
                      'status': "Approved",
                      'amount': amount.text,
                    });

                    FireStoreMethods().sendIndividualNotification(
                        id: notification['uid'],
                        title: 'Booking Accepted',
                        body:
                            "Your booking has been approved, please pay to confirm your booking as soon as possible.");
                    await FirebaseFirestore.instance
                        .collection('users')
                        .where("societyId", isEqualTo: Constants.societyId)
                        .where('type', isEqualTo: 'admin')
                        .get()
                        .then((data) => data.docs.forEach((doc) {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(doc.id)
                                  .collection('notifications')
                                  .doc(notification['id'])
                                  .delete();
                            }));
                  }
                },
                height: 60,
                width: 60,
                text: "",
                iconData: CupertinoIcons.check_mark,
                color: Colors.green[400],
              ),
              12.widthBox,
              CustomButton(
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(notification['uid'])
                      .collection('amenities')
                      .doc(notification['amenityId'])
                      .update({
                    'status': "Denied",
                    'amount': '',
                  });
                  FireStoreMethods().sendIndividualNotification(
                      id: notification['uid'],
                      title: 'Booking Denied',
                      body:
                          "Your booking has been denied, please select some other date or connect with the person responsible");

                  await FirebaseFirestore.instance
                      .collection('users')
                      .where("societyId", isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .get()
                      .then((data) => data.docs.forEach((doc) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .collection('notifications')
                                .doc(notification['id'])
                                .delete();
                          }));
                },
                height: 60,
                width: 60,
                text: '',
                iconData: CupertinoIcons.xmark,
                color: Colors.red[400],
              )
            ],
          )
        ]),
      ),

      // Add more UI elements as needed
    );
  }
}

class normalCard extends StatelessWidget {
  const normalCard({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification['title'] ?? '',
                style: AppTheme.subheading2,
                maxLines: 2,
              ),
              4.heightBox,
              Text(
                notification['body'] ?? '',
                maxLines: 4,
                style: AppTheme.smallText,
              ),
              notification["image"] == null
                  ? const SizedBox()
                  : Image.network(notification["image"] ?? ''),
            ]),
      ),

      // Add more UI elements as needed
    ).onTap(() {
      if (notification["type"] == "notice") {
        Get.back();
        Get.to(const NoticeScreen());
      }
    });
  }
}
