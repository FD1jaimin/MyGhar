// ignore_for_file: curly_braces_in_flow_control_structures, must_be_immutable, depend_on_referenced_packages, library_private_types_in_public_api, prefer_typing_uninitialized_variables, deprecated_member_use, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:share_plus/share_plus.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/models/user.dart';
import 'package:urbannest/views/chats/chat.dart';
import 'package:urbannest/views/guard_members_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:urbannest/widgets/floating_action_button.dart';
import 'package:urbannest/widgets/profile_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/notification_method.dart';
import '../core/storage_method.dart';
import '../widgets/text_fields.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  State<MemberScreen> createState() => _NoticeState();
}

var _file = Uint8List(0).obs;

var isLoading = false.obs;

TextEditingController searchController = TextEditingController();
var searchText = ''.obs;

class _NoticeState extends State<MemberScreen> with TickerProviderStateMixin {
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  final TextEditingController date = TextEditingController();

  late TabController pageController;

  @override
  void initState() {
    pageController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: Constants.type == "admin"
          ? CustomFloatingActionButton(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    child: _buildPopUp(context),
                  ),
                );
                // Respond to button press
              },
            )
          : const SizedBox(),
      body: SafeArea(
          child: DefaultTabController(
        initialIndex: 0,
        length: 2,
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
                        "Members",
                        style:
                            AppTheme.subheading.copyWith(letterSpacing: -0.3),
                      ),
                    ),
                  ],
                )),
            (Constants.type == "admin" || Constants.type == "guard")
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    child: CustomTextField(
                        isForm: true,
                        onChanged: (value) {
                          searchController.text = value;
                          searchText.value = value;
                        },
                        textController: searchController,
                        hint: "Search name",
                        icon: const Icon(Icons.search),
                        validator: (value) {
                          return null;
                        }),
                  )
                : 0.heightBox,
            (Constants.type == "admin" || Constants.type == "guard")
                ? 6.heightBox
                : 0.heightBox,
            TabBar(
                indicatorColor: AppTheme.appColor,
                labelPadding: const EdgeInsets.all(8),
                enableFeedback: false,
                dividerColor: Colors.transparent,
                labelColor: AppTheme.appColor,
                controller: pageController,
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.transparent;
                }),
                labelStyle:
                    AppTheme.smallText.copyWith(fontWeight: FontWeight.bold),
                tabs: const [Text("Members"), Text("Chairmen")]),
            Expanded(
              child: TabBarView(controller: pageController, children: [
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: getMembersList(false),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: getMembersList(true),
                ),
              ]),
            )
          ],
        ),
      )),
    );
  }

  SizedBox _buildPopUp(BuildContext context) {
    return SizedBox(
      // height: 410,
      width: MediaQuery.of(context).size.width - 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              8.heightBox,
              const Text(
                'Add members',
                style: AppTheme.subheading2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          12.heightBox,
          const Text(
            "Share this code with your society members for a smooth and seamless entry into the community.",
            style: AppTheme.smallText,
          ),
          16.heightBox,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color.fromARGB(255, 105, 110,
                    116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                width: 2,
              ),
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Center(
                      child: Text(
                    Constants.userData.societyCode!,
                    style: AppTheme.subheading,
                  )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: const Icon(
                          FontAwesomeIcons.share,
                          color: AppTheme.lightText,
                          size: 26,
                        ).onTap(() async {
                          Fluttertoast.showToast(msg: "Copied to Clipboard");
                          await Clipboard.setData(ClipboardData(
                              text: Constants.userData.societyCode!));
                          Share.share(
                              // ignore: prefer_adjacent_string_concatenation
                              "Use this code to effortlessly connect with your fellow society members and join our community:\n" +
                                  '\n' +
                                  "${Constants.userData.societyCode!}.\n\n Enjoy seamless access to society updates and events by entering this code during registration.\n https://play.google.com/store/apps/details?id=com.shelter.myghar");
                          // copied successfully
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          16.heightBox,
          const Text(
            "Note: Kindly refrain from sharing this code with non-society members. Prior to approval, please verify and ensure the authenticity of the member.",
            style: AppTheme.smallText,
          ),
        ],
      ),
    );
  }

  Widget getMembersList(bool isAdmin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: MyMembersList(isAdmin: isAdmin),
    );
  }
}

class MyMembersList extends StatefulWidget {
  const MyMembersList({
    super.key,
    this.isAdmin = false,
  });
  final bool isAdmin;
  @override
  _MyMembersListState createState() => _MyMembersListState();
}

