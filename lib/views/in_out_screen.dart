// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:pdf/pdf.dart';
import 'dart:convert' show base64, utf8;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/storage_method.dart';
import 'package:urbannest/models/entry.dart';
import 'package:urbannest/models/handymen.dart';
import 'package:urbannest/views/gallery_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/user_provider.dart';
import '../models/user.dart' as model;
import 'handymen_screen.dart';
import 'pole_screen.dart';

class InOutScreen extends StatefulWidget {
  @override
  State<InOutScreen> createState() => _InOutScreenState();
}

class _InOutScreenState extends State<InOutScreen>
    with TickerProviderStateMixin {
  TextEditingController name = TextEditingController();

  TextEditingController vehicleNumber = TextEditingController();
  TextEditingController number = TextEditingController();

  TextEditingController count = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  var correctQR = false.obs;
  List<String> services = [];
  var selectedService = ''.obs;
  var checkedValue = false.obs;
  var isLoading = false.obs;
  final _file = Uint8List(0).obs;

  TextEditingController house = TextEditingController();
  TextEditingController block = TextEditingController();
  final List<pw.Widget> dataMaintenance = [];
  bool isPdfGenerated = false;
  pw.Document pdf = pw.Document();
  List<Entry> data = [];
  bool isFirst = true;

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (file != null) {
      return await file.readAsBytes();
    }
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
                    "In & outs",
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
                    CupertinoIcons.doc_text_fill,
                    color: Colors.black87,
                    size: 28,
                  ),
                  2.heightBox,
                  Text("Report",
                      style:
                          AppTheme.smallText.copyWith(color: Colors.black87)),
                ],
              ).onTap(() async {
                if (isFirst) {
                  isFirst = false;
                  final data = await entryData();
                  await generateAndShowPDF(data!);
                  isPdfGenerated = true;
                  isFirst = true;
                } else {
                  Fluttertoast.showToast(msg: "Please wait!");
                }
              }),
            ),
          ],
        ));
  }

  Future<void> generateAndShowPDF(
    List<Entry> entryData,
  ) async {
    // dynamic entryData = FirebaseFirestore.instance
    //     .collection('societies')
    //     .doc(Constants.societyId)
    //     .collection('entries')
    //     .orderBy('createdOn', descending: true)
    //     .snapshots();

    // List<Entry> entryList = [];

    // for (int i = 0; i < entryData.data!.docs.length; i++) {
    //   Entry entry = Entry.fromSnap(entryData.data!.docs[i].data());
    //   entryList.add(entry);
    // }

    final pdf = await generatePdf(entryData);
    Printing.layoutPdf(onLayout: (PdfPageFormat format) {
      return pdf.save();
    });
  }

  Future<pw.Document> generatePdf(List<Entry> entryData) async {
    for (int i = 0; i < entryData.length; i++) {
      String inTime = DateFormat.jmz().format(entryData[i].createdOn);
      String outTime = entryData[i].exitTime == ''
          ? '-'
          : DateFormat.jmz().format(entryData[i].exitTime);
      var now = DateTime.now();
      var formatter = DateFormat('dd/MM');
      String formattedDate = formatter.format(now);

      dataMaintenance.add(
        pw.Row(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 20,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text('${i + 1}',
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 50,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(entryData[i].name.toString(),
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 75,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(entryData[i].number.toString(),
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 60,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child:
                      pw.Text(inTime, style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 60,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(outTime == '' ? '' : outTime,
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 50,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(formattedDate,
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 40,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(entryData[i].count.toString(),
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 50,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(
                      '${entryData[i].house.toString()} / ${entryData[i].block.toString()}',
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            // pw.Padding(
            //   padding: const pw.EdgeInsets.all(5),
            //   child: pw.SizedBox(
            //     width: 50,
            //     child: pw.Padding(
            //       padding: const pw.EdgeInsets.all(0),
            //       child: pw.Text(entryData[i].block.toString(),
            //           style: const pw.TextStyle(fontSize: 12)),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    }

    final pdf = pw.Document();
    List<List<pw.Widget>> docList = [];
    docList.add([]);
    int j = 0;
    int count = 0;
    for (int i = 0; i < entryData.length; i++) {
      count++;
      if (count == 19) {
        count = 0;
        docList.add([]);
        j++;
      }
      docList[j].add(dataMaintenance[i]);
    }

    for (int i = 0; i < docList.length; i++) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 10),
                  pw.Text("Attendance Sheet",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 25),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Society Name: ${Constants.userData.societyName}'),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 15),
                  pw.Row(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 20,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("No",
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 50,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text('Name',
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 75,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text("Number",
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 60,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("InTime",
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 60,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("OutTime",
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 50,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("Date",
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 40,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("People",
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 50,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("House / Block",
                                style: const pw.TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      // pw.Padding(
                      //   padding: const pw.EdgeInsets.all(5),
                      //   child: pw.SizedBox(
                      //     width: 50,
                      //     child: pw.Padding(
                      //       padding: const pw.EdgeInsets.all(0),
                      //       child: pw.Text("Block",
                      //           style: const pw.TextStyle(fontSize: 12)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.SizedBox(height: 15),
                  pw.Column(children: docList[i]),
                  pw.SizedBox(height: 5),
                  pw.Align(
                    alignment: pw.Alignment.bottomRight,
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          //pw.Divider(),
                          pw.Divider(borderStyle: pw.BorderStyle.dashed),
                          //pw.Divider(),
                        ]),
                  ),
                  pw.SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      );
    }
    isPdfGenerated = true;
    return pdf;
  }

  Future<List<Entry>?> entryData() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('societies')
        .doc(Constants.societyId)
        .collection("entries")
        .orderBy("createdOn", descending: true)
        .get();

    final data = querySnapshot.docs.map((doc) {
      //final map = doc.data() as Map<String, dynamic>;
      return Entry.fromSnap(doc);
    }).toList();

    return data;
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          titlePadding:
              const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
          title: const Text(
            'Amenity Image',
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
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file.value = file!;
                    // if (_file.value != null);
                  });
                  // String profile = await StorageMethods()
                  //     .uploadImageToStorage('profile', _file!,
                  //         FirebaseAuth.instance.currentUser!.uid);
                  // FireStoreMethods().editProfile(photoUrl: profile);

                  // print("success");
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
                  Uint8List? file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file.value = file!;
                    // if (_file.value != null) coverUrl = "null";
                  });
                  // String profile = await StorageMethods()
                  //     .uploadImageToStorage('profile', _file!,
                  //         FirebaseAuth.instance.currentUser!.uid);
                  // FireStoreMethods().editProfile(photoUrl: profile);

                  setState(() {});
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: userinfo!.type == "guard"
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  backgroundColor: AppTheme.appColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    selectedService.value = "";
                    checkedValue.value = false;
                    name.text = "";
                    house.text = "";
                    block.text = "";
                    number.text = "";
                    vehicleNumber.text = "";
                    count.text = "";
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => CustomDialog(
                              child: SizedBox(
                                height: 550,
                                width: MediaQuery.of(context).size.width - 120,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('societies')
                                        .doc(Constants.societyId)
                                        .collection('handymen')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox();
                                      } else {
                                        List<String> names = [];
                                        Map<String, List<Handymen>> data = {};
                                        for (int i = 0;
                                            i < snapshot.data!.docs.length;
                                            i++) {
                                          Handymen handyman = Handymen.fromSnap(
                                              snapshot.data!.docs[i]);
                                          if (data.containsKey(handyman.type)) {
                                            List<Handymen> newValue =
                                                data[handyman.type]!;
                                            newValue.add(handyman);
                                            data[handyman.type!] = newValue;
                                          } else {
                                            names.add(handyman.type!);
                                            data[handyman.type!] = [handyman];
                                          }
                                        }

                                        return data.isEmpty
                                            ? const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 24),
                                                child: Center(
                                                    child: Text(
                                                  "No Handymen Available",
                                                  style: AppTheme.smallText,
                                                )),
                                              )
                                            : ListView(
                                                children: List<Widget>.generate(
                                                    names.length, (i) {
                                                  List<Handymen> temp =
                                                      data[names[i]]!;
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 0,
                                                                right: 0,
                                                                bottom: 0,
                                                                top: 0),
                                                        child: Text(
                                                          names[i],
                                                          style: AppTheme
                                                              .subheading,
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      ),
                                                      ListView(
                                                        // physics: const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        children: List<
                                                            Widget>.generate(
                                                          temp.length,
                                                          (int index) {
                                                            return MiniHandyMenTile(
                                                              index: index,
                                                              handyData:
                                                                  temp[index],
                                                              snap: snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .data(),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ));

                    // Respond to button press
                  },
                  child: const Icon(Icons.person_add),
                ),
                8.widthBox,
                FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),

                  // mini: true,
                  backgroundColor: AppTheme.appColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    selectedService.value = "";
                    checkedValue.value = false;
                    name.text = "";
                    house.text = "";
                    block.text = "";
                    number.text = "";
                    vehicleNumber.text = "";
                    count.text = "";
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => CustomDialog(
                              child: SizedBox(
                                // height: 400,
                                width: MediaQuery.of(context).size.width - 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    8.heightBox,
                                    const Text(
                                      'Add Entry',
                                      style: AppTheme.subheading2,
                                      textAlign: TextAlign.center,
                                    ),
                                    12.heightBox,

                                    CustomTextField(
                                        icon: const Icon(Icons.person),
                                        isForm: true,
                                        keyboardType: TextInputType.name,
                                        hint: "Enter Visitor name",
                                        validator: (value) {
                                          return null;
                                        },
                                        textController: name),
                                    12.heightBox,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('societies')
                                                  .doc(Constants.societyId)
                                                  .collection("houses")
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                // if (snapshot.hasData) {
                                                List<String> sugges = [];
                                                if (snapshot.hasData) {
                                                  for (int i = 0;
                                                      i <
                                                          snapshot.data!.docs
                                                              .length;
                                                      i++) {
                                                    sugges.add(snapshot
                                                        .data!.docs[i]
                                                        .data()['houseName']);
                                                  }
                                                }

                                                return TypeAheadField(
                                                  animationStart: 0,
                                                  animationDuration:
                                                      Duration.zero,
                                                  textFieldConfiguration:
                                                      TextFieldConfiguration(
                                                    controller: house,
                                                    autofocus: false,
                                                    expands: false,
                                                    // maxLines: 1,

                                                    enableInteractiveSelection:
                                                        true,
                                                    enabled: true,

                                                    enableSuggestions:
                                                        snapshot.hasData,
                                                    // enabled: societyId!="",
                                                    style: AppTheme.subheading3,
                                                    decoration: InputDecoration(
                                                        hintStyle: AppTheme
                                                            .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                                        hintText: "House",
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 20),
                                                        errorStyle: AppTheme
                                                            .smallText
                                                            .copyWith(
                                                          fontSize: 10,
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Color.fromRGBO(
                                                                105,
                                                                110,
                                                                116,
                                                                1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Color.fromARGB(
                                                                255,
                                                                105,
                                                                110,
                                                                116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        disabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    231,
                                                                    236,
                                                                    243,
                                                                    1),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        // focusColor: MyColors.resolveCompanyCOlour(),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    171,
                                                                    177,
                                                                    186,
                                                                    1),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              BorderSide(
                                                            color: AppTheme
                                                                .appColor,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    231,
                                                                    236,
                                                                    243,
                                                                    1),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        // suffixIcon:  suffix ?? null,

                                                        prefixIcon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 26,
                                                                  right: 16),
                                                          child: IconTheme(
                                                            data: IconThemeData(
                                                                color: AppTheme
                                                                    .appColor
                                                                    .withOpacity(
                                                                        0.8)),
                                                            child: const Icon(
                                                                FontAwesomeIcons
                                                                    .home),
                                                          ),
                                                        )),
                                                  ),
                                                  suggestionsBoxDecoration:
                                                      SuggestionsBoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          elevation: 0,
                                                          color: Colors.white),
                                                  suggestionsCallback:
                                                      (pattern) {
                                                    List<String> matches =
                                                        <String>[];
                                                    matches.addAll(sugges);

                                                    matches.retainWhere((s) {
                                                      return s
                                                          .toLowerCase()
                                                          .contains(pattern
                                                              .toLowerCase());
                                                    });
                                                    return matches;
                                                  },
                                                  minCharsForSuggestions: 1,
                                                  getImmediateSuggestions:
                                                      false,
                                                  hideKeyboardOnDrag: true,
                                                  hideOnEmpty: true,
                                                  hideOnError: true,
                                                  hideSuggestionsOnKeyboardHide:
                                                      false,
                                                  itemBuilder: (context, sone) {
                                                    return Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 8),
                                                      child:
                                                          Text(sone.toString()),
                                                    );
                                                  },
                                                  onSuggestionSelected:
                                                      (suggestion) {
                                                    house.text = suggestion;
                                                  },
                                                );
                                                // } else {
                                                //   return SizedBox();
                                                // }
                                              }),
                                          // }),
                                        ),
                                        12.widthBox,
                                        Expanded(
                                          flex: 1,
                                          child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('societies')
                                                  .doc(Constants.societyId)
                                                  .collection("blocks")
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                List<String> sugges = [];
                                                if (snapshot.hasData) {
                                                  for (int i = 0;
                                                      i <
                                                          snapshot.data!.docs
                                                              .length;
                                                      i++) {
                                                    sugges.add(snapshot
                                                        .data!.docs[i]
                                                        .data()['blockName']);
                                                  }
                                                }
                                                return TypeAheadField(
                                                  animationStart: 0,
                                                  animationDuration:
                                                      Duration.zero,
                                                  textFieldConfiguration:
                                                      TextFieldConfiguration(
                                                    controller: block,
                                                    autofocus: false,
                                                    expands: false,
                                                    enableInteractiveSelection:
                                                        true,
                                                    enabled: true,
                                                    enableSuggestions:
                                                        snapshot.hasData,
                                                    style: AppTheme.subheading3,
                                                    decoration: InputDecoration(
                                                        hintStyle: AppTheme
                                                            .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                                        hintText: "Block",
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 20),
                                                        errorStyle: AppTheme
                                                            .smallText
                                                            .copyWith(
                                                          fontSize: 10,
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Color.fromRGBO(
                                                                105,
                                                                110,
                                                                116,
                                                                1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Color.fromARGB(
                                                                255,
                                                                105,
                                                                110,
                                                                116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        disabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    231,
                                                                    236,
                                                                    243,
                                                                    1),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        // focusColor: MyColors.resolveCompanyCOlour(),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    171,
                                                                    177,
                                                                    186,
                                                                    1),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              BorderSide(
                                                            color: AppTheme
                                                                .appColor,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              const BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    231,
                                                                    236,
                                                                    243,
                                                                    1),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        // suffixIcon:  suffix ?? null,

                                                        prefixIcon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 26,
                                                                  right: 16),
                                                          child: IconTheme(
                                                            data: IconThemeData(
                                                                color: AppTheme
                                                                    .appColor
                                                                    .withOpacity(
                                                                        0.8)),
                                                            child: const Icon(
                                                                FontAwesomeIcons
                                                                    .building),
                                                          ),
                                                        )),
                                                  ),
                                                  suggestionsBoxDecoration:
                                                      SuggestionsBoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          elevation: 0,
                                                          color: Colors.white),
                                                  suggestionsCallback:
                                                      (pattern) {
                                                    List<String> matches =
                                                        <String>[];
                                                    matches.addAll(sugges);

                                                    matches.retainWhere((s) {
                                                      return s
                                                          .toLowerCase()
                                                          .contains(pattern
                                                              .toLowerCase());
                                                    });
                                                    return matches;
                                                  },
                                                  hideKeyboardOnDrag: true,
                                                  minCharsForSuggestions: 1,
                                                  getImmediateSuggestions:
                                                      false,
                                                  hideSuggestionsOnKeyboardHide:
                                                      false,
                                                  hideOnEmpty: true,
                                                  hideOnError: true,
                                                  hideOnLoading: true,
                                                  itemBuilder: (context, sone) {
                                                    return Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 8),
                                                      child:
                                                          Text(sone.toString()),
                                                    );
                                                  },
                                                  onSuggestionSelected:
                                                      (suggestion) {
                                                    block.text = suggestion;
                                                  },
                                                );
                                              }),
                                          // }),
                                        ),
                                      ],
                                    ),
                                    12.heightBox,
                                    CustomTextField(
                                        isForm: true,
                                        icon: const Icon(Icons.phone),
                                        keyboardType: TextInputType.number,
                                        hint: "Enter Phone number",
                                        validator: (value) {
                                          return null;
                                        },
                                        textController: number),
                                    12.heightBox,
                                    // CustomTextField(
                                    //     isForm: true,
                                    //     icon:
                                    //         const Icon(Icons.time_to_leave_rounded),
                                    //     keyboardType: TextInputType.text,
                                    //     hint: "Enter Vehicle number",
                                    //     validator: (value) {
                                    //       return null;
                                    //     },
                                    //     textController: vehicleNumber),
                                    // 12.heightBox,

                                    // 12.heightBox,
                                    // Obx(() {
                                    //   return Theme(
                                    //     data: ThemeData(
                                    //         splashColor: Colors.transparent,
                                    //         highlightColor: Colors.transparent),
                                    //     child: SizedBox(
                                    //       width: 180,
                                    //       child: Center(
                                    //         child: CheckboxListTile(
                                    //           dense: true,

                                    //           title: const Text(
                                    //             "is Inhouse?",
                                    //             style: AppTheme.smallText,
                                    //           ),
                                    //           value: checkedValue.value,
                                    //           hoverColor: Colors.transparent,
                                    //           splashRadius: 0,
                                    //           overlayColor:
                                    //               const MaterialStatePropertyAll(
                                    //                   Colors.white),

                                    //           onChanged: (newValue) {
                                    //             checkedValue.value = newValue!;
                                    //             setState(() {});
                                    //           },
                                    //           activeColor: AppTheme.appColor,
                                    //           controlAffinity: ListTileControlAffinity
                                    //               .leading, //  <-- leading Checkbox
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   );
                                    // }),
                                    CustomTextField(
                                        isForm: true,
                                        icon: const Icon(Icons.people),
                                        keyboardType: TextInputType.number,
                                        hint: "Enter Visitor Count",
                                        validator: (value) {
                                          return null;
                                        },
                                        textController: count),
                                    12.heightBox,

                                    12.heightBox,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 58,
                                          width: 188,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            color: AppTheme.buttonColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: Obx(() {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  isLoading.value
                                                      ? LoadingAnimationWidget
                                                          .waveDots(
                                                              color:
                                                                  Colors.white,
                                                              size: 40)
                                                      : const Text(
                                                          'Add Entry',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                ],
                                              );
                                            }),
                                          ),
                                        ).onTap(() async {
                                          if (name.text.length > 2 &&
                                              house.text != "") {
                                            if (!isLoading.value) {
                                              isLoading.value = true;
                                              FireStoreMethods().createEntry(
                                                  name: name.text,
                                                  house: house.text,
                                                  block: block.text,
                                                  phone: number.text,
                                                  vehicleNumber:
                                                      vehicleNumber.text,
                                                  count: count.text);

                                              isLoading.value = false;
                                              name.clear();
                                              number.clear();
                                              serviceController.clear();
                                              Get.back();
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Please fill values correctly');
                                          }
                                        }),
                                        12.widthBox,
                                        CustomButton(
                                          onTap: () {
                                            _showQRScanner(context);
                                          },
                                          height: 58,
                                          width: 58,
                                          text: "",
                                          iconData:
                                              CupertinoIcons.qrcode_viewfinder,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ));

                    // Respond to button press
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : const SizedBox(),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: getMyCourseList(),
            ),
          ),
        ],
      )),
    );
  }

  void _showQRScanner(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiBarcodeScanner(
          validator: (value) {
            DateTime now = DateTime.now();
            String today =
                now.day.toString() + now.month.toString() + now.year.toString();
            String todayPermanent = now.month.toString() + now.year.toString();
            return value.startsWith(today) || value.startsWith(todayPermanent);
          },
          canPop: false,
          onScan: (String value) async {
            if (value.contains('€')) {
              // final plainText = 'bhargav singh barad€1104€Block A€3-5';
              // final key = enc.Key.fromUtf8('my 32 length key................');
              // final iv = enc.IV.fromLength(16);

              // final encrypter = enc.Encrypter(enc.AES(key));

              // final encrypted = encrypter.encrypt(plainText, iv: iv);
              // final decrypted = encrypter.decrypt((encrypted.base64)., iv: iv);

              // print(
              //     decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
              // print(encrypted.bytes);

              debugPrint(value);
              List<String> tempValue = value.split('€');

              setState(() {
                name.text = tempValue[1];
                house.text = tempValue[2];
                block.text = tempValue[3];
                count.text = tempValue[4];
              });
            }
          },
          onDetect: (p0) {
            Future.delayed(Duration(milliseconds: 100)).then((value) => {
                  if (name.text != '') {Get.back()}
                });
          },
          onDispose: () {
            debugPrint("Barcode scanner disposed!");
          },
          controller: MobileScannerController(
            autoStart: true,
            detectionSpeed: DetectionSpeed.noDuplicates,
          ),
        ),
      ),
    );
  }

  Widget getMyCourseList() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: MyCourseList(),
    );
  }
}

