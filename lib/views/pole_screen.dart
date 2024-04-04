import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:textfield_datepicker/textfield_datepicker.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_polls/flutter_polls.dart';

import '../core/constants.dart';
import '../core/firestore_methods.dart';
import '../core/notification_method.dart';

class PoleScreen extends StatefulWidget {
  const PoleScreen({super.key, this.societyId});
  final String? societyId;
  @override
  State<PoleScreen> createState() => _PoleScreenState();
}

class _PoleScreenState extends State<PoleScreen> {
  bool result = false;
  // BannerAd? bannerAd;

  @override
  void initState() {
    // bannerAd = Constants.initBannerAdd(size: AdSize.banner);
    // result = Constants.getProbability(0.6);
    super.initState();
  }

  TextEditingController title = TextEditingController();
  RxList<TextEditingController> optionsList = [TextEditingController()].obs;
  TextEditingController body = TextEditingController();
  final TextEditingController date = TextEditingController();
  // getAd() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 12,),
  //     child: SizedBox(height: 65, child: AdWidget(ad: bannerAd!)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
  List<bool> hasVoted = [];
  List<int> number = [];
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: Constants.type != 'admin'
          ? SizedBox()
          : FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              backgroundColor: AppTheme.appColor,
              foregroundColor: Colors.white,
              onPressed: () {
                optionsList = [TextEditingController()].obs;
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => CustomDialog(
                            child: SizedBox(
                          // height: 410,
                          width: MediaQuery.of(context).size.width - 120,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  8.heightBox,
                                  const Text(
                                    'Create Poll',
                                    style: AppTheme.subheading2,
                                    textAlign: TextAlign.center,
                                  ),
                                  14.heightBox,
                                  CustomTextField(
                                      isForm: true,
                                      maxLines: 2,
                                      minLines: 2,
                                      // icon: Icon(Icons.question_mark_rounded),
                                      keyboardType: TextInputType.text,
                                      hint: "Enter poll question",
                                      validator: (value) {
                                        return null;
                                      },
                                      textController: title),
                                  12.heightBox,
                                  Obx(() {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: optionsList.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                      isForm: true,
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
                                                      hint:
                                                          "Enter option ${index + 1}",
                                                      validator: (value) {
                                                        return null;
                                                      },
                                                      textController:
                                                          optionsList
                                                              .toList()[index]),
                                                ),
                                                (index ==
                                                            optionsList.length -
                                                                1 &&
                                                        index < 3)
                                                    ? const Padding(
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Icon(Icons.add),
                                                      ).onTap(() {
                                                        optionsList.add(
                                                            TextEditingController());
                                                        if (index == 2) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Reached maximum limit");
                                                        }
                                                      })
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                                  TextfieldDatePicker(
                                    cupertinoDatePickerBackgroundColor:
                                        Colors.white,
                                    cupertinoDatePickerMaximumDate:
                                        DateTime(2099),
                                    cupertinoDatePickerMaximumYear: 2099,
                                    cupertinoDatePickerMinimumYear:
                                        DateTime.now().year,
                                    cupertinoDatePickerMinimumDate:
                                        DateTime.now(),
                                    cupertinoDateInitialDateTime:
                                        DateTime.now(),
                                    materialDatePickerFirstDate: DateTime.now(),
                                    materialDatePickerInitialDate:
                                        DateTime.now(),
                                    materialDatePickerLastDate: DateTime(2099),
                                    preferredDateFormat: DateFormat
                                        .yMMMEd(), //DateFormat("yyyy-MM-dd hh:mm:ss"),
                                    textfieldDatePickerController: date,
                                    style: AppTheme.subheading3,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintStyle: AppTheme
                                          .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                      hintText: "Select End Date",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                          color: Color.fromARGB(255, 105, 110,
                                              116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                          width: 2,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(231, 236, 243, 1),
                                          width: 2,
                                        ),
                                      ),
                                      // focusColor: MyColors.resolveCompanyCOlour(),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromRGBO(171, 177, 186, 1),
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
                                          color:
                                              Color.fromRGBO(231, 236, 243, 1),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                              ).onTap(() async {
                                bool optionsfilled = false;
                                for (int i = 0; i < optionsList.length; i++) {
                                  if (optionsList[i].text != "") {
                                    optionsfilled = true;
                                  } else {
                                    optionsfilled = false;
                                  }
                                }
                                if (optionsfilled &&
                                    title.text != "" &&
                                    date.text != '') {
                                  if (optionsList.length >= 2) {
                                    DateTime tempDate =
                                        DateFormat.yMMMEd().parse(date.text);

                                    Get.back();
                                    Get.back();
                                    await FireStoreMethods().createPoll(
                                      context,
                                      question: title.text,
                                      options: optionsList.toList(),
                                      expiry: tempDate,
                                      societyId: widget
                                          .societyId, //userinfo!.societyId,
                                    );

                                    Fluttertoast.showToast(
                                        msg: 'New Poll Added');
                                    await NotificationMethods()
                                        .sendNotificationTopics(
                                      to: '/topics/member-${Constants.societyId}',
                                      title: "New Poll Added",
                                      body: "Title : "+title.text,
                                      type: 'poll',
                                    );
                                     await NotificationMethods()
                                        .sendNotificationTopics(
                                      to: '/topics/admin-${Constants.societyId}',
                                      title: "New Poll Added",
                                      body: title.text,
                                      type: 'poll',
                                    );
                                    title.clear();
                                    body.clear();
                                    date.clear();
                                  } else {}
                                  Fluttertoast.showToast(
                                      msg: "Please select 2 options to select");
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please fill all the fields");
                                }
                              }),
                            ],
                          ),
                        )));
              },
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 16, left: 24, right: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CustomBackButton(),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.8, left: 16),
                      child: Text(
                        "Polls",
                        style:
                            AppTheme.subheading.copyWith(letterSpacing: -0.3),
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('societies')
                      .doc(widget.societyId)
                      .collection('polls')
                      .orderBy("createdOn", descending: true).limit(8)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                      try{
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    } else {
                      
                      // setState(() {
                        
                      // });
                      return snapshot.data!.docs.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 50),
                              child: Center(
                                  child: Text(
                                "No Polls Available",
                                style: AppTheme.smallText,
                              )),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                for (int i = 0;
                                    i < snapshot.data!.docs.length;
                                    i++) {
                                  hasVoted.add(false);
                                  number.add(1);
                                }
                                // return Container(color: Colors.red,height: 100,);
                                final Map<String, dynamic> poll = snapshot
                                    .data!.docs[index]
                                    .data(); // polls()[index];

                                final int days = DateTime(
                                  poll['endDate'].toDate().year,
                                  poll['endDate'].toDate().month,
                                  poll['endDate'].toDate().day,
                                )
                                    .difference(DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                    ))
                                    .inDays;

                                for (int i = 0;
                                    i < poll['options'].length;
                                    i++) {
                                  List<dynamic> votes =
                                      poll['options'][i]['votes'];
                                  if (votes.contains(
                                      FirebaseAuth.instance.currentUser!.uid)) {
                                    hasVoted[index] = true;
                                    number[index] = i;
                                    break;
                                    // index = i;
                                  }
                                }
                                return Column(
                                  children: [
                                    FlutterPolls(
                                      hasVoted: hasVoted[index],
                                      loadingWidget:
                                          LoadingAnimationWidget.waveDots(
                                              color: AppTheme.lightText,
                                              size: 40),
                                      votedBackgroundColor: Colors.white,
                                      pollOptionsFillColor: Colors.white,
                                      pollOptionsBorder: Border.all(
                                          color: AppTheme.lightText
                                              .withOpacity(0.1),
                                          width: 2),
                                      pollId: poll['id'].toString(),
                                      userVotedOptionId:
                                          number[index].toString(),
                                      onVoted: (PollOption pollOption,
                                          int newTotalVotes) async {
                                        // fontcolor = Colors.white;
                                        List<dynamic> temp = poll['options'];
                                        dynamic currentOption =
                                            temp[int.parse(pollOption.id!)];
                                        List<dynamic> temp2 =
                                            currentOption['votes'];
                                        temp2.add(FirebaseAuth
                                            .instance.currentUser!.uid);
                                        currentOption['votes'] = temp2;
                                        temp[int.parse(pollOption.id!)] =
                                            currentOption;
                                        await FirebaseFirestore.instance
                                            .collection('societies')
                                            .doc(widget.societyId)
                                            .collection('polls')
                                            .doc(poll['id'])
                                            .update({'options': temp});

                                        Fluttertoast.showToast(
                                            msg:
                                                'Your voted has been registered');
                                        setState(() {});
                                        Get.back();
                                        return true;
                                      },

                                      pollEnded: days < 0,
                                      pollTitle: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(poll['question'],
                                            style: AppTheme.heading3),
                                      ),

                                      pollOptionsHeight: 55,
                                      votedPollOptionsRadius:
                                          const Radius.circular(16),
                                      pollOptionsSplashColor:
                                          Colors.transparent,
                                      leadingVotedProgessColor:
                                          const Color.fromARGB(
                                              255, 171, 214, 231),
                                      votedProgressColor: const Color.fromARGB(
                                          255, 186, 233, 252),
                                      voteInProgressColor: Colors.white,
                                      // pollOptionsBorderRadius: BorderRadius.circular(20),
                                      votesTextStyle: AppTheme.subheading3,

                                      pollOptions: List<PollOption>.from(
                                        poll['options'].map(
                                          (option) {
                                            var a = PollOption(
                                              id: option['id'].toString(),
                                              title: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    150,
                                                child: Text(option['title'],
                                                    // maxLines: 1,
                                                    // overflow: TextOverflow.ellipsis,
                                                    style: AppTheme.subheading3
                                                        .copyWith(
                                                            color: AppTheme
                                                                .appColor)),
                                              ),
                                              votes: option['votes'].length,
                                            );
                                            return a;
                                          },
                                        ),
                                      ),
                                      votedPercentageTextStyle:
                                          AppTheme.smallText,
                                      metaWidget: Row(
                                        children: [
                                          const SizedBox(width: 6),
                                          const Text(
                                            '•',
                                            style: AppTheme.smallText,
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            days < 0
                                                ? "ended"
                                                : "ends $days days",
                                            style: AppTheme.smallText,
                                          ),
                                        ],
                                      ),
                                    ),
                                    16.heightBox,
                                    const SizedBox(
                                      width: 56,
                                      child: VxDivider(
                                        color: AppTheme.lightText,
                                      ),
                                    ),
                                    16.heightBox,
                                  ],
                                );
                              },
                            );
                    }
                      }catch(e){
                        return SizedBox();
                      }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
