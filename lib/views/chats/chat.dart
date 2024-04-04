// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:http/http.dart' as http;

import 'package:urbannest/models/user.dart' as model;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../widgets/back_button.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.room,
  });

  final types.Room room;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    // TODO: implement initState
    String targetId = widget.room.users[0].id == Constants.userId
        ? widget.room.users[1].id
        : widget.room.users[0].id;

    FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.userId)
        .update({
      'newMessage': FieldValue.arrayRemove([widget.room.id]),
    });
    super.initState();
  }

  bool _isAttachmentUploading = false;
  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      // backgroundColor: Colors.white,
      builder: (BuildContext context) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            height: 155,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleImageSelection();
                    },
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Photo',
                        style: AppTheme.subheading3,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleFileSelection();
                    },
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'File',
                        style: AppTheme.subheading3,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Cancel',
                        style: AppTheme.subheading3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        for (int i = 0; i < widget.room.users.length; i++) {
          if (widget.room.users[i].id == Constants.userId) continue;
          var targetUser = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.room.users[i].id)
              .get();
          if (targetUser["blockedUser"].contains(Constants.userId)) continue;
          if (!targetUser['newMessage'].contains(widget.room.id)) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.room.users[i].id)
                .update({
              'newMessage': FieldValue.arrayUnion([widget.room.id]),
            });
          }
        }

        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        for (int i = 0; i < widget.room.users.length; i++) {
          if (widget.room.users[i].id == Constants.userId) continue;
          var targetUser = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.room.users[i].id)
              .get();
          if (targetUser["blockedUser"].contains(Constants.userId)) continue;
          if (!targetUser['newMessage'].contains(widget.room.id)) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.room.users[i].id)
                .update({
              'newMessage': FieldValue.arrayUnion([widget.room.id]),
            });
          }
        }
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _handleSendPressed(types.PartialText message) async {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
    // if (widget.room.type == types.RoomType.group) {
    for (int i = 0; i < widget.room.users.length; i++) {
      if (widget.room.users[i].id == Constants.userId) continue;
      var targetUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.room.users[i].id)
          .get();
      try {
        if (targetUser["blockedUser"] != null &&
            targetUser["blockedUser"].contains(Constants.userId)) continue;
      } catch (e) {
        debugPrint(e.toString());
      }
      if (!targetUser['newMessage'].contains(widget.room.id)) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.room.users[i].id)
            .update({
          'newMessage': FieldValue.arrayUnion([widget.room.id]),
        });
      }
    }
    // }
    // String targetId = widget.room.users[0].id == Constants.userId
    //     ? widget.room.users[1].id
    //     : widget.room.users[0].id;
    // var targetUser = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(targetId)
    //     .get();

    // if (!targetUser['newMessage'].contains(Constants.userId)) {
    //   FirebaseFirestore.instance.collection('users').doc(targetId).update({
    //     'newMessage': FieldValue.arrayUnion([Constants.userId]),
    //   });
    // }
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              StreamBuilder<types.Room>(
                initialData: widget.room,
                stream: FirebaseChatCore.instance.room(widget.room.id),
                builder: (context, snapshot) =>
                    StreamBuilder<List<types.Message>>(
                  initialData: const [],
                  stream: FirebaseChatCore.instance.messages(snapshot.data!),
                  builder: (context, snapshot) => Chat(
                    isAttachmentUploading: _isAttachmentUploading,
                    messages: snapshot.data ?? [],
                    onAttachmentPressed: _handleAtachmentPressed,
                    // audioMessageBuilder: _audio,
                    onMessageTap: _handleMessageTap,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    onSendPressed: _handleSendPressed,
                    inputOptions: InputOptions(sendButtonVisibilityMode: SendButtonVisibilityMode.always),
                    showUserNames:
                        widget.room.type == types.RoomType.group ? true : false,
                    user: types.User(
                      id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                    ),
                  ),
                ),
              ),
              SafeArea(
                  child: Row(
                children: [
                  16.widthBox,
                  const CustomBackButton(
                    color: Colors.white,
                  )
                ],
              ))
            ],
          ),
        ),
      );
}