class MiniHandyMenTile extends StatelessWidget {
  const MiniHandyMenTile(
      {Key? key, this.snap, this.index, this.handyData, this.callback})
      : super(key: key);

  final snap;
  final int? index;
  final VoidCallback? callback;
  final Handymen? handyData;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          clipBehavior: Clip.antiAlias,
          // height: 145,
          width: double.infinity,
          decoration: BoxDecoration(
            // border: Border.all(color: AppTheme.lightText,width: 2),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    12.widthBox,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        // border: Border.all(
                        //     color: Colors.white, width: 2),
                        // shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 0),
                              blurRadius: 8,
                              color: AppTheme.appColor.withOpacity(0.1))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: const BoxDecoration(),
                          width: 54,
                          height: 54,
                          child: CachedNetworkImage(
                            imageUrl: handyData!.image ?? "",
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const skeleton(
                              height: 54,
                              width: 54,
                              colors: Colors.white,
                            ),
                            errorWidget: (context, url, error) =>
                                const skeleton(
                              height: 54,
                              width: 54,
                              colors: Colors.white,
                            ),
                          ), //'images/glimpselogo.png'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(handyData!.name!, style: AppTheme.heading2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                handyData!.inHouse!
                    ? Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(
                          "IN-HOUSE",
                          style: AppTheme.smallText
                              .copyWith(color: Colors.green[400]),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ).onTap(() {
          FireStoreMethods().createEntry(
              name: handyData!.name,
              house: '-',
              block: '-',
              phone: handyData!.number,
              vehicleNumber: '',
              count: handyData!.type);

          Get.back();
        }));
  }
}

