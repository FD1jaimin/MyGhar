// ignore_for_file: depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../widgets/text_fields.dart';
import 'chat.dart';
import 'util.dart';

class UsersPage extends StatelessWidget {
  UsersPage({super.key});

  static Widget buildAvatar(types.User user) {
    final color = getUserAvatarNameColor(user);
    final hasImage = user.imageUrl != null && user.imageUrl != '';
    final name = getUserName(user);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      height: 50,
      width: 50,
      child:
       hasImage
          ? CachedNetworkImage(
              imageUrl: user.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: hasImage ? Colors.white : color,
                child: Center(
                  child: Text(
                    name.isEmpty ? '' : name[0].toUpperCase(),
                    style: AppTheme.subheading2.copyWith(color: Colors.white),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: hasImage ? Colors.white : color,
                child: Center(
                  child: Text(
                    name.isEmpty ? '' : name[0].toUpperCase(),
                    style: AppTheme.subheading2.copyWith(color: Colors.white),
                  ),
                ),
              ),
            )
          :
           Container(
              color: hasImage ? Colors.white : color,
              child: Center(
                child: Text(
                  name.isEmpty ? '' : name[0].toUpperCase(),
                  style: AppTheme.subheading2.copyWith(color: Colors.white),
                ),
              ),
            ),
    );
  }

  void _handlePressed(types.User otherUser, BuildContext context) async {
    final navigator = Navigator.of(context);
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
  }

  bool isFirst = true;
  TextEditingController searchController = TextEditingController();
  var searchText = ''.obs;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 16, left: 24, right: 24),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                child: CustomTextField(
                    isForm: true,
                    onChanged: (value) {
                      searchController.text = value;
                      searchText.value = value;
                    },
                    textController: searchController,
                    hint: "Search name",
                    icon: const Icon(Icons.search),
                    validator: (value) {
                      return null;
                    }),
              ),
              6.heightBox,
              Obx(() {
                return Expanded(
                  child: StreamBuilder<List<types.User>>(
                    stream: (((searchText.value != "" &&
                                searchText.value != null)
                            ? FirebaseFirestore.instance
                                .collection('users')
                                .where('societyId',
                                    isEqualTo: Constants.societyId)
                                .where('searchName',
                                    isGreaterThanOrEqualTo:
                                        searchText.value.trim())
                                .where('searchName',
                                    isLessThan: searchText.value.trim() + 'z')
                                .limit(8)
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('users')
                                .where('societyId',
                                    isEqualTo: Constants.societyId)
                                .snapshots()))
                        .map(
                      (snapshot) => snapshot.docs.fold<List<types.User>>(
                        [],
                        (previousValue, doc) {
                          if (Constants.userId == doc.id) {
                            return previousValue;
                          }
                          if (doc.data()['type'] == 'guard') {
                            return previousValue;
                          }

                          final data = doc.data();

                          data['createdAt'] =
                              data['createdAt']?.millisecondsSinceEpoch;
                          data['id'] = doc.id;
                          data['lastSeen'] =
                              data['lastSeen']?.millisecondsSinceEpoch;
                          data['updatedAt'] =
                              data['updatedAt']?.millisecondsSinceEpoch;

                          return [...previousValue, types.User.fromJson(data)];
                        },
                      ),
                    ),
                    initialData: const [],
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                            bottom: 200,
                          ),
                          child: const Text('No users'),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data![index];

                          return GestureDetector(
                            onTap: () {
                              if(isFirst){
                              isFirst =  false;
                              _handlePressed(user, context);
                              }else{
                                Fluttertoast.showToast(msg: "Please wait!");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 4),
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
                                    Container(
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
                                        child: buildAvatar(user)),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(getUserName(user),
                                                style: AppTheme.subheading2),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "Say HII!!!", //room.lastMessages,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTheme.smallText,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          //  GestureDetector(
                          //     onTap: () {
                          //       _handlePressed(user, context);
                          //     },
                          //     child: Container(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 16,
                          //         vertical: 8,
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           _buildAvatar(user),
                          //           Text(getUserName(user)),
                          //         ],
                          //       ),
                          //     ),
                          //   );
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      );
}
