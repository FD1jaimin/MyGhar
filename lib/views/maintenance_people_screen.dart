// ignore_for_file: curly_braces_in_flow_control_structures, depend_on_referenced_packages, must_be_immutable, library_private_types_in_public_api, prefer_typing_uninitialized_variables, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:printing/printing.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/models/maintenance.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/views/chats/chat.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/profile_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/notification_method.dart';
import '../core/storage_method.dart';
import '../widgets/text_fields.dart';

class MaintenanceMemberScreen extends StatefulWidget {
  const MaintenanceMemberScreen({super.key, required this.maintenanceData});
  final Maintenance maintenanceData;

  @override
  State<MaintenanceMemberScreen> createState() => _NoticeState();
}

var _file = Uint8List(0).obs;

class _NoticeState extends State<MaintenanceMemberScreen>
    with TickerProviderStateMixin {
  final List<pw.Widget> dataMaintenance = [];
  bool isPdfGenerated = false;
  pw.Document pdf = pw.Document();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  final TextEditingController date = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool isFirst = true;
  late TabController pageController;

  @override
  void initState() {
    pageController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 0, bottom: 16, left: 24, right: 24),
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
                        "Members",
                        style:
                            AppTheme.subheading.copyWith(letterSpacing: -0.3),
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
                            style: AppTheme.smallText
                                .copyWith(color: Colors.black87)),
                      ],
                    )).onTap(() async {
                  if (isFirst) {
                    isFirst = false;
                    final data = await entryData();
                    await generateAndShowPDF(widget.maintenanceData, data!);
                    isPdfGenerated = true;
                    isFirst = true;
                  } else {
                    Fluttertoast.showToast(msg: "Please wait!");
                  }
                })
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: getMembersList(widget.maintenanceData),
            ),
          )
        ],
      )),
    );
  }

  Future<List<UserData>?> entryData() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('societyId', isEqualTo: Constants.societyId)
        .where('houseOwner', isEqualTo: true)
        //.where('type', isNotEqualTo: "guard")
        .get();

    final data = querySnapshot.docs.map((doc) {
      //final map = doc.data() as Map<String, dynamic>;
      return UserData.fromSnap(doc);
    }).toList();

    return data;
  }

  Future<void> generateAndShowPDF(
    Maintenance maintenanceData,
    List<UserData> entryData,
  ) async {
    final pdf = await generatePdf(entryData, maintenanceData);
    Printing.layoutPdf(onLayout: (PdfPageFormat format) {
      return pdf.save();
    });
  }

  Future<pw.Document> generatePdf(
      List<UserData> entryData, Maintenance maintenanceData) async {
    for (int i = 0; i < entryData.length; i++) {
      List<dynamic> isPaidArray = maintenanceData.isPaidArray!;

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
                width: 70,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(entryData[i].firstName.toString(),
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 80,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(0),
                  child: pw.Text(entryData[i].phone.toString(),
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
                  child: pw.Text(entryData[i].house.toString(),
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
                  child: pw.Text(entryData[i].block.toString(),
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
                      maintenanceData.isPaidArray!.contains(entryData[i].house)
                          ? "Paid"
                          : "UnPaid",
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ),
            ),
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
      pw.TextStyle smallText =
          pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
      String dueDate = DateFormat.yMMMEd().format(maintenanceData.dueDate);
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 10),
                  pw.Text("Maintenance Sheet",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 25),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Society Name: ${Constants.userData.societyName}'),
                          pw.Text('Due Date: $dueDate'),
                        ],
                      ),
                      pw.Text('Amount of pay: ${maintenanceData.amount}'),
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
                            child: pw.Text("No.", style: smallText),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 70,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text('Name', style: smallText),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 80,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text("Number", style: smallText),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 50,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("House", style: smallText),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 50,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("Block", style: smallText),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.SizedBox(
                          width: 50,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(0),
                            child: pw.Text("Status", style: smallText),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.SizedBox(height: 15),
                  pw.Column(children: docList[i]),
                  pw.SizedBox(height: 5),
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      );
    }

    isPdfGenerated = true;
    return pdf;
  }

  Widget getMembersList(Maintenance maintenanceData) {
    return MyMembersList(maintenanceData);
  }
}

class MyMembersList extends StatefulWidget {
  const MyMembersList(this.maintenanceData, {super.key});
  final Maintenance maintenanceData;
  @override
  _MyMembersListState createState() => _MyMembersListState();
}

