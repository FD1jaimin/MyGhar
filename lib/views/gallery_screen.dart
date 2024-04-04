// ignore_for_file: avoid_print, unused_local_variable, depend_on_referenced_packages, camel_case_types

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/storage_method.dart';
import 'package:urbannest/views/album_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:urbannest/widgets/floating_action_button.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:urbannest/widgets/topbar.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen(
      {this.albumId = '',
      this.albumName = '',
      this.isAlbum = false,
      super.key});
  final bool isAlbum;
  final String albumId;
  final String albumName;
  @override
  // ignore: library_private_types_in_public_api
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  TextEditingController albumName = TextEditingController();
  List<UploadTask>? uploadedTasks = [];

  List<File> selectedFiles = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  autoDeleteImages() {
    FirebaseFirestore.instance
        .collection('socities')
        .doc(Constants.societyId)
        .collection('gallery')
        .get()
        .then(
          (data) => data.docs.forEach(
            (doc) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              DateTime imageDate = doc.data()['createdAt'].toDate();
              DateTime visitorDate =
                  DateTime(imageDate.year + 1, imageDate.month, imageDate.day);
              if (today.isAfter(visitorDate)) {
                StorageMethods().deleteImage(doc.id);
                FireStoreMethods().deleteGalleryImage(doc.id);
              }
            },
          ),
        );
  }

  int totalImageCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Constants.type == "admin"
          ? CustomFloatingActionButton(
              onTap: () {
                if (totalImageCount > 100) {
                  Fluttertoast.showToast(msg: "Can't add more images.");
                } else {
                  selectImage(context);
                }
              },
            )
          : SizedBox(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CreateTopBar(title: 'Gallery'),
            getAlbums(),
            getImages(),
          ],
        ),
      ),
    );
  }

  Expanded getImages() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('gallery')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading images. Please try again later.",
                  style: AppTheme.smallText),
            );
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            totalImageCount = snapshot.data!.docs.length;
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 6),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24))),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data!.docs[index];
                    var imageUrl = document.get("url");
                    var documentId = document.id;
                    return _buildImageTile(imageUrl, context).onTap(() {
                      _showFullScreenImage(imageUrl, documentId, context);
                    });
                  },
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.only(bottom: 116 + 42),
              child: Center(
                  child: Text(
                "No images available.",
                style: AppTheme.smallText,
              )),
            );
          }
        },
      ),
    );
  }

  Widget _buildImageTile(
    String imageUrl,
    BuildContext context,
  ) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const skeleton(),
      errorWidget: (context, url, error) => const skeleton(),
    );
  }

  uploadFileToStorage(File file) {
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child("images/${DateTime.now().toString()}")
        .putFile(file);
    return task;
  }

  writeImageUrlToFireStore(imageUrl, albumId, albumName) {
    FirebaseFirestore.instance
        .collection("societies")
        .doc(Constants.societyId)
        .collection('gallery')
        .add({
      "url": imageUrl,
      "albumId": albumId,
      "albumName": albumName,
      "createdAt": FieldValue.serverTimestamp()
    }).whenComplete(() => print("$imageUrl is saved in Firestore"));
  }

  saveImageUrlToFirebase(UploadTask task) {
    task.snapshotEvents.listen((snapShot) {
      if (snapShot.state == TaskState.success) {
        snapShot.ref.getDownloadURL().then((imageUrl) =>
            writeImageUrlToFireStore(
                imageUrl, widget.albumId, widget.albumName));
      }
    });
  }

  Future selectFileToUpload(int length) async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);

      if (result != null) {
        selectedFiles.clear();

        for (var selectedFile in result.files) {
          File file = File(selectedFile.path!);
          selectedFiles.add(file);
        }

        for (var file in selectedFiles) {
          if (length > 10)
            return Fluttertoast.showToast(msg: "Cannot add more images.");
          final UploadTask task = uploadFileToStorage(file);
          saveImageUrlToFirebase(task);

          setState(() {
            uploadedTasks!.add(task);
          });
        }
      } else {
        print("User has cancelled the selection");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          titlePadding:
              const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
          title: const Text(
            'Image',
            style: AppTheme.subheading,
          ),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 24),
                      child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                              color: HexColorNew('#F8FAFB'),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(
                            FontAwesomeIcons.images,
                            color: AppTheme.lightText,
                          )),
                    ),
                    const Text(
                      'Choose from Gallery',
                      style: AppTheme.smallText,
                    ),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true, type: FileType.image);

                    if (result != null) {
                      selectedFiles.clear();

                      for (var selectedFile in result.files) {
                        File file = File(selectedFile.path!);
                        selectedFiles.add(file);
                      }

                      for (var file in selectedFiles) {
                        // print(
                        // 'sizeeeeeeee'+ file.readAsBytesSync().length.toString(),
                        // );
                        // if(file.readAsBytesSync().length > 500) {

                        // Uint8List fileU =await  Constants.compressImage(file.readAsBytesSync(),720 , 720, 70);
                        // file = File.fromRawPath(fileU);
                        // }
                        // print(
                        // 'newsizeeeeeeee'+ file.readAsBytesSync().length.toString(),
                        // );
                        final UploadTask task = uploadFileToStorage(file);
                        saveImageUrlToFirebase(task);

                        setState(() {
                          uploadedTasks!.add(task);
                        });
                      }
                    } else {
                      print("User has cancelled the selection");
                    }
                  } catch (e) {
                    print(e);
                  }
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 24),
                      child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                              color: HexColorNew('#F8FAFB'),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(
                            FontAwesomeIcons.camera,
                            color: AppTheme.lightText,
                          )),
                    ),
                    const Text(
                      'Take a photo',
                      style: AppTheme.smallText,
                    ),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);

                    if (pickedFile != null) {
                      File file = File(pickedFile.path);
                      final UploadTask task = uploadFileToStorage(file);
                      saveImageUrlToFirebase(task);

                      setState(() {
                        uploadedTasks!.add(task);
                      });
                    } else {
                      print("User has cancelled the camera capture");
                    }
                  } catch (e) {
                    print(e);
                  }
                }),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(
      String imageUrl, String documentId, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                _buildImageGallery(imageUrl),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomBackButton(
                          color: Colors.black12,
                          iconColor: Colors.white,
                        ),
                        Constants.type == 'admin'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16.8),
                                child: GestureDetector(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(80),
                                      shape: BoxShape.rectangle,
                                    ),
                                    alignment:
                                        const AlignmentDirectional(-0.0, 0),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  onTap: () {
                                    StorageMethods().deleteImage(imageUrl);
                                    FireStoreMethods()
                                        .deleteGalleryImage(documentId);
                                    Get.back();
                                  },
                                ),
                              )
                            : SizedBox()
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getAlbums() {
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 8),
        child: SizedBox(
          // height: 116 + 45,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('societies')
                  .doc(Constants.societyId)
                  .collection('gallery')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Constants.type != 'admin'
                      ? SizedBox()
                      : SizedBox(
                          height: 116 + 45,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12),
                            child: Row(
                              children: [
                                Constants.type != 'admin'
                                    ? SizedBox()
                                    : addAlbumButton(context),
                              ],
                            ),
                          ),
                        );
                } else {
                  List<String> names = [];
                  Map<String, List<dynamic>> data = {};
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    dynamic image = {
                      'albumId': snapshot.data!.docs[i]['albumId'],
                      'albumName': snapshot.data!.docs[i]['albumName'],
                      'createdAt': snapshot.data!.docs[i]['createdAt'],
                      'url': snapshot.data!.docs[i]['url'],
                    };
                    if (image['albumId'] == '') continue;
                    if (data.containsKey(image['albumId'])) {
                      List<dynamic> newValue = data[image['albumId']]!;
                      newValue.add(image);
                      data[image['albumId']] = newValue;
                    } else {
                      names.add(image['albumId']);
                      data[image['albumId']] = [image];
                    }
                  }
                  return Constants.type != 'admin' && names.isEmpty
                      ? SizedBox()
                      : SizedBox(
                          height: 116 + 45,
                          width: double.infinity,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: List<Widget>.generate(
                              names.length + 1,
                              (int index) {
                                List<dynamic> albumData = [];
                                if (index != 0)
                                  albumData = data[names[index - 1]]!;

                                return index == 0
                                    ? Constants.type != 'admin'
                                        ? SizedBox()
                                        : addAlbumButton(context)
                                    : albumsList(albumData, snapshot);
                              },
                            ),
                          ),
                        );
                }
              }),
        ));
  }

  Padding albumsList(List<dynamic> albumData,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color:
                      const Color.fromARGB(255, 141, 191, 217).withOpacity(0.1),
                  width: 1),
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.centerLeft,
              height: 112,
              width: 112,
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: albumCollageBuilder(albumData, snapshot),
            ),
          ),
          2.heightBox,
          SizedBox(
              width: 74,
              child: Text(
                albumData[0]["albumName"],
                textAlign: TextAlign.center,
                style: AppTheme.smallText.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
        ],
      ).onTap(() {
        Get.to(AlbumScreen(
          albumId: albumData[0]["albumId"],
          albumName: albumData[0]["albumName"],
          canAdd: totalImageCount < 100,
        ));
      }),
    );
  }

  GridView albumCollageBuilder(List<dynamic> albumData,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, i) {
        QueryDocumentSnapshot<Map<String, dynamic>> document;
        // ignore: prefer_typing_uninitialized_variables
        var imageUrl;
        String documentId;
        if (i >= albumData.length) {
        } else {
          document = snapshot.data!.docs[i];
          imageUrl = i < albumData.length ? albumData[i]["url"] : '';
          documentId = document.id;
        }

        return i < albumData.length
            ? _buildImageTile(imageUrl, context)
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: const Icon(
                  Icons.image,
                  color: Colors.black26,
                  size: 24,
                ),
              );
      },
    );
  }

  GestureDetector addAlbumButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        albumName.clear();

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => CustomDialog(
                  child: SizedBox(
                    height: 180,
                    width: MediaQuery.of(context).size.width - 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        8.heightBox,
                        const Text(
                          'New Album',
                          style: AppTheme.subheading2,
                          textAlign: TextAlign.center,
                        ),
                        14.heightBox,
                        CustomTextField(
                          icon: const Icon(Icons.photo_library_rounded),
                          isForm: true,
                          keyboardType: TextInputType.name,
                          hint: "Enter Album name",
                          validator: (value) {
                            return null;
                          },
                          textController: albumName,
                        ),
                        12.heightBox,
                        Container(
                          height: 58,
                          width: 188,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: AppTheme.buttonColor,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Add Album',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).onTap(() {
                          String albumId = const Uuid().v1();

                          if (albumName.text != "") {
                            Get.back();
                            Get.to(
                              AlbumScreen(
                                albumId: albumId,
                                albumName: albumName.text,
                                canAdd: totalImageCount < 100,
                              ),
                            );
                            albumName.clear();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please add album name");
                          }
                        }),
                      ],
                    ),
                  ),
                ));
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color:
                      const Color.fromARGB(255, 141, 191, 217).withOpacity(0.1),
                  width: 1),
            ),
            child: Container(
              alignment: Alignment.centerLeft,
              height: 112,
              width: 112,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color.fromARGB(255, 141, 191, 217)
                        .withOpacity(0.1),
                    width: 3),
              ),
              child: const Center(
                  child: Icon(
                // ignore: deprecated_member_use
                FontAwesomeIcons.add,
                color: AppTheme.lightText,
              )),
            ),
          ),
          2.heightBox,
          Text(
            "Add Album",
            style: AppTheme.smallText.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(String imageUrl) {
    return PhotoViewGallery.builder(
      itemCount: 1,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      // loadingBuilder: ,
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
      pageController: PageController(),
    );
  }

  fileFromImageUrl(String url, String userName) async {
    final response = await http.get(
      Uri.parse(url),
    );

    final documentDirectory = await getApplicationDocumentsDirectory();

    var randomNumber = Random();

    final file = File(
      "${documentDirectory.path}${randomNumber.nextInt(100)}_$userName.png",
    );

    file.writeAsBytesSync(response.bodyBytes);

    return XFile(file.path);
  }
}

class skeleton extends StatelessWidget {
  const skeleton({
    this.height,
    this.width,
    this.colors,
    super.key,
  });

  final double? height;
  final Color? colors;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.04)),
      child: Icon(
        Icons.image,
        color: colors != null ? Colors.white : AppTheme.lightBackgroundColor,
        size: height != null ? (height! - 20) : 60,
      ),
    );
  }
}