class _MyMembersListState extends State<MyMembersList>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  BannerAd? bannerAd;

  @override
  void initState() {
    bannerAd = Constants.initBannerAdd(size: AdSize.largeBanner);
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
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: StreamBuilder(
          stream: !widget.isAdmin
              ? ((searchText.value != "")
                  ? (searchText.value.isDigit()
                      ? FirebaseFirestore.instance
                          .collection('users')
                          .where('societyId', isEqualTo: Constants.societyId)
                          .where('house',
                              isGreaterThanOrEqualTo: searchText.value.trim())
                          .where('house',
                              isLessThan: searchText.value.trim() + '9')
                          .limit(8)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('users')
                          .where('societyId', isEqualTo: Constants.societyId)
                          .where('searchName',
                              isGreaterThanOrEqualTo:
                                  searchText.value.toLowerCase().trim())
                          .where('searchName',
                              isLessThan:
                                  searchText.value.toLowerCase().trim() + 'z')
                          .limit(8)
                          .snapshots())
                  : FirebaseFirestore.instance
                      .collection('users')
                      .where('societyId', isEqualTo: Constants.societyId)
                      .snapshots())
              : searchText.value == ""
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .where('societyId', isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('users')
                      .where('societyId', isEqualTo: Constants.societyId)
                      .where('type', isEqualTo: 'admin')
                      .where('searchName',
                          isGreaterThanOrEqualTo:
                              searchText.value.toLowerCase().trim())
                      .where(
                        'searchName',
                      )
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
                      // physics: const NeverScrollableScrollPhysics(),
                      // shrinkWrap: true,
                      children: List<Widget>.generate(
                        names.length + 1,
                        (int i) {
                          List<UserData> temp = i == names.length
                              ? data[names[i - 1]]!
                              : data[names[i]]!;
                          return i == names.length
                              ? widget.isAdmin && Constants.showAd
                                  ? getAd()
                                  : const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    widget.isAdmin
                                        ? const SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                left: 24,
                                                right: 24,
                                                bottom: 8,
                                                top: 16),
                                            child: Text(
                                              names[i] == "zzzzz"
                                                  ? "Others"
                                                  : names[i],
                                              style: AppTheme.subheading,
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                    ListView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: List<Widget>.generate(
                                          temp.length, (int index) {
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
                                            memberData: temp[index],
                                            snap: snapshot.data!.docs[index]
                                                .data(),
                                            animation: animation,
                                            animationController:
                                                animationController,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                );
                        },
                      ),
                    );
            }
          },
        ),
      );
    });
  }

  getAd() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24),
      child: SizedBox(height: 120, child: AdWidget(ad: bannerAd!)),
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
      this.callback})
      : super(key: key);

  final snap;
  final int? index;
  final VoidCallback? callback;
  final UserData? memberData;
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
              child: MemberCard(
                context,
                data: memberData!,
              ).onTap(() {
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
                            if (!isLoading.value) {
                              isLoading.value = true;

                              _file.value = await compressImage(_file.value);
                              String guestID = const Uuid().v1();
                              imageUrl = await StorageMethods()
                                  .uploadImageToStorage(
                                      'visitors', _file.value, guestID);

                              await NotificationMethods()
                                  .sendGuardAskNotification(
                                      imageUrl: imageUrl,
                                      name: nameContoller.text,
                                      count: selectedPeople,
                                      targetId: data.token,
                                      targetUID: data.uid);

                              imageUrl = "";
                              isLoading.value = false;
                              _file.value = Uint8List(0);
                              nameContoller.clear();
                              Get.back();
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16.0),
                            child: isLoading.value
                                ? Center(
                                    child: LoadingAnimationWidget.waveDots(
                                        color: Colors.white, size: 40),
                                  )
                                : Row(
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
                    return (type.value == "user" || type.value == "extra") &&
                            Constants.type != "admin"
                        ? const SizedBox()
                        : Container(
                            child: (type.value == 'member' ||
                                        type.value == 'user' ||
                                        type.value == 'extra') &&
                                    Constants.type == "admin"
                                ? Text(
                                    '+ Add Role',
                                    style: AppTheme.smallText.copyWith(
                                        color: Colors.green[400],
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.green[400]),
                                  )
                                : Container(
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: type.value == "member"
                                          ? Colors.orangeAccent.withOpacity(0.1)
                                          : type.value == "guard"
                                              ? const Color.fromARGB(
                                                      255, 30, 99, 160)
                                                  .withOpacity(0.1)
                                              : AppTheme.appColor
                                                  .withOpacity(0.1),
                                      border: Border.all(
                                          color: type.value == "member"
                                              ? Colors.orangeAccent
                                                  .withOpacity(0.4)
                                              : type.value == "guard"
                                                  ? const Color.fromARGB(
                                                          255, 30, 99, 160)
                                                      .withOpacity(0.4)
                                                  : AppTheme.appColor
                                                      .withOpacity(0.4),
                                          width: 2),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12)),
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
                                  ),
                          ).onTap(() {
                            List<String> types = [
                              "admin",
                              "guard",
                              "member",
                              "user"
                            ];
                            List<String> name = [
                              "Chairman",
                              "Guard",
                              "Member",
                              "⨯ Remove"
                            ];
                            List<Color> color = [
                              AppTheme.appColor,
                              const Color.fromARGB(255, 30, 99, 160),
                              Colors.orangeAccent,
                              const Color.fromARGB(255, 238, 82, 79)
                            ];
                            if (Constants.type == "admin" &&
                                data.uid != Constants.userId)
                              showDialog(
                                  context: context,
                                  builder: (context) => Center(
                                          child: Container(
                                        width: 250,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32)),
                                        ),
                                        // width: 180,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 24,
                                              right: 24,
                                              bottom: 24,
                                              top: 24),
                                          child: GridView.builder(
                                            shrinkWrap: true,

                                            // children: [],
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 6,
                                              crossAxisSpacing: 6,
                                              childAspectRatio: 2.3,
                                            ),
                                            itemCount: 4,
                                            itemBuilder: (context, i) {
                                              return Container(
                                                  width: 100,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: color[i]
                                                        .withOpacity(0.1),
                                                    border: Border.all(
                                                        color: color[i]
                                                            .withOpacity(0.4),
                                                        width: 2),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                12)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Center(
                                                      child: Text(name[i],
                                                          style: AppTheme
                                                              .smallText
                                                              .copyWith(
                                                                  color: color[
                                                                      i])),
                                                    ),
                                                  )).onTap(() async {
                                                dynamic societyData =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('societies')
                                                        .doc(
                                                            Constants.societyId)
                                                        .get();
                                                if (types[i] != 'admin' &&
                                                    data.type == 'admin') {
                                                  FirebaseFirestore.instance
                                                      .collection('rooms')
                                                      .doc(societyData[
                                                          'societyAdminGroupId'])
                                                      .update({
                                                    'userIds':
                                                        FieldValue.arrayRemove(
                                                            [data.uid]),
                                                  });
                                                  FirebaseMessaging.instance
                                                      .subscribeToTopic(
                                                          'admin-${Constants.societyId}');
                                                }
                                                if (types[i] == "guard") {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(data.uid)
                                                      .update({
                                                    'block': "zzzzz",
                                                    "house": '',
                                                    'type': types[i]
                                                  });
                                                  FirebaseMessaging.instance
                                                      .subscribeToTopic(
                                                          'guard-${Constants.societyId}');
                                                } else if (types[i] ==
                                                    "admin") {
                                                  if (data.house != "" &&
                                                      data.block != "zzzzz") {
                                                    FirebaseMessaging.instance
                                                        .subscribeToTopic(
                                                            'admin-${Constants.societyId}');

                                                    FirebaseFirestore.instance
                                                        .collection('rooms')
                                                        .doc(societyData[
                                                            'societyAdminGroupId'])
                                                        .update({
                                                      'userIds':
                                                          FieldValue.arrayUnion(
                                                              [data.uid]),
                                                    });
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(data.uid)
                                                        .update(
                                                            {'type': types[i]});
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'No house is assigned to user');
                                                  }
                                                } else if (types[i] ==
                                                    "member") {
                                                  if (data.house != "" &&
                                                      data.block != "zzzzz") {
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(data.uid)
                                                        .update(
                                                            {'type': types[i]});
                                                    await FirebaseMessaging
                                                        .instance
                                                        .subscribeToTopic(
                                                            'member-${Constants.societyId}');
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'No house is assigned to user');
                                                  }
                                                } else {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(data.uid)
                                                      .update({
                                                    'societyId': "",
                                                    'societyCode': "",
                                                    'societyName': "",
                                                    'societyGroupId': '',
                                                    'societyAdminGroupId': '',
                                                    'block': "",
                                                    "sector": "",
                                                    "address": "",
                                                    "type": 'user',
                                                  });
                                                  FirebaseFirestore.instance
                                                      .collection('rooms')
                                                      .doc(Constants.userData
                                                          .societyGroupId)
                                                      .update({
                                                    'userIds':
                                                        FieldValue.arrayRemove(
                                                            [Constants.userId]),
                                                  });
                                                  FirebaseFirestore.instance
                                                      .collection('rooms')
                                                      .doc(Constants.userData
                                                          .societyAdminGroupId)
                                                      .update({
                                                    'userIds':
                                                        FieldValue.arrayRemove(
                                                            [Constants.userId]),
                                                  });
                                                }
                                                type.value = types[i];
                                                Get.back();
                                                Get.back();
                                              });
                                            },
                                          ),
                                        ),
                                      )));
                          });
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
                                        (type.value == "user" ||
                                                type.value == "extra")
                                            ? ""
                                            : data.house!,
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
                                        (type.value == "user" ||
                                                type.value == "extra")
                                            ? ""
                                            : data.block!,
                                        style: AppTheme.smallText,
                                        textAlign: TextAlign.center,
                                      ))
                                ],
                              )

                              // Image.asset(data.icon),
                            ],
                          ),
                        ),
                  Constants.userId == data.uid
                      ? SizedBox(
                          height: 16,
                          width: double.infinity,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 24, bottom: 12),
                          child: Column(
                            children: [
                              Row(
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
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            color: AppTheme.buttonColor,
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              Uri phoneno = Uri.parse(
                                                  'tel:+${data.phone}');
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                          padding:
                                              const EdgeInsets.only(left: 24),
                                          child: GestureDetector(
                                            onTap: () async {
                                              _file.value = await pickImage(
                                                  ImageSource.camera);
                                            },
                                            child: Container(
                                              height: 54,
                                              width: 112,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: AppTheme.buttonColor,
                                              ),
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
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                          Constants.type == "user" ||
                                          data.type! == "guard" ||
                                          data.type == "user" ||
                                          data.type == "extra"
                                      ? const SizedBox()
                                      : CustomButton(
                                          onTap: () {
                                            types.User chatUser =
                                                Constants.changeUserChat(data);

                                            _handlePressed(chatUser, context);
                                          },
                                          height: 54,
                                          width: 112,
                                          text: "Chat",
                                          iconData:
                                              CupertinoIcons.chat_bubble_2),
                                ],
                              ),
                              12.heightBox,
                              Constants.type == 'guard'
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 24, right: 24, bottom: 8),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await NotificationMethods()
                                              .sendGuardDeliveryAskNotification(
                                                  targetId: data.token,
                                                  targetUID: data.uid);
                                          Get.back();
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Approval request send to member");

                                          // _file.value = await pickImage(
                                          //     ImageSource.camera);
                                        },
                                        child: Container(
                                          height: 54,
                                          // width: 112,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            color: AppTheme.buttonColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0, right: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "DELIVERY",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                12.widthBox,
                                                const Icon(
                                                  CupertinoIcons.cube_box,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
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
      minHeight: 250,
      minWidth: 250,
      quality: 40,
    );
    return result;
  }
}

class MemberCard extends StatelessWidget {
  MemberCard(
    this.context, {
    required this.data,
    this.subtitle = "",
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final UserData data;
  String subtitle;
  @override
  Widget build(BuildContext context) {
    if (subtitle == "") subtitle = data.email;
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
                    data: data,
                    uid: data.uid,
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
                        Text(data.firstName, style: AppTheme.subheading2),
                        const SizedBox(height: 8),
                        Text(
                          data.type == 'user' ||
                                  (data.block == "zzzzz" && data.house == "")
                              ? "-"
                              : "${data.house!}, ${data.block}",
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
          (data.isTenant!)
              ? Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    "TENANT",
                    style: AppTheme.smallText.copyWith(
                        color: const Color.fromARGB(255, 239, 174, 71)),
                  ),
                )
              : (data.type == "user" ||
                      data.type == "member" ||
                      data.type == "extra")
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Text(
                        data.type == "admin" ? "CHAIRMEN" : "GUARD",
                        style: AppTheme.smallText.copyWith(
                            color: data.type == "admin"
                                ? AppTheme.appColor
                                : const Color.fromARGB(255, 30, 99, 160)),
                      ),
                    )
        ],
      ),
    );
  }
}