class MyCourseList extends StatefulWidget {
  const MyCourseList({super.key});

  @override
  _MyCourseListState createState() => _MyCourseListState();
}

class _MyCourseListState extends State<MyCourseList>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('entries')
            .orderBy('createdOn', descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            List<String> names = [];

            Map<String, List<Entry>> data = {};

            Map<String, int> count = {};
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              Entry entry = Entry.fromSnap(snapshot.data!.docs[i]);
              String date = DateFormat.MMMMd().format(entry.createdOn);
              if (data.containsKey(date)) {
                List<Entry> newValue = data[date]!;
                newValue.add(entry);
                if (entry.exitTime == "") {
                  int newvalue = count[date]!;
                  count[date] = newvalue + 1;
                }
                data[date] = newValue;
              } else {
                names.add(date);
                if (entry.exitTime == "") {
                  count[date] = 1;
                } else {
                  count[date] = 0;
                }
                data[date] = [entry];
              }
            }

            return data.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Center(
                        child: Text(
                      "No Entries Available",
                      style: AppTheme.smallText,
                    )),
                  )
                : ListView(
                    children: List<Widget>.generate(names.length, (i) {
                      List<Entry> temp = data[names[i]]!;
                      int incount = count[names[i]]!;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 24, right: 24, bottom: 8, top: 16),
                            child: Text(
                              "${names[i]} (${incount})",
                              style: AppTheme.subheading,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: List<Widget>.generate(
                              temp.length,
                              (int index) {
                                const int count = 15;
                                final Animation<double> animation =
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: animationController!,
                                    curve: Interval((1 / count) * index, 1.0,
                                        curve: Curves.fastOutSlowIn),
                                  ),
                                );
                                animationController?.forward();
                                return Slidable(
                                  closeOnScroll: true,
                                  enabled:
                                      Constants.type == "guard" ? true : false,
                                  endActionPane: ActionPane(
                                    extentRatio: temp[index].exitTime == ""
                                        ? 0.35
                                        : 0.24,
                                    motion: const StretchMotion(),
                                    children: temp[index].exitTime == ""
                                        ? [
                                            SlidableAction(
                                              flex: 2,
                                              onPressed: (context) async {
                                                var number = snapshot
                                                    .data!.docs[index]
                                                    .data()['number'];
                                                Uri phoneno = Uri.parse(
                                                    'tel:+91 $number');
                                                if (await launchUrl(phoneno)) {
                                                  //dialer opened
                                                } else {
                                                  //dailer is not opened
                                                }
                                              },
                                              icon: Icons.call_rounded,
                                              autoClose: true,
                                              label: "Call",
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              backgroundColor:
                                                  AppTheme.lightBackgroundColor,
                                            ),
                                            SlidableAction(
                                              flex: 2,
                                              onPressed: (context) {
                                                FireStoreMethods()
                                                    .outEntry(temp[index].id!);
                                              },
                                              icon: Icons.exit_to_app_rounded,
                                              autoClose: true,
                                              label: "Out",
                                              padding: const EdgeInsets.all(0),
                                              backgroundColor:
                                                  AppTheme.lightBackgroundColor,
                                            ),
                                          ]
                                        : [
                                            SlidableAction(
                                              flex: 2,
                                              onPressed: (context) async {
                                                var number = snapshot
                                                    .data!.docs[index]
                                                    .data()['number'];
                                                Uri phoneno = Uri.parse(
                                                    'tel:+91 $number');
                                                if (await launchUrl(phoneno)) {
                                                  //dialer opened
                                                } else {
                                                  //dailer is not opened
                                                }
                                              },
                                              icon: Icons.call_rounded,
                                              autoClose: true,
                                              label: "Call",
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              backgroundColor:
                                                  AppTheme.lightBackgroundColor,
                                            ),
                                          ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: CategoryView(
                                      index: index,
                                      entryData: temp[index],
                                      snap: snapshot.data!.docs[index].data(),
                                      animation: animation,
                                      animationController: animationController,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  );
          }
        },
      ),
    );
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView(
      {this.snap,
      this.index,
      this.entryData,
      this.animationController,
      this.animation,
      this.callback});

  final snap;
  final int? index;
  final VoidCallback? callback;
  final Entry? entryData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  // height: 145,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// name

                          RichText(
                            text: TextSpan(
                              style: AppTheme.subheading2,
                              text: entryData!.name!,
                              children: [
                                WidgetSpan(
                                    child: entryData!.exitTime == ""
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 3, left: 8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.green[400],
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 8),
                                                child: Text(
                                                  'IN',
                                                  style: AppTheme.smallText
                                                      .copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox()),
                              ],
                            ),
                          ),

                          Text(
                            '${entryData!.house!}, ${entryData!.block!}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.smallText,
                          ),
                          8.heightBox,

                          /// number
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_rounded,
                                          color: AppTheme.lightText,
                                          size: 20,
                                        ),
                                        8.widthBox,
                                        Text(
                                          DateFormat.jmz()
                                              .format(entryData!.createdOn),
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.heading2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 12.widthBox,
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.timer_off_rounded,
                                          color: AppTheme.lightText,
                                          size: 20,
                                        ),
                                        8.widthBox,
                                        Text(
                                          entryData!.exitTime == ""
                                              ? "- "
                                              : DateFormat.jmz()
                                                  .format(entryData!.exitTime),
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.heading2,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          color: AppTheme.lightText,
                                          size: 20,
                                        ),
                                        8.widthBox,
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.4,
                                          child: Text(
                                            entryData!.number!,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTheme.heading3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 12.widthBox,
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          color: AppTheme.lightText,
                                          size: 20,
                                        ),
                                        8.widthBox,
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.4,
                                          child: Text(
                                            entryData!.count!,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTheme.heading3,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),

                          // Row(
                          //   children: [
                          //     const Icon(
                          //       Icons.call_rounded,
                          //       size: 20,
                          //     ),
                          //     8.widthBox,
                          //     Text(
                          //       entryData!.!,
                          //       overflow: TextOverflow.ellipsis,
                          //       style: AppTheme.heading2,
                          //     ),
                          //   ],
                          // ),
                          16.heightBox,

                          /// address
                          // Row(
                          //   crossAxisAlignment:
                          //       CrossAxisAlignment.start,
                          //   children: [
                          //     const Icon(Icons.home_outlined, size: 16),
                          //     const SizedBox(width: 8),
                          //     SizedBox(
                          //       width: 250,
                          //       child: Text(
                          //         entryData!.type!,
                          //         style: AppTheme.smallText,
                          //         overflow: TextOverflow.ellipsis,
                          //         maxLines: 2,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        );
      },
    );
  }
}

// // ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

// import 'dart:convert';
// import 'dart:io';

// import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:pdf/pdf.dart';
// import 'dart:convert' show base64, utf8;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:printing/printing.dart';
// import 'package:provider/provider.dart';
// import 'package:urbannest/app_theme.dart';
// import 'package:urbannest/core/constants.dart';
// import 'package:urbannest/core/firestore_methods.dart';
// import 'package:urbannest/core/storage_method.dart';
// import 'package:urbannest/models/entry.dart';
// import 'package:urbannest/models/handymen.dart';
// import 'package:urbannest/views/gallery_screen.dart';
// import 'package:urbannest/widgets/back_button.dart';
// import 'package:urbannest/widgets/button.dart';
// import 'package:urbannest/widgets/dialog.dart';
// import 'package:urbannest/widgets/text_fields.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:uuid/uuid.dart';
// import 'package:velocity_x/velocity_x.dart';

// import '../core/user_provider.dart';
// import '../models/user.dart' as model;
// import 'handymen_screen.dart';
// import 'pole_screen.dart';

// class InOutScreen extends StatefulWidget {
//   @override
//   State<InOutScreen> createState() => _InOutScreenState();
// }

// class _InOutScreenState extends State<InOutScreen>
//     with TickerProviderStateMixin {
//   TextEditingController name = TextEditingController();

//   TextEditingController vehicleNumber = TextEditingController();
//   TextEditingController number = TextEditingController();

//   TextEditingController count = TextEditingController();
//   TextEditingController serviceController = TextEditingController();
//   var correctQR = false.obs;
//   List<String> services = [];
//   var selectedService = ''.obs;
//   var checkedValue = false.obs;
//   var isLoading = false.obs;
//   final _file = Uint8List(0).obs;

//   TextEditingController house = TextEditingController();
//   TextEditingController block = TextEditingController();
//   final List<pw.Widget> dataMaintenance = [];
//   bool isPdfGenerated = false;
//   pw.Document pdf = pw.Document();
//   List<Entry> data = [];
//   bool isFirst = true;

//   pickImage(ImageSource source) async {
//     final ImagePicker imagePicker = ImagePicker();
//     XFile? file = await imagePicker.pickImage(
//         source: source, preferredCameraDevice: CameraDevice.rear);
//     if (file != null) {
//       return await file.readAsBytes();
//     }
//   }

//   Padding _buildAppBar() {
//     return Padding(
//         padding: const EdgeInsets.only(top: 0, bottom: 16, left: 24, right: 24),
//         child: Row(
//           // mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const CustomBackButton(),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.8, left: 16),
//                   child: Text(
//                     "In & outs",
//                     style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 16.8, right: 16),
//               child: Column(
//                 children: [
//                   const Icon(
//                     CupertinoIcons.doc_text_fill,
//                     color: Colors.black87,
//                     size: 28,
//                   ),
//                   2.heightBox,
//                   Text("Report",
//                       style:
//                           AppTheme.smallText.copyWith(color: Colors.black87)),
//                 ],
//               ).onTap(() async {
//                 if (isFirst) {
//                   isFirst = false;
//                   final data = await entryData();
//                   await generateAndShowPDF(data!);
//                   isPdfGenerated = true;
//                   isFirst = true;
//                 } else {
//                   Fluttertoast.showToast(msg: "Please wait!");
//                 }
//               }),
//             ),
//           ],
//         ));
//   }

//   Future<void> generateAndShowPDF(
//     List<Entry> entryData,
//   ) async {
//     // dynamic entryData = FirebaseFirestore.instance
//     //     .collection('societies')
//     //     .doc(Constants.societyId)
//     //     .collection('entries')
//     //     .orderBy('createdOn', descending: true)
//     //     .snapshots();

//     // List<Entry> entryList = [];

//     // for (int i = 0; i < entryData.data!.docs.length; i++) {
//     //   Entry entry = Entry.fromSnap(entryData.data!.docs[i].data());
//     //   entryList.add(entry);
//     // }

//     final pdf = await generatePdf(entryData);
//     Printing.layoutPdf(onLayout: (PdfPageFormat format) {
//       return pdf.save();
//     });
//   }

//   Future<pw.Document> generatePdf(List<Entry> entryData) async {
//     for (int i = 0; i < entryData.length; i++) {
//       String inTime = DateFormat.jmz().format(entryData[i].createdOn);
//       // var now = DateTime.now();
//       // var formatter = DateFormat('dd-MM-yyyy');
//       // String formattedDate = formatter.format(now);
//       String outTime = entryData[i].exitTime == ''
//           ? '-'
//           : DateFormat.jmz().format(entryData[i].exitTime);

