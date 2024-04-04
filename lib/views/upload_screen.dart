// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:urbannest/views/gallery_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  List<UploadTask>? uploadedTasks = [];

  List<File> selectedFiles = [];

  uploadFileToStorage(File file) {
    UploadTask task = _firebaseStorage
        .ref()
        .child("images/${DateTime.now().toString()}")
        .putFile(file);
    return task;
  }

  writeImageUrlToFireStore(imageUrl) {
    _firebaseFirestore.collection("images").add({"url": imageUrl}).whenComplete(
        () => print("$imageUrl is saved in Firestore"));
  }

  saveImageUrlToFirebase(UploadTask task) {
    task.snapshotEvents.listen((snapShot) {
      if (snapShot.state == TaskState.success) {
        snapShot.ref
            .getDownloadURL()
            .then((imageUrl) => writeImageUrlToFireStore(imageUrl));
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
        print("User has cancelled the selection");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery App"),
        actions: [
          IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const GalleryScreen()));
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectFileToUpload();
        },
        child: const Icon(Icons.add),
      ),
      body: uploadedTasks!.isEmpty
          ? const Center(child: Text("Please tap on add button to upload images"))
          : ListView.separated(
              itemBuilder: (context, index) {
                return StreamBuilder<TaskSnapshot>(
                  builder: (context, snapShot) {
                    return snapShot.hasError
                        ? const Text("There is some error in uploading file")
                        : snapShot.hasData
                            ? ListTile(
                                title: Text(
                                    "${snapShot.data!.bytesTransferred}/${snapShot.data!.totalBytes} ${snapShot.data!.state == TaskState.success ? "Completed" : snapShot.data!.state == TaskState.running ? "In Progress" : "Error"}"),
                              )
                            : Container();
                  },
                  stream: uploadedTasks![index].snapshotEvents,
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: uploadedTasks!.length,
            ),
    );
  }
}