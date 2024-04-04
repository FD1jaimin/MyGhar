import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/models/chatroom.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/views/chats/chat_room_screen.dart';
import 'package:urbannest/views/chats/chat_search.dart';
import 'package:urbannest/views/member_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:velocity_x/velocity_x.dart';


class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 12, left: 24, right: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CustomBackButton(),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.8, left: 16),
                      child: Text(
                        "Chats",
                        style:
                            AppTheme.subheading.copyWith(letterSpacing: -0.3),
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${user!.uid}", isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;
                    
                      return ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                    
                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;
                    
                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(user.uid);
                    
                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserData targetUser = userData.data as UserData;
                    
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: MemberCard(context, data: targetUser,subtitle: chatRoomModel.lastMessage ?? "Say HII!!",).onTap(() {
                                      Get.to(ChatRoomPage(
                                            chatroom: chatRoomModel,
                                            targetUser: targetUser,
                                          ),);
                                    }),
                                  );
                                  
                                } else {
                                  return const SizedBox();
                                }
                              } else {
                                return const SizedBox();
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom :64.0),
                          child: Text("Something went wrong!\nPlease try again after some time",style: AppTheme.smallText,textAlign: TextAlign.center,),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.only(bottom :64.0),
                        child: Center(
                          child: Text("Nothing here!\nTry searching your residents",style: AppTheme.smallText,textAlign: TextAlign.center),
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        backgroundColor: AppTheme.appColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Get.to(const SearchPage());
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

class FirebaseHelper {
  static Future<UserData?> getUserModelById(String uid) async {
    UserData? userModel;

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserData.fromSnap(docSnap);
    }

    return userModel;
  }
}