//       dataMaintenance.add(
//         pw.Row(
//           children: [
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 15,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child: pw.Text('${i + 1}',
//                       style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 50,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child: pw.Text(entryData[i].name.toString(),
//                       style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 70,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child: pw.Text(entryData[i].number.toString(),
//                       style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 50,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child:
//                       pw.Text(inTime, style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 50,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child: pw.Text(outTime == '' ? '' : outTime,
//                       style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//             // pw.Padding(
//             //   padding: const pw.EdgeInsets.all(5),
//             //   child: pw.SizedBox(
//             //     width: 80,
//             //     child: pw.Padding(
//             //       padding: const pw.EdgeInsets.all(0),
//             //       child: pw.Text(formattedDate,
//             //           style: const pw.TextStyle(fontSize: 12)),
//             //     ),
//             //   ),
//             // ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 40,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child: pw.Text(entryData[i].count.toString(),
//                       style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 35,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child: pw.Text(entryData[i].house.toString(),
//                       style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//             pw.Padding(
//               padding: const pw.EdgeInsets.all(5),
//               child: pw.SizedBox(
//                 width: 30,
//                 child: pw.Padding(
//                   padding: const pw.EdgeInsets.all(0),
//                   child: pw.Text(entryData[i].block.toString(),
//                       style: const pw.TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     final pdf = pw.Document();
//     List<List<pw.Widget>> docList = [];
//     docList.add([]);
//     int j = 0;
//     int count = 0;
//     for (int i = 0; i < entryData.length; i++) {
//       count++;
//       if (count == 19) {
//         count = 0;
//         docList.add([]);
//         j++;
//       }
//       docList[j].add(dataMaintenance[i]);
//     }

//     for (int i = 0; i < docList.length; i++) {
//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Center(
//               child: pw.Column(
//                 mainAxisAlignment: pw.MainAxisAlignment.start,
//                 crossAxisAlignment: pw.CrossAxisAlignment.center,
//                 children: [
//                   pw.SizedBox(height: 10),
//                   pw.Text("Attendance Sheet",
//                       style: pw.TextStyle(
//                           fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                   pw.SizedBox(height: 25),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.start,
//                     children: [
//                       pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                               'Society Name: ${Constants.userData.societyName}'),
//                         ],
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(height: 15),
//                   pw.Row(
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 20,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(0),
//                             child: pw.Text("No.",
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 50,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(0),
//                             child: pw.Text('Name',
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 70,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(2),
//                             child: pw.Text("Number",
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 50,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(0),
//                             child: pw.Text("InTime",
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 50,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(0),
//                             child: pw.Text("OutTime",
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                       // pw.Padding(
//                       //   padding: const pw.EdgeInsets.all(5),
//                       //   child: pw.SizedBox(
//                       //     width: 50,
//                       //     child: pw.Padding(
//                       //       padding: const pw.EdgeInsets.all(0),
//                       //       child: pw.Text("Date",
//                       //           style: const pw.TextStyle(fontSize: 12)),
//                       //     ),
//                       //   ),
//                       // ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 40,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(0),
//                             child: pw.Text("People",
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 35,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(0),
//                             child: pw.Text("House",
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(5),
//                         child: pw.SizedBox(
//                           width: 30,
//                           child: pw.Padding(
//                             padding: const pw.EdgeInsets.all(0),
//                             child: pw.Text("Block",
//                                 style: const pw.TextStyle(fontSize: 12)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.Divider(borderStyle: pw.BorderStyle.dashed),
//                   pw.SizedBox(height: 15),
//                   pw.Column(children: docList[i]),
//                   pw.SizedBox(height: 5),
//                   pw.Align(
//                     alignment: pw.Alignment.bottomRight,
//                     child: pw.Column(
//                         mainAxisAlignment: pw.MainAxisAlignment.end,
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           //pw.Divider(),
//                           pw.Divider(borderStyle: pw.BorderStyle.dashed),
//                           //pw.Divider(),
//                         ]),
//                   ),
//                   pw.SizedBox(height: 30),
//                 ],
//               ),
//             );
//           },
//         ),
//       );
//     }
//     isPdfGenerated = true;
//     return pdf;
//   }

//   Future<List<Entry>?> entryData() async {
//     final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('societies')
//         .doc(Constants.societyId)
//         .collection('entries')
//         .get();

//     final data = querySnapshot.docs.map((doc) {
//       //final map = doc.data() as Map<String, dynamic>;
//       return Entry.fromSnap(doc);
//     }).toList();

//     return data;
//   }

//   _selectImage(BuildContext parentContext) async {
//     return showDialog(
//       context: parentContext,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           backgroundColor: Colors.white,
//           titlePadding:
//               const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
//           title: const Text(
//             'Amenity Image',
//             style: AppTheme.subheading,
//           ),
//           children: <Widget>[
//             SimpleDialogOption(
//                 padding: const EdgeInsets.all(8),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0, right: 24),
//                       child: Container(
//                           height: 54,
//                           width: 54,
//                           decoration: BoxDecoration(
//                               color: HexColorNew('#F8FAFB'),
//                               borderRadius: BorderRadius.circular(12)),
//                           child: const Icon(
//                             FontAwesomeIcons.images,
//                             color: AppTheme.lightText,
//                           )),
//                     ),
//                     const Text(
//                       'Choose from Gallery',
//                       style: AppTheme.smallText,
//                     ),
//                   ],
//                 ),
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   Uint8List? file = await pickImage(ImageSource.gallery);
//                   setState(() {
//                     _file.value = file!;
//                     // if (_file.value != null);
//                   });
//                   // String profile = await StorageMethods()
//                   //     .uploadImageToStorage('profile', _file!,
//                   //         FirebaseAuth.instance.currentUser!.uid);
//                   // FireStoreMethods().editProfile(photoUrl: profile);

//                   // print("success");
//                 }),
//             SimpleDialogOption(
//                 padding: const EdgeInsets.all(8),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0, right: 24),
//                       child: Container(
//                           height: 54,
//                           width: 54,
//                           decoration: BoxDecoration(
//                               color: HexColorNew('#F8FAFB'),
//                               borderRadius: BorderRadius.circular(12)),
//                           child: const Icon(
//                             FontAwesomeIcons.camera,
//                             color: AppTheme.lightText,
//                           )),
//                     ),
//                     const Text(
//                       'Take a photo',
//                       style: AppTheme.smallText,
//                     ),
//                   ],
//                 ),
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   Uint8List? file = await pickImage(ImageSource.camera);
//                   setState(() {
//                     _file.value = file!;
//                     // if (_file.value != null) coverUrl = "null";
//                   });
//                   // String profile = await StorageMethods()
//                   //     .uploadImageToStorage('profile', _file!,
//                   //         FirebaseAuth.instance.currentUser!.uid);
//                   // FireStoreMethods().editProfile(photoUrl: profile);

//                   setState(() {});
//                 }),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
//     return Scaffold(
//       backgroundColor: AppTheme.lightBackgroundColor,
//       floatingActionButton: userinfo!.type == "guard"
//           ? Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 FloatingActionButton(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(40)),
//                   backgroundColor: AppTheme.appColor,
//                   foregroundColor: Colors.white,
//                   onPressed: () {
//                     selectedService.value = "";
//                     checkedValue.value = false;
//                     name.text = "";
//                     house.text = "";
//                     block.text = "";
//                     number.text = "";
//                     vehicleNumber.text = "";
//                     count.text = "";
//                     showDialog(
//                         barrierDismissible: false,
//                         context: context,
//                         builder: (context) => CustomDialog(
//                               child: SizedBox(
//                                 height: 550,
//                                 width: MediaQuery.of(context).size.width - 120,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(top: 8),
//                                   child: StreamBuilder(
//                                     stream: FirebaseFirestore.instance
//                                         .collection('societies')
//                                         .doc(Constants.societyId)
//                                         .collection('handymen')
//                                         .snapshots(),
//                                     builder: (BuildContext context,
//                                         AsyncSnapshot<
//                                                 QuerySnapshot<
//                                                     Map<String, dynamic>>>
//                                             snapshot) {
//                                       if (!snapshot.hasData) {
//                                         return const SizedBox();
//                                       } else {
//                                         List<String> names = [];
//                                         Map<String, List<Handymen>> data = {};
//                                         for (int i = 0;
//                                             i < snapshot.data!.docs.length;
//                                             i++) {
//                                           Handymen handyman = Handymen.fromSnap(
//                                               snapshot.data!.docs[i]);
//                                           if (data.containsKey(handyman.type)) {
//                                             List<Handymen> newValue =
//                                                 data[handyman.type]!;
//                                             newValue.add(handyman);
//                                             data[handyman.type!] = newValue;
//                                           } else {
//                                             names.add(handyman.type!);
//                                             data[handyman.type!] = [handyman];
//                                           }
//                                         }

//                                         return data.isEmpty
//                                             ? const Padding(
//                                                 padding:
//                                                     EdgeInsets.only(left: 24),
//                                                 child: Center(
//                                                     child: Text(
//                                                   "No Handymen Available",
//                                                   style: AppTheme.smallText,
//                                                 )),
//                                               )
//                                             : ListView(
//                                                 children: List<Widget>.generate(
//                                                     names.length, (i) {
//                                                   List<Handymen> temp =
//                                                       data[names[i]]!;
//                                                   return Column(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(
//                                                                 left: 0,
//                                                                 right: 0,
//                                                                 bottom: 0,
//                                                                 top: 0),
//                                                         child: Text(
//                                                           names[i],
//                                                           style: AppTheme
//                                                               .subheading,
//                                                           textAlign:
//                                                               TextAlign.start,
//                                                         ),
//                                                       ),
//                                                       ListView(
//                                                         // physics: const NeverScrollableScrollPhysics(),
//                                                         shrinkWrap: true,
//                                                         children: List<
//                                                             Widget>.generate(
//                                                           temp.length,
//                                                           (int index) {
//                                                             return MiniHandyMenTile(
//                                                               index: index,
//                                                               handyData:
//                                                                   temp[index],
//                                                               snap: snapshot
//                                                                   .data!
//                                                                   .docs[index]
//                                                                   .data(),
//                                                             );
//                                                           },
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   );
//                                                 }),
//                                               );
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ));

//                     // Respond to button press
//                   },
//                   child: const Icon(Icons.person_add),
//                 ),
//                 8.widthBox,
//                 FloatingActionButton(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(40)),

//                   // mini: true,
//                   backgroundColor: AppTheme.appColor,
//                   foregroundColor: Colors.white,
//                   onPressed: () {
//                     selectedService.value = "";
//                     checkedValue.value = false;
//                     name.text = "";
//                     house.text = "";
//                     block.text = "";
//                     number.text = "";
//                     vehicleNumber.text = "";
//                     count.text = "";
//                     showDialog(
//                         barrierDismissible: false,
//                         context: context,
//                         builder: (context) => CustomDialog(
//                               child: SizedBox(
//                                 // height: 400,
//                                 width: MediaQuery.of(context).size.width - 120,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     8.heightBox,
//                                     const Text(
//                                       'Add Entry',
//                                       style: AppTheme.subheading2,
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     12.heightBox,

