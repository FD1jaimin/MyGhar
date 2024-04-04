// ignore_for_file: depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/user_provider.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/views/chats/chat.dart';
import 'package:urbannest/views/pole_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:velocity_x/velocity_x.dart';

// import '../../models/user.dart' as model;
import '../../widgets/floating_action_button.dart';
import '../gallery_screen.dart';
import 'users.dart';
import 'util.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key,this.userData});

  final UserData? userData;

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  static Widget buildAvatar(types.Room room) {
    var color = Colors.transparent;

    final hasImage = room.imageUrl != null && room.imageUrl != "";
    if (!hasImage) {
      try {
        final otherUser = room.users.firstWhere(
          (u) => u.id != Constants.userId,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found.
      }
    }

    final name = room.name ?? '';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: hasImage ? Colors.white : color, shape: BoxShape.circle),
      height: 50,
      width: 50,
      child: 
      hasImage
          ? CachedNetworkImage(
              imageUrl: room.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
              child: Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: AppTheme.subheading2.copyWith(color: Colors.white),
              ),
            ),
              errorWidget: (context, url, error) => const skeleton(
                height: 50,
                width: 50,
                colors: Colors.white,
              ),
            )
          :
           Center(
              child: Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: AppTheme.subheading2.copyWith(color: Colors.white),
              ),
            ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    messageList = widget.userData!.newMessage;
    blockedList = widget.userData!.blockedUser;
    super.initState();
  }

  List<dynamic> messageList = []; 

  List<dynamic> blockedList = []; 
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: CustomFloatingActionButton(
        onTap: () {
          Get.to( UsersPage());
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: StreamBuilder<List<types.Room>>(
                stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: true),
                initialData: const [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 64.0),
                        child: LoadingAnimationWidget.waveDots(
                            color: AppTheme.lightText, size: 40),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 64.0),
                        child: Text(
                            "Nothing here!\nTry searching your residents",
                            style: AppTheme.smallText,
                            textAlign: TextAlign.center),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final room = snapshot.data![index];
                      String targetId =room.users[0].id == Constants.userId ? room.users[1].id : room.users[0].id;
    
                      return blockedList.contains(targetId) ?SizedBox(): Slidable(
                          closeOnScroll: true,
                          enabled: room.type == types.RoomType.group ? false: true,

                          // enabled: user.uid == widget.data['uid'] ? true : false,
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                flex: 1,
                                onPressed: (context) {
                                  blockedList.add(targetId);
                                  setState(() {
                                    
                                  });
                                  FirebaseFirestore.instance.collection('users').doc(Constants.userId).update({
                                    'blockedUser':FieldValue.arrayUnion([targetId]),
                                  });
                                  // FireStoreMethods()
                                  //     .deleteNotice(data[index].id!);
                                  // deletechapter(widget.snap.chapterId);
                                  // widget.chaptername.clear();
                                  // widget.description.clear();
                                  // icon = FontAwesomeIcons.add;
                                  // Fluttertoast.showToast(msg: "Chapter Deleted");
                                },

                                // showDialog(
                                //   context: context,
                                //   builder: (context) => CupertinoAlertDialog(
                                //     title: new Text("Dialog Title"),
                                //     content: new Text("This is my content"),
                                //     actions: <Widget>[
                                //       CupertinoDialogAction(
                                //         isDefaultAction: true,
                                //         child: Text("Yes"),
                                //       ),
                                //       CupertinoDialogAction(
                                //         child: Text("No"),
                                //       )
                                //     ],
                                //   ),
                                // );
                                // },s
                                icon: FontAwesomeIcons.x,

                                autoClose: true,
                                label: "Block",

                                padding: const EdgeInsets.all(12),
                                backgroundColor: AppTheme.lightBackgroundColor,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: 
                      chatBox( context, room),
                          ),
                        );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector chatBox( BuildContext context, types.Room room) {
    return GestureDetector(
                      onTap: () {
                        messageList.remove(room.id);
                        setState(() {
                          
                        });
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              room: room,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 24,top: 4,bottom: 4,),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(32)),
                          ),
                          child: Row(
                            children: [
                              16.widthBox,
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, bottom: 16),
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              AppTheme.lightBackgroundColor,
                                          width: 2),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            offset: const Offset(0, 0),
                                            blurRadius: 8,
                                            color: AppTheme.appColor
                                                .withOpacity(0.08))
                                      ],
                                    ),
                                    child: buildAvatar(room)),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room.name ?? '',
                                        style: AppTheme.heading2,
                                        maxLines: 2,
                                      ),
                                     
                                    ],
                                  ),
                                ),
                              ),
                               messageList.contains(room.id) ? Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                              color: Colors.green[400],
                              shape: BoxShape.circle)) : SizedBox(),
                              24.widthBox,
                            ],
                          ),
                        ),
                      ),
                    );
  }

  Padding _buildAppBar() {
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 16, left: 24, right: 24),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
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
                    "Chats",
                    style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.8, right: 16),
              child: Column(
                children: [
                  const Icon(
                    Icons.poll,
                    color: Colors.black87,
                    size: 30,
                  ),
                  2.heightBox,
                  Text("Polls",
                      style:
                          AppTheme.smallText.copyWith(color: Colors.black87)),
                ],
              ).onTap(() {
                Get.to(PoleScreen(
                  societyId: Constants.societyId,
                ));
              }),
            ),
          ],
        ));
  }
}
