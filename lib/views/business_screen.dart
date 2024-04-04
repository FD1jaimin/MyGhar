// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/models/stores.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/storage_method.dart';
import '../widgets/text_fields.dart';

TextEditingController searchController = TextEditingController();
var searchText = ''.obs;

class BusinessScreenNew extends StatefulWidget {
  const BusinessScreenNew({super.key});

  @override
  State<BusinessScreenNew> createState() => _BusinessScreenNewState();
}

class _BusinessScreenNewState extends State<BusinessScreenNew> {
  TextEditingController businessLink = TextEditingController();
  TextEditingController businessdes = TextEditingController();
  TextEditingController businessTitle = TextEditingController();
  TextEditingController address = TextEditingController();
  final TextEditingController date = TextEditingController();

  var isLoading = false.obs;
  final _file = Uint8List(0).obs;

  bool isediting = true;

  List<String> services = [];
  var selectedService = ''.obs;

  TextEditingController serviceController = TextEditingController();

  var data;

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
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),

              // mini: true,
              backgroundColor: AppTheme.appColor,
              foregroundColor: Colors.white,
              onPressed: () {
                selectedService.value = "";
                _file.value = Uint8List(0);
                businessTitle.clear();
                businessLink.clear();

                serviceController.clear();
                businessdes.clear();
                showDialog(

                  barrierDismissible: false,
                    context: context,
                    builder: (context) => CustomDialog(
                          child: SizedBox(
                            // height: 510,
                            width: MediaQuery.of(context).size.width - 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                0.heightBox,
                                const Text(
                                  'Add Business',
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
                                              color: AppTheme.appColor
                                                  .withOpacity(0.1))
                                        ],
                                      ),
                                      width: 114,
                                      height: 114,
                                      child: _file.value.isEmpty
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: HexColorNew('#F8FAFB'),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
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
                                12.heightBox,
                                CustomTextField(
                                  icon: const Icon(Icons.add_business_rounded),
                                  isForm: true,
                                  keyboardType: TextInputType.name,
                                  hint: 'Enter business title',
                                  validator: (value) {
                                    return null;
                                  },
                                  textController: businessTitle,
                                ),
                                10.heightBox,
                                CustomTextField(
                                  icon: const Icon(Icons.link),
                                  isForm: true,
                                  keyboardType: TextInputType.url,
                                  hint: 'Enter business accessible link',
                                  validator: (value) {
                                    return null;
                                  },
                                  textController: businessLink,
                                ),
                                10.heightBox,
                                StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('societies')
                                        .doc(Constants.societyId)
                                        .collection('business')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      List<String> data = [];
                                      data.add("Add new ");
                                      if (snapshot.hasData) {
                                        for (int i = 0;
                                            i < snapshot.data!.docs.length;
                                            i++) {
                                          if (!data.contains(
                                              snapshot.data!.docs[i]["type"])) {
                                            data.add(
                                                snapshot.data!.docs[i]["type"]);
                                          }
                                        }
                                      }
                                      return Obx(() {
                                        return selectedService.value ==
                                                "Add new "
                                            ? CustomTextField(
                                                isForm: true,
                                                keyboardType:
                                                    TextInputType.text,
                                                hint: "Enter Business Type",
                                                validator: (value) {
                                                  return null;
                                                },
                                                textController:
                                                    serviceController)
                                            : DropdownButtonFormField2<String>(
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 18),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  // Add more decoration..
                                                ),
                                                hint: const Text(
                                                  'Business Type',
                                                  style: AppTheme.smallText,
                                                ),
                                                items: data
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: item,
                                                          child: Text(item,
                                                              style: AppTheme
                                                                  .subheading3),
                                                        ))
                                                    .toList(),
                                                validator: (value) {
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  selectedService.value =
                                                      value.toString();
                                                  setState(() {});
                                                  //Do something when selected item is changed.
                                                },
                                                onSaved: (value) {
                                                  selectedService.value =
                                                      value.toString();
                                                  setState(() {});
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding:
                                                      EdgeInsets.only(right: 8),
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: AppTheme.lightText,
                                                  ),
                                                  iconSize: 24,
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                ),
                                              );
                                      });
                                    }),
                                10.heightBox,
                                CustomTextField(
                                  //icon: const Icon(Icons.description),
                                  isForm: true,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  minLines: 2,
                                  hint: "Enter Business Description",
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
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: Obx(() {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      String profile = '';
                                      isLoading.value = true;
                                      String memberId = const Uuid().v1();

                                      if (_file.value.isNotEmpty) {
                                        String profileCompress =
                                            await StorageMethods()
                                                .uploadImageToStorage(
                                                    'business',
                                                    _file.value,
                                                    memberId);
                                        setState(() {
                                          profile = profileCompress;
                                        });
                                      }

                                      FireStoreMethods().createBusiness(
                                          businessId: memberId,
                                          image: profile,
                                          title: businessTitle.text,
                                          des: businessdes.text,
                                          link: businessLink.text,
                                          type: selectedService.value ==
                                                  "Add new "
                                              ? serviceController.text
                                              : selectedService.value,
                                          name: Constants.userData.firstName,
                                          number: Constants.userData.phone,
                                          house: Constants.userData.house,
                                          userId: Constants.userId);

                                      isLoading.value = false;

                                      Get.back();

                                      _file.value = Uint8List(0);
                                      businessTitle.clear();
                                      businessLink.clear();

                                      serviceController.clear();
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
                //   // Respond to button press
              },
              child: const Icon(Icons.add),
            )
         ,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
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
                        "Business",
                        style:
                            AppTheme.subheading.copyWith(letterSpacing: -0.3),
                      ),
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              child: CustomTextField(
                  isForm: true,
                  onChanged: (value) {
                    searchController.text = value;
                    searchText.value = value;
                  },
                  textController: searchController,
                  hint: "Search different businesses",
                  icon: const Icon(Icons.search),
                  validator: (value) {
                    return null;
                  }),
            ),
            6.heightBox,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: getMyCourseList(),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget getMyCourseList() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: MyCourseList(),
    );
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
  bool result = false;
  int selectIndex = 0;

  List<BannerAd> bannerAds = [];

  @override
  void initState() {
    result = Constants.getProbability(0.6);
    for (int i = 0; i < 3; i++) {
      BannerAd? bannerAdTemp;
      bannerAdTemp = Constants.initBannerAdd(size: AdSize.largeBanner);
      bannerAds.add(bannerAdTemp);
    }
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
    // final UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: StreamBuilder(
          stream: (((searchText.value != "" && searchText.value != null)
              ? FirebaseFirestore.instance
                  .collection('societies')
                  .doc(Constants.societyId)
                  .collection("business")
                  .where('type',
                      isGreaterThanOrEqualTo:
                          searchText.value.capitalizeFirst!.trim())
                  .where('type',
                      isLessThan:
                          searchText.value.capitalizeFirst!.trim() + 'z')
                  // .orderBy('createdOn', descending: true)
                  .limit(10)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('societies')
                  .doc(Constants.societyId)
                  .collection("business")
                  .orderBy('createdOn', descending: true)
                  .limit(20)
                  .snapshots())),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: LoadingAnimationWidget.waveDots(
                    color: AppTheme.lightText, size: 40),
              );
            } else {
              List<String> names = [];
              Map<String, List<Stores>> data = {};
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                Stores stores = Stores.fromSnap(snapshot.data!.docs[i]);
                if (data.containsKey(stores.type)) {
                  List<Stores> newValue = data[stores.type]!;
                  newValue.add(stores);
                  data[stores.type!] = newValue;
                } else {
                  names.add(stores.type!);
                  data[stores.type!] = [stores];
                }
              }

              return data.isEmpty
                  ? const Center(
                      child: Text(
                      "No business Available",
                      style: AppTheme.smallText,
                    ))
                  : ListView(
                      children: List<Widget>.generate(names.length, (i) {
                        List<Stores> temp = data[names[i]]!;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24, right: 24, bottom: 8, top: 16),
                              child: Text(
                                i == 0 ? names[i] : names[i - 1],
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
                                      Tween<double>(begin: 0.0, end: 1.0)
                                          .animate(
                                    CurvedAnimation(
                                      parent: animationController!,
                                      curve: Interval((1 / count) * index, 1.0,
                                          curve: Curves.fastOutSlowIn),
                                    ),
                                  );

                                  String userId =
                                      snapshot.data!.docs[index].data()['id'];
                                  animationController?.forward();
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
                                                  if (await launchUrl(
                                                      phoneno)) {
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
                                                backgroundColor: AppTheme
                                                    .lightBackgroundColor,
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
                                                padding:
                                                    const EdgeInsets.all(0),
                                                backgroundColor: AppTheme
                                                    .lightBackgroundColor,
                                              ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 24.0, top: 8, bottom: 8),
                                      child: CategoryView(
                                        index: index,
                                        snap: snapshot.data!.docs[index].data(),
                                        animation: animation,
                                        animationController:
                                            animationController,
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
    });
  }
}

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
                         snap["image"] != ''
                                    ? 0.heightBox:16.heightBox,
                         snap["image"] != ''
                                    ? Padding(
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
                                )
                              ),
                              //  Image.network(
                              //   snap!["image"] ?? "",
                              //   fit: BoxFit.cover,
                              // ), //'images/glimpselogo.png'),
                              // ),
                            ),
                          ),
                        ): SizedBox(),

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