//                                     CustomTextField(
//                                         icon: const Icon(Icons.person),
//                                         isForm: true,
//                                         keyboardType: TextInputType.name,
//                                         hint: "Enter Visitor name",
//                                         validator: (value) {
//                                           return null;
//                                         },
//                                         textController: name),
//                                     12.heightBox,
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Expanded(
//                                           flex: 1,
//                                           child: StreamBuilder(
//                                               stream: FirebaseFirestore.instance
//                                                   .collection('societies')
//                                                   .doc(Constants.societyId)
//                                                   .collection("houses")
//                                                   .snapshots(),
//                                               builder: (BuildContext context,
//                                                   AsyncSnapshot<
//                                                           QuerySnapshot<
//                                                               Map<String,
//                                                                   dynamic>>>
//                                                       snapshot) {
//                                                 // if (snapshot.hasData) {
//                                                 List<String> sugges = [];
//                                                 if (snapshot.hasData) {
//                                                   for (int i = 0;
//                                                       i <
//                                                           snapshot.data!.docs
//                                                               .length;
//                                                       i++) {
//                                                     sugges.add(snapshot
//                                                         .data!.docs[i]
//                                                         .data()['houseName']);
//                                                   }
//                                                 }

//                                                 return TypeAheadField(
//                                                   animationStart: 0,
//                                                   animationDuration:
//                                                       Duration.zero,
//                                                   textFieldConfiguration:
//                                                       TextFieldConfiguration(
//                                                     controller: house,
//                                                     autofocus: false,
//                                                     expands: false,
//                                                     // maxLines: 1,

//                                                     enableInteractiveSelection:
//                                                         true,
//                                                     enabled: true,

//                                                     enableSuggestions:
//                                                         snapshot.hasData,
//                                                     // enabled: societyId!="",
//                                                     style: AppTheme.subheading3,
//                                                     decoration: InputDecoration(
//                                                         hintStyle: AppTheme
//                                                             .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
//                                                         hintText: "House",
//                                                         contentPadding:
//                                                             const EdgeInsets
//                                                                 .symmetric(
//                                                                 horizontal: 12,
//                                                                 vertical: 20),
//                                                         errorStyle: AppTheme
//                                                             .smallText
//                                                             .copyWith(
//                                                           fontSize: 10,
//                                                         ),
//                                                         errorBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color: Color.fromRGBO(
//                                                                 105,
//                                                                 110,
//                                                                 116,
//                                                                 1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         focusedErrorBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color: Color.fromARGB(
//                                                                 255,
//                                                                 105,
//                                                                 110,
//                                                                 116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         disabledBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     231,
//                                                                     236,
//                                                                     243,
//                                                                     1),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         // focusColor: MyColors.resolveCompanyCOlour(),
//                                                         enabledBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     171,
//                                                                     177,
//                                                                     186,
//                                                                     1),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         focusedBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               BorderSide(
//                                                             color: AppTheme
//                                                                 .appColor,
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         border:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     231,
//                                                                     236,
//                                                                     243,
//                                                                     1),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         // suffixIcon:  suffix ?? null,

//                                                         prefixIcon: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   left: 26,
//                                                                   right: 16),
//                                                           child: IconTheme(
//                                                             data: IconThemeData(
//                                                                 color: AppTheme
//                                                                     .appColor
//                                                                     .withOpacity(
//                                                                         0.8)),
//                                                             child: const Icon(
//                                                                 FontAwesomeIcons
//                                                                     .home),
//                                                           ),
//                                                         )),
//                                                   ),
//                                                   suggestionsBoxDecoration:
//                                                       SuggestionsBoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(12),
//                                                           elevation: 0,
//                                                           color: Colors.white),
//                                                   suggestionsCallback:
//                                                       (pattern) {
//                                                     List<String> matches =
//                                                         <String>[];
//                                                     matches.addAll(sugges);

//                                                     matches.retainWhere((s) {
//                                                       return s
//                                                           .toLowerCase()
//                                                           .contains(pattern
//                                                               .toLowerCase());
//                                                     });
//                                                     return matches;
//                                                   },
//                                                   minCharsForSuggestions: 1,
//                                                   getImmediateSuggestions:
//                                                       false,
//                                                   hideKeyboardOnDrag: true,
//                                                   hideOnEmpty: true,
//                                                   hideOnError: true,
//                                                   hideSuggestionsOnKeyboardHide:
//                                                       false,
//                                                   itemBuilder: (context, sone) {
//                                                     return Container(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           horizontal: 20,
//                                                           vertical: 8),
//                                                       child:
//                                                           Text(sone.toString()),
//                                                     );
//                                                   },
//                                                   onSuggestionSelected:
//                                                       (suggestion) {
//                                                     house.text = suggestion;
//                                                   },
//                                                 );
//                                                 // } else {
//                                                 //   return SizedBox();
//                                                 // }
//                                               }),
//                                           // }),
//                                         ),
//                                         12.widthBox,
//                                         Expanded(
//                                           flex: 1,
//                                           child: StreamBuilder(
//                                               stream: FirebaseFirestore.instance
//                                                   .collection('societies')
//                                                   .doc(Constants.societyId)
//                                                   .collection("blocks")
//                                                   .snapshots(),
//                                               builder: (BuildContext context,
//                                                   AsyncSnapshot<
//                                                           QuerySnapshot<
//                                                               Map<String,
//                                                                   dynamic>>>
//                                                       snapshot) {
//                                                 List<String> sugges = [];
//                                                 if (snapshot.hasData) {
//                                                   for (int i = 0;
//                                                       i <
//                                                           snapshot.data!.docs
//                                                               .length;
//                                                       i++) {
//                                                     sugges.add(snapshot
//                                                         .data!.docs[i]
//                                                         .data()['blockName']);
//                                                   }
//                                                 }
//                                                 return TypeAheadField(
//                                                   animationStart: 0,
//                                                   animationDuration:
//                                                       Duration.zero,
//                                                   textFieldConfiguration:
//                                                       TextFieldConfiguration(
//                                                     controller: block,
//                                                     autofocus: false,
//                                                     expands: false,
//                                                     enableInteractiveSelection:
//                                                         true,
//                                                     enabled: true,
//                                                     enableSuggestions:
//                                                         snapshot.hasData,
//                                                     style: AppTheme.subheading3,
//                                                     decoration: InputDecoration(
//                                                         hintStyle: AppTheme
//                                                             .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
//                                                         hintText: "Block",
//                                                         contentPadding:
//                                                             const EdgeInsets
//                                                                 .symmetric(
//                                                                 horizontal: 12,
//                                                                 vertical: 20),
//                                                         errorStyle: AppTheme
//                                                             .smallText
//                                                             .copyWith(
//                                                           fontSize: 10,
//                                                         ),
//                                                         errorBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color: Color.fromRGBO(
//                                                                 105,
//                                                                 110,
//                                                                 116,
//                                                                 1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         focusedErrorBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color: Color.fromARGB(
//                                                                 255,
//                                                                 105,
//                                                                 110,
//                                                                 116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         disabledBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     231,
//                                                                     236,
//                                                                     243,
//                                                                     1),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         // focusColor: MyColors.resolveCompanyCOlour(),
//                                                         enabledBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     171,
//                                                                     177,
//                                                                     186,
//                                                                     1),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         focusedBorder:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               BorderSide(
//                                                             color: AppTheme
//                                                                 .appColor,
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         border:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(16),
//                                                           borderSide:
//                                                               const BorderSide(
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     231,
//                                                                     236,
//                                                                     243,
//                                                                     1),
//                                                             width: 2,
//                                                           ),
//                                                         ),
//                                                         // suffixIcon:  suffix ?? null,

//                                                         prefixIcon: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   left: 26,
//                                                                   right: 16),
//                                                           child: IconTheme(
//                                                             data: IconThemeData(
//                                                                 color: AppTheme
//                                                                     .appColor
//                                                                     .withOpacity(
//                                                                         0.8)),
//                                                             child: const Icon(
//                                                                 FontAwesomeIcons
//                                                                     .building),
//                                                           ),
//                                                         )),
//                                                   ),
//                                                   suggestionsBoxDecoration:
//                                                       SuggestionsBoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(12),
//                                                           elevation: 0,
//                                                           color: Colors.white),
//                                                   suggestionsCallback:
//                                                       (pattern) {
//                                                     List<String> matches =
//                                                         <String>[];
//                                                     matches.addAll(sugges);

//                                                     matches.retainWhere((s) {
//                                                       return s
//                                                           .toLowerCase()
//                                                           .contains(pattern
//                                                               .toLowerCase());
//                                                     });
//                                                     return matches;
//                                                   },
//                                                   hideKeyboardOnDrag: true,
//                                                   minCharsForSuggestions: 1,
//                                                   getImmediateSuggestions:
//                                                       false,
//                                                   hideSuggestionsOnKeyboardHide:
//                                                       false,
//                                                   hideOnEmpty: true,
//                                                   hideOnError: true,
//                                                   hideOnLoading: true,
//                                                   itemBuilder: (context, sone) {
//                                                     return Container(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           horizontal: 20,
//                                                           vertical: 8),
//                                                       child:
//                                                           Text(sone.toString()),
//                                                     );
//                                                   },
//                                                   onSuggestionSelected:
//                                                       (suggestion) {
//                                                     block.text = suggestion;
//                                                   },
//                                                 );
//                                               }),
//                                           // }),
//                                         ),
//                                       ],
//                                     ),
//                                     12.heightBox,
//                                     CustomTextField(
//                                         isForm: true,
//                                         icon: const Icon(Icons.phone),
//                                         keyboardType: TextInputType.number,
//                                         hint: "Enter Phone number",
//                                         validator: (value) {
//                                           return null;
//                                         },
//                                         textController: number),
//                                     12.heightBox,
//                                     // CustomTextField(
//                                     //     isForm: true,
//                                     //     icon:
//                                     //         const Icon(Icons.time_to_leave_rounded),
//                                     //     keyboardType: TextInputType.text,
//                                     //     hint: "Enter Vehicle number",
//                                     //     validator: (value) {
//                                     //       return null;
//                                     //     },
//                                     //     textController: vehicleNumber),
//                                     // 12.heightBox,

//                                     // 12.heightBox,
//                                     // Obx(() {
//                                     //   return Theme(
//                                     //     data: ThemeData(
//                                     //         splashColor: Colors.transparent,
//                                     //         highlightColor: Colors.transparent),
//                                     //     child: SizedBox(
//                                     //       width: 180,
//                                     //       child: Center(
//                                     //         child: CheckboxListTile(
//                                     //           dense: true,

//                                     //           title: const Text(
//                                     //             "is Inhouse?",
//                                     //             style: AppTheme.smallText,
//                                     //           ),
//                                     //           value: checkedValue.value,
//                                     //           hoverColor: Colors.transparent,
//                                     //           splashRadius: 0,
//                                     //           overlayColor:
//                                     //               const MaterialStatePropertyAll(
//                                     //                   Colors.white),

//                                     //           onChanged: (newValue) {
//                                     //             checkedValue.value = newValue!;
//                                     //             setState(() {});
//                                     //           },
//                                     //           activeColor: AppTheme.appColor,
//                                     //           controlAffinity: ListTileControlAffinity
//                                     //               .leading, //  <-- leading Checkbox
//                                     //         ),
//                                     //       ),
//                                     //     ),
//                                     //   );
//                                     // }),
//                                     CustomTextField(
//                                         isForm: true,
//                                         icon: const Icon(Icons.people),
//                                         keyboardType: TextInputType.number,
//                                         hint: "Enter Visitor Count",
//                                         validator: (value) {
//                                           return null;
//                                         },
//                                         textController: count),
//                                     12.heightBox,

//                                     12.heightBox,
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Container(
//                                           height: 58,
//                                           width: 188,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(40),
//                                             color: AppTheme.buttonColor,
//                                           ),
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(
//                                                 left: 8.0, right: 8.0),
//                                             child: Obx(() {
//                                               return Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   isLoading.value
//                                                       ? LoadingAnimationWidget
//                                                           .waveDots(
//                                                               color:
//                                                                   Colors.white,
//                                                               size: 40)
//                                                       : const Text(
//                                                           'Add Entry',
//                                                           style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize: 18,
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                           ),
//                                                         ),
//                                                 ],
//                                               );
//                                             }),
//                                           ),
//                                         ).onTap(() async {
//                                           if (name.text.length > 2 &&
//                                               house.text != "") {
//                                             if (!isLoading.value) {
//                                               isLoading.value = true;
//                                               FireStoreMethods().createEntry(
//                                                   name: name.text,
//                                                   house: house.text,
//                                                   block: block.text,
//                                                   phone: number.text,
//                                                   vehicleNumber:
//                                                       vehicleNumber.text,
//                                                   count: count.text);

//                                               isLoading.value = false;
//                                               name.clear();
//                                               number.clear();
//                                               serviceController.clear();
//                                               Get.back();
//                                             }
//                                           } else {
//                                             Fluttertoast.showToast(
//                                                 msg:
//                                                     'Please fill values correctly');
//                                           }
//                                         }),
//                                         12.widthBox,
//                                         CustomButton(
//                                           onTap: () {
//                                             _showQRScanner(context);
//                                           },
//                                           height: 58,
//                                           width: 58,
//                                           text: "",
//                                           iconData:
//                                               CupertinoIcons.qrcode_viewfinder,
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ));

