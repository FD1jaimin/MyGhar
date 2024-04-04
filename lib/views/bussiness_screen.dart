// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/storage_method.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen>
    with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  var searchText = ''.obs;

  AnimationController? animationController;
  var isLoading = false.obs;
  final _file = Uint8List(0).obs;
  bool isediting = true;
  bool isIssue = false;
  TextEditingController businessLink = TextEditingController();
  TextEditingController businessdes = TextEditingController();
  TextEditingController businessTitle = TextEditingController();
  List allResult = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    // getBusinessStream();
    super.initState();
  }

  // didC

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    return true;
  }

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (file != null) {
      return await file.readAsBytes();
    }
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        backgroundColor: AppTheme.appColor,
        foregroundColor: Colors.white,
        onPressed: () {
          _file.value = Uint8List(0);
          businessTitle.clear();
          businessLink.clear();
          businessdes.clear();
          showDialog(
              context: context,

                  barrierDismissible: false,
              builder: (context) => CustomDialog(
                    child: SizedBox(
                      // height: 510,
                      width: MediaQuery.of(context).size.width - 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          8.heightBox,
                          const Text(
                            'Add business title',
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
                                        color:
                                            AppTheme.appColor.withOpacity(0.1))
                                  ],
                                ),
                                width: 124,
                                height: 124,
                                child: _file.value.isEmpty
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
                                        _file.value,
                                        fit: BoxFit.cover,
                                      ), //'images/glimpselogo.png'),
                              ).onTap(() {
                                _selectHouseHoldImage(context);
                              }),
                            );
                          }),
                          16.heightBox,
                          CustomTextField(
                            icon: const Icon(Icons.add_business_rounded),
                            isForm: true,
                            keyboardType: TextInputType.name,
                            hint: 'Add business title',
                            validator: (value) {
                              return null;
                            },
                            textController: businessTitle,
                          ),
                          12.heightBox,
                          CustomTextField(
                            icon: const Icon(Icons.link),
                            isForm: true,
                            keyboardType: TextInputType.url,
                            hint: 'Add business link',
                            validator: (value) {
                              return null;
                            },
                            textController: businessLink,
                          ),
                          12.heightBox,
                          CustomTextField(
                            //icon: const Icon(Icons.description),
                            isForm: true,
                            keyboardType: TextInputType.name,
                            maxLines: 3,
                            minLines: 3,
                            hint: "Add business Des",
                            validator: (value) {
                              return null;
                            },
                            textController: businessdes,
                          ),
                          12.heightBox,
                          Container(
                            height: 58,
                            width: 188,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: AppTheme.buttonColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
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
                              if (businessTitle.text != "" &&
                                  businessdes.text != "") {
                                isLoading.value = true;
                                String memberId = const Uuid().v1();
                                String profile = await StorageMethods()
                                    .uploadImageToStorage(
                                        'business', _file.value, memberId);
                                FireStoreMethods().createBusiness(
                                    businessId: memberId,
                                    image: profile,
                                    title: businessTitle.text,
                                    des: businessdes.text,
                                    link: businessLink.text,
                                    name: Constants.userData.firstName,
                                    number: Constants.userData.phone,
                                    house: Constants.userData.house,
                                    userId: Constants.userId);

                                isLoading.value = false;

                                Get.back();

                                _file.value = Uint8List(0);
                                businessTitle.clear();
                                businessLink.clear();
                                businessdes.clear();
                                if (Constants.showAd) {
                                  Constants.showIntertitialAd();
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please fill all the fields");
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please fill all the fields");
                            }
                          }),
                        ],
                      ),
                    ),
                  ));
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 0, bottom: 12, left: 24, right: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomBackButton(),
                Padding(
                  padding: const EdgeInsets.only(top: 16.8, left: 16),
                  child: Text(
                    "Business",
                    style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                  ),
                ),
              ],
            ).onTap(() {}),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
          //   child: CustomTextField(
          //       isForm: true,
          //       textController: searchController,
          //       hint: "Search name",
          //       icon: const Icon(Icons.search),
          //       validator: (value) {
          //         //setState(() {});
          //       }),
          // ),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('societies')
                    .doc(Constants.societyId)
                    .collection("business")
                    .orderBy('createdOn', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  } else {
                    return snapshot.data!.docs.isEmpty
                        ? const Center(
                            child: Text(
                            "No business Available",
                            style: AppTheme.smallText,
                          ))
                        : ListView(
                            //physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: List<Widget>.generate(
                              snapshot.data!.docs.length,
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
                                String userId =
                                    snapshot.data!.docs[index].data()['id'];
                                return Slidable(
                                  closeOnScroll: true,
                                  enabled: true,
                                  endActionPane: ActionPane(
                                    extentRatio: 0.2,
                                    motion: const StretchMotion(),
                                    children: [
                                      userId !=
                                              FirebaseAuth
                                                  .instance.currentUser!.uid
                                          ? SlidableAction(
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
                                            )
                                          : SlidableAction(
                                              flex: 2,
                                              onPressed: (context) {
                                                dynamic data = snapshot
                                                    .data!.docs[index]
                                                    .data();
                                                FireStoreMethods()
                                                    .deleteBusiness(
                                                        data["businessid"]);
                                              },
                                              icon: Icons.delete,
                                              autoClose: true,
                                              label: "Delete",
                                              padding: const EdgeInsets.all(0),
                                              backgroundColor:
                                                  AppTheme.lightBackgroundColor,
                                            ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 8),
                                    child: CategoryView(
                                      index: index,
                                      snap: snapshot.data!.docs[index].data(),
                                      animation: animation,
                                      animationController: animationController,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                  }
                }),
          )
        ],
      )),
    );
  }
}

