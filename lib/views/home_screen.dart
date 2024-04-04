// ignore_for_file: avoid_function_literals_in_foreach_calls, unnecessary_null_comparison

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'dart:io';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/models/notices.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/models/user_visitor.dart';
import 'package:urbannest/views/business_screen.dart';
import 'package:urbannest/views/bussiness_screen.dart';
import 'package:urbannest/views/chats/room.dart';
import 'package:urbannest/views/gallery_screen.dart';
import 'package:urbannest/views/guard_members_screen.dart';
import 'package:urbannest/views/helpdesk_screen.dart';
import 'package:urbannest/views/in_out_screen.dart';
import 'package:urbannest/views/member_screen.dart';
import 'package:urbannest/views/notice_screen.dart';
import 'package:urbannest/views/notification_screen.dart';
import 'package:urbannest/views/vehicle_screen.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/notice_card.dart';
import 'package:urbannest/widgets/profile_avatar.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/notification_method.dart';
import '../core/user_provider.dart';
import '../models/user.dart' as model;
import '../widgets/dropdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController animationController;
  AdRequest? adRequest;
  BannerAd? bannerAd;
  int selectIndex = 0;
  TextEditingController guestname = TextEditingController();
  TextEditingController selectedPeople = TextEditingController();
  TextEditingController selectedCompanyController = TextEditingController();
  TextEditingController selectedDate = TextEditingController();
  var selectedCompany = 'Amazon'.obs;
  List<String> dates = ["Today", "Tomorrow"];
  List<String> people = ["1 - 2", "3 - 5", "5 +"];
  List<String> company = ["Amazon", "Flipkart", "Zomato", "Myntra", "Other"];
  bool result = false;
  bool resultVisitor = false;
  int notificationCounts = 0;
  List<String> items = [
    "Members",
    "Notices",
    "Gallery",
    "Business",
    "Help Desk",
  ];
  List<String> itemsAdmin = [
    "Members",
    "Notices",
    "Gallery",
    "Business",
    "Help Desk",
    "In & Outs"
  ];
  List<Widget> screens = [
    const MemberScreen(),
    const NoticeScreen(),
    const GalleryScreen(),
    const BusinessScreenNew(),
    const HelpDeskScreen(),
    InOutScreen(),
  ];

   List<EdgeInsets> padd = [const EdgeInsets.all(0),const EdgeInsets.only(top: 24,bottom: 0,left: 16,right: 16),const EdgeInsets.only(top: 24,bottom: 0,left: 20,right: 20),const EdgeInsets.only(left: 16,right: 16,top: 0),const EdgeInsets.only(left: 8,right: 8,top: 16),const EdgeInsets.only(top: 36,bottom: 0,left: 24,right: 24 ),const EdgeInsets.only(top: 36,bottom: 0,left: 24,right: 24)];
    

  late TabController pageController;

  @override
  void initState() {
    bannerAd = Constants.initBannerAdd(size: AdSize.banner);
    result = Constants.getProbability(0.7);
    resultVisitor = Constants.getProbability(0.5);
    autoDeleteVisitor();
    pageController = TabController(length: 2, vsync: this);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    super.initState();
    Random ran = Random();
    result = ran.nextDouble() <= 0.8;
    qrCode = QrCode.fromData(
      data: 'Bhargav',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    qrImage = QrImage(qrCode);

    decoration = const PrettyQrDecoration(
      
      // shape: PrettyQrSmoothSymbol(
      //   color: PrettyQrSettings.kDefaultQrDecorationBrush,
      // ),
      image: PrettyQrDecorationImage(image: AssetImage('assets/logo.png')) ,
    );
  }
  late QrCode qrCode;

  @protected
  late QrImage qrImage;

  @protected
  late PrettyQrDecoration decoration;

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              getAppBarUI(),
              getVisitors(),
              Constants.showAd && result ? getAd() : const SizedBox(),
              getNotices(),
              getCommunityCards(),
            ],
          ),
        ),
      )),
    );
  }

  autoDeleteVisitor() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.userId)
        .collection('guests')
        .get()
        .then((data) => data.docs.forEach((doc) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              DateTime visitDate = doc.data()['visitDate'].toDate();
              DateTime visitorDate =
                  DateTime(visitDate.year, visitDate.month, visitDate.day);
              if (today.isAfter(visitorDate)) {
                FireStoreMethods().deleteVisitor(doc.id);
              }
            }));
  }

  getAd() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(height: 50, child: AdWidget(ad: bannerAd!)),
    );
  }

  Column getCommunityCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24.0, top: 16),
          child: Text(
            "Community",
            style: AppTheme.subheading2,
          ),
        ),
        GridView(
          padding: const EdgeInsets.all(24),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          // ignore: sort_child_properties_last
          children: List<Widget>.generate(
            Constants.type == "admin" ? itemsAdmin.length : items.length,
            (int index) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          Constants.type == "admin"
                              ? itemsAdmin[index]
                              : items[index],
                          style: AppTheme.subheading2,
                        ),
                      ),
                    ),
                    Padding(
                      padding: padd[index],
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Lottie.asset(
                              Constants.type == "admin"
                                  ? "assets/${itemsAdmin[index]}.json"
                                  : "assets/${items[index]}.json",
                              fit: BoxFit.fitWidth,
                              height: 140)),
                    ),
                  ],
                ),
              ).onTap(() {
                Get.to(screens[index]);
              });
            },
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 1,
          ),
        ),
      ],
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> getNotices() {
    return StreamBuilder(
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
            //Checks if notice Expired or Not
            List<Notice> data = [];
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              if (data.length == 3) {
                break;
              }
              Notice userVisitor = Notice.fromSnap(snapshot.data!.docs[i]);
              DateTime cardDate = DateTime(userVisitor.expiry.year,
                  userVisitor.expiry.month, userVisitor.expiry.day);
              if (today.isBefore(cardDate) ||
                  today.isAtSameMomentAs(cardDate)) {
                data.add(userVisitor);
              }
            }
            if (data.isEmpty) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  height: 164,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: PageView.builder(
                    itemBuilder: (context, index) {
                      return NoticeCard(context,
                          height: 164,
                          dateTime: DateFormat.MMMEd()
                              .add_jm()
                              .format(data[index].createdOn),
                          name: data[index].username ?? "Unknown",
                          title: data[index].title!,
                          body: data[index].body!);
                    },
                    itemCount: data.length,
                    allowImplicitScrolling: true,
                    onPageChanged: (value) {
                      setState(() => selectIndex = value);
                    },
                  ),
                ).onTap(() {
                  Get.to(const NoticeScreen());
                }),
                _buildPageIndicator(data.length)
              ]),
            );
          }
        });
  }

  Widget _indicator(bool isActive) {
    return SizedBox(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        height: 4.0,
        width: isActive ? 16 : 4.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          color: isActive ? const Color(0XFF101010) : const Color(0xFFBDBDBD),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int length) {
    List<Widget> list = [];
    for (int i = 0; i < length; i++) {
      list.add(i == selectIndex ? _indicator(true) : _indicator(false));
    }
    return Container(
      height: 164,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list,
      ),
    );
  }

  Widget getVisitors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24, top: 24),
          child: Text(
            "My Visitors",
            style: AppTheme.subheading2,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 116,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(Constants.userId)
                      .collection("guests")
                      .orderBy("datePublished", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (!snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12),
                        child: Row(
                          children: [
                            addGuestButton(context),
                          ],
                        ),
                      );
                    } else {
                      List<UserVisitor> data = [];

                      for (int i = 0; i < snapshot.data!.docs.length; i++) {
                        UserVisitor userVisitor =
                            UserVisitor.fromSnap(snapshot.data!.docs[i]);
                        data.add(userVisitor);
                      }
                      return SizedBox(
                        height: 112,
                        width: double.infinity,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: List<Widget>.generate(
                            data.length + 1,
                            (int index) {
                              return index == 0
                                  ? addGuestButton(context)
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        children: [
                                          Container(
                                            clipBehavior: Clip.antiAlias,
                                            alignment: Alignment.centerLeft,
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                          255, 141, 191, 217)
                                                      .withOpacity(0.1),
                                                  width: 3),
                                            ),
                                            child: data[index - 1]
                                                    .count!
                                                    .contains("1")
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Lottie.asset(
                                                        "assets/bike.json"),
                                                  )
                                                : data[index - 1]
                                                        .count!
                                                        .contains("3")
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Lottie.asset(
                                                          "assets/car.json",
                                                        ),
                                                      )
                                                    : data[index - 1]
                                                            .count!
                                                            .contains("5 +")
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(6.0),
                                                            child: Lottie.asset(
                                                              "assets/bus.json",
                                                            ),
                                                          )
                                                        : Lottie.asset(
                                                            "assets/delivery.json",
                                                          ),
                                          ),
                                          SizedBox(
                                              width: 74,
                                              child: Text(
                                                data[index - 1].guestName!,
                                                textAlign: TextAlign.center,
                                                style: AppTheme.smallText
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        ],
                                      ).onTap(() {
                                        visitorCard(data[index - 1]);
                                      }),
                                    );
                            },
                          ),
                        ),
                      );
                    }
                  }),
            )),
      ],
    );
  }

  GestureDetector addGuestButton(BuildContext context) {
    // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return GestureDetector(
      onTap: () {
        selectedCompany.value = "Amazon";
        showDialog(
            context: context,
            builder: (context) => Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: 6,
                        width: 70,
                        decoration: BoxDecoration(
                            color: AppTheme.buttonColor,
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
                        padding: const EdgeInsets.only(
                          bottom: 24.0,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  height: 42,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: AppTheme.buttonColor,
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(22),
                                          bottomRight: Radius.circular(22)))),
                              12.heightBox,
                              const Text(
                                'Get gate pass',
                                style: AppTheme.subheading2,
                                textAlign: TextAlign.center,
                              ),
                              4.heightBox,
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 120,
                                child: DefaultTabController(
                                  initialIndex: 0,
                                  length: 2,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TabBar(
                                          indicatorColor: AppTheme.appColor,
                                          labelPadding: const EdgeInsets.all(8),
                                          enableFeedback: false,
                                          dividerColor: Colors.transparent,
                                          labelColor: AppTheme.appColor,
                                          controller: pageController,
                                          overlayColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) {
                                            return Colors.transparent;
                                          }),
                                          labelStyle: AppTheme.smallText
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          tabs: const [
                                            Text("Guest"),
                                            Text("Delivery")
                                          ]),
                                      12.heightBox,
                                      SizedBox(
                                        height: 210,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                110,
                                        child: TabBarView(
                                          controller: pageController,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          children: <Widget>[
                                            guestAdd(),
                                            deliveryAdd()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              12.heightBox,
                              CustomButton(
                                  onTap: () {
                                    final now = DateTime.now();
                                    DateTime date =
                                        DateTime(now.year, now.month, now.day);
                                    if (selectedDate.text == 'Tomorrow') {
                                      date = date.add(const Duration(days: 1));
                                    }
                                    if (pageController.index != 0) {
                                      addDelivery(Constants.userData, date);
                                    } else {
                                      addGuest(Constants.userData, date);
                                    }
                                    guestname.clear();
                                    selectedPeople.clear();
                                    selectedDate.text = "Today";
                                    selectedCompany.value = 'Amazon';
                                    if (Constants.showAd && resultVisitor)
                                      Constants.showIntertitialAd();
                                  },
                                  height: 58,
                                  width: 188,
                                  text: "Submit")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )));
      },
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                  color:
                      const Color.fromARGB(255, 141, 191, 217).withOpacity(0.1),
                  width: 3),
            ),
            child: const Center(
                child: Icon(
              // ignore: deprecated_member_use
              FontAwesomeIcons.add,
              color: AppTheme.lightText,
            )),
          ),
          Text(
            "Add",
            style: AppTheme.smallText.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void addGuest(UserData userinfo, DateTime date) {
    if (guestname.text.length >= 2 ||
        selectedPeople.text != "" ||
        selectedDate.text != "") {
      FireStoreMethods().createGuest(
          house: userinfo.house,
          block: userinfo.block,
          count: selectedPeople.text,
          guestname: guestname.text,
          username: userinfo.firstName,
          visitdate: date);
      Get.back();
    } else {
      Fluttertoast.showToast(msg: "Please fill all the above details");
    }
  }

  void addDelivery(UserData userinfo, DateTime date) {
    if ((selectedCompany.value == "Other" &&
        selectedCompanyController.text == "")) {
      Fluttertoast.showToast(msg: 'Please fill up all the details');
    } else {
      String title = "Delivery Awaited at ${userinfo.house} ${userinfo.block}";
      String body =
          "A delivery have been expected at :\nHouse : ${userinfo.house} ${userinfo.block}\n For : ${userinfo.firstName}\n On : ${DateFormat.yMMMEd().format(date)}";

      FireStoreMethods().createGuest(
          house: userinfo.house,
          block: userinfo.block,
          count: "delivery",
          guestname: selectedCompany.value != "Other"
              ? selectedCompany.value
              : selectedCompanyController.text,
          username: userinfo.firstName,
          visitdate: date);

      // NotificationMethods().sendNotificationTopics(
      //     to: '/topics/guard-${Constants.socie tyId}',
      //     title: title,
      //     body: body,
      //     type: 'delivery');
      Get.back();
    }

  }

  Padding guestAdd() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 280,
        child: Column(
          children: [
            CustomTextField(
                isForm: true,
                hint: "Guest Name",
                icon: const Icon(
                  FontAwesomeIcons.user,
                  size: 20,
                ),
                validator: (value) {
                  return null;
                },
                textController: guestname),
            12.heightBox,
            CustomDropDown(
              hint: "Number of People",
              values: people,
              selectedValue: selectedPeople,
            ),
            12.heightBox,
            CustomDropDown(
              value: "Today",
              hint: "Select visiting date",
              values: dates,
              selectedValue: selectedDate,
            ),
          ],
        ),
      ),
    );
  }

  Padding deliveryAdd() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 280,
        child: Column(
          children: [
            Obx(() {
              return selectedCompany.value == "Other"
                  ? CustomTextField(
                      isForm: true,
                      keyboardType: TextInputType.text,
                      hint: "Enter Delivery Provider name",
                      validator: (value) {
                        return null;
                      },
                      textController: selectedCompanyController)
                  : DropdownButtonFormField2<String>(
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
                      ),
                      value: selectedCompany.value,
                      hint: const Text(
                        "Select Delivery Provider name",
                        style: AppTheme.smallText,
                      ),
                      items: company
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item, style: AppTheme.subheading3),
                              ))
                          .toList(),
                      validator: (value) {
                        return null;
                      },
                      onChanged: (value) {
                        selectedCompany.value = value.toString();
                      },
                      onSaved: (value) {
                        selectedCompany.value = value.toString();
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
                    );
            }),

            12.heightBox,
            CustomDropDown(
              value: "Today",
              hint: "Select visiting date",
              values: dates,
              selectedValue: selectedDate,
            ),
          ]
          
        ),
      ),
    );
  }

  Widget getAppBarUI() {
    final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                ProfileAvatar(
                  uid: Constants.userId,
                  height: 50,
                  width: 50,
                  data: Constants.userData,
                ),
                12.widthBox,
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width/2.2,
                      child: Text(
                          Constants.type == null
                              ? 'New user'
                              : Constants.userData.firstName,
                          textAlign: TextAlign.left,
                          
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppTheme.subheading.copyWith(fontSize: 23,height: 1)),
                    ),
                    4.heightBox,
                    SizedBox(
                       width: MediaQuery.of(context).size.width/2.2,
                      child: Text(
                          Constants.type == "guard"
                              ? "SECURITY"
                              : Constants.userData.type == "user"
                                  ? "-"
                                  : "${Constants.userData.house}, ${Constants.userData.block}",
                       overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppTheme.smallText),
                    )
                  ],
                ),
              ],
            ),
          ),
          getNotificationIcon(),
          16.widthBox,
          Stack(
            children: [
              const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                color: Colors.black87,
                size: 26,
              ),

              userinfo!.newMessage.length != 0
                  ? Positioned(
                      right: 3,
                      top: 3,
                      child: Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                              color: Colors.red[400], shape: BoxShape.circle)))
                  : const SizedBox(),
            ],
          ).onTap(() {
            Get.to(RoomsPage(
              userData: userinfo,
            ));
          }),
          12.widthBox,
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> getNotificationIcon() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(Constants.userId)
            .collection('notifications')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Icon(
              CupertinoIcons.bell_fill,
              color: Colors.black87,
              size: 26,
            ).onTap(() {
              Get.to(const NotificationPage());
            });
          } else {
            notificationCounts = notificationCounts > snapshot.data!.docs.length
                ? snapshot.data!.docs.length
                : notificationCounts;
            return Stack(
              children: [
                const Icon(
                  CupertinoIcons.bell_fill,
                  color: Colors.black87,
                  size: 26,
                ),
                snapshot.data!.docs.length > notificationCounts
                    ? Positioned(
                        right: 3,
                        top: 3,
                        child: Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                                color: Colors.red[400],
                                shape: BoxShape.circle)))
                    : const SizedBox(),
              ],
            ).onTap(() {
              Get.to(const NotificationPage());
              notificationCounts = snapshot.data!.docs.length;
            });
          }
        });
  }

  Image? imagenew(){
    return Image.asset('');
  }

  Future _shareQRImage(String url) async {

    QrCode qrCode = QrCode.fromData(
      data: url,
      errorCorrectLevel: QrErrorCorrectLevel.H,



    );

    QrImage qrImage = QrImage(qrCode);
final image = await qrImage.toImageAsBytes(size: 300,);


    const filename = 'qr_code.png';
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$filename').create();
    var bytes = image!.buffer.asUint8List();
    await file.writeAsBytes(bytes);
    // ignore: deprecated_member_use
    Share.shareFiles([file.path],
        text: '', subject: 'QR Code', mimeTypes: ['image/png']);
  }

  Future<dynamic> visitorCard(UserVisitor data) {
    return showDialog(
        context: context, builder: (context) => VisitorQRCard(data));
  }

  // ignore: non_constant_identifier_names
  Center VisitorQRCard(UserVisitor data) {
    
    DateTime visitDate = data.visitDate.toDate();
    // final model.UserData? user = Provider.of<UserProvider>(context).getUser;
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 6,
            width: 70,
            decoration: BoxDecoration(
                color: AppTheme.buttonColor,
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
                        color: AppTheme.buttonColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22)))),
                            12.heightBox,
                            SizedBox(width: 200, child: Text("*This QR is not for scan please use the share option below",style: AppTheme.smallText.copyWith(fontSize: 10),)),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 130,
                    width: 130,
                    child:
                    // PrettyQrView(
                    //       qrImage: qrImage,
                    //       decoration: decoration,
                    //     ),

                    
                    
                    
                    SfBarcodeGenerator(
                      
          value: 'www.syncfusion.com',
          symbology: QRCode(),
           
          showValue: true,
        ),
                    //  QrImageView(
                    //   data: "ERROR"+visitDate.day.toString() +
                    //       visitDate.month.toString() +
                    //       visitDate.year.toString(),
                    //   version: QrVersions.auto,
                    //   size: 100.0,
                    // ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.centerLeft,
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                            color: const Color.fromARGB(255, 141, 191, 217)
                                .withOpacity(0.1),
                            width: 3),
                      ),
                      child: data.count!.contains("1")
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Lottie.asset("assets/bike.json"),
                            )
                          : data.count!.contains("3")
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Lottie.asset(
                                    "assets/car.json",
                                  ),
                                )
                              : data.count!.contains("5 +")
                                  ? Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Lottie.asset(
                                        "assets/bus.json",
                                      ),
                                    )
                                  : Lottie.asset(
                                      "assets/delivery.json",
                                    ),
                    ),
                    12.widthBox,
                    SizedBox(
                      width: 105,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(data.guestName!,
                              textAlign: TextAlign.left,
                              style: AppTheme.subheading2),
                          Text('at ' +data.house! + ", " + data.block!,
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
                      FireStoreMethods().deleteVisitor(data.guestId!);
                    }),
                    12.widthBox,
                    const Icon(
                      Icons.share_rounded,
                      color: AppTheme.darkText,
                      size: 28,
                    ).onTap(() {
                       SfBarcodeGenerator n =  SfBarcodeGenerator(value: "value");
                       
                      _shareQRImage(
                        "${visitDate.day}${visitDate.month}${visitDate.year}€${data.guestName}€${Constants.userData.house}€${Constants.userData.block}€${data.count}",
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
}

