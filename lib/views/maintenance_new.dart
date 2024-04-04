// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:textfield_datepicker/textfield_datepicker.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/models/maintenance.dart';
import 'package:urbannest/views/maintenance_people_screen.dart';
import 'package:urbannest/views/member_screen.dart';
import 'package:urbannest/views/pay_upi.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:uuid/uuid.dart';
import '../core/notification_method.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:velocity_x/velocity_x.dart';

import 'pay_upi_ios.dart';

TextEditingController upiId = TextEditingController();

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _NoticeState();
}

class _NoticeState extends State<MaintenanceScreen>
    with TickerProviderStateMixin {
  TextEditingController amount = TextEditingController();
  TextEditingController des = TextEditingController();
  final TextEditingController dueDate = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => CustomDialog(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 120,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              8.heightBox,
                              const Text(
                                'Create Maintenance',
                                style: AppTheme.subheading2,
                                textAlign: TextAlign.center,
                              ),
                              14.heightBox,
                              CustomTextField(
                                  isForm: true,
                                  icon: const Icon(
                                      FontAwesomeIcons.indianRupeeSign),
                                  keyboardType: TextInputType.number,
                                  hint: "Enter Total Amount",
                                  validator: (value) {
                                    return null;
                                  },
                                  textController: amount),
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
                              CustomTextField(
                                  isForm: true,
                                  //  expands: true,
                                  maxLines: 4,
                                  minLines: 4,
                                  keyboardType: TextInputType.text,
                                  hint: "Enter note for the members",
                                  validator: (value) {
                                    return null;
                                  },
                                  textController: des),
                              TextfieldDatePicker(
                                cupertinoDatePickerBackgroundColor:
                                    Colors.white,
                                cupertinoDatePickerMaximumDate: DateTime(2099),
                                cupertinoDatePickerMaximumYear: 2099,
                                cupertinoDatePickerMinimumYear:
                                    DateTime.now().year,
                                cupertinoDatePickerMinimumDate: DateTime.now(),
                                cupertinoDateInitialDateTime: DateTime.now(),
                                materialDatePickerFirstDate: DateTime.now(),
                                materialDatePickerInitialDate: DateTime.now(),
                                materialDatePickerLastDate: DateTime(2099),
                                preferredDateFormat: DateFormat.yMMMEd(),
                                textfieldDatePickerController: dueDate,
                                style: AppTheme.subheading3,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  hintStyle: AppTheme
                                      .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                  hintText: "Select Due Date",
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 18),

                                  errorStyle: AppTheme.smallText.copyWith(
                                    fontSize: 10,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color.fromRGBO(105, 110, 116,
                                          1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 105, 110, 116),
                                      width: 2,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color.fromRGBO(231, 236, 243, 1),
                                      width: 2,
                                    ),
                                  ),
                                  // focusColor: MyColors.resolveCompanyCOlour(),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color.fromRGBO(171, 177, 186, 1),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppTheme.appColor,
                                      width: 2,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color.fromRGBO(231, 236, 243, 1),
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
                                      child:
                                          const Icon(FontAwesomeIcons.calendar),
                                    ),
                                  ),
                                ),
                              )
                            ],
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Send',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  12.widthBox,
                                  const Icon(Icons.send_rounded,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                          ).onTap(() {
                            if (amount.text != '' &&
                                dueDate.text != '' &&
                                upiId.text != '' &&
                                amount.text != '') {
                              DateTime tempDate =
                                  DateFormat.yMMMEd().parse(dueDate.text);

                              FireStoreMethods().createMaintenance(
                                  creatorData: Constants.userData,
                                  amount: amount.text,
                                  upi: upiId.text,
                                  note: des.text,
                                  dueDate: tempDate);
                              Get.back();
                              des.clear();
                              amount.clear();
                              dueDate.clear();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please fill all the fields");
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : SizedBox(),
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
                    "Maintenance",
                    style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                  ),
                ),
              ],
            ),
          ),
          getMyCourseList(),
        ],
      )),
    );
  }

  Widget getMyCourseList() {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.0, right: 24),
        child: MyCourseList(),
      ),
    );
  }
}

