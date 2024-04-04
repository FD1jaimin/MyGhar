// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:textfield_datepicker/textfield_dateAndTimePicker.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/storage_method.dart';

class AmenitiesScreen extends StatefulWidget {
  const AmenitiesScreen({super.key});

  @override
  State<AmenitiesScreen> createState() => _NoticeState();
}

TextEditingController upiId = TextEditingController();

class _NoticeState extends State<AmenitiesScreen>
    with TickerProviderStateMixin {
  TextEditingController name = TextEditingController();

  TextEditingController price = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  String selectedPriceType = 'p/d';
  List<String> priceType = ["p/d", "p/m", 'other'];
  final _file = Uint8List(0).obs;
  String coverUrl = "";

  List<String> services = [];
  var selectedService = ''.obs;
  var checkedValue = false.obs;
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pickImage(ImageSource source) async {
      final ImagePicker imagePicker = ImagePicker();
      XFile? file0 = await imagePicker.pickImage(
          source: source, preferredCameraDevice: CameraDevice.rear);
      if (file0 != null) {
        return await file0.readAsBytes();
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

    // final UserData? userinfo = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: Constants.type == "admin"
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),

              // mini: true,
              backgroundColor: AppTheme.appColor,
              foregroundColor: Colors.white,
              onPressed: () {
                selectedService.value = "";
                checkedValue.value = false;
                showDialog(
                    barrierDismissible: false,
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
                                    'Add Amenities',
                                    style: AppTheme.subheading2,
                                    textAlign: TextAlign.center,
                                  ),
                                  14.heightBox,
                                  Obx(() {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                                                    color:
                                                        HexColorNew('#F8FAFB'),
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
                                        selectImage(context);
                                      }),
                                    );
                                  }),
                                  16.heightBox,
                                  CustomTextField(
                                      icon: const Icon(Icons.gite_rounded),
                                      isForm: true,
                                      keyboardType: TextInputType.name,
                                      hint: "Enter Amenity name",
                                      validator: (value) {
                                        return null;
                                      },
                                      textController: name),
                                  12.heightBox,
                                  CustomTextField(
                                      isForm: true,
                                      icon: const Icon(CupertinoIcons
                                          .arrow_left_right_square_fill),
                                      keyboardType: TextInputType.text,
                                      hint: "Enter receiver UPI id",
                                      validator: (value) {
                                        return null;
                                      },
                                      textController: upiId),
                                  4.heightBox,
                                  Text(
                                    "*NOTE: Please only add Merchant UPI IDs",
                                    style: AppTheme.smallText,
                                  ),
                                  12.heightBox,
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Obx(() {
                                            return CustomTextField(
                                                isForm: true,
                                                readOnly: checkedValue.value,
                                                icon: const Icon(Icons
                                                    .currency_rupee_rounded),
                                                keyboardType:
                                                    TextInputType.number,
                                                hint: "Est. Price",
                                                validator: (value) {
                                                  return null;
                                                },
                                                textController: price);
                                          })),
                                      12.widthBox,
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField2<String>(
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    171, 177, 186, 1),
                                                width: 2,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    171, 177, 186, 1),
                                                width: 2,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    171, 177, 186, 1),
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 18),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    171, 177, 186, 1),
                                                width: 2,
                                              ),
                                            ),
                                            // Add more decoration..
                                          ),
                                          hint: const Text(
                                            ' - ',
                                            style: AppTheme.smallText,
                                          ),
                                          items: priceType
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(item,
                                                        style: AppTheme
                                                            .subheading3),
                                                  ))
                                              .toList(),

                                          value: priceType[0],
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select mode';
                                            }
                                            return null;
                                          },
                                          // value: 'p/day',
                                          onChanged: (value) {
                                            selectedPriceType =
                                                value.toString();
                                            setState(() {});
                                            //Do something when selected item is changed.
                                          },
                                          onSaved: (value) {
                                            selectedPriceType =
                                                value.toString();
                                            setState(() {});
                                          },
                                          buttonStyleData:
                                              const ButtonStyleData(
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
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Obx(() {
                                    return Theme(
                                      data: ThemeData(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent),
                                      child: SizedBox(
                                        width: 150,
                                        child: Center(
                                          child: CheckboxListTile(
                                            dense: true,

                                            title: const Text(
                                              "is Free?",
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
                                                ? LoadingAnimationWidget
                                                    .waveDots(
                                                        color: Colors.white,
                                                        size: 40)
                                                : const Text(
                                                    'Add Amenity',
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
                                    if (!isLoading.value) {
                                      if (name.text != "" && (checkedValue.value == true ||  (checkedValue.value == false && price.text != ""))) {
                                        if (_file.value.isNotEmpty) {
                                          isLoading.value = true;

                                          String amenityID = const Uuid().v1();
                                          Uint8List compressed =
                                              await Constants.compressImage(
                                                  _file.value, 200, 200, 70);
                                          String profile =
                                              await StorageMethods()
                                                  .uploadImageToStorage(
                                                      'amenities',
                                                      compressed,
                                                      amenityID);
                                          FireStoreMethods().createAmenities(
                                            amenityId: amenityID,
                                            name: name.text,
                                            price: price.text,
                                            type: selectedPriceType,
                                            image: profile,
                                            isFree: checkedValue.value,
                                            upi: upiId.text.trim(),
                                          );

                                          isLoading.value = false;
                                          name.clear();
                                          _file.value = Uint8List(0);
                                          price.clear();
                                          serviceController.clear();
                                          Get.back();
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Please Select image");
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Please fill all the fields");
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Please wait");
                                    }
                                  }),
                                ]),
                          ),
                        ));

                // Respond to button press
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
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
                        "Select Amenities",
                        style:
                            AppTheme.subheading.copyWith(letterSpacing: -0.3),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('amenities')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: Text(
              "No Amenities Available",
              style: AppTheme.smallText,
            ));
          } else {
            if (snapshot.data!.docs.isNotEmpty) {
              if (upiId.text == "") {
                upiId.text = snapshot.data!.docs[0]['upi'];
              }
            }
            return snapshot.data!.docs.isEmpty
                ? const Center(
                    child: Text(
                    "No Amenities Available",
                    style: AppTheme.smallText,
                  ))
                : ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
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
                        return Slidable(
                          closeOnScroll: true,
                          enabled: true,
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                flex: 2,
                                onPressed: (context) {
                                  dynamic data =
                                      snapshot.data!.docs[index].data();

                                  FireStoreMethods().deleteAmenity(data["id"]);
                                },
                                icon: Icons.delete,
                                autoClose: true,
                                label: "Delete",
                                padding: const EdgeInsets.all(0),
                                backgroundColor: AppTheme.lightBackgroundColor,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: AmenityCard(
                              index: index,
                              // handyData: temp[index],
                              snap: snapshot.data!.docs[index].data(),
                              animation: animation,
                              animationController: animationController,
                            ),
                          ),
                        );
                      },
                    ));
          }
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class AmenityCard extends StatefulWidget {
  AmenityCard(
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
  // final Handymen? handyData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  State<AmenityCard> createState() => _AmenityCardState();
}

class _AmenityCardState extends State<AmenityCard> {
  var fromDate = TextEditingController().obs;

  var endDate = TextEditingController().obs;

  DateTime? from;

  DateTime? to;
  bool result = false;

  @override
  void initState() {
    result = Constants.getProbability(0.6);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => CustomDialog(
                              child: SizedBox(
                                // height: 340,
                                width: MediaQuery.of(context).size.width - 120,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      8.heightBox,
                                      Text(
                                        'Book ${widget.snap!['name']}',
                                        style: AppTheme.subheading2,
                                        textAlign: TextAlign.center,
                                      ),
                                      14.heightBox,
                                      const SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'From :',
                                            style: AppTheme.subheading3,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                      Obx(() {
                                        return TextfieldDateAndTimePicker(
                                          cupertinoDatePickerBackgroundColor:
                                              Colors.white,
                                          cupertinoDatePickerMaximumDate:
                                              DateTime(2099),
                                          cupertinoDatePickerMaximumYear: 2099,
                                          cupertinoDatePickerMinimumYear: 1990,
                                          cupertinoDatePickerMinimumDate:
                                              DateTime(1990),
                                          cupertinoDateInitialDateTime:
                                              DateTime.now(),
                                          materialDatePickerFirstDate:
                                              DateTime.now(),
                                          materialDatePickerInitialDate:
                                              DateTime.now(),
                                          materialDatePickerLastDate:
                                              DateTime(2099),
                                          preferredDateFormat:
                                              DateFormat.yMMMEd(),
                                          materialTimePickerUse24hrFormat:
                                              false,
                                          cupertinoTimePickerMinuteInterval: 1,
                                          cupertinoTimePickerUse24hFormat:
                                              false,
                                          textfieldDateAndTimePickerController:
                                              fromDate.value,
                                          materialInitialTime: TimeOfDay.now(),
                                          style: AppTheme.subheading3,
                                          onFieldSubmitted: (v) {
                                            fromDate.value.text = v;
                                          },
                                          onEditingComplete: () {},
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            hintStyle: AppTheme
                                                .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                            hintText: "Booking From",
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 18),

                                            errorStyle:
                                                AppTheme.smallText.copyWith(
                                              fontSize: 10,
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
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
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromARGB(
                                                    255,
                                                    105,
                                                    110,
                                                    116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                                width: 2,
                                              ),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    231, 236, 243, 1),
                                                width: 2,
                                              ),
                                            ),
                                            // focusColor: MyColors.resolveCompanyCOlour(),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    171, 177, 186, 1),
                                                width: 2,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: AppTheme.appColor,
                                                width: 2,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    231, 236, 243, 1),
                                                width: 2,
                                              ),
                                            ),

                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 26, right: 16),
                                              child: IconTheme(
                                                data: IconThemeData(
                                                    color: AppTheme.appColor
                                                        .withOpacity(0.8)),
                                                child: const Icon(
                                                    FontAwesomeIcons.calendar),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'To :',
                                            style: AppTheme.subheading3,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                      Obx(() {
                                        DateTime tempFrom =
                                            fromDate.value.text == ''
                                                ? DateTime.now()
                                                : DateFormat.yMMMEd()
                                                    .parse(fromDate.value.text);
                                        return TextfieldDateAndTimePicker(
                                          cupertinoDatePickerBackgroundColor:
                                              Colors.white,
                                          cupertinoDatePickerMaximumDate:
                                              DateTime(2099),
                                          cupertinoDatePickerMaximumYear: 2099,
                                          cupertinoDatePickerMinimumYear:
                                              fromDate.value.text == ''
                                                  ? 1990
                                                  : DateFormat.yMMMEd()
                                                      .parse(
                                                          fromDate.value.text)
                                                      .year,
                                          cupertinoDatePickerMinimumDate:
                                              fromDate.value.text == ''
                                                  ? DateTime(1990)
                                                  : DateTime(
                                                      tempFrom.year,
                                                      tempFrom.month,
                                                      tempFrom.day),
                                          cupertinoDateInitialDateTime:
                                              DateTime.now(),
                                          materialDatePickerFirstDate:
                                              DateTime.now(),
                                          materialDatePickerInitialDate:
                                              DateTime.now(),
                                          materialDatePickerLastDate:
                                              DateTime(2099),
                                          preferredDateFormat:
                                              DateFormat.yMMMEd(),
                                          materialTimePickerUse24hrFormat:
                                              false,
                                          cupertinoTimePickerMinuteInterval: 1,
                                          cupertinoTimePickerUse24hFormat:
                                              false,
                                          textfieldDateAndTimePickerController:
                                              endDate.value,
                                          materialInitialTime: TimeOfDay.now(),
                                          style: AppTheme.subheading3,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            hintStyle: AppTheme
                                                .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                            hintText: "Booking Till",
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 18),

                                            errorStyle:
                                                AppTheme.smallText.copyWith(
                                              fontSize: 10,
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
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
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromARGB(
                                                    255,
                                                    105,
                                                    110,
                                                    116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                                width: 2,
                                              ),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    231, 236, 243, 1),
                                                width: 2,
                                              ),
                                            ),
                                            // focusColor: MyColors.resolveCompanyCOlour(),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    171, 177, 186, 1),
                                                width: 2,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: AppTheme.appColor,
                                                width: 2,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    231, 236, 243, 1),
                                                width: 2,
                                              ),
                                            ),

                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 26, right: 16),
                                              child: IconTheme(
                                                data: IconThemeData(
                                                    color: AppTheme.appColor
                                                        .withOpacity(0.8)),
                                                child: const Icon(
                                                    FontAwesomeIcons.calendar),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      6.heightBox,
                                      // const Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Padding(
                                      //       padding:
                                      //           EdgeInsets.only(left: 16.0),
                                      //       child: Text(
                                      //         'Amount to pay :',
                                      //         style: AppTheme.subheading3,
                                      //         textAlign: TextAlign.start,
                                      //       ),
                                      //     ),
                                      //     Padding(
                                      //       padding:
                                      //           EdgeInsets.only(right: 16.0),
                                      //       child: Text(
                                      //         '₹ 0', //${snap["price"]}',
                                      //         style: AppTheme.subheading3,
                                      //         textAlign: TextAlign.start,
                                      //       ),
                                      //     )
                                      //   ],
                                      // ),
                                      // Obx(() {
                                      //       return Theme(
                                      //         data: ThemeData(
                                      //             splashColor: Colors.transparent,
                                      //             highlightColor: Colors.transparent),
                                      //         child: Container(
                                      //           width: 150,
                                      //           child: Center(
                                      //             child: CheckboxListTile(
                                      //               dense: true,

                                      //               title: Text(
                                      //                 "is Free?",
                                      //                 style: AppTheme.smallText,
                                      //               ),
                                      //               value: checkedValue.value,
                                      //               hoverColor: Colors.transparent,
                                      //               splashRadius: 0,
                                      //               overlayColor: MaterialStatePropertyAll(
                                      //                   Colors.white),

                                      //               onChanged: (newValue) {
                                      //                 checkedValue.value = newValue!;

                                      //                 setState(() {});
                                      //               },
                                      //               activeColor: AppTheme.appColor,
                                      //               controlAffinity: ListTileControlAffinity
                                      //                   .leading, //  <-- leading Checkbox
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       );
                                      //     }),
                                      12.heightBox,
                                      Container(
                                        height: 58,
                                        width: 188,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          color: AppTheme.buttonColor,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // isLoading.value ?
                                              // LoadingAnimationWidget.waveDots(
                                              //               color: Colors.white, size: 40)
                                              //          :
                                              Text(
                                                'Book',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).onTap(() async {
                                        // isLoading.value =true;
                                        DateTime from = DateFormat.yMMMEd()
                                            .parse(fromDate.value.text);
                                        DateTime to = DateFormat.yMMMEd()
                                            .parse(endDate.value.text);
                                        String amenityID = const Uuid().v1();

                                        FireStoreMethods().addBooking(
                                            amenityId: amenityID,
                                            from: from,
                                            to: to,
                                            upi: widget.snap['upi'],
                                            amount: widget.snap['price'],
                                            type: widget.snap['type'],
                                            name: widget.snap!["name"],
                                            imageUrl: widget.snap!["image"]);

                                        FireStoreMethods()
                                            .sendAdminNotification(
                                          amenityId: amenityID,
                                          title:
                                              "New Booking for ${widget.snap!['name']}",
                                          body:
                                              "${Constants.userData.firstName} wants to book ${widget.snap!['name']}\nFrom : ${DateFormat.MMMEd().add_jm().format(from)}\nTo : ${DateFormat.MMMEd().add_jm().format(to)}\nkindly approve their booking.",
                                          type: "newBooking",
                                        );
                                        if (Constants.showAd && result)
                                          Constants.showIntertitialAd();
                                        Fluttertoast.showToast(
                                            msg: "Booking send for Approval");
                                        // isLoading.value=false;
                                        fromDate.value.clear();
                                        endDate.value.clear();
                                        Get.back();
                                      }),
                                    ]),
                              ),
                            ));
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                20.widthBox,
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: const Offset(0, 0),
                                          blurRadius: 8,
                                          color: AppTheme.appColor
                                              .withOpacity(0.1))
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: const BoxDecoration(),
                                      width: 54,
                                      height: 54,
                                      child: Image.network(
                                        widget.snap!["image"] ?? "",
                                        fit: BoxFit.cover,
                                      ), //'images/glimpselogo.png'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16, bottom: 0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// name
                                        4.heightBox,
                                        Text(widget.snap!["name"],
                                            style: AppTheme.subheading2),

                                        8.heightBox,

                                        /// number
                                        widget.snap!["isFree"]
                                            ? Text(
                                                widget.snap!["isFree"]
                                                    ? "Free"
                                                    : widget.snap!["price"] +
                                                        " " +
                                                        widget.snap!["type"],
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTheme.smallText,
                                              )
                                            : Row(
                                              
                                                children: [
                                                  Text(
                                                      widget.snap!["isFree"]
                                                        ? ""
                                                        : "Est. ",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTheme.smallText,
                                                  ),
                                                  const Icon(
                                                    Icons.currency_rupee_sharp,
                                                    size: 14,
                                                  ),
                                                  Text(
                                                      widget.snap!["isFree"]
                                                        ? "Free"
                                                        : widget.snap![
                                                                "price"] +
                                                            " " +
                                                            widget
                                                                .snap!["type"],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTheme.smallText,
                                                  ),
                                                ],
                                              ),

                                        16.heightBox,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: Text(
                                widget.snap!["isFree"] ? "FREE" : "PAID",
                                style: AppTheme.smallText.copyWith(
                                    color: widget.snap!["isFree"]
                                        ? Colors.green[400]
                                        : Colors.orange[400]),
                              ),
                            )
                          ],
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

  dateTimePickerWidget(BuildContext context) {
    return DatePicker.showDatePicker(
      context,
      dateFormat: 'dd MMMM yyyy HH:mm',
      initialDateTime: DateTime.now(),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(3000),
      onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime, List<int> index) {},
    );
  }
}