class _MyMembersListState extends State<MyMembersList>
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
            .collection('users')
            .where('societyId', isEqualTo: Constants.societyId)
            .where('houseOwner', isEqualTo: true)
            .orderBy('block')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: LoadingAnimationWidget.waveDots(
                  color: AppTheme.lightText, size: 40),
            );
          } else {
            List<String> names = [];
            Map<String, List<UserData>> data = {};
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              UserData user = UserData.fromSnap(snapshot.data!.docs[i]);
              if (data.containsKey(user.block)) {
                List<UserData> newValue = data[user.block]!;
                newValue.add(user);
                data[user.block!] = newValue;
              } else {
                if (snapshot.data!.docs[i]['block'] != "" &&
                    snapshot.data!.docs[i]['type'] == "user") continue;
                names.add(user.block!);
                data[user.block!] = [user];
              }
            }
            // List<UserData> data = [];
            // for (int i = 0; i < snapshot.data!.docs.length; i++) {
            //   UserData member = UserData.fromSnap(snapshot.data!.docs[i]);
            //   data.add(member);
            // }

            return data.isEmpty
                ? const Center(
                    child: Text(
                    "No members found",
                    style: AppTheme.smallText,
                  ))
                : ListView(
                    padding: const EdgeInsets.all(0),
                    children: List<Widget>.generate(
                      names.length,
                      (int i) {
                        List<UserData> temp = data[names[i]]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            names[i] == "zzzzz"
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24,
                                        right: 24,
                                        bottom: 8,
                                        top: 16),
                                    child: Text(
                                      names[i] == "zzzzz" ? "Others" : names[i],
                                      style: AppTheme.subheading,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                            names[i] == "zzzzz"
                                ? const SizedBox()
                                : ListView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: List<Widget>.generate(temp.length,
                                        (int index) {
                                      final int count = temp.length;
                                      final Animation<double> animation =
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: animationController!,
                                          curve: Interval(
                                              (1 / count) * index, 1.0,
                                              curve: Curves.fastOutSlowIn),
                                        ),
                                      );
                                      animationController?.forward();
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 24.0),
                                        child: CategoryView(
                                          index: index,
                                          maintenanceData:
                                              widget.maintenanceData,
                                          memberData: temp[index],
                                          snap:
                                              snapshot.data!.docs[index].data(),
                                          animation: animation,
                                          animationController:
                                              animationController,
                                        ),
                                      );
                                    }),
                                  )
                          ],
                        );
                      },
                    ),
                  );
          }
        },
      ),
    );
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key? key,
      this.snap,
      this.index,
      this.memberData,
      this.animationController,
      this.animation,
      this.maintenanceData,
      this.callback})
      : super(key: key);

  final snap;
  final int? index;
  final VoidCallback? callback;
  final UserData? memberData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final Maintenance? maintenanceData;

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
              child: MemberCard(context,
                      data: memberData!, maintenanceData: maintenanceData)
                  .onTap(() {
                showDialog(
                  context: context,
                  builder: (context) => Center(
                      child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: MemberPopUp(
                      context,
                      data: memberData!,
                    ),
                  )),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class MemberPopUp extends StatelessWidget {
  const MemberPopUp(
    this.context, {
    required this.data,
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final UserData data;
  @override
  Widget build(BuildContext context) {
    TextEditingController nameContoller = TextEditingController();
    List<String> people = ["1 - 2", "3 - 5", "5 +"];
    String selectedPeople = '';
    String imageUrl = '';
    var type = 'user'.obs;
    type.value = data.type!;
    // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Obx(() {
        return _file.value.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    24.heightBox,
                    ClipRRect(
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
                        width: 144,
                        height: 144,
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
                              ), //'images/glimpselogo.png'),
                      ),
                    ),
                    20.heightBox,
                    Material(
                      color: Colors.white,
                      child: CustomTextField(
                          icon: const Icon(Icons.person),
                          isForm: true,
                          keyboardType: TextInputType.name,
                          hint: "Enter Guest Name",
                          validator: (value) {
                            return null;
                          },
                          textController: nameContoller),
                    ),
                    12.heightBox,
                    Material(
                      color: Colors.white,
                      child: DropdownButtonFormField2<String>(
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
                          'Number of People',
                          style: AppTheme.smallText,
                        ),
                        items: people
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child:
                                      Text(item, style: AppTheme.subheading3),
                                ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select number of people';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          selectedPeople = value.toString();
                          // setState(() {});
                          //Do something when selected item is changed.
                        },
                        onSaved: (value) {
                          selectedPeople = value.toString();
                          // setState(() {});
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
                      ),
                    ),
                    // 12.heightBox,
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 12, bottom: 24),
                      child: Container(
                        height: 54,
                        width: 112,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: AppTheme.buttonColor,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            // NotificationMethods().sendGuardAskNotification(
                            //     imageUrl,
                            //     nameContoller.text,
                            //     selectedPeople,
                            //     data.token);
                            imageUrl = "";
                            _file.value = Uint8List(0);
                            nameContoller.clear();

                            Get.back();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "ASK",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                12.widthBox,
                                const Icon(
                                  Icons.announcement,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  24.heightBox,
                  GestureDetector(
                    onTap: () {
                      // user_card(userinfo == null
                      //     ? user!.displayName ?? "Newbie"
                      //     : userinfo.firstName ?? "Newbie");
                    },
                    // onTap: () => Get.to(ProfilePage()),
                    child: ProfileAvatar(
                      uid: data.uid,
                      height: 70,
                      data: data,
                      width: 70,
                    ),
                  ),
                  12.heightBox,
                  Text(data.firstName, style: AppTheme.subheading2),
                  6.heightBox,
                  Obx(() {
                    return type.value == "user" && Constants.type != "admin"
                        ? const SizedBox()
                        : Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: type.value == "member"
                                  ? Colors.orangeAccent.withOpacity(0.1)
                                  : type.value == "guard"
                                      ? const Color.fromARGB(255, 30, 99, 160)
                                          .withOpacity(0.1)
                                      : AppTheme.appColor.withOpacity(0.1),
                              border: Border.all(
                                  color: type.value == "member"
                                      ? Colors.orangeAccent.withOpacity(0.4)
                                      : type.value == "guard"
                                          ? const Color.fromARGB(
                                                  255, 30, 99, 160)
                                              .withOpacity(0.4)
                                          : AppTheme.appColor.withOpacity(0.4),
                                  width: 2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Center(
                                child: Text(
                                    type.value == "member"
                                        ? "Member"
                                        : type.value == "guard"
                                            ? "Guard"
                                            : "Chairman",
                                    style: AppTheme.smallText.copyWith(
                                        color: type.value == "member"
                                            ? Colors.orangeAccent
                                            : type.value == "guard"
                                                ? const Color.fromARGB(
                                                    255, 30, 99, 160)
                                                : AppTheme.appColor)),
                              ),
                            ),
                          );
                  }),
                  data.type == "user" || data.type == "guard"
                      ? 0.heightBox
                      : 8.heightBox,
                  data.type == "user" || data.type == "guard"
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.lightBackgroundColor,
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
                                        data.societyName!,
                                        style: AppTheme.smallText,
                                        textAlign: TextAlign.center,
                                      ))
                                ],
                              ),
                              Container(
                                width: 2,
                                height: 52,
                                decoration: BoxDecoration(
                                    color: AppTheme.lightText.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.lightBackgroundColor,
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
                                        data.house!,
                                        style: AppTheme.smallText,
                                        textAlign: TextAlign.center,
                                      ))
                                ],
                              ),
                              Container(
                                width: 2,
                                height: 52,
                                decoration: BoxDecoration(
                                    color: AppTheme.lightText.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.lightBackgroundColor,
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
                                        data.block!,
                                        style: AppTheme.smallText,
                                        textAlign: TextAlign.center,
                                      ))
                                ],
                              )

                              // Image.asset(data.icon),
                            ],
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (Constants.type == "member" ||
                                    Constants.type == "user") &&
                                data.type != 'admin' &&
                                data.type != 'guard'
                            ? const SizedBox()
                            : Container(
                                height: 54,
                                width: 112,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: AppTheme.buttonColor,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    Uri phoneno =
                                        Uri.parse('tel:+919106390823');
                                    if (await launchUrl(phoneno)) {
                                      //dialer opened
                                    } else {
                                      //dailer is not opened
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Call",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        12.widthBox,
                                        const Icon(
                                          CupertinoIcons.phone,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        Constants.type == 'guard'
                            ? Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Container(
                                  height: 54,
                                  width: 112,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: AppTheme.buttonColor,
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      _file.value =
                                          await pickImage(ImageSource.camera);
                                      _file.value =
                                          await compressImage(_file.value);
                                      String guestID = const Uuid().v1();
                                      imageUrl = await StorageMethods()
                                          .uploadImageToStorage('amenities',
                                              _file.value, guestID);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "ASK",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          12.widthBox,
                                          const Icon(
                                            Icons.announcement,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        Constants.type == "guard" ||
                                Constants.type == "user" ||
                                data.type! == "guard" ||
                                data.type == "user"
                            ? 0.widthBox
                            : 12.widthBox,
                        Constants.type == "guard" ||
                                Constants.type == "user" ||
                                data.type! == "guard" ||
                                data.type == "user"
                            ? const SizedBox()
                            : CustomButton(
                                onTap: () {
                                  types.User chatUser =
                                      Constants.changeUserChat(
                                          Constants.userData);

                                  _handlePressed(chatUser, context);
                                },
                                height: 54,
                                width: 112,
                                text: "Chat",
                                iconData: CupertinoIcons.chat_bubble_2),
                      ],
                    ),
                  ),
                ],
              );
      }),
    );
  }

  void _handlePressed(types.User otherUser, BuildContext context) async {
    final navigator = Navigator.of(context);
    types.Room data =
        types.Room(id: '', type: types.RoomType.direct, users: []);
    await FirebaseFirestore.instance
        .collection('rooms')
        .where('type', isEqualTo: 'direct')
        .where('userIds', arrayContains: otherUser.id)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> newdata = (doc.data());
        if ((newdata['userIds'][0] == otherUser.id &&
                newdata['userIds'][1] == Constants.userId) ||
            (newdata['userIds'][1] == otherUser.id &&
                newdata['userIds'][0] == Constants.userId)) {
          // doc.data()['createdAt'] = 1;
          types.User chatUser = Constants.changeUserChat(Constants.userData);
          data = types.Room(
            id: doc.id,
            type: types.RoomType.direct,
            users: [otherUser, chatUser],
          );

          break;
        }
      }
    });

    navigator.pop();
    if (data.id == "") {
      final room = await FirebaseChatCore.instance.createRoom(otherUser);
      print('create rooommmmm');
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            room: room,
          ),
        ),
      );
    } else {
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            room: data,
          ),
        ),
      );
    }
  }

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
  }

  Future<Uint8List> compressImage(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 450,
      minWidth: 450,
      quality: 60,
    );
    return result;
  }
}