class MyCourseList extends StatefulWidget {
  const MyCourseList({super.key});

  @override
  _MyCourseListState createState() => _MyCourseListState();
}

class _MyCourseListState extends State<MyCourseList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? animationController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  final List<pw.Widget> dataMaintenance = [];
  bool isPdfGenerated = false;
  pw.Document pdf = pw.Document();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (isPdfGenerated) {
        clearPdfData();
        isPdfGenerated = false;
      }
    }
  }

  /// Save invoice
  void savePdf() async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
  }

  /// clear invoice
  void clearPdfData() {
    setState(() {
      dataMaintenance.clear();
    });
    pdf = pw.Document();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('maintenances')
            .limit(5)
            .orderBy("createdOn", descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(left: 24.0, bottom: 50),
                child: Text(
                  "No Maintenance available yet",
                  style: AppTheme.smallText,
                ),
              ),
            );
          } else {
            List<Maintenance> data = [];

            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              Maintenance maintenance =
                  Maintenance.fromSnap(snapshot.data!.docs[i]);

              data.add(maintenance);
            }
            setFund(data);
            if (data.isNotEmpty && upiId.text == "") {
              upiId.text = snapshot.data!.docs[0]['upi'];
            }

            return data.isEmpty
                ? const Center(
                    child: Text(
                      "No Maintenance available yet",
                      style: AppTheme.smallText,
                    ),
                  )
                : ListView(
                    //physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: List<Widget>.generate(
                      data.length,
                      (int index) {
                        animationController?.forward();
                        return Slidable(
                          closeOnScroll: true,
                          enabled: true,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: GestureDetector(
                              child: CategoryView(
                                index: index,
                                maintenanceData: data[index],
                                snap: snapshot.data!.docs[index].data(),
                                animationController: animationController,
                              ),
                              onTap: () async {
                                if (!data[index]
                                    .isPaidArray!
                                    .contains(Constants.userData.house)) {
                                  // Get.to(() => PayUpiScreen(
                                  //       amount:
                                  //           double.parse(data[index].amount!),
                                  //       id: data[index].creatorId!,
                                  //       maintenanceId:
                                  //           data[index].maintenanceId!,
                                  //     ));
                                } else {
                                  await generateAndShowPDF(data[index]);
                                  isPdfGenerated = true;
                                }
                              },
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

  void setFund(List<Maintenance> data) async {
    for (int i = 0; i < data.length; i++) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      DateTime cardDate = DateTime(
          data[i].dueDate.year, data[i].dueDate.month, data[i].dueDate.day);
      if (today.isAfter(cardDate)) {
        if (data[i].totalFund == null || data[i].totalFund == 0) {
          int fund = data[i].isPaidArray!.length * int.parse(data[i].amount!);
          firestore
              .collection('societies')
              .doc(Constants.societyId)
              .collection('maintenances')
              .doc(data[i].maintenanceId)
              .update({'totalFund': fund});
          String res = await FireStoreMethods().createTransaction(
            title: "Maintenance Money (${data[i].isPaidArray!.length} houses)",
            // body: body.text,
            amount: fund,
            type: true,
            societyId: Constants.societyId,
          );
        }
      }
    }
  }

  Future<void> generateAndShowPDF(Maintenance maintenanceData) async {
    final pdf = await generatePdf(maintenanceData);
    Printing.layoutPdf(onLayout: (PdfPageFormat format) {
      return pdf.save();
    });
  }

  Future<pw.Document> generatePdf(Maintenance maintenanceData) async {
    dataMaintenance.add(
      pw.Row(
        children: [
          pw.SizedBox(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(maintenanceData.note.toString(),
                  style: const pw.TextStyle(fontSize: 16)),
            ),
          ),
          pw.Spacer(),
          pw.SizedBox(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(maintenanceData.amount.toString(),
                  style: const pw.TextStyle(fontSize: 16)),
            ),
          )
        ],
      ),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text(Constants.userData.societyName.toString(),
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 25),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Name: ${Constants.userData.firstName}'),
                        pw.Text('Address: ${Constants.userData.address}'),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                            'Due Date : ${DateFormat.yMMMEd().format(maintenanceData.dueDate)}'),
                        pw.Text('Mobile No: ${Constants.userData.phone}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(
                      width: 80,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(0),
                        child: pw.Text("No.",
                            style: const pw.TextStyle(fontSize: 14)),
                      ),
                    ),
                    pw.Spacer(),
                    pw.SizedBox(
                      width: 80,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text("Amount",
                            style: const pw.TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Column(children: dataMaintenance),
                pw.SizedBox(height: 5),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        //pw.Divider(),
                        pw.Divider(),

                        pw.Text("Total Amount   : ${maintenanceData.amount}",
                            style: const pw.TextStyle(fontSize: 16)),
                        pw.Divider(),
                        //pw.Divider(),
                      ]),
                ),
                pw.Text("Transaction Id   : ${maintenanceData.transactionId}",
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 30),
                pw.Text("Terms and Conditions",
                    style: const pw.TextStyle(fontSize: 18))
              ],
            ),
          );
        },
      ),
    );
    isPdfGenerated = true;
    return pdf;
  }

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
}

