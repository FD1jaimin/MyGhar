import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/notification_method.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/notices.dart';
import '../widgets/date_picker.dart';
import '../widgets/dialog.dart';
import '../widgets/floating_action_button.dart';
import '../widgets/notice_card.dart';
import '../widgets/topbar.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  // const NoticeScreen({super.key});
  TextEditingController title = TextEditingController();

  TextEditingController body = TextEditingController();

  final TextEditingController date = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: Constants.type == "admin"
          ? CustomFloatingActionButton(
              onTap: () async {
    //             await  NotificationMethods().sendNotificationTopics(
    //   to: '/topics/${Constants.societyId}',
    //   title: "Notice : ${title.text}",
    //   body: body.text,
    //   type: 'notice',
    // );
                _addNoticePopUp(context);
              },
            )
          : const SizedBox(),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CreateTopBar(title: "Notices"),
          getNoticesList(),
          
        ],
      )),
    );
  }

  Future<dynamic> _addNoticePopUp(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              8.heightBox,
              const Text(
                'Send Notice',
                style: AppTheme.subheading2,
                textAlign: TextAlign.center,
              ),
              14.heightBox,
              CustomTextField(
                  isForm: true,
                  keyboardType: TextInputType.text,
                  hint: "Enter notice title",
                  validator: (value) {
                    return null;
                  },
                  textController: title),
              12.heightBox,
              CustomTextField(
                  isForm: true,
                  minLines: 4,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  hint: "Enter notice body",
                  validator: (value) {
                    return null;
                  },
                  textController: body),
              CustomTextfieldDatePicker(
                date: date,
                icon: FontAwesomeIcons.calendar,
                hint: "Select End Date",
              ),
              12.heightBox,
              CustomButton(
                  onTap: () async {
                    if(date.text != ''&& title.text!=''&& body.text !=""){

                    DateTime tempDate = DateFormat.yMMMEd().parse(date.text);
                    Get.back();
                    String res = await FireStoreMethods().createNotice(
                      title: title.text,
                      body: body.text,
                      expiry: tempDate,
                      societyId: Constants.societyId,
                      
                    );

                    if (res == "success") {
                      sendNotification();
                    }
                    }else{
                      Fluttertoast.showToast(msg: "Please fill all the details");
                    }
                  },
                  height: 58,
                  width: 188,
                  text: "Send"),
            ],
          ),
        ),
      ),
    );
  }

  void sendNotification() async {
   await  NotificationMethods().sendNotificationTopics(
      to: '/topics/${Constants.societyId}',
      title: "Notice : ${title.text}",
      body: body.text,
      type: 'notice',
    );
   
    Fluttertoast.showToast(msg: 'Notice Send');
    title.clear();
    body.clear();
    date.clear();
  }

  Widget getNoticesList() {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 24.0),
        child: NoticeList(),
      ),
    );
  }
}

class NoticeList extends StatefulWidget {
  const NoticeList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> with TickerProviderStateMixin {
  AnimationController? animationController;

  bool result = false;
  bool resultShare = false;
  BannerAd? bannerAd;



  getAd() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(height: 65, child: AdWidget(ad: bannerAd!)),
    );
  }
  
  @override
  void initState() {
    bannerAd = Constants.initBannerAdd(size: AdSize.banner);
    result = Constants.getProbability(0.9);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('notices')
            .orderBy("datePublished", descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            List<Notice> data = [];
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              Notice userVisitor = Notice.fromSnap(snapshot.data!.docs[i]);
              DateTime cardDate = DateTime(userVisitor.expiry.year,
                  userVisitor.expiry.month, userVisitor.expiry.day);

              if (today.isBefore(cardDate) ||
                  today.isAtSameMomentAs(cardDate)) {
                data.add(userVisitor);
              }
            }

            return data.isEmpty
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      "No Active Notices",
                      style: AppTheme.smallText,
                    ),
                  ))
                : ListView(
                    children: List<Widget>.generate(
                      data.length  +1,
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
                        return index == data.length  ? Constants.showAd && result ? getAd() : const SizedBox()
              :Slidable(
                          closeOnScroll: true,
                          enabled: Constants.type == "admin" ? true : false,
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                flex: 2,
                                onPressed: (context) {
                                  FireStoreMethods()
                                      .deleteNotice(data[index].noticeId!);
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
                            padding: const EdgeInsets.only(left: 24.0),
                            child: NoticeItem(
                              noticeData: data[index],
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
}

class NoticeItem extends StatelessWidget {
  const NoticeItem({
    Key? key,
    this.noticeData,
    this.animationController,
    this.animation,
  }) : super(key: key);

  final Notice? noticeData;
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
                  height: 164,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: NoticeCard(
                    height: 164,
                    context,
                    title: noticeData!.title!,
                    body: noticeData!.body!,
                    name: noticeData!.username ?? "Unknown",
                    dateTime: DateFormat.MMMEd()
                        .add_jm()
                        .format(noticeData!.createdOn),
                  )).onTap(() {
                showDialog(
                  context: context,
                  builder: (context) => Center(
                      child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: NoticeCard(
                      isExpanded: true,
                      height: 460,
                      context,
                      title: noticeData!.title!,
                      body: noticeData!.body!,
                      name: noticeData!.username ?? "Unknown",
                      dateTime: DateFormat.MMMEd()
                          .add_jm()
                          .format(noticeData!.createdOn),
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

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 8.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          // ignore: sort_child_properties_last
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(20)),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