class MemberCard extends StatefulWidget {
  MemberCard(
    this.context, {
    required this.data,
    this.maintenanceData,
    this.subtitle = "",
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final Maintenance? maintenanceData;
  final UserData data;
  String subtitle;

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> isPaidArray = widget.maintenanceData!.isPaidArray!;
    //if (subtitle == "") subtitle = data.email;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                16.widthBox,
                GestureDetector(
                  onTap: () {
                    // user_card(userinfo == null
                    //     ? user!.displayName ?? "Newbie"
                    //     : userinfo.firstName ?? "Newbie");
                  },
                  // onTap: () => Get.to(ProfilePage()),
                  child: ProfileAvatar(
                    data: widget.data,
                    uid: widget.data.uid,
                    height: 50,
                    width: 50,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.data.firstName,
                            style: AppTheme.subheading2),
                        const SizedBox(height: 8),
                        Text(
                          widget.data.type == 'user' ||
                                  (widget.data.block == "zzzzz" &&
                                      widget.data.house == "")
                              ? "-"
                              : "${widget.data.house!}, ${widget.data.block}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.smallText,
                        )
                      ],
                    ),
                  ),
                ),
                // Image.asset(data.icon),
              ],
            ),
          ),
          (isPaidArray.contains(widget.data.house))
              ? Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    "PAID",
                    style:
                        AppTheme.smallText.copyWith(color: Colors.green[400]),
                  ),
                )
              : Row(
                  children: [
                    CustomButton(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('societies')
                            .doc(Constants.societyId)
                            .collection('maintenances')
                            .doc(widget.maintenanceData!.maintenanceId)
                            .update({
                          'isPaidArray':
                              FieldValue.arrayUnion([widget.data.house])
                        });
                        isPaidArray.add(widget.data.house);
                        setState(() {});
                      },
                      height: 56,
                      width: 56,
                      text: "",
                      iconData: CupertinoIcons.checkmark_alt,
                    ),
                    8.widthBox,
                    CustomButton(
                      onTap: () {
                        String notificationId = const Uuid().v1();
                        DateFormat.yMMMEd()
                            .format(widget.maintenanceData!.dueDate);
                        NotificationMethods().sendNotificationIndividual(
                            targetId: widget.data.token,
                            targetUID: widget.data.uid,
                            title: "Maintenance Reminder",
                            body:
                                "This is an reminder to submit your maintenance fee ,\nDue Date: ${DateFormat.yMMMEd().format(widget.maintenanceData!.dueDate)}");

                        Fluttertoast.showToast(msg: "Reminder Sent");
                      },
                      height: 56,
                      width: 56,
                      text: "",
                      iconData: CupertinoIcons.bell_solid,
                    ),
                    12.widthBox
                  ],
                )
        ],
      ),
    );
  }
}
