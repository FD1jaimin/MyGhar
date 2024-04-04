import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urbannest/core/notification_method.dart';
import 'package:urbannest/models/helpdesk.dart';
import 'package:urbannest/widgets/dialog.dart';
import '../core/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/storage_method.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import '../widgets/floating_action_button.dart';
import '../widgets/topbar.dart';
import 'notice_screen.dart';

class HelpDeskScreen extends StatefulWidget {
  const HelpDeskScreen({super.key});

  @override
  State<HelpDeskScreen> createState() => _HelpDeskScreenState();
}

class _HelpDeskScreenState extends State<HelpDeskScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  var coverUrl = ''.obs;
  var isLoading = false.obs;
  final _file = Uint8List(0).obs;
  String houseHoldcoverUrl = "";
  bool isediting = true;
  bool isIssue = false;
  TextEditingController helpDesController = TextEditingController();
  TextEditingController helpTitleController = TextEditingController();
  List allResult = [];

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
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  file = (await Constants.compressImage(file!, 300, 300, 50));
                  setState(() {
                    _file.value = file!;
                  });
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
                  file = (await Constants.compressImage(file!, 300, 300, 50));
                  setState(() {
                    _file.value = file!;
                  });
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
      floatingActionButton: CustomFloatingActionButton(
        onTap: () {
          _addHelpDeskPopUp(context);
        },
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const CreateTopBar(title: "Help Desk"), helpDeskList()],
      )),
    );
  }

  Expanded helpDeskList() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection("helpDesk")
            .orderBy("createdOn", descending: true)
            .limit(10)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            List<HelpDesk> data = [];

            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              HelpDesk userVisitor = HelpDesk.fromSnap(snapshot.data!.docs[i]);

              data.add(userVisitor);
            }

            return data.isEmpty
                ? const Center(
                    child: Text(
                    "No Ticket Raised",
                    style: AppTheme.smallText,
                  ))
                : ListView(
                    padding: const EdgeInsets.all(0),
                    children: List<Widget>.generate(
                      data.length,
                      (int index) {
                        final int count = data.length;
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
                          enabled: Constants.userId == data[index].uid
                              ? true
                              : false,
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                flex: 2,
                                onPressed: (context) {
                                  FireStoreMethods()
                                      .deleteHelpDesk(data[index].id!);
                                },
                                icon: Icons.delete,
                                autoClose: true,
                                label: "Delete",
                                padding: const EdgeInsets.all(12),
                                backgroundColor: AppTheme.lightBackgroundColor,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            child: HelpDeskAnimation(
                              index: index,
                              helpDeskData: data[index],
                              animation: animation,
                              animationController: animationController,
                            ),
                          ),
                        );
                      },
                    ),
                  );
          }
        },
      ),
    );
  }

  Future<dynamic> _addHelpDeskPopUp(
    BuildContext context,
  ) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomDialog(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    8.heightBox,
                    const Text(
                      'Raise Issue',
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
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(0, 0),
                                  blurRadius: 8,
                                  color: AppTheme.appColor.withOpacity(0.1))
                            ],
                          ),
                          width: 124,
                          height: 124,
                          child: _file.value.isEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: HexColorNew('#F8FAFB'),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(
                                    FontAwesomeIcons.images,
                                    color: AppTheme.lightText,
                                    size: 34,
                                  ))
                              : Image.memory(
                                  _file.value,
                                  fit: BoxFit.cover,
                                ),
                        ).onTap(() {
                          _selectHouseHoldImage(context);
                        }),
                      );
                    }),
                    16.heightBox,
                    CustomTextField(
                      // icon: const Icon(Icons.report_rounded),
                      isForm: true,
                      keyboardType: TextInputType.name,
                      hint: 'Issue Title',
                      validator: (value) {
                        return null;
                      },
                      textController: helpTitleController,
                    ),
                    12.heightBox,
                    CustomTextField(
                      isForm: true,
                      keyboardType: TextInputType.name,
                      maxLines: 3,
                      minLines: 3,
                      hint: "Issue Description",
                      validator: (value) {
                        return null;
                      },
                      textController: helpDesController,
                    ),
                    12.heightBox,
                    Container(
                      height: 58,
                      width: 188,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: const Color(0xff132137),
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
                                      'Send',
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
                        if (helpTitleController.text != "" &&
                            helpDesController.text != "") {
                          String memberId = const Uuid().v1();
                          String profile = '';

                          isLoading.value = true;
                          if (_file.value.isNotEmpty) {
                            Uint8List compress = await Constants.compressImage(
                                _file.value, 200, 200, 60);
                            String profileCompress = await StorageMethods()
                                .uploadImageToStorage(
                                    'helpDesk', compress, memberId);
                            setState(() {
                              profile = profileCompress;
                            });
                          }

                          String helpDeskID = const Uuid().v1();
                          String res = await FireStoreMethods().addHelpDesk(
                              helpDeskId: helpDeskID,
                              title: helpTitleController.text,
                              des: helpDesController.text,
                              amount: "0",
                              name: Constants.userData.firstName,
                              number: Constants.userData.phone,
                              token: Constants.userData.token,
                              imageUrl: profile);
                          if (res == "success") {
                            await NotificationMethods().sendNotificationTopics(
                                to: '/topics/guard-${Constants.societyId}',
                                title:  "New Issue has been raised by ${Constants.userData.firstName}",
                                body:  helpTitleController.text,
                                type: 'helpdesk');
                            await NotificationMethods().sendNotificationTopics(
                                to: '/topics/admin-${Constants.societyId}',
                                title: "New Issue has been raised by ${Constants.userData.firstName}",
                                body: helpTitleController.text,
                                type: 'helpdesk');
                          }


                          isLoading.value = false;
                          Get.back();
                          _file.value = Uint8List(0);
                          helpTitleController.clear();
                          helpDesController.clear();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please fill all the fields");
                        }
                      } else {
                        Fluttertoast.showToast(msg: "Please wait");
                      }
                      // if (!isLoading.value) {
                      //   if (helpTitleController.text != "" &&
                      //       helpDesController.text != "") {
                      //     String memberId = const Uuid().v1();
                      //     String profile = "";
                      //     if (_file.value != Uint8List(0)) {
                      //     isLoading.value = true;
                      //       Uint8List compress = await Constants.compressImage(
                      //           _file.value, 200, 200, 60);
                      //       profile = await StorageMethods()
                      //           .uploadImageToStorage(
                      //               'helpDesk', compress, memberId);
                      //     }

                      //     String helpDeskID = const Uuid().v1();
                      //     String res = await FireStoreMethods().addHelpDesk(
                      //         helpDeskId: helpDeskID,
                      //         title: helpTitleController.text,
                      //         des: helpDesController.text,
                      //         amount: "0",
                      //         name: Constants.userData.firstName,
                      //         number: Constants.userData.phone,
                      //         token: Constants.userData.token,
                      //         imageUrl: profile);
                      //     if (res == "success") {
                      //       await NotificationMethods().sendNotificationTopics(
                      //           to: '/topics/guard-${Constants.societyId}',
                      //           title:  "New Issue has been raised by ${Constants.userData.firstName}",
                      //           body:  helpTitleController.text,
                      //           type: 'helpdesk');
                      //       await NotificationMethods().sendNotificationTopics(
                      //           to: '/topics/admin-${Constants.societyId}',
                      //           title: "New Issue has been raised by ${Constants.userData.firstName}",
                      //           body: helpTitleController.text,
                      //           type: 'helpdesk');
                      //     }

                      //     isLoading.value = false;
                      //     Get.back();
                      //     _file.value = Uint8List(0);
                      //     helpTitleController.clear();
                      //     helpDesController.clear();
                      //   } else {
                      //     Fluttertoast.showToast(
                      //         msg: "Please fill all the details");
                      //   }
                      // } else {
                      //   Fluttertoast.showToast(
                      //       msg: "Please fill all the details");
                      // }
                    }),
                  ],
                ),
              ),
            ));
  }
}

