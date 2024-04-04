// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/models/amenity.dart';
import 'package:urbannest/models/business.dart';
import 'package:urbannest/models/entry.dart';
import 'package:urbannest/models/helpdesk.dart';
import 'package:urbannest/models/maintenance.dart';
import 'package:urbannest/models/notices.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/models/user_visitor.dart';

import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/handymen.dart';
import '../models/stores.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  // Future<String> createCourse({
  //   String courseId,
  //   String courseName,
  //   String bookUrl,
  //   String coverUrl,
  //   String description,
  //   bool ispublic,
  // }) async {
  //   String res = "Some error occurred";
  //   try {
  //     Course course = Course(
  //         uid: FirebaseAuth.instance.currentUser.uid,
  //         courseId: courseId,
  //         courseName: courseName,
  //         coverUrl:
  //             coverUrl, //"https://img.freepik.com/free-vector/man-robot-with-computers-sitting-together-workplace-artificial-intelligence-workforce-future-flat-illustration_74855-20635.jpg",
  //         description: description,
  //         bookUrl: bookUrl,
  //         chapters: [],
  //         likes: [],
  //         members: [FirebaseAuth.instance.currentUser.uid],
  //         datePublished: DateTime.now().millisecondsSinceEpoch,
  //         isverified: FirebaseAuth.instance.currentUser != null
  //             ? FirebaseAuth.instance.currentUser.email ==
  //                     "bhargavsinghbarad007@gmail.com"
  //                 ? true
  //                 : false
  //             : false,
  //         ispublic: ispublic,
  //         byglimpse: FirebaseAuth.instance.currentUser != null
  //             ? FirebaseAuth.instance.currentUser.email ==
  //                     "bhargavsinghbarad007@gmail.com"
  //                 ? true
  //                 : false
  //             : false);
  //     var a = course.toJson();
  //     await _firestore.collection('courses').doc(courseId).set(a);
  //     res = "success";
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> editCourse({
  //   String courseId,
  //   String courseName,
  //   String bookUrl,
  //   String coverUrl,
  //   String description,
  //   bool ispublic,
  // }) async {
  //   String res = "Some error occurred";
  //   try {
  //     _firestore
  //         .collection('courses')
  //         .doc(courseId)
  //         .update({'courseName': courseName});
  //     _firestore
  //         .collection('courses')
  //         .doc(courseId)
  //         .update({'coverUrl': coverUrl});
  //     _firestore
  //         .collection('courses')
  //         .doc(courseId)
  //         .update({'bookUrl': bookUrl});
  //     _firestore
  //         .collection('courses')
  //         .doc(courseId)
  //         .update({'bookUrl': bookUrl});
  //     _firestore
  //         .collection('courses')
  //         .doc(courseId)
  //         .update({'description': description});
  //     _firestore
  //         .collection('courses')
  //         .doc(courseId)
  //         .update({'ispublic': ispublic});
  //     res = "success";
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> editChapter({
  //   String chapterId,
  //   String chapterName,
  //   IconData icon,
  //   String description,
  // }) async {
  //   String res = "Some error occurred";
  //   try {
  //     _firestore
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .update({'chapterName': chapterName});
  //     _firestore
  //         .collection('chapters')
  //         .doc(chapterId)
  //         .update({'description': description});
  //     _firestore.collection('chapters').doc(chapterId).update({'icon': icon});
  //     res = "success";
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  Future<String> createGuest({
    String? house,
    String? block,
    String? guestname,
    dynamic visitdate,
    String? count,
    String? username,
  }) async {
    String res = "Some error occurred";
    try {
      String guestId = const Uuid().v1();
      UserVisitor userVisitor = UserVisitor(
        uid: user!.uid,
        guestId: guestId,
        username: username,
        house: house,
        block: block,
        guestName: guestname,
        visitDate: visitdate,
        count: count,
        datePublished: DateTime.now().millisecondsSinceEpoch,
      );
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection("guests")
          .doc(guestId)
          .set(userVisitor.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addHelpDesk({
    String? amount,
    String? helpDeskId,
    String? name,
    String? title,
    String? des,
    String? number,
    String? imageUrl,
    String? token,
  }) async {
    String res = "Some error occurred";
    try {
      HelpDesk helpDesk = HelpDesk(
        uid: user!.uid,
        id: helpDeskId,
        name: name,
        title: title,
        des: des,
        number: number,
        image: imageUrl,
        status: 'Pending',
        username: user!.displayName,
        token: token,
        createdOn: FieldValue.serverTimestamp(),
      );
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection("helpDesk")
          .doc(helpDeskId)
          .set(helpDesk.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createNotice({
    String? title,
    String? body,
    dynamic expiry,
    String? societyId,
  }) async {
    String res = "Some error occurred";
    try {
      String noticeId = const Uuid().v1();
      Notice notice = Notice(
        uid: Constants.userId,
        noticeId: noticeId,
        username: Constants.userData.firstName,
        title: title,
        body: body,
        expiry: expiry,
        createdOn: FieldValue.serverTimestamp(),
        datePublished: DateTime.now().millisecondsSinceEpoch,
        societyId: societyId,
      );
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('notices')
          .doc(noticeId)
          .set(notice.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  Future<String> createTransaction({
    String? title,
    // String? body,
    int? amount,
    bool? type,
    String? societyId,
  }) async {
    String res = "Some error occurred";
    try {
      String transactionId = const Uuid().v1();
      
        
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('transactions')
          .doc(transactionId)
          .set({"uid": Constants.userId,
        "noticeId": transactionId,
        "username": Constants.userData.firstName,
        "title": title,
        // "body": body,
        'amount':amount,
        'type':type,
        "createdOn": FieldValue.serverTimestamp(),
        "societyId": societyId,});
        var res2 = await   _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .get();

        int f = type! ? res2['funds'] + amount : res2['funds'] - amount;
         await   _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .update({'funds':f});
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createPoll(
    BuildContext context, {
    String? question,
    List<TextEditingController>? options,
    dynamic expiry,
    String? societyId,
  }) async {
    String res = "Some error occurred";
    // final UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    try {
      String pollId = const Uuid().v1();

      List<Map<String, dynamic>> temp = [];
      for (int i = 0; i < options!.length; i++) {
        temp.add({
          "id": i,
          "title": options[i].text.trim(),
          'votes': [],
        });
      }

      await _firestore
          .collection('societies')
          .doc(societyId)
          .collection('polls')
          .doc(pollId)
          .set(
        {
          'id': pollId,
          'question': question,
          'endDate': expiry,
          'options': temp,
          "createdOn": FieldValue.serverTimestamp(),
        },
      );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createMaintenance({
    String? amount,
    String? note,
    String? upi,
    dynamic? dueDate,
    UserData? creatorData,
  }) async {
    String res = "Some error occurred";
    try {
      String maintenanceId = const Uuid().v1();
      Maintenance maintenance = Maintenance(
        creatorId: user!.uid,
        maintenanceId: maintenanceId,
        amount: amount,
        creatorNumber: creatorData!.phone,
        creatorName: creatorData.firstName,
        isPaidArray: [],
        dueDate: dueDate,
        note: note,
        upi: upi,
        transactionId: '',
        totalFund: 0,
        createdOn: FieldValue.serverTimestamp(),
      );
      await _firestore
          .collection("societies")
          .doc(Constants.societyId)
          .collection('maintenances')
          .doc(maintenanceId)
          .set(maintenance.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addRule({
    String? text,
  }) async {
    String res = "Some error occurred";
    try {
      String ruleId = const Uuid().v1();

      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('rules')
          .doc(ruleId)
          .set({
        "ruleId": ruleId,
        "text": text,
        "createdOn": FieldValue.serverTimestamp(),
        "uid": user!.uid
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createStores({
    String? name,
    String? type,
    String? number,
    String? address,
    String? area,
  }) async {
    String res = "Some error occurred";
    try {
      String storeId = const Uuid().v1();
      Stores stores = Stores(
        uid: 'admin', // user!.uid,
        storeId: storeId,
        username: 'admin', //user!.displayName,
        name: name,
        type: type,
        number: number,
        address: address,
        area: area,
        createdOn: FieldValue.serverTimestamp(),
      );
      await _firestore.collection('stores').doc(storeId).set(stores.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createHandymen({
    String? name,
    String? number,
    String? handymenId,
    String? image,
    String? type,
    bool? inHouse,
  }) async {
    String res = "Some error occurred";
    try {
      Handymen handyman = Handymen(
        id: handymenId,
        name: name,
        number: number,
        image: image,
        type: type,
        inHouse: inHouse,
        createdOn: FieldValue.serverTimestamp(),
      );
      // var chapters = await _firestore
      //     .collection('courses')
      //     .doc('Artificial Intelligence')
      //     .collection('chapters')
      //     .doc('2')
      //     .get();
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('handymen')
          .doc(handymenId)
          .set(handyman.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createEntry({
    String? name,
    String? house,
    String? block,
    String? phone,
    String? count,
    String? vehicleNumber,
  }) async {
    String res = "Some error occurred";
    try {
      String entryId = const Uuid().v1();
      Entry entry = Entry(
        id: entryId,
        name: name,
        number: phone,
        house: house,
        block: block,
        vehicleNumber: vehicleNumber,
        count: count,
        createdOn: FieldValue.serverTimestamp(),
      );

      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('entries')
          .doc(entryId)
          .set(entry.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> outEntry(String handymenId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('entries')
          .doc(handymenId)
          .update({'exitTime': DateTime.now()});
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createHouseHoldMember({
    
    String? name,
    String? uid,
    String? image,
    String? role,
    String? type,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('house')
          .doc(Constants.userData.house)
          .collection("households")
          .doc(uid)
          .set({
        'uid': uid,
        "name": name,
        "role": role,
        "image": image,
        "type": type,
        "createdOn": FieldValue.serverTimestamp(),
        'isTenant': Constants.userData.isTenant,
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createAmenities({
    String? name,
    String? price,
    String? upi,
    String? amenityId,
    String? image,
    String? type,
    bool? isFree,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('amenities')
          .doc(amenityId)
          .set({
        "id": amenityId,
        "name": name,
        "price": price,
        "type": type,
        'upi':upi,
        "image": image,
        "isFree": isFree,
        'status': 'Pending',
        "createdOn": FieldValue.serverTimestamp(),
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addBooking({
    String? amount,
    String? amenityId,
    dynamic from,
    dynamic to,
    String? upi,
    String? name,
    String? imageUrl,
    String? type,
  }) async {
    String res = "Some error occurred";
    try {
      Amenity amenity = Amenity(
        uid: user!.uid,
        id: amenityId,
        name: name,
        upi: upi,
        image: imageUrl,
        amount: amount,
        from: from,
        to: to,
        status: 'Pending',
        type: type,
        username: user!.displayName,
        createdOn: FieldValue.serverTimestamp(),
      );
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection("amenities")
          .doc(amenityId)
          .set(amenity.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createBusiness({
    String? name,
    String? title,
    String? link,
    String? businessId,
    String? image,
    String? des,
    String? number,
    String? type,
    String? house,
    String? userId,
  }) async {
    String res = "Some error occurred";
    try {
      Business business = Business(
        id: userId,
        name: name,
        title: title,
        link: link,
        des: des,
        image: image,
        number: number,
        house: house,
        businessid: businessId,
        type : type,
        createdOn: FieldValue.serverTimestamp(),
      );
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection("business")
          .doc(businessId)
          .set(business.toJson());

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteBusiness(String businessID) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection("business")
          .doc(businessID)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> sendGuardNotification({
    String? type,
    String? body,
    String? title,
    // dynamic date,
  }) async {
    String res = "Some error occurred";
    try {
                String notificationId = const Uuid().v1();
      FirebaseFirestore.instance
          .collection('users')
          .where("societyId", isEqualTo: Constants.societyId)
          .where("type", isEqualTo: 'guard')
          .get()
          .then((data) => data.docs.forEach((doc) {

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .collection('notifications')
                    .doc(notificationId)
                    .set({
                  'id': notificationId,
                  'title': title,
                  'body': body,
                  'timestamp': FieldValue.serverTimestamp(),
                  'type': type,
                  'uid': Constants.userId,
                });
                // userIds.add(doc["id"]);
              }));
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> sendAdminNotification({
    String? type,
    String? body,
    String? title,
    String? amenityId,
    // dynamic date,
  }) async {
    String res = "Some error occurred";
    try {
                String notificationId = const Uuid().v1();
      FirebaseFirestore.instance
          .collection('users')
          .where("societyId", isEqualTo: Constants.societyId)
          .where("type", isEqualTo: 'admin')
          .get()
          .then((data) => data.docs.forEach((doc) {

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .collection('notifications')
                    .doc(notificationId)
                    .set({
                  'id': notificationId,
                  'title': title,
                  'body': body,
                  'timestamp': FieldValue.serverTimestamp(),
                  'type': type,
                  'uid': Constants.userId,
                  'amenityId': amenityId,
                });
                // userIds.add(doc["id"]);
              }));
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> sendMemberNotification({
    String? type,
    String? body,
    String? title,
    // dynamic date,
  }) async {
    String res = "Some error occurred";
    try {
                String notificationId = const Uuid().v1();
      FirebaseFirestore.instance
          .collection('users')
          .where("societyId", isEqualTo: Constants.societyId)
          .where("type", isEqualTo: 'member')
          .get()
          .then((data) => data.docs.forEach((doc) {

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .collection('notifications')
                    .doc(notificationId)
                    .set({
                  'id': notificationId,
                  'title': title,
                  'body': body,
                  'timestamp': FieldValue.serverTimestamp(),
                  'type': type,
                  'uid': Constants.userId,
                });
                // userIds.add(doc["id"]);
              }));
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> sendUserNotification({
    String? type,
    String? body,
    String? title,
    // dynamic date,
  }) async {
    String res = "Some error occurred";
    try {
                String notificationId = const Uuid().v1();
      await FirebaseFirestore.instance
          .collection('users')
          .where("societyId", isEqualTo: Constants.societyId)
          .get()
          .then((data) => data.docs.forEach((doc) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .collection('notifications')
                    .doc(notificationId)
                    .set({
                  'id': notificationId,
                  'title': title,
                  'body': body,
                  'timestamp': FieldValue.serverTimestamp(),
                  'type': type,
                  'uid': Constants.userId,
                });

                // userIds.add(doc["id"]);
              }));
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> sendIndividualNotification({
    String? type,
    String? body,
    String? title,
    String? id,
    // dynamic date,
  }) async {
    String res = "Some error occurred";

    String notificationId = const Uuid().v1();
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('notifications')
        .doc(notificationId)
        .set({
      'id': notificationId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'uid': Constants.userId,
    });

    res = "success";

    return res;
  }

  // Future<String> createCard({
  //   int index,
  //   String username,
  //   String courseId,
  //   String course,
  //   String chapterId,
  //   String chapter,
  //   String title,
  //   String youtubeId,
  //   String description,
  //   String keypoint,
  //   String notes,
  //   String questions,
  //   String questionsList,
  //   String nExtension,
  //   String qExtension,
  //   bool isverified,
  //   // String profImage
  // }) async {
  //   String res = "Some error occurred";
  //   try {
  //     // String photoUrl =
  //     //     await StorageMethods().uploadImageToStorage('posts', file, true);
  //     String cardId = const Uuid().v1();

  //     Card card = Card(
  //       description: description,
  //       uid: FirebaseAuth.instance.currentUser.uid,
  //       username: username,
  //       likes: [],
  //       reads: [],
  //       cardId: cardId,
  //       datePublished: DateTime.now().millisecondsSinceEpoch,
  //       // postUrl: photoUrl,
  //       nExtension: nExtension,
  //       qExtension: qExtension,
  //       course: course,
  //       courseId: courseId,
  //       chapterId: chapterId,
  //       chapter: chapter,
  //       index: 1,

  //       isverified: FirebaseAuth.instance.currentUser != null
  //           ? FirebaseAuth.instance.currentUser.email ==
  //                   "bhargavsinghbarad007@gmail.com"
  //               ? true
  //               : false
  //           : false,
  //       notes: notes,
  //       title: title,
  //       questions: questions,
  //       questionsList: "Test Questions?",
  //       keypoint: keypoint,
  //       youtubeId: youtubeId,

  //       // profImage: profImage,
  //     );

  //     _firestore.collection('cards').doc(cardId).set(card.toJson());
  //     _firestore.collection("chapters").doc(chapterId).update({"members": []});
  //     res = "success";
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> editCard({
  //   int index,
  //   String cardId,
  //   String title,
  //   String youtubeId,
  //   String description,
  //   String keypoint,
  //   String notes,
  //   String questions,
  //   String questionsList,
  //   String qExtension,
  //   String nExtension,
  //   // String profImage
  // }) async {
  //   String res = "Some error occurred";
  //   try {
  //     // String photoUrl =
  //     //     await StorageMethods().uploadImageToStorage('posts', file, true);
  //     _firestore.collection('cards').doc(cardId).update({'title': title});
  //     _firestore
  //         .collection('cards')
  //         .doc(cardId)
  //         .update({'youtubeId': youtubeId});
  //     _firestore
  //         .collection('cards')
  //         .doc(cardId)
  //         .update({'description': description});
  //     _firestore.collection('cards').doc(cardId).update({'keypoint': keypoint});
  //     _firestore.collection('cards').doc(cardId).update({'notes': notes});
  //     _firestore
  //         .collection('cards')
  //         .doc(cardId)
  //         .update({'nExtension': nExtension});
  //     _firestore
  //         .collection('cards')
  //         .doc(cardId)
  //         .update({'qExtension': qExtension});

  //     _firestore
  //         .collection('cards')
  //         .doc(cardId)
  //         .update({'questions': questions});

  //     res = "success";
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  Future<String> editProfile({
    String? imageUrl,
    // String profImage
  }) async {
    String res = "Some error occurred";
    try {
      // String imageUrl =
      //     await StorageMethods().uploadImageToStorage('posts', file, true);
      _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'imageUrl': imageUrl});
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> editUserData({
    String? name,
    bool? isResident,
    String? phone,
  }) async {
    String res = "Some error occurred";
    try {
      // String imageUrl =
      //     await StorageMethods().uploadImageToStorage('posts', file, true);
      _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'firstName': name,
        "isResident": isResident,
        'phone': phone,
        'searchName': name!.toLowerCase().removeAllWhiteSpace(),
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // // Future<String> uploadPost(
  // //   String description,
  // //   Uint8List file,
  // //   String uid,
  // //   String username,
  // //   // String profImage
  // // ) async {
  // //   String res = "Some error occurred";
  // //   try {
  // //     // String photoUrl =
  // //     //     await StorageMethods().uploadImageToStorage('posts', file, true);
  // //     String postId = const Uuid().v1();
  // //     String chapterId = "1"; //const Uuid().v1();
  // //     String courseId = "1"; // const Uuid().v1();

  // //     Card card = Card(
  // //       description: description,
  // //       uid: uid,
  // //       username: username,
  // //       likes: [],
  // //       postId: postId,
  // //       datePublished: DateTime.now(),
  // //       // postUrl: photoUrl,
  // //       course: "Artificial Intelligence",
  // //       courseId: courseId,
  // //       chapterId: chapterId,
  // //       chapter: "Introduction",
  // //       index: 1,
  // //       isverified: true,
  // //       notes:
  // //           "https://codingjr.online/assets/frontend/default/home/popular_course/7.pdf",
  // //       title: "Thinking out Load",
  // //       questions:
  // //           "https://codingjr.online/assets/frontend/default/home/popular_course/7.pdf",
  // //       questionsList: "Heyyy?",
  // //       keypoint: "It is mutable",
  // //       youtubeId: "L7mfjvdnPno",

  // //       // profImage: profImage,
  // //     );

  // //     var courses = await _firestore.collection('courses').doc(courseId).get();
  // //     if (!courses.exists) {
  // //       await _firestore
  // //           .collection('courses')
  // //           .doc('Artificial Intelligence')
  // //           .set({"Id": 1, "name": "python"});
  // //     }
  // //     var chapters = await _firestore
  // //         .collection('courses')
  // //         .doc('Artificial Intelligence')
  // //         .collection('chapters')
  // //         .doc('2')
  // //         .get();
  // //     if (!chapters.exists) {
  // //       await _firestore
  // //           .collection('courses')
  // //           .doc('Artificial Intelligence')
  // //           .collection('chapters')
  // //           .doc('2')
  // //           .set({"Id": 1, "name": "Lists"});
  // //     }
  // //     _firestore
  // //         .collection('courses')
  // //         .doc('Artificial Intelligence')
  // //         .collection('chapters')
  // //         .doc('2')
  // //         .collection('cards')
  // //         .doc(postId)
  // //         .set(card.toJson());
  // //     res = "success";
  // //   } catch (err) {
  // //     res = err.toString();
  // //   }
  // //   return res;
  // // }

  // Future<String> reportCourse({
  //   String courseId,
  //   String courseName,
  //   String issue,
  // }) async {
  //   String res = "Some error occurred";
  //   try {
  //     await _firestore
  //         .collection('issues')
  //         .doc(courseName + " - " + courseId)
  //         .set({
  //       "courseId": courseId,
  //       "issue": issue,
  //       "CourseName": courseName,
  //       "uid": FirebaseAuth.instance.currentUser.uid
  //     });
  //     res = "success";
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  Future<String> report({
    String? issue,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('issues')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({"issue": issue, "uid": FirebaseAuth.instance.currentUser!.uid});
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Future<String> likePost(String postId, String uid, List likes) async {
  //   String res = "Some error occurred";
  //   try {
  //     if (likes.contains(uid)) {
  //       // if the likes list contains the user uid, we need to remove it
  //       _firestore.collection('cards').doc(postId).update({
  //         'likes': FieldValue.arrayRemove([uid])
  //       });
  //     } else {
  //       // else we need to add uid to the likes array
  //       _firestore.collection('cards').doc(postId).update({
  //         'likes': FieldValue.arrayUnion([uid])
  //       });
  //     }
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> chapterComplete(
  //     String chapterID, String uid, List members) async {
  //   String res = "Some error occurred";
  //   try {
  //     if (members.contains(uid)) {
  //       // if the likes list contains the user uid, we need to remove it
  //       _firestore.collection('chapters').doc(chapterID).update({
  //         'members': FieldValue.arrayRemove([uid])
  //       });
  //     } else {
  //       // else we need to add uid to the likes array
  //       _firestore.collection('chapters').doc(chapterID).update({
  //         'members': FieldValue.arrayUnion([uid])
  //       });
  //     }
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> courseEnrolled(
  //     String courseID, String uid, List members) async {
  //   String res = "Some error occurred";
  //   try {
  //     if (members.contains(uid)) {
  //       // if the likes list contains the user uid, we need to remove it
  //       _firestore.collection('courses').doc(courseID).update({
  //         'members': FieldValue.arrayRemove([uid])
  //       });
  //     } else {
  //       // else we need to add uid to the likes array
  //       _firestore.collection('courses').doc(courseID).update({
  //         'members': FieldValue.arrayUnion([uid])
  //       });
  //     }
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> readsCard(String postId, String uid, List likes) async {
  //   String res = "Some error occurred";
  //   try {
  //     if (!likes.contains(uid)) {
  //       _firestore.collection('cards').doc(postId).update({
  //         'reads': FieldValue.arrayUnion([uid])
  //       });
  //       // if the likes list contains the user uid, we need to remove it
  //       // _firestore.collection('cards').doc(postId).update({
  //       //   'reads': FieldValue.arrayRemove([uid])
  //       // });
  //     }
  //     //else {
  //     //   // else we need to add uid to the likes array
  //     // }
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> likeCourse(String courseId, String uid, List likes) async {
  //   String res = "Some error occurred";
  //   try {
  //     if (likes.contains(uid)) {
  //       // if the likes list contains the user uid, we need to remove it
  //       _firestore.collection('courses').doc(courseId).update({
  //         'likes': FieldValue.arrayRemove([uid]),
  //         'likesCount': FieldValue.increment(-1)
  //       });
  //     } else {
  //       // else we need to add uid to the likes array
  //       _firestore.collection('courses').doc(courseId).update({
  //         'likes': FieldValue.arrayUnion([uid]),
  //         'likesCount': FieldValue.increment(1)
  //       });
  //     }
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> changeScope(String courseId, bool ispublic) async {
  //   String res = "Some error occurred";
  //   try {
  //     if (ispublic) {
  //       // if the likes list contains the user uid, we need to remove it
  //       _firestore
  //           .collection('courses')
  //           .doc(courseId)
  //           .update({'ispublic': false});
  //     } else {
  //       // else we need to add uid to the likes array
  //       _firestore
  //           .collection('courses')
  //           .doc(courseId)
  //           .update({'ispublic': true});
  //     }
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<String> addmoney(int coins, String uid) async {
  //   String res = "Some error occurred";
  //   try {
  //     if (coins != 0) {
  //       DocumentSnapshot currentusersnap =
  //           await _firestore.collection('users').doc(uid).get();
  //       await _firestore.collection('users').doc(uid).update({
  //         'coins': ((currentusersnap.data() as Map<String, dynamic>)['coins'] +
  //             coins)
  //       });

  //       res = 'success';
  //     } else {
  //       res = "Please enter text";
  //     }
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // // Post transactions
  // Future<String> postTransactions(String postId, int coins, String uid,
  //     String name, String profilePic) async {
  //   String res = "Some error occurred";

  //   try {
  //     if (coins != 0) {
  //       DocumentSnapshot currentusersnap =
  //           await _firestore.collection('users').doc(uid).get();

  //       await _firestore.collection('users').doc(uid).update({
  //         'coins': ((currentusersnap.data() as Map<String, dynamic>)['coins'] -
  //             coins)
  //       });

  //       DocumentSnapshot postusersnap =
  //           await _firestore.collection('posts').doc(postId).get();
  //       DocumentSnapshot postuseridsnap = await _firestore
  //           .collection('users')
  //           .doc((postusersnap.data() as Map<String, dynamic>)['uid'])
  //           .get();
  //       await _firestore
  //           .collection('users')
  //           .doc((postusersnap.data() as Map<String, dynamic>)['uid'])
  //           .update({
  //         'coins':
  //             ((postuseridsnap.data() as Map<String, dynamic>)['coins'] + coins)
  //       });

  //       String payementId = const Uuid().v1();

  //       _firestore
  //           .collection('posts')
  //           .doc(postId)
  //           .collection('transactions')
  //           .doc(payementId)
  //           .set({
  //         // 'profilePic': profilePic,
  //         'name': name,
  //         'uid': uid,
  //         'coins': coins,
  //         'payementId': payementId,
  //         'datePublished': DateTime.now(),
  //       });
  //       res = 'success';
  //     } else {
  //       res = "Please enter text";
  //     }
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // // Delete Chapter
  Future<String> deleteNotice(String noticeId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('notices')
          .doc(noticeId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteMaintenance(String noticeId) async {
    String res = "Some error occurred";
    try {
      _firestore
          .collection("societies")
          .doc(Constants.societyId)
          .collection('maintenances')
          .doc(noticeId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

   Future<String> deleteHouseHoldMember({
    String? uid,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('house')
          .doc(Constants.userData.house)
          .collection("households")
          .doc(uid)
          .delete();
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteGalleryImage(String imageId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('gallery')
          .doc(imageId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteStore(String storeId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('stores').doc(storeId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteHandymen(String handymenId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('handymen')
          .doc(handymenId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteVehicle(String vehicleId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteAmenity(String amenityID) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('amenities')
          .doc(amenityID)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteRule(String ruleId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('rules')
          .doc(ruleId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removeUser(String uid) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('users').doc(uid).update({
        'societyCode': "",
        'societyId': "",
        'societyName': '',
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteVisitor(String visitorID) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('guests')
          .doc(visitorID)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteHelpDesk(String helpDeskID) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('societies')
          .doc(Constants.societyId)
          .collection('helpDesk')
          .doc(helpDeskID)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  // Future<String> deleteCourse(String courseId) async {
  //   String res = "Some error occurred";
  //   try {
  //     await _firestore.collection('courses').doc(courseId).delete();

  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // // Delete Post
  // Future<String> deletePost(String postId) async {
  //   String res = "Some error occurred";
  //   try {
  //     await _firestore.collection('posts').doc(postId).delete();
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Future<void> followUser(String uid, String followId) async {
  //   try {
  //     DocumentSnapshot snap =
  //         await _firestore.collection('users').doc(uid).get();
  //     List following = (snap.data() as dynamic)['following'];

  //     if (following.contains(followId)) {
  //       await _firestore.collection('users').doc(followId).update({
  //         'followers': FieldValue.arrayRemove([uid])
  //       });

  //       await _firestore.collection('users').doc(uid).update({
  //         'following': FieldValue.arrayRemove([followId])
  //       });
  //     } else {
  //       await _firestore.collection('users').doc(followId).update({
  //         'followers': FieldValue.arrayUnion([uid])
  //       });

  //       await _firestore.collection('users').doc(uid).update({
  //         'following': FieldValue.arrayUnion([followId])
  //       });
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
}
