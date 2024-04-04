// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/storage_method.dart';
import 'package:urbannest/models/handymen.dart';
import 'package:urbannest/views/gallery_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/user_provider.dart';
import '../models/user.dart' as model;

class HandymenScreen extends StatefulWidget {
  const HandymenScreen({super.key});

  @override
  State<HandymenScreen> createState() => _NoticeState();
}

class _NoticeState extends State<HandymenScreen> with TickerProviderStateMixin {
  TextEditingController name = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController serviceController = TextEditingController();

  List<String> services = [];
  var selectedService = ''.obs;
  var checkedValue = false.obs;
  var isLoading = false.obs;
  final _file = Uint8List(0).obs;
  @override
  void initState() {
    super.initState();
  }

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
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: userinfo!.type == "admin"
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),

              // mini: true,
              backgroundColor: AppTheme.appColor,
              foregroundColor: Colors.white,
              onPressed: () {
                selectedService.value = "";
                checkedValue.value = false;
                _file.value = Uint8List(0);
                name.clear();
                number.clear();
                serviceController.clear();
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
                                  'Add Handymen',
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
                                      width: 124,
                                      height: 124,
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
                                      _selectImage(context);
                                    }),
                                  );
                                }),
                                16.heightBox,

                                CustomTextField(
                                    icon: const Icon(Icons.person),
                                    isForm: true,
                                    keyboardType: TextInputType.name,
                                    hint: "Enter Handyman name",
                                    validator: (value) {
                                      return null;
                                    },
                                    textController: name),
                                12.heightBox,
                                CustomTextField(
                                    isForm: true,
                                    maxLength: 10,
                                    icon: const Icon(Icons.phone),
                                    keyboardType: TextInputType.number,
                                    hint: "Enter Handyman number",
                                    validator: (value) {
                                      return null;
                                    },
                                    textController: number),
                                6.heightBox,

                                StreamBuilder(
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
                                      List<String> data = ["Add new ",];
                                      data.add('Maid');
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
                                                hint: "Enter Handyman Service",
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
                                                  'Handyman Service',
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
                                // 12.heightBox,
                                Obx(() {
                                  return Theme(
                                    data: ThemeData(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent),
                                    child: SizedBox(
                                      width: 180,
                                      height: 40,
                                      child: Center(
                                        child: CheckboxListTile(
                                          dense: true,

                                          title: const Text(
                                            "is Inhouse?",
                                            style: AppTheme.smallText,
                                          ),
                                          value: checkedValue.value,
                                          hoverColor: Colors.transparent,
                                          splashRadius: 0,
                                          overlayColor:
                                              const MaterialStatePropertyAll(
                                                  Colors.white),

                                          onChanged: (newValue) {
                                            checkedValue.value = newValue!;
                                            setState(() {});
                                          },
                                          activeColor: AppTheme.appColor,
                                          controlAffinity: ListTileControlAffinity
                                              .leading, //  <-- leading Checkbox
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                6.heightBox,
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
                                                  'Add Handyman',
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
                                    if (_file.value.isNotEmpty &&
                                        name.text != '' &&
                                        number.text != '' &&
                                        ((selectedService.value == "Add new " &&
                                                serviceController.text != '') ||
                                            selectedService.value !=
                                                "Add new ") && selectedService.value !="") {
                                      isLoading.value = true;
                                      String handymanId = const Uuid().v1();
                                      _file.value =
                                          await Constants.compressImage(
                                              _file.value, 200, 200, 70);
                                      String profile = await StorageMethods()
                                          .uploadImageToStorage('Handymen',
                                              _file.value, handymanId);
                                      FireStoreMethods().createHandymen(
                                        name: name.text,
                                        number: number.text,
                                        handymenId: handymanId,
                                        inHouse: checkedValue.value,
                                        image: profile,
                                        type:
                                            selectedService.value == "Add new "
                                                ? serviceController.text
                                                : selectedService.value,
                                      );

                                      isLoading.value = false;
                                      name.clear();
                                      number.clear();
                                      serviceController.clear();
                                      Get.back();
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Please fill all the fields");
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Please add image");
                                  }
                                }),
                              ],
                            ),
                          ),
                        ));

                // Respond to button press
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 16.8, left: 16),
                    child: Text(
                      "Handymen",
                      style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ],
              )),
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
    final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('handymen')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            List<String> names = [];
            Map<String, List<Handymen>> data = {};
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              Handymen handyman = Handymen.fromSnap(snapshot.data!.docs[i]);
              if (data.containsKey(handyman.type)) {
                List<Handymen> newValue = data[handyman.type]!;
                newValue.add(handyman);
                data[handyman.type!] = newValue;
              } else {
                names.add(handyman.type!);
                data[handyman.type!] = [handyman];
              }
            }

            return data.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Center(
                        child: Text(
                      "No Handymen Available",
                      style: AppTheme.smallText,
                    )),
                  )
                : ListView(
                    children: List<Widget>.generate(names.length, (i) {
                      List<Handymen> temp = data[names[i]]!;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 24, right: 24, bottom: 8, top: 16),
                            child: Text(
                              names[i],
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
                                  enabled: true,
                                  endActionPane: ActionPane(
                                    extentRatio:
                                        userinfo!.type == "admin" ? 0.35 : 0.24,
                                    motion: const StretchMotion(),
                                    children: userinfo.type == "admin"
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
                                                    .deleteHandymen(
                                                        temp[index].id!);
                                              },
                                              icon: Icons.delete,
                                              autoClose: true,
                                              label: "Delete",
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
                                    child: HandyMenTile(
                                      index: index,
                                      handyData: temp[index],
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

class HandyMenTile extends StatelessWidget {
  const HandyMenTile(
      {Key? key,
      this.snap,
      this.index,
      this.handyData,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final snap;
  final int? index;
  final VoidCallback? callback;
  final Handymen? handyData;
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          24.widthBox,
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
                                width: 64,
                                height: 64,
                                child: CachedNetworkImage(
                                  imageUrl: handyData!.image ?? "",
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const skeleton(
                                    height: 64,
                                    width: 64,
                                    colors: Colors.white,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const skeleton(
                                    height: 64,
                                    width: 64,
                                    colors: Colors.white,
                                  ),
                                ), //'images/glimpselogo.png'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 0),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// name
                                  4.heightBox,
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: Text(
                                      handyData!.name!,
                                      style: AppTheme.subheading2,
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: Text(
                                      handyData!.type!,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.smallText,
                                      maxLines: 1,
                                    ),
                                  ),
                                  8.heightBox,

                                  /// number
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.call_rounded,
                                          color: Colors.green[400],
                                          size: 20,
                                        ),
                                        8.widthBox,
                                        Text(
                                          handyData!.number!,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.heading2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 8.heightBox,
                                  // Row(
                                  //   children: [
                                  //     const Icon(
                                  //       Icons.call_rounded,
                                  //       size: 20,
                                  //     ),
                                  //     8.widthBox,
                                  //     Text(
                                  //       handyData!.!,
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
                                  //         handyData!.type!,
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
                )),
          ),
        );
      },
    );
  }
}
