import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:urbannest/core/constants.dart';
import 'package:velocity_x/velocity_x.dart';

// enum Role { admin, agent, moderator, user }

class UserData {
  final String email;
  final String uid;
  final String imageUrl;
  final String firstName;
  final String lastName;
  //chat
  final int? lastSeen;
  final Map<String, dynamic>? metadata;
  final types.Role? role;
  final int? createdAt;
  final int? updatedAt;
  final String? token;
  final String? societyId;
  final String? house;
  final String? block;
  final String? phone;
  final String? address;
  final String? societyName;
  final String? societyCode;
  final String? type;
  final bool? isResident;
  final newMessage;
  final bool? isSuperAdmin;
  final bool? houseOwner;
  final String? societyGroupId;
  final String? societyAdminGroupId;
  final bool? isTenant;

  final blockedUser;

  const UserData({
    required this.firstName,
    this.lastName = "",
    required this.uid,
    this.imageUrl = "",
    required this.email,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.role,
    this.type,
    this.token,
    this.societyId,
    this.house,
    this.block,
    this.address,
    this.phone,
    this.societyName,
    this.societyCode,
    this.isResident,
    this.newMessage,
    this.blockedUser,
    this.houseOwner,
    this.isSuperAdmin,
    this.isTenant,
    this.societyAdminGroupId,
    this.societyGroupId,
  });
  static UserData fromSnap(DocumentSnapshot snap) {
    Future<UserData> uploaduser() async {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final currentuser = FirebaseAuth.instance.currentUser;
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      Constants.FCM = fcmToken;
      await _firestore.collection("users").doc(currentuser!.uid).set({
        "uid": currentuser.uid,
        "email": currentuser.email,
        'createdAt': FieldValue.serverTimestamp(),
        'firstName': currentuser.displayName!,
        'imageUrl': '',
        'lastName': '',
        'lastSeen': FieldValue.serverTimestamp(),
        'metadata': null,
        'role': null,
        'updatedAt': FieldValue.serverTimestamp(),
        'token': fcmToken,
        'type': 'user',
        'isResident': true,
        'societyId': '',
        'societyCode': '',
        'societyName': '',
        'societyAdminGroupId': "",
        'societyGroupId':"",
        'block': '',
        'house': '',
        'address': '',
        'newMessage': [],
        'blockedUser': [],
        'searchName':
            currentuser.displayName!.toLowerCase().removeAllWhiteSpace()
      });

      return UserData(uid: currentuser.uid,
        email: currentuser.email!,
        firstName: currentuser.displayName!,
        imageUrl: '',
        lastName: '',
        metadata: null,
        role: null,
        token: fcmToken,
        type: 'user',
        isResident: true,
        societyId: '',
        societyCode: '',
        societyName: '',
        block: '',
        house: '',
        address: '',
        newMessage: [],
        isSuperAdmin: false,
        houseOwner: false,
        phone: '',
        isTenant: false,
        societyAdminGroupId: '',
        societyGroupId: '',

        blockedUser: [],);
    }

      

    if (snap.data() == null) {
      uploaduser();
       final currentuser = FirebaseAuth.instance.currentUser;
       return UserData(uid: currentuser!.uid,
        email: currentuser.email!,
        firstName: currentuser.displayName!,
        imageUrl: '',
        lastName: '',
        metadata: null,
        role: null,
        token: Constants.FCM,
        type: 'user',
        isResident: true,
        societyId: '',
        societyCode: '',
        societyName: '',
        block: '',
        house: '',
        address: '',
        newMessage: [],
        isSuperAdmin: false,
        houseOwner: false,
        phone: '',
        isTenant: false,societyAdminGroupId: '',societyGroupId: '',

        blockedUser: [],);
      
    } else {
      var snapshot = snap.data() as Map<String, dynamic>;
      Constants.societyId = snapshot['societyId'];
      Constants.userId = snapshot['uid'];
      Constants.type = snapshot['type'];
      
      UserData data = UserData(
          firstName: snapshot["firstName"],
          lastName: snapshot["lastName"],
          uid: snapshot["uid"],
          email: snapshot["email"],
          imageUrl: snapshot["imageUrl"],
          token: snapshot["token"],
          // lastSeen: snapshot["lastSeen"] as int?,
          // createdAt: snapshot["createdAt"],
          metadata: snapshot["metadata"],
          role: snapshot["role"],
          societyId: snapshot['societyId'],
          societyCode: snapshot['societyCode'],
          block: snapshot["block"],
          house: snapshot['house'],
          address: snapshot["address"],
          societyName: snapshot['societyName'],
          phone: snapshot['phone'],
          type: snapshot["type"],
          isResident: snapshot["isResident"] ?? true,
          blockedUser: snapshot['blockedUser'] ?? [],
          newMessage: snapshot['newMessage'] ?? [],
          houseOwner: snapshot['houseOwner'] ?? false,
          isSuperAdmin: snapshot['isSuperAdmin'] ?? false,
          isTenant: snapshot['isTenant'] ?? false,
          societyGroupId: snapshot['societyAdminGroupId']??"",
          societyAdminGroupId: snapshot['societyAdminGroupId']??'',
          // updatedAt: snapshot["updatedAt"],
          );
      Constants.userData = data;
      return data;
    }
  }

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        'lastName': lastName,
        "uid": uid,
        "email": email,
        "imageUrl": imageUrl,
        "lastSeen": lastSeen,
        "createdAt": createdAt,
        'metadata': metadata,
        'role': role,
        "updatedAt": updatedAt,
        'societyCode': societyCode,
        'societyId': societyId,
        'societyName': societyName,
        'house': house,
        'block': block,
        'address': address,
        'phone': phone,
        'type': type,
        'isResident': isResident,
        'newMessage': newMessage,
        'blockedUser': blockedUser,
        'houseOwner': houseOwner,
        'isSuperAdmin': isSuperAdmin,
        'isTenant': isTenant,
        'societyAdminGroupId':societyAdminGroupId,
        'societyGroupId': societyGroupId,
      };
}