bool isFirst = true;

class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key? key,
      this.snap,
      this.index,
      this.maintenanceData,
      this.animationController,
      this.animation})
      : super(key: key);

  final snap;
  final int? index;
  final Maintenance? maintenanceData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime cardDate = DateTime(maintenanceData!.dueDate.year,
        maintenanceData!.dueDate.month, maintenanceData!.dueDate.day);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 0),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    4.heightBox,
                    Text(
                        "Due : ${DateFormat.yMMMEd().format(maintenanceData!.dueDate)}",
                        style: AppTheme.subheading2),
                    4.heightBox,
                    maintenanceData!.isPaidArray!
                            .contains(Constants.userData.house)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Text(
                              "PAID",
                              style: AppTheme.heading3
                                  .copyWith(color: Colors.green[400]),
                            ),
                          )
                        : today.isBefore(cardDate) ||
                                today.isAtSameMomentAs(cardDate)
                            ? Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Text(
                                  "PENDING",
                                  style: AppTheme.heading3
                                      .copyWith(color: Colors.yellow),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Text(
                                  "PENALTY",
                                  style: AppTheme.heading3
                                      .copyWith(color: Colors.red),
                                ),
                              ),
                    12.heightBox,
                    Text(
                      maintenanceData!.note!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 100,
                      style: AppTheme.smallText,
                    ),
                    8.heightBox,

                    /// due Date
                    Text(
                      (maintenanceData!.isPaidArray!
                                  .contains(Constants.userData.house)
                              ? "Amount Paid : "
                              : "Amount to Pay : ") +
                          "${maintenanceData!.amount}",
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.subheading3,
                    ),
                    Text(
                      "Due Date : ${DateFormat.yMMMEd().format(maintenanceData!.dueDate)}",
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.subheading3,
                    ),
                    10.heightBox,
                  ],
                ),
              ),
            ),
            maintenanceData!.isPaidArray!.contains(Constants.userData.house)
                ? const SizedBox()
                : (today.isBefore(cardDate) || today.isAtSameMomentAs(cardDate))
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            onTap: () async {
                              if (isFirst) {
                                isFirst = false;
                                String notificationId = const Uuid().v1();
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .where("societyId",
                                        isEqualTo: Constants.societyId)
                                    .where("type", isEqualTo: 'admin')
                                    .get()
                                    .then((data) => data.docs.forEach((doc) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(doc.id)
                                              .collection('notifications')
                                              .doc(notificationId)
                                              .set({
                                            'id': notificationId,
                                            'title':
                                                "Maintenance paid by ${Constants.userData.firstName}",
                                            'body':
                                                "${Constants.userData.firstName} : I've already paid this month's maintenance fees please check",
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                            'type': "newMaintenance",
                                            'house': Constants.userData.house,
                                            'uid': Constants.userId,
                                            'amenityId':
                                                maintenanceData!.maintenanceId,
                                          });
                                          // userIds.add(doc["id"]);
                                        }));

                                Fluttertoast.showToast(
                                    msg:
                                        "Maintenance request send for Approval");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Maintenance request already send");
                              }
                            },
                            height: 54,
                            width: 142,
                            text: "I have paid",
                          ),
                          12.widthBox,
                          CustomButton(
                            onTap: () async {
                              (Platform.isIOS)
                                  ? Get.to(ScreenPayment(
                                      note:
                                          "Maintenance ${DateFormat.yMMMEd().format(maintenanceData!.dueDate)}",
                                      amount: double.parse(
                                          maintenanceData!.amount!),
                                      id: maintenanceData!.upi!,
                                      house: Constants.userData.house,
                                      maintenanceId:
                                          maintenanceData!.maintenanceId!,
                                    ))
                                  : Get.to(() => PayUpiScreen(
                                        note:
                                            "Maintenance ${DateFormat.yMMMEd().format(maintenanceData!.dueDate)}",
                                        amount: double.parse(
                                            maintenanceData!.amount!),
                                        id: maintenanceData!.upi!,
                                        house: Constants.userData.house,
                                        maintenanceId:
                                            maintenanceData!.maintenanceId!,
                                      ));
                            },
                            height: 54,
                            width: 142,
                            text: "Pay now",
                          )
                        ],
                      )
                    : SizedBox(),
            (today.isBefore(cardDate) || today.isAtSameMomentAs(cardDate)) &&
                    !(maintenanceData!.isPaidArray!
                        .contains(Constants.userData.house))
                ? 10.heightBox
                : 0.heightBox,
            maintenanceData!.isPaidArray!.contains(Constants.userData.house)
                ? const SizedBox()
                : (today.isAfter(cardDate))
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: CustomButton(
                          onTap: () async {
                            Get.to(MemberScreen());
                          },
                          height: 54,
                          width: double.infinity,
                          // width: 240,
                          text: "Contact Chairmen",
                        ),
                      )
                    : SizedBox(),
            (today.isBefore(cardDate)) &&
                    !(maintenanceData!.isPaidArray!
                        .contains(Constants.userData.house))
                ? 0.heightBox
                : 12.heightBox,
            Constants.userData.houseOwner ?? false
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Constants.type == 'admin'
                          ? Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: CustomButton(
                                height: 54,
                                width: 142,
                                text: "Check",
                                iconData: Icons.people,
                                onTap: () {
                                  Get.to(MaintenanceMemberScreen(
                                    maintenanceData: maintenanceData!,
                                  ));
                                },
                              ),
                            )
                          : const SizedBox(),
                      Constants.type == "admin" ? 12.widthBox : 0.widthBox,
                      Constants.type == "admin"
                          ? CustomButton(
                              onTap: () {
                                Fluttertoast.showToast(msg: "Reminder Sent");
                                 
   
                                NotificationMethods().sendNotificationTopics(
                                    to: '/topics/member-${Constants.societyId}',
                                    title: "Maintenance Reminder",
                                    body:
                                        "This is an reminder to submit the maintenance fee ,\nDue Date: ${DateFormat.yMMMEd().format(maintenanceData!.dueDate)}");
                                         NotificationMethods().sendNotificationTopics(
                                    to: '/topics/admin-${Constants.societyId}',
                                    title: "Maintenance Reminder",
                                    body:
                                        "This is an reminder to submit the maintenance fee ,\nDue Date: ${DateFormat.yMMMEd().format(maintenanceData!.dueDate)}");
                              },
                              height: 54,
                              width: 142,
                              text: "Remind",
                              iconData: Icons.notifications)
                          : const SizedBox()
                    ],
                  )
                : SizedBox(),
            12.heightBox,
          ],
        ),
      ),
    );
  }
}
