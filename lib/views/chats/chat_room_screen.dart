// ignore_for_file: unused_local_variable, library_private_types_in_public_api

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/models/message.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/profile_avatar.dart';
import 'package:uuid/uuid.dart';

import '../../models/chatroom.dart';

class ChatRoomPage extends StatefulWidget {
  final UserData targetUser;
  final ChatRoomModel chatroom;

  const ChatRoomPage({
    Key? key,
    required this.targetUser,
    required this.chatroom,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
var uuid = const Uuid();
    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: user!.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [HexColorNew("#c0eaf8"), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
            ),
            Image.asset("assets/bg.png"),
            Column(
              children: [
                Container( decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24),bottomRight: Radius.circular(24))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0,bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Row(
                      children: [
                        const CustomBackButton(color:  Colors.white,),
                     Padding(
                    padding: const EdgeInsets.only(top: 16.8, ),
                      child: ProfileAvatar(uid: widget.targetUser.uid),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 16.8, left: 16),
                      child: Text(widget.targetUser.firstName,style: AppTheme.heading2,),
                    ),
                      ],
                    ),
                  ]),
                ),
                ),
                // This is where the chats will go
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("chatrooms")
                          .doc(widget.chatroom.chatroomid)
                          .collection("messages")
                          .orderBy("createdon", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;
            
                            return ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        dataSnapshot.docs[index].data()
                                            as Map<String, dynamic>);
            
                                return Row(
                                  mainAxisAlignment:
                                      (currentMessage.sender == user!.uid)
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 1.4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (currentMessage.sender ==
                                                user!.uid)
                                            ? AppTheme.darkText
                                            : AppTheme.lightText,
                                        borderRadius: !(currentMessage
                                                    .sender ==
                                                user!.uid)
                                            ? const BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(20),
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(5))
                                            : const BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(5),
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                      ),
                                      child: Text(
                                          currentMessage.text.toString(),
                                          style: AppTheme.heading3.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  "An error occured! Please check your internet connection."),
                            );
                          } else {
                            return const Center(
                              child: Text("Say hi to your new friend"),
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
                ),
            
                Container(
                  color: Colors.grey[200],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter message",
                              hintStyle: AppTheme.smallText),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}