//                     // Respond to button press
//                   },
//                   child: const Icon(Icons.add),
//                 ),
//               ],
//             )
//           : const SizedBox(),
//       body: SafeArea(
//           child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildAppBar(),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 24.0),
//               child: getMyCourseList(),
//             ),
//           ),
//         ],
//       )),
//     );
//   }

//   void _showQRScanner(BuildContext context) async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => AiBarcodeScanner(
//           validator: (value) {
//             DateTime now = DateTime.now();
//             String today =
//                 now.day.toString() + now.month.toString() + now.year.toString();
//             String todayPermanent = now.month.toString() + now.year.toString();
//             return value.startsWith(today) || value.startsWith(todayPermanent);
//           },
//           canPop: false,
//           onScan: (String value) async {
//             if (value.contains('€')) {
//               // final plainText = 'bhargav singh barad€1104€Block A€3-5';
//               // final key = enc.Key.fromUtf8('my 32 length key................');
//               // final iv = enc.IV.fromLength(16);

//               // final encrypter = enc.Encrypter(enc.AES(key));

//               // final encrypted = encrypter.encrypt(plainText, iv: iv);
//               // final decrypted = encrypter.decrypt((encrypted.base64)., iv: iv);

//               // print(
//               //     decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
//               // print(encrypted.bytes);

//               debugPrint(value);
//               List<String> tempValue = value.split('€');

//               setState(() {
//                 name.text = tempValue[1];
//                 house.text = tempValue[2];
//                 block.text = tempValue[3];
//                 count.text = tempValue[4];
//               });
//             }
//           },
//           onDetect: (p0) {
//             Future.delayed(Duration(milliseconds: 100)).then((value) => {
//                   if (name.text != '') {Get.back()}
//                 });
//           },
//           onDispose: () {
//             debugPrint("Barcode scanner disposed!");
//           },
//           controller: MobileScannerController(
//             autoStart: true,
//             detectionSpeed: DetectionSpeed.noDuplicates,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget getMyCourseList() {
//     return const Padding(
//       padding: EdgeInsets.only(bottom: 16.0),
//       child: MyCourseList(),
//     );
//   }
// }

// class MiniHandyMenTile extends StatelessWidget {
//   const MiniHandyMenTile(
//       {Key? key, this.snap, this.index, this.handyData, this.callback})
//       : super(key: key);

