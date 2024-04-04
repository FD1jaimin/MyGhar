// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/views/chats/chat_room_screen.dart';
import 'package:urbannest/views/member_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/chatroom.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var uuid = const Uuid();
  TextEditingController searchController = TextEditingController();
  TextEditingController name = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserData targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${user!.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "No Message yet",
        participants: {
          user!.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      "Search",
                      style:
                          AppTheme.subheading.copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ],
              )),
            CustomTextField(
              hint: "Search name",
              isForm: true,
              icon: const Icon(CupertinoIcons.search),
              obsecure: false,
              autofocus: false,
              validator: (value) {
               
                return null;
              },
              textController: searchController,
            ).px24().py4(),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 58,
              width: 188,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: AppTheme.buttonColor,
              ),
              child: InkWell(
                // key: const ValueKey('Sign Up button'),
                onTap: () {
                  setState(() {});
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Icon(Icons.arrow_forward_rounded,
                      //     color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            searchController.text.isEmpty
                ? Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot userSnapshot =
                                snapshot.data as QuerySnapshot;
        
                            return ListView.builder(
                              itemCount: userSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                UserData newUser = UserData.fromSnap(
                                    userSnapshot.docs[index]);
        
                                return ListTile(
                                  onTap: () async {
                                    ChatRoomModel? chatroomModel =
                                        await getChatroomModel(newUser);
        
                                    if (chatroomModel != null) {
                                      Navigator.pop(context);
                                      Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (context) {
                                        return ChatRoomPage(
                                          targetUser: newUser,
                                          chatroom: chatroomModel,
                                        );
                                      }));
                                    }
                                  },
                                  // leading: const CircleAvatar(
                                  //   backgroundImage: NetworkImage(
                                  //       "targetUserData.photoUrl"),
                                  // ),
                                  title: Text(
                                    newUser.firstName,
                                    style: AppTheme.subheading3,
                                  ),
                                  subtitle: const Text(
                                    "Say hi to your new friend!",
                                    style: AppTheme.smallText,
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else {
                            return const Center(
                              child: Text("No Chats"),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        
                          .where('name',
                              isGreaterThanOrEqualTo: searchController.text.trim())
                          .where('name',
                              isLessThan: '${searchController.text.trim()}z')
                          .limit(8)
                          
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
        
                          if (dataSnapshot.docs.isNotEmpty) {
                            // Map<String, dynamic> userMap = dataSnapshot.docs[0]
                            //     .data() as Map<String, dynamic>;
        
                            UserData searchedUser =
                                UserData.fromSnap(dataSnapshot.docs[0]);
        
                            return ListTile(
                              onTap: () async {
                                ChatRoomModel? chatroomModel =
                                    await getChatroomModel(searchedUser);
        
                                if (chatroomModel != null) {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ChatRoomPage(
                                      targetUser: searchedUser,
                                      chatroom: chatroomModel,
                                    );
                                  }));
                                }
                              },
                              // leading: CircleAvatar(
                              //   backgroundImage:
                              //       NetworkImage(searchedUser.photoUrl!),
                              //   backgroundColor: Colors.grey[500],
                              // ),
                              title: Text(searchedUser.firstName),
                              subtitle: Text(searchedUser.email),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                            );
                          } else {
                            return Expanded(
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    // .where("participants.${userinfo!.uid}", isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.active) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot userSnapshot =
                                          snapshot.data as QuerySnapshot;
        
                                      return ListView.builder(
                                        itemCount: userSnapshot.docs.length,
                                        itemBuilder: (context, index) {
        
                                          UserData targetUserData =
                                              UserData.fromSnap(
                                            userSnapshot.docs[index],
                                          );
        
                                          return MemberCard(context, data: targetUserData,subtitle: "Say HII!",);
                                          
                                          //  ListTile(
                                          //   onTap: () {
                                          //     // ChatRoomModel? chatroomModel =
                                          //     //     await getChatroomModel(
                                          //     //         searchedUser);
        
                                          //     // if (chatroomModel == null) {
                                          //     //   Navigator.pop(context);
                                          //     //   // ignore: use_build_context_synchronously
                                          //     //   Navigator.push(context,
                                          //     //       MaterialPageRoute(
                                          //     //           builder: (context) {
                                          //     //     return ChatRoomPage(
                                          //     //       targetUser: searchedUser,
                                          //     //       chatroom: chatroomModel!,
                                          //     //     );
                                          //     //   }));
                                          //     // }
                                          //     Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //           builder: (context) {
                                          //         return ChatRoomPage(
                                          //             chatroom: chatRoomModel,
                                          //             targetUser:
                                          //                 UserData.fromSnap(
                                          //               userSnapshot
                                          //                   .docs[index],
                                          //             ));
                                          //       }),
                                          //     );
                                          //   },
                                          //   // leading: const CircleAvatar(
                                          //   //   backgroundImage: NetworkImage(
                                          //   //       "targetUserData.photoUrl"),
                                          //   // ),
                                          //   title: Text(
                                          //     targetUserData.firstName,
                                          //     style: AppTheme.subheading3,
                                          //   ),
                                          //   subtitle: (chatRoomModel
                                          //               .chatroomid
                                          //               .toString() !=
                                          //           "")
                                          //       ? const Text(
                                          //           "Say hi to your new friend!",
                                          //           maxLines: 1,
                                          //         )
                                          //       : const Text(
                                          //           "Say hi to your new friend!",
                                          //           style: AppTheme.smallText,
                                          //         ),
                                          // );
        
                                          // return FutureBuilder(
                                          //   future:
                                          //       FirebaseHelper.getUserModelById(
                                          //           participantKeys[0]),
                                          //   builder: (context, userData) {
                                          //     if (userData.connectionState ==
                                          //         ConnectionState.done) {
                                          //       if (userData.data != null) {
                                          //         UserData targetUser =
                                          //             userData.data as UserData;
        
                                          //         return SizedBox();
                                          //       } else {
                                          //         return Container();
                                          //       }
                                          //     } else {
                                          //       return Container();
                                          //     }
                                          //   },
                                          // );
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child:
                                            Text(snapshot.error.toString()),
                                      );
                                    } else {
                                      return const Center(
                                        child: Text("No Chats"),
                                      );
                                    }
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return const Text("An error occured!");
                        } else {
                          return const Text("No results found!");
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
          ],
        ),
      ),
    );
  }
}