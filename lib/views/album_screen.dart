// ignore_for_file: depend_on_referenced_packages, duplicate_ignore, empty_catches

import 'dart:io';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/storage_method.dart';
import 'package:urbannest/views/gallery_screen.dart';
import 'package:urbannest/widgets/back_button.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({this.albumId ='',this.albumName ='',this.canAdd = true, super.key});
  
  final String albumId;
  final bool canAdd;
  final String albumName;
  @override
  // ignore: library_private_types_in_public_api
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> with TickerProviderStateMixin{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late AnimationController animationController;
  
  bool _isLoading =false;
  List<UploadTask>? uploadedTasks = [];

  List<File> selectedFiles = [];

  uploadFileToStorage(File file) {
    _isLoading=true;
    UploadTask task = _firebaseStorage
        .ref()
        .child("images/${DateTime.now().toString()}")
        .putFile(file);
    return task;
  }

  writeImageUrlToFireStore(imageUrl,albumId ,albumName){
   
  _firebaseFirestore.collection('societies').doc(Constants.societyId).collection('gallery').add({
      "url": imageUrl,
      "albumId":albumId,
      "albumName":albumName,
      "createdAt": FieldValue.serverTimestamp()
    }).whenComplete(() {
    _isLoading = false;
    // print("$imageUrl is saved in Firestore");
    });
    
  }

  saveImageUrlToFirebase(UploadTask task) {
    task.snapshotEvents.listen((snapShot) {
      if (snapShot.state == TaskState.success) {
        snapShot.ref
            .getDownloadURL()
            .then((imageUrl) => writeImageUrlToFireStore(imageUrl,widget.albumId,widget.albumName));
      }
    });
  }

  Future selectFileToUpload() async {
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
          final UploadTask task = uploadFileToStorage(file);
          saveImageUrlToFirebase(task);

          setState(() {
            uploadedTasks!.add(task);
          });
        }
      } else {
      }
    } catch (e) {
    }
  }
  @override
  void initState() {
     animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {


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
                          final UploadTask task = uploadFileToStorage(file);
                          saveImageUrlToFirebase(task);

                          setState(() {
                            uploadedTasks!.add(task);
                          });
                        }
                      } else {
                      }
                    } catch (e) {
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
                      }
                    } catch (e) {
                    }
                  }),
            ],
          );
        },
      );
    }

    // var inProgress = 0.obs;
    // int total = 0;
    // List<UploadTask> temp = [];
    // for (int i = 0; i < uploadedTasks!.length; i++) {
    //   if (uploadedTasks![i].snapshot.state == TaskState.success) continue;
    //   temp.add(uploadedTasks![i]);
    //   total = uploadedTasks![i].snapshot.totalBytes;
    // }
    // uploadedTasks = temp;
    return Scaffold(
      floatingActionButton: Constants.type == "admin" ?  FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        backgroundColor: AppTheme.appColor,
        foregroundColor: Colors.white,
        onPressed: () {
          if(!widget.canAdd){

          Fluttertoast.showToast(msg: "Can't add more images.");
          }else{

          selectImage(context);
          } 
          //selectFileToUpload();
        },
        child: const Icon(Icons.add),
      ):SizedBox(),
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.8, left: 16,right: 0),
                        child: 
                        Text( 
                          widget.albumName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: 
                              AppTheme.subheading.copyWith(letterSpacing: -0.3),)
                        
                       
                      ),
                    ),
                  ],
                )),
            // :
            // SizedBox(
            //   height: 40,
            //   child: ListView.builder(
            //       itemBuilder: (context, index) {
            //         return StreamBuilder<TaskSnapshot>(
            //           builder: (context, snapShot) {
            //             // dynamic bytes = snapShot.data!.bytesTransferred;
            //             if (!snapShot.hasData) {
            //               return SizedBox();
            //             } else {
            //               // inProgress.value =
            //               //     snapShot.data!.bytesTransferred;
            //               return snapShot.hasError
            //                   ? SizedBox()
            //                   : snapShot.hasData
            //                       ? index == 0
            //                           ? ListTile(
            //                               title: Text(
            //                               "${snapShot.data!.bytesTransferred}/${snapShot.data!.totalBytes}",
            //                             )
            //                                )
            //                           : SizedBox()
            //                       : Container();
            //             }
            //           },
            //           stream: uploadedTasks![index].snapshotEvents,
            //         );
            //       },
            //       // separatorBuilder: (context, index) => const Divider(),
            //       itemCount: uploadedTasks!.length,
            //     ),
            // ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: 
                 _firebaseFirestore
                    .collection('societies').doc(Constants.societyId).collection('gallery').where('albumId',isEqualTo: widget.albumId)
                    // .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.waveDots(
                                        color: AppTheme.lightText, size: 40),
                    );
          
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: Center(child: Text(" Error : No images available.")),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data!.docs.isNotEmpty) {

                      // totalImageCount = snapshot.data!.docs.length;
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 24, right: 24, top: 6),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24))),
                        child: GridView.builder(
                          shrinkWrap: true,

                          // children: [],
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                            return _buildImageTile(
                                imageUrl, documentId, context);
                          },
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: !_isLoading ? const Center(child: Text("No images available.")) : Center(
              child: LoadingAnimationWidget.waveDots(
                  color: AppTheme.lightText, size: 40),
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

  Widget _buildImageTile(
      String imageUrl, String documentId, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(imageUrl, documentId, context);
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const skeleton(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  void _showFullScreenImage(
      String imageUrl, String documentId, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          // appBar: AppBar(

          //   actions: [
          //     IconButton(
          //       icon: Icon(Icons.share),
          //       onPressed: () {
          //         _shareImage(imageUrl);
          //       },
          //     ),
          //     IconButton(
          //       icon: Icon(Icons.delete),
          //       onPressed: () {
          //         _deleteImage(imageUrl, documentId);
          //         Navigator.of(context)
          //             .pop(); // Close the full-screen image view after deletion
          //       },
          //     ),
          //   ],
          // ),

          body: SafeArea(
            child: Stack(
              children: [
                _buildImageGallery(imageUrl),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomBackButton(
                          color: Colors.black12,
                          iconColor: Colors.white,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           
                            Constants.type == 'admin' ? Padding(
                              padding: const EdgeInsets.only(top: 16.8),
                              child: GestureDetector(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    boxShadow: const [
                                      // BoxShadow(
                                      //   blurRadius: 4,
                                      //   color: Color.fromARGB(8, 23, 23, 23),
                                      //   offset: Offset(0, 2),
                                      // )
                                    ],
                                    borderRadius: BorderRadius.circular(80),
                                    shape: BoxShape.rectangle,
                                    // border: Border.all(
                                    //   color: const Color.fromRGBO(57, 75, 123, 0.9),
                                    //   width: 1.8,
                                    // ),
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
                                  FireStoreMethods().deleteGalleryImage(documentId);
                                  Get.back();
                                },
                              ),
                            ): SizedBox(),
                          ],
                        )
                        
                      ],
                    ))
              ],
            ),
          ),
        ),
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
    
        final file = File( "${documentDirectory.path}${randomNumber.nextInt(100)}_$userName.png",);
    
        file.writeAsBytesSync(response.bodyBytes);
    
        return XFile(file.path);
      }

}
  