//   final snap;
//   final int? index;
//   final VoidCallback? callback;
//   final Handymen? handyData;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6.0),
//         child: Container(
//           clipBehavior: Clip.antiAlias,
//           // height: 145,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             // border: Border.all(color: AppTheme.lightText,width: 2),
//             color: Colors.white,
//             borderRadius: BorderRadius.all(Radius.circular(32)),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(6.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     12.widthBox,
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(14),
//                         // border: Border.all(
//                         //     color: Colors.white, width: 2),
//                         // shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                               offset: const Offset(0, 0),
//                               blurRadius: 8,
//                               color: AppTheme.appColor.withOpacity(0.1))
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(14),
//                         child: Container(
//                           clipBehavior: Clip.antiAliasWithSaveLayer,
//                           decoration: const BoxDecoration(),
//                           width: 54,
//                           height: 54,
//                           child: CachedNetworkImage(
//                             imageUrl: handyData!.image ?? "",
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) => const skeleton(
//                               height: 54,
//                               width: 54,
//                               colors: Colors.white,
//                             ),
//                             errorWidget: (context, url, error) =>
//                                 const skeleton(
//                               height: 54,
//                               width: 54,
//                               colors: Colors.white,
//                             ),
//                           ), //'images/glimpselogo.png'),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 0, bottom: 0),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 20, right: 20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(handyData!.name!, style: AppTheme.heading2),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 handyData!.inHouse!
//                     ? Padding(
//                         padding: const EdgeInsets.only(right: 24),
//                         child: Text(
//                           "IN-HOUSE",
//                           style: AppTheme.smallText
//                               .copyWith(color: Colors.green[400]),
//                         ),
//                       )
//                     : const SizedBox(),
//               ],
//             ),
//           ),
//         ).onTap(() {
//           FireStoreMethods().createEntry(
//               name: handyData!.name,
//               house: '-',
//               block: '-',
//               phone: handyData!.number,
//               vehicleNumber: '',
//               count: handyData!.type);

//           Get.back();
//         }));
//   }
// }

// class MyCourseList extends StatefulWidget {
//   const MyCourseList({super.key});

//   @override
//   _MyCourseListState createState() => _MyCourseListState();
// }

// class _MyCourseListState extends State<MyCourseList>
//     with TickerProviderStateMixin {
//   AnimationController? animationController;
//   @override
//   void initState() {
//     animationController = AnimationController(
//         duration: const Duration(milliseconds: 800), vsync: this);
//     super.initState();
//   }

//   Future<bool> getData() async {
//     await Future<dynamic>.delayed(const Duration(milliseconds: 100));
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
//     return Padding(
//       padding: const EdgeInsets.only(top: 8),
//       child: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('societies')
//             .doc(Constants.societyId)
//             .collection('entries')
//             .orderBy('createdOn', descending: true)
//             .snapshots(),
//         builder: (BuildContext context,
//             AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//           if (!snapshot.hasData) {
//             return const SizedBox();
//           } else {
//             List<String> names = [];

//             Map<String, List<Entry>> data = {};

//             Map<String, int> count = {};
//             for (int i = 0; i < snapshot.data!.docs.length; i++) {
//               Entry entry = Entry.fromSnap(snapshot.data!.docs[i]);
//               String date = DateFormat.MMMMd().format(entry.createdOn);
//               if (data.containsKey(date)) {
//                 List<Entry> newValue = data[date]!;
//                 newValue.add(entry);
//                 if (entry.exitTime == "") {
//                   int newvalue = count[date]!;
//                   count[date] = newvalue + 1;
//                 }
//                 data[date] = newValue;
//               } else {
//                 names.add(date);
//                 if (entry.exitTime == "") {
//                   count[date] = 1;
//                 } else {
//                   count[date] = 0;
//                 }
//                 data[date] = [entry];
//               }
//             }

//             return data.isEmpty
//                 ? const Padding(
//                     padding: EdgeInsets.only(left: 24),
//                     child: Center(
//                         child: Text(
//                       "No Entries Available",
//                       style: AppTheme.smallText,
//                     )),
//                   )
//                 : ListView(
//                     children: List<Widget>.generate(names.length, (i) {
//                       List<Entry> temp = data[names[i]]!;
//                       int incount = count[names[i]]!;
//                       return Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 24, right: 24, bottom: 8, top: 16),
//                             child: Text(
//                               "${names[i]} (${incount})",
//                               style: AppTheme.subheading,
//                               textAlign: TextAlign.start,
//                             ),
//                           ),
//                           ListView(
//                             physics: const NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             children: List<Widget>.generate(
//                               temp.length,
//                               (int index) {
//                                 const int count = 15;
//                                 final Animation<double> animation =
//                                     Tween<double>(begin: 0.0, end: 1.0).animate(
//                                   CurvedAnimation(
//                                     parent: animationController!,
//                                     curve: Interval((1 / count) * index, 1.0,
//                                         curve: Curves.fastOutSlowIn),
//                                   ),
//                                 );
//                                 animationController?.forward();
//                                 return Slidable(
//                                   closeOnScroll: true,
//                                   enabled:
//                                       Constants.type == "guard" ? true : false,
//                                   endActionPane: ActionPane(
//                                     extentRatio: temp[index].exitTime == ""
//                                         ? 0.35
//                                         : 0.24,
//                                     motion: const StretchMotion(),
//                                     children: temp[index].exitTime == ""
//                                         ? [
//                                             SlidableAction(
//                                               flex: 2,
//                                               onPressed: (context) async {
//                                                 var number = snapshot
//                                                     .data!.docs[index]
//                                                     .data()['number'];
//                                                 Uri phoneno = Uri.parse(
//                                                     'tel:+91 $number');
//                                                 if (await launchUrl(phoneno)) {
//                                                   //dialer opened
//                                                 } else {
//                                                   //dailer is not opened
//                                                 }
//                                               },
//                                               icon: Icons.call_rounded,
//                                               autoClose: true,
//                                               label: "Call",
//                                               padding: const EdgeInsets.only(
//                                                   left: 8),
//                                               backgroundColor:
//                                                   AppTheme.lightBackgroundColor,
//                                             ),
//                                             SlidableAction(
//                                               flex: 2,
//                                               onPressed: (context) {
//                                                 FireStoreMethods()
//                                                     .outEntry(temp[index].id!);
//                                               },
//                                               icon: Icons.exit_to_app_rounded,
//                                               autoClose: true,
//                                               label: "Out",
//                                               padding: const EdgeInsets.all(0),
//                                               backgroundColor:
//                                                   AppTheme.lightBackgroundColor,
//                                             ),
//                                           ]
//                                         : [
//                                             SlidableAction(
//                                               flex: 2,
//                                               onPressed: (context) async {
//                                                 var number = snapshot
//                                                     .data!.docs[index]
//                                                     .data()['number'];
//                                                 Uri phoneno = Uri.parse(
//                                                     'tel:+91 $number');
//                                                 if (await launchUrl(phoneno)) {
//                                                   //dialer opened
//                                                 } else {
//                                                   //dailer is not opened
//                                                 }
//                                               },
//                                               icon: Icons.call_rounded,
//                                               autoClose: true,
//                                               label: "Call",
//                                               padding: const EdgeInsets.only(
//                                                   left: 8),
//                                               backgroundColor:
//                                                   AppTheme.lightBackgroundColor,
//                                             ),
//                                           ],
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(left: 24.0),
//                                     child: CategoryView(
//                                       index: index,
//                                       entryData: temp[index],
//                                       snap: snapshot.data!.docs[index].data(),
//                                       animation: animation,
//                                       animationController: animationController,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     }),
//                   );
//           }
//         },
//       ),
//     );
//   }
// }

// class CategoryView extends StatelessWidget {
//   const CategoryView(
//       {this.snap,
//       this.index,
//       this.entryData,
//       this.animationController,
//       this.animation,
//       this.callback});

//   final snap;
//   final int? index;
//   final VoidCallback? callback;
//   final Entry? entryData;
//   final AnimationController? animationController;
//   final Animation<double>? animation;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animationController!,
//       builder: (BuildContext context, Widget? child) {
//         return FadeTransition(
//           opacity: animation!,
//           child: Transform(
//             transform: Matrix4.translationValues(
//                 0.0, 50 * (1.0 - animation!.value), 0.0),
//             child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6.0),
//                 child: Container(
//                   clipBehavior: Clip.antiAlias,
//                   // height: 145,
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.all(Radius.circular(32)),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 16, bottom: 0),
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           /// name

//                           RichText(
//                             text: TextSpan(
//                               style: AppTheme.subheading2,
//                               text: entryData!.name!,
//                               children: [
//                                 WidgetSpan(
//                                     child: entryData!.exitTime == ""
//                                         ? Padding(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 3, left: 8),
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                   color: Colors.green[400],
//                                                   borderRadius:
//                                                       BorderRadius.circular(4)),
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 2,
//                                                         horizontal: 8),
//                                                 child: Text(
//                                                   'IN',
//                                                   style: AppTheme.smallText
//                                                       .copyWith(
//                                                     color: Colors.white,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : SizedBox()),
//                               ],
//                             ),
//                           ),

//                           Text(
//                             '${entryData!.house!}, ${entryData!.block!}',
//                             overflow: TextOverflow.ellipsis,
//                             style: AppTheme.smallText,
//                           ),
//                           8.heightBox,

//                           /// number
//                           Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 1,
//                                     child: Row(
//                                       children: [
//                                         const Icon(
//                                           Icons.timer_rounded,
//                                           color: AppTheme.lightText,
//                                           size: 20,
//                                         ),
//                                         8.widthBox,
//                                         Text(
//                                           DateFormat.jmz()
//                                               .format(entryData!.createdOn),
//                                           overflow: TextOverflow.ellipsis,
//                                           style: AppTheme.heading2,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   // 12.widthBox,
//                                   Expanded(
//                                     flex: 1,
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.timer_off_rounded,
//                                           color: AppTheme.lightText,
//                                           size: 20,
//                                         ),
//                                         8.widthBox,
//                                         Text(
//                                           entryData!.exitTime == ""
//                                               ? "- "
//                                               : DateFormat.jmz()
//                                                   .format(entryData!.exitTime),
//                                           overflow: TextOverflow.ellipsis,
//                                           style: AppTheme.heading2,
//                                         )
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 1,
//                                     child: Row(
//                                       children: [
//                                         const Icon(
//                                           Icons.phone,
//                                           color: AppTheme.lightText,
//                                           size: 20,
//                                         ),
//                                         8.widthBox,
//                                         SizedBox(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width /
//                                               3.4,
//                                           child: Text(
//                                             entryData!.number!,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: AppTheme.heading3,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   // 12.widthBox,
//                                   Expanded(
//                                     flex: 1,
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.people,
//                                           color: AppTheme.lightText,
//                                           size: 20,
//                                         ),
//                                         8.widthBox,
//                                         SizedBox(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width /
//                                               3.4,
//                                           child: Text(
//                                             entryData!.count!,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: AppTheme.heading3,
//                                             maxLines: 1,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),

//                           // Row(
//                           //   children: [
//                           //     const Icon(
//                           //       Icons.call_rounded,
//                           //       size: 20,
//                           //     ),
//                           //     8.widthBox,
//                           //     Text(
//                           //       entryData!.!,
//                           //       overflow: TextOverflow.ellipsis,
//                           //       style: AppTheme.heading2,
//                           //     ),
//                           //   ],
//                           // ),
//                           16.heightBox,

//                           /// address
//                           // Row(
//                           //   crossAxisAlignment:
//                           //       CrossAxisAlignment.start,
//                           //   children: [
//                           //     const Icon(Icons.home_outlined, size: 16),
//                           //     const SizedBox(width: 8),
//                           //     SizedBox(
//                           //       width: 250,
//                           //       child: Text(
//                           //         entryData!.type!,
//                           //         style: AppTheme.smallText,
//                           //         overflow: TextOverflow.ellipsis,
//                           //         maxLines: 2,
//                           //       ),
//                           //     ),
//                           //   ],
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )),
//           ),
//         );
//       },
//     );
//   }
// }