// ignore: must_be_immutable
class CategoryView extends StatelessWidget {
  CategoryView(
      {Key? key,
      this.snap,
      this.index,
      // this.handyData,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  final snap;
  final int? index;
  final VoidCallback? callback;
  final AnimationController? animationController;
  final Animation<double>? animation;

  DateTime? from;
  DateTime? to;
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
                child: GestureDetector(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    //height: 145,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 0),
                                    blurRadius: 2,
                                    color: AppTheme.appColor.withOpacity(0.1))
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: const BoxDecoration(),
                                width: double.maxFinite,
                                height: 180,
                                child: CachedNetworkImage(
                                  imageUrl: snap!["image"] ?? "",
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => skeleton(
                                    width: double.maxFinite,
                                    height: 180,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      skeleton(
                                    width: double.maxFinite,
                                    height: 180,
                                  ),

                                  width: double.maxFinite,
                                  height: 180, //'images/glimpselogo.png'),
                                ),
                              ),
                              //  Image.network(
                              //   snap!["image"] ?? "",
                              //   fit: BoxFit.cover,
                              // ), //'images/glimpselogo.png'),
                              // ),
                            ),
                          ),
                        ),

                        /// Call
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 12, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${snap!["title"]}',
                                  style: AppTheme.subheading2),
                              4.heightBox,
                              Text('By : ${snap!["name"]}',
                                  style: AppTheme.smallText),
                              4.heightBox,
                              Text('${snap!["des"]}',
                                  style: AppTheme.smallText,
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis),

                              4.heightBox,
                              Row(
                                children: [
                                  const Icon(Icons.call, color: Colors.green),
                                  12.widthBox,
                                  Text(
                                    '${snap!["number"]}',
                                  ).onTap(() {}),
                                ],
                              ),

                              /// Link
                              Row(
                                children: [
                                  const Icon(Icons.link, color: Colors.blue),
                                  12.widthBox,
                                  Text('Click Here',
                                      style: AppTheme.subheading3.copyWith(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                      )).onTap(() async {
                                    String url = '${snap!["link"]}';
                                    try {
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                      // ignore: empty_catches
                                    } catch (e) {}
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        );
      },
    );
  }
}