// ignore: must_be_immutable
class HelpDeskAnimation extends StatelessWidget {
  const HelpDeskAnimation(
      {Key? key,
      this.index,
      this.helpDeskData,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final int? index;
  final VoidCallback? callback;
  final HelpDesk? helpDeskData;
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: HelpDeskCard(
                    context,
                    helpDeskData: helpDeskData,
                  )).onTap(() {}),
            ),
          ),
        );
      },
    );
  }
}

class HelpDeskCard extends StatelessWidget {
  const HelpDeskCard(
    this.context, {
    this.helpDeskData,
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final HelpDesk? helpDeskData;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 34, bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              helpDeskData!.title!,
                              style: AppTheme.subheading,
                              maxLines: 1,
                            ),
                            SizedBox(
                              // width: MediaQuery.of(context).size.width /2.1,
                              child: Text(
                                helpDeskData!.des!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: AppTheme.smallText,
                              ),
                            ),
                            6.heightBox,
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: const Offset(0, 0),
                                        blurRadius: 8,
                                        color:
                                            AppTheme.appColor.withOpacity(0.1))
                                  ],
                                ),
                                // width: 84,
                                // height: 84,
                                child: helpDeskData!.image == ""? SizedBox(): Image.network(
                                  helpDeskData!.image ?? "",
                                  fit: BoxFit.cover,
                                ), //'images/glimpselogo.png'),
                              ),
                            ),
                            12.widthBox,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                4.heightBox,
                                4.heightBox,
                              ],
                            ),
                          ],
                        ),
                      ),
                      12.heightBox,
                      MySeparator(
                        color: AppTheme.lightText.withOpacity(0.4),
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Text(
                          "Ticket Raised By : ${helpDeskData!.name!}",
                          style: AppTheme.smallText,
                        ),
                      ),
                      helpDeskData!.status != 'Solved' &&
                              Constants.type == "admin"
                          ? Center(
                              child: CustomButton(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('societies')
                                        .doc(Constants.societyId)
                                        .collection("helpDesk")
                                        .doc(helpDeskData!.id!)
                                        .update({
                                      'status': "Solved",
                                    });

                                    await NotificationMethods()
                                        .sendNotificationIndividual(
                                            targetId: helpDeskData!.token,
                                            targetUID: helpDeskData!.uid,
                                            title: "Issue Resolved",
                                            body:
                                                "The issue raised by you : ${helpDeskData!.title} has been resolved.",
                                            type: 'helpdesk');
                                  },
                                  height: 54,
                                  width: 188,
                                  text: "Issue Solved"),
                            )
                          : const SizedBox(),
                      helpDeskData!.status != 'Solved' &&
                              Constants.type == "admin"
                          ? 12.heightBox
                          : 0.heightBox,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          color: helpDeskData!.status! == "Solved"
                              ? Colors.green[400]
                              : Colors.orange[400]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Text(
                          "  ${helpDeskData!.status!}  ",
                          style: AppTheme.smallText
                              .copyWith(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
