// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, deprecated_member_use, unrelated_type_equality_checks, non_constant_identifier_names

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/views/gallery_screen.dart';
import 'package:urbannest/views/navigation_wrapper.dart';
import 'package:urbannest/views/society_selection_screen.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../app_theme.dart';
import '../core/storage_method.dart';
import '../core/user_provider.dart';
import '../models/user.dart' as model;
import '../models/user.dart';
import '../widgets/text_fields.dart';
// import '../onboarding/storage_methods.dart';
// import '../providers/user_provider.dart';
// import '../widget/BackButton.dart';
// import '../widget/like_animation.dart';
// import '../widget/profile_widget.dart';
// import 'createCatogaryPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  Uint8List? _file;

  List<String> vehicleTypes = [
    "4-wheeler",
    "2-wheeler",
  ];
  String selectedVehicleType = '2-wheeler';
  var coverUrl = ''.obs;

  var isLoading = false.obs;
  var _houseHoldfile = Uint8List(0).obs;
  String houseHoldcoverUrl = "";
  bool isediting = false;
  bool isIssue = false;
  TextEditingController report = TextEditingController();
  TextEditingController householdName = TextEditingController();

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  var checkedValue = true;
  bool newHouse = true;
  bool newBlock = true;
  TextEditingController house = TextEditingController();
  TextEditingController block = TextEditingController();

  TextEditingController householdRole = TextEditingController();
  late AnimationController animationController;

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (file != null) {
      return await file.readAsBytes();
    }
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          titlePadding:
              const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
          title: const Text(
            'Profile',
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
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;

                    if (_file != null) coverUrl.value = "";
                  });
                  String profile = await StorageMethods().uploadImageToStorage(
                      'profile',
                      _file!,
                      FirebaseAuth.instance.currentUser!.uid);
                  FireStoreMethods().editProfile(imageUrl: profile);
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
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                    if (_file != null) coverUrl.value = '';
                  });
                  String profile = await StorageMethods().uploadImageToStorage(
                      'profile',
                      _file!,
                      FirebaseAuth.instance.currentUser!.uid);
                  FireStoreMethods().editProfile(imageUrl: profile);

                  setState(() {});
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
                          FontAwesomeIcons.remove,
                          color: AppTheme.lightText,
                        )),
                  ),
                  const Text(
                    'Remove Profile',
                    style: AppTheme.smallText,
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                FireStoreMethods().editProfile(imageUrl: "");
                setState(() {
                  coverUrl.value = "";
                  _file = null;
                });
              },
            )
          ],
        );
      },
    );
  }

  _selectHouseHoldImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          titlePadding:
              const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
          title: const Text(
            'HouseHold Image',
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
                    _houseHoldfile.value = file!;
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
                    _houseHoldfile.value = file!;
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

  bool result = false;
  bool resultShare = false;
  BannerAd? bannerAd;

  @override
  void initState() {
    getFamilyMember();
    bannerAd = Constants.initBannerAdd(size: AdSize.banner);
    result = Constants.getProbability(0.9);
    resultShare = Constants.getProbability(0.6);

    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  getFamilyMember() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where("societyId", isEqualTo: Constants.societyId)
        .where("house", isEqualTo: Constants.userData.house).where('block',isEqualTo: Constants.userData.block)
        .get()
        .then((data) => data.docs.forEach((doc) async {
              if (doc.id != Constants.userId) {
                await FireStoreMethods().deleteHouseHoldMember(
                  uid: doc.id,
                );
                await FireStoreMethods().createHouseHoldMember(
                  uid: doc.id,
                  image: doc['imageUrl'],
                  name: doc['firstName'],
                  role: 'Family',
                  type: "Family",
                );
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    final model.UserData? user = Provider.of<UserProvider>(context).getUser;
    final googleuser = FirebaseAuth.instance.currentUser;
    coverUrl.value = googleuser != null ? googleuser.photoURL ?? '' : "";
    coverUrl.value = user != null ? user.imageUrl : "";
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getAppBarUI(),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 8),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.edit),
                    ).onTap(() {
                      isediting = !isediting;
                      setState(() {});
                      name.text = user!.firstName;
                      phone.text = user.phone!;
                      block.text = user.block!;
                      house.text = user.house!;
                      checkedValue = user.isResident!;
                    }),
                  )
                ],
              ),
              Constants.showAd && result ? getAd() : const SizedBox(),
              isIssue
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        140.heightBox,
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "Please let us know if anything is wrong here by adding few words below",
                            style: AppTheme.smallText,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: TextField(
                            style: AppTheme.heading2,
                            decoration: InputDecoration(
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 105, 110,
                                      116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                  width: 2,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(231, 236, 243, 1),
                                  width: 2,
                                ),
                              ),
                              // focusColor: MyColors.resolveCompanyCOlour(),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(231, 236, 243, 1),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: AppTheme.appColor,
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(231, 236, 243, 1),
                                  width: 2,
                                ),
                              ),
                              hintStyle: AppTheme
                                  .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                              hintText: "type here ...",
                              contentPadding: const EdgeInsets.all(24),
                              errorStyle: AppTheme.smallText.copyWith(
                                fontSize: 10,
                              ),
                            ),
                            // hint: "type here ...",
                            keyboardType: TextInputType.multiline,
                            maxLines: 6,
                            controller: report,
                            // expands: true,
                            autofocus: false,
                            // textController: report,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Container(
                              height: 60,
                              width: 170,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: AppTheme.appColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      "    REPORT",
                                      style: AppTheme.subheading2
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 54,
                                    width: 54,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        CupertinoIcons.paperplane_fill,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ).onTap(
                              () {
                                if (report.text != "") {
                                  FireStoreMethods().report(issue: report.text);
                                  report.clear();
                                  Fluttertoast.showToast(msg: "Issue noted");
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Issue can't be empty");
                                }
                                isIssue = !isIssue;

                                setState(() {});
                              },
                            )),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  return Obx(() {
                                    if (!snapshot.hasData) {
                                      coverUrl.value = user!.imageUrl;
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  AppTheme.lightBackgroundColor,
                                              width: 2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(300),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                    offset: const Offset(0, 0),
                                                    blurRadius: 8,
                                                    color: AppTheme.appColor
                                                        .withOpacity(0.08))
                                              ],
                                              // image: DecorationImage(
                                              //     image: coverUrl == ""
                                              //         ? AssetImage(
                                              //             "images/profile.jpg")
                                              //         : NetworkImage(coverUrl))
                                            ),
                                            width: 144,
                                            height: 144,
                                            child: coverUrl == ""
                                                ? Lottie.asset(
                                                    "assets/profile.json")
                                                : Image.network(
                                                    coverUrl.value,
                                                    fit: BoxFit.cover,
                                                  ), //'images/glimpselogo.png'),
                                          ),
                                        ),
                                      );
                                    } else {
                                      coverUrl.value =
                                          snapshot.data!["imageUrl"];
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  AppTheme.lightBackgroundColor,
                                              width: 2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(300.0),
                                          clipBehavior: Clip.antiAlias,
                                          child: Container(
                                              // clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                // border: Border.all(
                                                //     color:
                                                //         AppTheme.lightBackgroundColor,
                                                //     width: 2),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                      offset:
                                                          const Offset(0, 0),
                                                      blurRadius: 8,
                                                      color: AppTheme.appColor
                                                          .withOpacity(0.08))
                                                ],

                                                // image: coverUrl != "" || _file != null
                                                //     ? DecorationImage(
                                                //         image:
                                                //             // AssetImage("images/profile.jpg", ),opacity: 0.7 ) ,  ),
                                                //             coverUrl != ""
                                                //                 ? coverUrl == ""
                                                //                     ? AssetImage(
                                                //                         "images/profile.jpg")
                                                //                     : NetworkImage(
                                                //                         coverUrl)
                                                //                 : MemoryImage(
                                                //                     _file,
                                                //                   ),
                                                //         fit: BoxFit.cover)
                                                //     : DecorationImage(
                                                //         image: coverUrl == ""
                                                //             ? AssetImage(
                                                //                 "images/profile.jpg")
                                                //             : NetworkImage(coverUrl))
                                              ),
                                              width: 144,
                                              height:
                                                  144, //'images/glimpselogo.png'),
                                              child: coverUrl == "" &&
                                                      _file != null
                                                  ? Image.memory(_file!,
                                                      fit: BoxFit.cover)
                                                  : (coverUrl == ""
                                                      ? Lottie.asset(
                                                          "assets/profile.json")
                                                      : Image.network(
                                                          coverUrl.value,
                                                          fit: BoxFit.cover))

                                              //  AssetImage(
                                              //     "images/profile.jpg")
                                              // : NetworkImage(coverUrl)),
                                              ),
                                        ),
                                      );
                                    }
                                  });
                                }),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: GestureDetector(
                                  onTap: () => _selectImage(context),
                                  child: buildEditIcon(AppTheme.appColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        isediting
                            ? _buildEditSection(user!)
                            : Column(
                                children: [
                                  buildName(user!),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 56),
                                    child: Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme
                                                    .lightBackgroundColor,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Icon(
                                                  FontAwesomeIcons.city,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width: 70,
                                                child: Text(
                                                  user.societyName!,
                                                  style: AppTheme.smallText,
                                                  textAlign: TextAlign.center,
                                                ))
                                          ],
                                        ),
                                        Container(
                                          width: 2,
                                          height: 52,
                                          decoration: BoxDecoration(
                                              color: AppTheme.lightText
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme
                                                    .lightBackgroundColor,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Icon(
                                                  FontAwesomeIcons.home,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width: 70,
                                                child: Text(
                                                  user.house!,
                                                  style: AppTheme.smallText,
                                                  textAlign: TextAlign.center,
                                                ))
                                          ],
                                        ),
                                        Container(
                                          width: 2,
                                          height: 52,
                                          decoration: BoxDecoration(
                                              color: AppTheme.lightText
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme
                                                    .lightBackgroundColor,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Icon(
                                                  FontAwesomeIcons.building,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width: 70,
                                                child: Text(
                                                  user.block!,
                                                  style: AppTheme.smallText,
                                                  textAlign: TextAlign.center,
                                                )),
                                          ],
                                        )

                                        // Image.asset(data.icon),
                                      ],
                                    ),
                                  ),
                                  6.heightBox,
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Add',
                                        style: AppTheme.smallText.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.lightText,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppTheme.lightText),
                                      ).onTap(() {
                                        Get.to(const SocietySelectScreen());
                                      }),
                                      Text(
                                        ' | ',
                                        style: AppTheme.smallText.copyWith(
                                            color: AppTheme.lightText),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.location,
                                            size: 12,
                                            color: AppTheme.lightText,
                                          ),
                                          Text(
                                            ' Share Address',
                                            style: AppTheme.smallText.copyWith(
                                                color: AppTheme.lightText,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppTheme.lightText),
                                          ),
                                        ],
                                      ).onTap(() {
                                        _shareAddress();
                                        Constants.showAd && resultShare
                                            ? Constants.showIntertitialAd()
                                            : SizedBox();
                                      }),
                                    ],
                                  ),
                                  16.heightBox,
                                  getHomes(),
                                  8.heightBox,
                                  getVisitors(type: "Family"),
                                  getVisitors(type: "Vehicle"),
                                  getVisitors(type: "Frequent Visitor"),
                                  getVisitors(type: "Daily help"),
                                ],
                              )
                      ],
                    ),
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     16.heightBox,
              //     Center(
              //         child: Profile_avatar(
              //       uid: userinfo!.uid,
              //       height: 164,
              //       width: 164,
              //     )),
              //     12.heightBox,
              //     Center(
              //         child: Text(
              //       userinfo.firstName + " " + userinfo.lastName,
              //       style: AppTheme.subheading,
              //     )),
              //     Center(
              //         child: Text(
              //       userinfo.email,
              //       style: AppTheme.smallText,
              //     )),

              // getServices(),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     // Padding(
              //     //   padding: const EdgeInsets.only(left: 24.0, top: 16),
              //     //   child: Text(
              //     //     "Community",
              //     //     style: AppTheme.subheading2,
              //     //   ),
              //     // ),
              //     GridView(
              //       padding: const EdgeInsets.all(24),
              //       physics: const NeverScrollableScrollPhysics(),
              //       shrinkWrap: true,
              //       children: List<Widget>.generate(
              //         items.length,
              //         (int index) {
              //           final int count = 1;
              //           final Animation<double> animation =
              //               Tween<double>(begin: 0.0, end: 1.0).animate(
              //             CurvedAnimation(
              //               parent: animationController,
              //               curve: Interval((1 / count) * index, 1.0,
              //                   curve: Curves.fastOutSlowIn),
              //             ),
              //           );
              //           animationController?.forward();
              //           return Container(
              //             decoration: const BoxDecoration(
              //               color: Colors.white,
              //               borderRadius: BorderRadius.all(Radius.circular(32)),
              //             ),
              //             child: Stack(
              //               children: [
              //                 Align(
              //                   alignment: Alignment.topCenter,
              //                   child: Padding(
              //                     padding: const EdgeInsets.all(16.0),
              //                     child: Text(
              //                       items[index],
              //                       textAlign: TextAlign.center,
              //                       style: AppTheme.subheading2.copyWith(fontSize: 19),
              //                     ),
              //                   ),
              //                 ),
              //                 Align(
              //                     alignment: Alignment.bottomCenter,
              //                     child: Lottie.asset(
              //                         "assets/${items[index]}.json",
              //                         fit: BoxFit.fitWidth,
              //                         height: 150)),
              //               ],
              //             ),
              //           ).onTap(() {
              //             Get.to(screens[index]);
              //           });
              //         },
              //       ),
              //       gridDelegate:
              //           const SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount: 2,
              //         mainAxisSpacing: 16.0,
              //         crossAxisSpacing: 16.0,
              //         childAspectRatio: 1,
              //       ),
              //     ),

              // ],)
              //   ],
              // )
            ],
          ),
        ),
      )),
    );

    // SizedBox(
    //   child: Center(
    //     child: Text(
    //       "- We appreciate ur feebacks ;)",
    //       style: AppTheme.smallText,
    //     ),
    //   ),
    //   height: 16.8 + 40,
    // ),

    // const SizedBox(height: 24),
  }

  getAd() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(height: 65, child: AdWidget(ad: bannerAd!)),
    );
  }

  Future<void> _shareAddress() async {
    // if (userAddress != null && userAddress.isNotEmpty) {
    String encodedAddress = Uri.encodeFull(Constants.userData.address!);
    Share.share('${Constants.userData.address}' +
        '\n\n' +
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    // } else {}
  }

  Column _buildEditSection(UserData data) {
    return Column(
      children: [
        SizedBox(
          width: 300.0,
          child: Column(
            children: <Widget>[
              CustomTextField(
                hint: "Edit Name",
                icon: const Icon(CupertinoIcons.person_fill, size: 28),
                obsecure: false,
                autofocus: false,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter your name";
                  } else if (value!.length < 3) {
                    return "Name must be longer than 3 character";
                  }
                  return null;
                },
                textController: name,
              ),
              12.heightBox,
              CustomTextField(
                hint: "Edit Phone number",
                icon: const Icon(CupertinoIcons.phone_fill, size: 28),
                obsecure: false,
                autofocus: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter your number";
                  } else if (value!.length < 10) {
                    return "number must be longer than 10 digits";
                  }
                  return null;
                },
                textController: phone,
              ),
              12.heightBox,
              _buildContinueButton(),
              6.heightBox,
              Text(
                'leave society',
                style: AppTheme.smallText.copyWith(
                    color: Colors.red[400],
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.red[400]),
              ).onTap(() {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          8.heightBox,
                          const Text(
                            'Are you sure?',
                            style: AppTheme.subheading2,
                            textAlign: TextAlign.center,
                          ),
                          14.heightBox,
                          const Text(
                            'Are you sure you want to leave the society? Action is irreversible.',
                            style: AppTheme.smallText,
                          ),
                          12.heightBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 58,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.red[
                                      400], // AppTheme.buttonColor.withOpacity(0.9),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      12.widthBox,
                                      const Icon(
                                        FontAwesomeIcons.check,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ).onTap(() async {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({
                                  'societyId': "",
                                  'societyCode': "",
                                  'societyName': "",
                                  'societyGroupId':'',
                                  'societyAdminGroupId':'',
                                  'block': "",
                                  "sector": "",
                                  "address": "",
                                  "type": 'user',
                                });
                                FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          Constants.societyId);
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'admin-${Constants.societyId}');
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'member-${Constants.societyId}');
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'guard-${Constants.societyId}');
                                FirebaseFirestore.instance
                                    .collection('rooms')
                                    .doc(Constants.userData.societyGroupId)
                                    .update({
                                  'userIds': FieldValue.arrayRemove(
                                      [Constants.userId]),
                                });
                                FirebaseFirestore.instance
                                    .collection('rooms')
                                    .doc(Constants.userData.societyAdminGroupId)
                                    .update({
                                  'userIds': FieldValue.arrayRemove(
                                      [Constants.userId]),
                                });
                                Get.back();
                              }),
                              Container(
                                height: 58,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors
                                      .green[400], // AppTheme.buttonColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'No',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      12.widthBox,
                                      const Icon(
                                        FontAwesomeIcons.x,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ).onTap(() async {
                                Get.back();
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ],
    );
  }

  Widget getVisitors({String? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 0, bottom: 0),
          child: Text(
            type!,
            style: AppTheme.subheading2,
          ),
        ),
        SizedBox(
          height: 120,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('societies')
                  .doc(Constants.societyId)
                  .collection('house')
                  .doc(Constants.userData.house)
                  .collection("households")
                  .where('type', isEqualTo: type)
                  .where('isTenant', isEqualTo: Constants.userData.isTenant)
                  // .orderBy('createdOn', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 6),
                    child: Row(
                      children: [
                        AddGuestButton(context, type),
                      ],
                    ),
                  );
                } else {
                  List<dynamic> data = [];
                  // List<String> names = [];
                  // Map<String, List<dynamic>> data = {};
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    dynamic member = {
                      'id': snapshot.data!.docs[i]['uid'],
                      'name': snapshot.data!.docs[i]['name'],
                      'role': snapshot.data!.docs[i]['role'],
                      'type': snapshot.data!.docs[i]['type'],
                      'createdOn': snapshot.data!.docs[i]['createdOn'],
                      'image': snapshot.data!.docs[i]['image'],
                    };
                    // if (image['albumId'] == '') continue;
                    // if (data.containsKey(image['albumId'])) {
                    // List<dynamic> newValue = data[image['albumId']]!;
                    //   newValue.add(image);
                    //   data[image['albumId']] = newValue;
                    // } else {
                    //   names.add(image['albumId']);
                    //   data[image['albumId']] = [image];
                    // }
                    data.add(member);
                  }

                  return SizedBox(
                    height: 112,
                    width: double.infinity,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 6),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: List<Widget>.generate(
                        data.length + 1,
                        (int index) {
                          animationController.forward();

                          return index == 0
                              ? AddGuestButton(
                                  context,
                                  type,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                                  255, 141, 191, 217)
                                              .withOpacity(0.1),
                                          width: 1),
                                    ),
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      // alignment: Alignment.centerLeft,
                                      height: 112,
                                      // width: 112,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            4.widthBox,
                                            Container(
                                              clipBehavior: Clip.antiAlias,
                                              height: 66,
                                              width: 66,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: _buildImageTile(
                                                  data[index - 1]['image'],
                                                  data[index - 1]['id'],
                                                  context),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.qr_code_rounded,
                                                  color: AppTheme.lightText,
                                                  size: 30,
                                                ),
                                                6.heightBox,
                                                SizedBox(
                                                    width: 74,
                                                    child: Text(
                                                      data[index - 1]["name"],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: AppTheme.smallText
                                                          .copyWith(
                                                              height: 1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                SizedBox(
                                                  width: 74,
                                                  child: Text(
                                                      data[index - 1]["role"],
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      style: AppTheme.smallText
                                                          .copyWith(
                                                        height: 1,
                                                        fontSize: 10,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ).onTap(() {
                                    user_card(data[index - 1], context);
                                    // Get.to(AlbumScreen(
                                    //   albumId: albumData[0]["albumId"],
                                    //   householdName: albumData[0]["householdName"],
                                    // ));
                                    // user_card(data[index - 1].guestname!);
                                  }),
                                );
                        },
                      ),
                    ),
                  );
                }
              }),
        ),
      ],
    );
  }

  Widget getHomes() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(Constants.userId)
            .collection('homes')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            List<dynamic> data = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              dynamic home = {
                'block': snapshot.data!.docs[i]['block'],
                'house': snapshot.data!.docs[i]['house'],
                'type': snapshot.data!.docs[i]['type'],
                'address': snapshot.data!.docs[i]['address'],
                'societyId': snapshot.data!.docs[i]['societyId'],
                'societyCode': snapshot.data!.docs[i]['societyCode'],
                'societyName': snapshot.data!.docs[i]['societyName'],
                'isTenant': snapshot.data!.docs[i]['isTenant'] ?? false,
              };

              data.add(home);
            }
            return data.length <= 1
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 24, top: 0, bottom: 0),
                        child: Text(
                          "Your Homes",
                          style: AppTheme.subheading2,
                        ),
                      ),
                      ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 6),
                        // scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List<Widget>.generate(
                          data.length,
                          (int index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                              255, 141, 191, 217)
                                          .withOpacity(0.1),
                                      width: 1),
                                ),
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        4.widthBox,
                                        Container(
                                          clipBehavior: Clip.antiAlias,
                                          height: 44,
                                          width: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child:
                                              const Icon(FontAwesomeIcons.home),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              data[index]["house"] +
                                                  ", " +
                                                  data[index]["block"],
                                              // textAlign:
                                              //     TextAlign.center,
                                              style: AppTheme.smallText
                                                  .copyWith(
                                                      height: 1,
                                                      fontWeight:
                                                          FontWeight.w700),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(data[index]["address"],
                                                // textAlign:
                                                //     TextAlign.center,
                                                maxLines: 2,
                                                style:
                                                    AppTheme.smallText.copyWith(
                                                  height: 1,
                                                  fontSize: 10,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).onTap(() async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(Constants.userId)
                                    .update({
                                  'type': data[index]["type"],
                                  'house': data[index]["house"],
                                  'block': data[index]["block"],
                                  'address': data[index]["address"],
                                  'societyCode': data[index]["societyCode"],
                                  'societyId': data[index]["societyId"],
                                  'societyName': data[index]["societyName"],
                                });
                                addData();
                                Constants.type = data[index]["type"];
                                Get.offAll(const NavigationWrapper());
                                // user_card(data[index - 1], context);
                                // Get.to(AlbumScreen(
                                //   albumId: albumData[0]["albumId"],
                                //   householdName: albumData[0]["householdName"],
                                // ));
                                // user_card(data[index - 1].guestname!);
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  );
          }
        });
  }

  addData() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  Future<dynamic> user_card(dynamic data, BuildContext context) {
    return showDialog(context: context, builder: (context) => QRCard(data));
  }

  Center QRCard(dynamic data) {
    // final model.UserData? user = Provider.of<UserProvider>(context).getUser;

    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 6,
            width: 70,
            decoration: BoxDecoration(
                color: AppTheme.appColor,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24)))),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 9),
                    blurRadius: 7,
                    color: Colors.black.withOpacity(0.30))
              ]),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0, left: 24, right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    height: 42,
                    width: 60,
                    decoration: BoxDecoration(
                        color: AppTheme.appColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22)))),
                // SizedBox(height: 24,),
                // Container(width: 53,decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.grey.withOpacity(0.5)),height: 7,),
                12.heightBox,
                SizedBox(
                    width: 200,
                    child: Text(
                      "*This QR is not for scan please use the share option below",
                      style: AppTheme.smallText.copyWith(fontSize: 10),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 130,
                    width: 130,
                    child: QrImageView(
                      data: "${data['name']}}",
                      version: QrVersions.auto,
                      // size: 100.0,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.lightText.withOpacity(0.1),
                            width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: const BoxDecoration(color: Colors.white),
                          width: 54,
                          height: 54,
                          child: CachedNetworkImage(
                            imageUrl: data['image'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const skeleton(
                              colors: Colors.white,
                              height: 54,
                              width: 54,
                            ),
                            errorWidget: (context, url, error) =>
                                const skeleton(
                              height: 54,
                              colors: Colors.white,
                              width: 54,
                            ),
                          ), //'images/glimpselogo.png'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                      width: 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(data['name'],
                              textAlign: TextAlign.left,
                              style: AppTheme.subheading2),
                          Text(data['role'],
                              textAlign: TextAlign.left,
                              style: AppTheme.smallText)
                        ],
                      ),
                    ),
                    12.widthBox,
                    const Icon(
                      Icons.delete,
                      color: AppTheme.darkText,
                      size: 28,
                    ).onTap(() {
                      Get.back();
                      FireStoreMethods().deleteHouseHoldMember(uid: data['id']);
                    }),
                    12.widthBox,
                    Container(
                        child: const Icon(
                      Icons.share_rounded,
                      color: AppTheme.darkText,
                      size: 28,
                    )).onTap(() {
                      DateTime now = DateTime.now();
                      _shareQRImage(
                        "${now.month}${now.year}€${data['name']}€${Constants.userData.house}€${Constants.userData.block}€1",
                      );
                    }),
                    12.widthBox
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Container _buildContinueButton() {
    return Container(
      height: 58,
      width: 188,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: AppTheme.buttonColor,
      ),
      child: InkWell(
        onTap: (() {
          FireStoreMethods().editUserData(
              isResident: checkedValue,
              name: name.text.trim(),
              phone: phone.text.trim());
          Fluttertoast.showToast(msg: "Profile Updated");
          isediting = !isediting;
        }),
        child: const Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _shareQRImage(String url) async {
    QrCode qrCode = QrCode.fromData(
      data: url,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    QrImage qrImage = QrImage(qrCode);

    final image = await qrImage.toImageAsBytes(size: 300);

    const filename = 'qr_code.png';
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$filename').create();
    var bytes = image!.buffer.asUint8List();
    await file.writeAsBytes(bytes);
    // ignore: deprecated_member_use
    Share.shareFiles([file.path],
        text: '', subject: 'QR Code', mimeTypes: ['image/png']);
  }

  // Future _shareQRImage(String url) async {
  //   final image = await QrPainter(
  //     data: url,
  //     version: QrVersions.auto,
  //     gapless: true,
  //     dataModuleStyle: QrDataModuleStyle(color: AppTheme.lightBackgroundColor,dataModuleShape: QrDataModuleShape.square),
  //     color:Color.fromARGB(255, 37, 71, 84),

  //     emptyColor: Colors.white,
  //   ).toImageData(200.0);

  //   const filename = 'qr_code.png';
  //   final tempDir = await getTemporaryDirectory();
  //   final file = await File('${tempDir.path}/$filename').create();
  //   var bytes = image!.buffer.asUint8List();
  //   await file.writeAsBytes(bytes);
  //   // ignore: deprecated_member_use
  //   Share.shareFiles([file.path],
  //       text: '', subject: 'QR Code', mimeTypes: ['image/png']);
  // }

  Widget _buildImageTile(
    String imageUrl,
    String documentId,
    BuildContext context,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const skeleton(
          height: 66,
          width: 66,
          colors: Colors.white,
        ),
        errorWidget: (context, url, error) => const skeleton(
          height: 66,
          width: 66,
          colors: Colors.white,
        ),
      ),
    );
  }

  BoxWidget(int count, String heading, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 0),
                blurRadius: 0,
                color: AppTheme.appColor.withOpacity(0))
          ],
          borderRadius: const BorderRadius.all(Radius.circular(26.0)),
          // border: new Border.all(
          //     color: DesignCourseAppTheme.notWhite),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundOverlayColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                      child: Text(
                    count.toString(),
                    style: AppTheme.heading,
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 160,
                    child: Text(
                      heading, // "Introduction",

                      style: AppTheme.subheading,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTheme.smallText,
                  ),
                  const SizedBox(
                    height: 4,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppBarUI() {
    return const Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 4),
      child:
          Text('Profile', textAlign: TextAlign.left, style: AppTheme.heading),
    );
  }

  Widget buildName(UserData user) => Column(
        children: [
          RichText(
            maxLines: 2,
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${user.firstName} ${user.lastName}",
                  style: AppTheme.subheading,
                ),
                // WidgetSpan(
                //   child: isediting
                //       ? Padding(
                //           padding:
                //               const EdgeInsets.only(
                //                   left: 8,bottom: 6),
                //           child: Icon(
                //             Icons.edit,
                //             size: 12,
                //             color: AppTheme.appColor,

                //           ),
                //         )
                //       : Container(),
                // ),
              ],
            ),
          ),
          // const SizedBox(height: 4),
          // Text(
          //   "B63 Block 6",
          //   // user.email,
          //   style: AppTheme.smallText,
          // )
        ],
      );

  GestureDetector AddGuestButton(BuildContext context, String? type) {
    final UserData? user = Provider.of<UserProvider>(context).getUser;
    return GestureDetector(
      onTap: () {
        householdName.clear();
        showDialog(
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
                      Text(
                        type == 'Family'
                            ? 'Add Family member'
                            : type == "Vehicle"
                                ? 'Add Vehicle Detail'
                                : type == "Frequent Visitor"
                                    ? 'Add Frequent visitor'
                                    : 'Add Daily Help',
                        style: AppTheme.subheading2,
                        textAlign: TextAlign.center,
                      ),
                      14.heightBox,
                      Obx(() {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              // border:
                              // Border.all(color: Colors.white, width: 2),
                              // shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 0),
                                    blurRadius: 8,
                                    color: AppTheme.appColor.withOpacity(0.1))
                              ],
                            ),
                            width: 124,
                            height: 124,
                            child: _houseHoldfile.value.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                        color: HexColorNew('#F8FAFB'),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: const Icon(
                                      FontAwesomeIcons.images,
                                      color: AppTheme.lightText,
                                      size: 34,
                                    ))
                                : Image.memory(
                                    _houseHoldfile.value,
                                    fit: BoxFit.cover,
                                  ), //'images/glimpselogo.png'),
                          ).onTap(() {
                            _selectHouseHoldImage(context);
                          }),
                        );
                      }),
                      16.heightBox,
                      CustomTextField(
                        icon: type == 'Family'
                            ? const Icon(Icons.person)
                            : type == "Vehicle"
                                ? const Icon(Icons.twenty_one_mp_outlined)
                                : const Icon(Icons.person),
                        isForm: true,
                        keyboardType: TextInputType.name,
                        hint: type == 'Family'
                            ? 'Enter member name'
                            : type == "Vehicle"
                                ? 'Enter Vehicle number'
                                : type == "Frequent Visitor"
                                    ? "Enter visitor name"
                                    : 'Enter helper name',
                        validator: (value) {
                          return null;
                        },
                        textController: householdName,
                      ),
                      12.heightBox,
                      CustomTextField(
                        icon: type == 'Family'
                            ? const Icon(Icons.badge_rounded)
                            : type == "Vehicle"
                                ? const Icon(Icons.time_to_leave_rounded)
                                : type == "Frequent Visitor"
                                    ? const Icon(Icons.badge_rounded)
                                    : const Icon(Icons.handyman),
                        isForm: true,
                        keyboardType: TextInputType.name,
                        hint: type == 'Family'
                            ? 'Enter member role'
                            : type == "Vehicle"
                                ? 'Enter Vehicle model'
                                : type == "Frequent Visitor"
                                    ? "Enter visitor type"
                                    : 'Enter helper service',
                        validator: (value) {
                          return null;
                        },
                        textController: householdRole,
                      ),
                      type == "Vehicle" ? 12.heightBox : 0.heightBox,
                      type == "Vehicle"
                          ? DropdownButtonFormField2<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(171, 177, 186, 1),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(171, 177, 186, 1),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(171, 177, 186, 1),
                                    width: 2,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(171, 177, 186, 1),
                                    width: 2,
                                  ),
                                ),
                                // Add more decoration..
                              ),
                              hint: const Text(
                                'Vehicle Type',
                                style: AppTheme.smallText,
                              ),
                              value: "2-wheeler",
                              items: vehicleTypes
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item,
                                            style: AppTheme.subheading3),
                                      ))
                                  .toList(),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select vehicle type';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedVehicleType = value.toString();
                                });
                                //Do something when selected item is changed.
                              },
                              onSaved: (value) {
                                selectedVehicleType = value.toString();
                                setState(() {});
                              },
                              buttonStyleData: const ButtonStyleData(
                                padding: EdgeInsets.only(right: 8),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: AppTheme.lightText,
                                ),
                                iconSize: 24,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            )
                          : SizedBox(),
                      12.heightBox,
                      Container(
                        height: 58,
                        width: 188,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: AppTheme.buttonColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Obx(() {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isLoading.value
                                    ? LoadingAnimationWidget.waveDots(
                                        color: Colors.white, size: 40)
                                    : const Text(
                                        'Add',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ],
                            );
                          }),
                        ),
                      ).onTap(() async {
                        if (!isLoading.value) {
                          if (householdName.text != "" &&
                              householdName.text != "" &&
                              _houseHoldfile.value.isNotEmpty) {
                            isLoading.value = true;
                            String memberId = const Uuid().v1();
                            String profile = '';
                            if (_houseHoldfile.value.isNotEmpty) {
                              profile = await StorageMethods()
                                  .uploadImageToStorage('households',
                                      _houseHoldfile.value, memberId);
                            }
                            FireStoreMethods().createHouseHoldMember(
                              uid: memberId,
                              image: profile,
                              name: householdName.text,
                              role: householdRole.text,
                              type: type,
                            );
                            if (type == "Vehicle") {
                              FirebaseFirestore.instance
                                  .collection('societies')
                                  .doc(Constants.societyId)
                                  .collection('vehicles')
                                  .doc(memberId)
                                  .set({
                                'id': memberId,
                                'name': householdName.text,
                                'role': householdRole.text,
                                'image': profile,
                                "type": type,
                                'vehicleWheel': selectedVehicleType,
                                'number': user!.phone,
                                'username': user.firstName,
                                'lastDigits': householdName.text
                                    .substring(householdName.text.length - 4)
                              });
                            }
                            isLoading.value = false;
                            Get.back();

                            _houseHoldfile.value = Uint8List(0);
                            householdName.clear();
                            householdRole.clear();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please fill all the details");
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please fill all the details");
                        }
                      }),
                    ],
                  ),
                )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: const Color.fromARGB(255, 141, 191, 217).withOpacity(0.1),
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
                color:
                    const Color.fromARGB(255, 141, 191, 217).withOpacity(0.1),
                width: 3),
          ),
          child: const Center(
              child: Icon(
            FontAwesomeIcons.add,
            color: AppTheme.lightText,
          )),
        ),
      ),
    );
  }

  Widget buildAbout(UserData user) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.email,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    Widget? child,
    double? all,
    Color? color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all!),
          color: color,
          child: child,
        ),
      );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    final UserData? user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        physics: const BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: user!.imageUrl,
            isEdit: true,
            onClicked: () async {},
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: 'Full Name',
            text: "${user.firstName} ${user.lastName}",
            onChanged: (name) {},
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: 'Email',
            text: user.email,
            onChanged: (email) {},
          ),
          const SizedBox(height: 24),
          // TextFieldWidget(
          //   label: 'About',
          //   text: user.bio,
          //   maxLines: 5,
          //   onChanged: (about) {},
          // ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class TextFieldWidget extends StatefulWidget {
  final int maxLines;
  final String? label;
  final String? text;
  final ValueChanged<String>? onChanged;

  const TextFieldWidget({
    Key? key,
    this.maxLines = 1,
    this.label,
    this.text,
    this.onChanged,
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: widget.maxLines,
          ),
        ],
      );
}

class NumbersWidget extends StatelessWidget {
  const NumbersWidget({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, '4.8', 'Ranking'),
          buildDivider(),
          buildButton(context, '35', 'Following'),
          buildDivider(),
          buildButton(context, '50', 'Followers'),
        ],
      );
  Widget buildDivider() => const SizedBox(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}

class ProfileWidget extends StatelessWidget {
  final String? imagePath;
  final bool? isEdit;
  final VoidCallback? onClicked;

  const ProfileWidget({
    Key? key,
    this.imagePath,
    this.isEdit = false,
    this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath!);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          // child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => GestureDetector(
        onTap: onClicked,
        child: buildCircle(
          color: Colors.white,
          all: 3,
          child: buildCircle(
            color: color,
            all: 8,
            child: Icon(
              isEdit! ? Icons.add_a_photo : Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );

  Widget buildCircle({
    Widget? child,
    double? all,
    Color? color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all!),
          color: color,
          child: child,
        ),
      );
}
