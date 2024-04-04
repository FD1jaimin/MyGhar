// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:path_provider/path_provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/notification_method.dart';
import 'package:urbannest/views/home_screen.dart';
import 'package:urbannest/views/prof.dart';
import 'package:urbannest/views/rules_screen.dart';
import 'package:urbannest/views/service_screen.dart';
import 'package:urbannest/views/settings_screen.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../app_theme.dart';
import '../controllers/navigation_controller.dart';
import '../core/user_provider.dart';
import '../models/user.dart';
import '../widgets/dialog.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper>
    with TickerProviderStateMixin {
  final navigationController = Get.put(NavigationController(), permanent: true);
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animationController.animateTo(0.2);
    super.initState();
    addData();
    assignTopics();
  }

  addData() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'token': fcmToken,
    }).then((value) => print('token set'));
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  assignTopics() async {
    if (Constants.type != 'user') {
      await FirebaseMessaging.instance.subscribeToTopic(Constants.societyId);
    }
    // await FirebaseMessaging.instance
    //     .unsubscribeFromTopic('admin-${Constants.societyId}');
    // await FirebaseMessaging.instance
    //     .unsubscribeFromTopic('guard-${Constants.societyId}');
    // await FirebaseMessaging.instance
    //     .unsubscribeFromTopic('member-${Constants.societyId}');
    if (Constants.type == 'admin') {
      await FirebaseMessaging.instance
          .subscribeToTopic('admin-${Constants.societyId}');
    } else if (Constants.type == 'guard') {
      await FirebaseMessaging.instance
          .subscribeToTopic('guard-${Constants.societyId}');
    } else if (Constants.type == 'member') {
      await FirebaseMessaging.instance
          .subscribeToTopic('member-${Constants.societyId}');
    }
  }

  late PageController _pageController;
  List<String> items = [
    "Fire Alert",
    "Stuck in Lift",
    "Animal Threat",
    "Visitor Threat",
  ];
  List<String> title = [
    "Fire Alert!",
    "Emergency: Stuck in Elevator",
    "Animal Alert!",
    "Security Alert: Visitor Threat",
  ];
  List<String> body = [
    "Fire detected in the vicinity.\nBlock : ${Constants.userData.block} & by : ${Constants.userData.firstName}\nEvacuate immediately. Use stairwells. Follow safety procedures. Stay calm.",
    "Someone is stuck in the elevator.\nBlock : ${Constants.userData.block} & by : ${Constants.userData.firstName}\nPlease check and help them as soon as possible",
    "An animal has been spotted in the vicinity.\nBlock : ${Constants.userData.block} & by : ${Constants.userData.firstName}\n For your safety, please avoid approaching. ",
    "A potential security threat posed by a visitor has been identified.\nBlock : ${Constants.userData.block} & by : ${Constants.userData.firstName}\n Please remain vigilant and report any suspicious activity immediately to guards."
  ];
  List<String> icons = ["🧯", "🛗", "🦖", "🥷🏿"];

  List<String> topic = [
    Constants.societyId,
    "guard-${Constants.societyId}",
    Constants.societyId,
    Constants.societyId,
  ];

  @override
  Widget build(BuildContext buildcontext) {
    final UserData? user = Provider.of<UserProvider>(context).getUser;
    final googleuser = FirebaseAuth.instance.currentUser;
    _pageController =
        PageController(initialPage: navigationController.currentIndex.value);

    return GetX<NavigationController>(
        builder: (navigationController) => AdvancedDrawer(
              backdropColor: AppTheme.appColor,
              drawer: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    44.heightBox,
                    _buildDrawerBack(navigationController),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                            left: 24, top: 24, bottom: 24),
                        children: <Widget>[
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppTheme.lightBackgroundColor,
                                  width: 2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 0),
                                    blurRadius: 8,
                                    color: AppTheme.appColor.withOpacity(0.08))
                              ],
                              // image: DecorationImage(
                              //     fit: BoxFit.contain,
                              //     image: )
                            ),
                            width: 124,
                            height: 124,
                            child: googleuser != null &&
                                    googleuser.photoURL != null &&
                                    googleuser.photoURL != ""
                                ? SizedBox(
                                    width: 124,
                                    height: 124,
                                    child: Image.network(
                                      googleuser.photoURL!,
                                      fit: BoxFit.cover,
                                    ))
                                : user != null
                                    ? user.imageUrl == ""
                                        ? Lottie.asset("assets/profile.json")
                                        : SizedBox(
                                            width: 124,
                                            height: 124,
                                            child: Image.network(
                                              user.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ) //NetworkImage
                                    : Lottie.asset("assets/profile.json"), //
                          ),
                          36.heightBox,
                          _buildUserDetails(user, googleuser),
                          24.heightBox,
                          BoxWidget(
                            Icons.shield,
                            "Security Alert",
                            "Alert everyone of threats",
                            () {
                              navigationController.advancedDrawerController
                                  .hideDrawer();
                              if (Constants.type != 'user') {
                                showDialog(
                                  context: buildcontext,
                                  
                                  builder: (context) => CustomDialog(
                                    child: _buildPopUp(context),
                                  ),
                                );
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please wait for the approval");
                              }
                            },
                          ),
                          BoxWidget(
                              Icons.rule, "Society Rules", "Follow this rules",
                              () {
                            navigationController.advancedDrawerController
                                .hideDrawer();
                            Get.to(const RulesScreen());
                          }),
                          BoxWidget(
                              Icons.settings, "Settings", "Setup you app here",
                              () {
                            navigationController.advancedDrawerController
                                .hideDrawer();
                            Get.to(const SettingsScreen());
                          }),
                          Padding(
                              padding: const EdgeInsets.all(24),
                              child: CustomButton(
                                height: 58,
                                width: 140,
                                onTap: () async{
                                  navigationController.advancedDrawerController
                                      .hideDrawer();
                                  await FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          Constants.societyId);
                                  await FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'admin-${Constants.societyId}');
                                  await FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'member-${Constants.societyId}');
                                  await FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'guard-${Constants.societyId}');

                                  _deleteCacheDir();
                                  /// this will delete cache

                                  await FirebaseAuth.instance.signOut();
                                },
                                text: 'Log Out',
                              ))
                        ],
                      ),
                    ),
                    // Expanded(
                    //   child: MainDrawer(
                    //     context: context,
                    //   ),
                    // )
                  ],
                ),
              ),
              controller: navigationController.advancedDrawerController,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 500),
              animateChildDecoration: true,
              rtlOpening: false,
              openScale: 0.85,
              openRatio: 0.7,
              // disabledGestures: true,
              childDecoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),

              child: Scaffold(
                  body: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [HexColorNew("#c0eaf8"), Colors.white],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                      ),
                      Image.asset("assets/bg.png",
                          fit: BoxFit.cover, width: double.infinity),
                      SizedBox.expand(
                        child: PageView(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _pageController,
                            onPageChanged: (index) {
                              navigationController.onPageChange(index);
                            },
                            children: const <Widget>[
                              HomeScreen(),
                              ServiceScreen(), ProfilePage(),
                              // HomeScreen(animationController: _animationController),
                              // MyCoursePage(),
                              // MyGroupsScreen(),
                            ]),
                      ),
                    ],
                  ),
                  bottomNavigationBar: Container(
                    color: const Color.fromARGB(255, 253, 255, 255),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        child: GNav(
                          gap: 16,
                          backgroundColor: Colors.transparent,
                          activeColor: Colors.white.withOpacity(0.95),
                          iconSize: 21,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 18),
                          duration: const Duration(milliseconds: 400),
                          tabBackgroundColor:
                              AppTheme.appColor, //Colors.grey[100]!,
                          color: AppTheme.appColor,
                          // curve: Curves.slowMiddle,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          tabs: const [
                            GButton(
                              icon: FontAwesomeIcons.home,
                              text: 'Home',
                            ),
                            GButton(
                              icon: FontAwesomeIcons.screwdriver,
                              text: 'Services',
                            ),
                            GButton(
                              icon: FontAwesomeIcons.person,
                              text: 'Profile',
                            ),
                          ],
                          selectedIndex:
                              navigationController.currentIndex.value,
                          onTabChange: (index) {
                            // navigationController.onPageChange(index);
                            _pageController.jumpToPage(index);
                            // _pageController.animateToPage(
                            //   index,
                            //   duration: Duration(milliseconds: 900),
                            //   curve: Curves.fastOutSlowIn,
                            // );
                            // if (index == 0) {
                            _animationController.animateBack(0.2);
                            // } else if (index == 1) {
                            //   _animationController?.animateTo(0.4);
                            // } else if (index == 2) {
                            //   _animationController?.animateTo(0.6);
                            // }
                          },
                        ),
                      ),
                    ),
                  )),
            ));
  }

  SizedBox _buildPopUp(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          8.heightBox,
          const Text(
            'Security Alert',
            style: AppTheme.subheading2,
            textAlign: TextAlign.center,
          ),
          14.heightBox,
          GridView(
            padding: const EdgeInsets.all(6),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // ignore: sort_child_properties_last
            children: List<Widget>.generate(
              items.length,
              (int index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: AppTheme.lightText.withOpacity(0.2), width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 8),
                          child: Text(
                            items[index],
                            style: AppTheme.subheading3.copyWith(
                                color: AppTheme.appColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              icons[index],
                              style: AppTheme.heading.copyWith(fontSize: 34),
                            ),
                          )),
                    ],
                  ),
                ).onTap(() async {
                  Get.back();
                  Fluttertoast.showToast(msg: "Alert Sent! Be Safe.");
                  await NotificationMethods().sendNotificationTopics(
                      body: body[index],
                      title: title[index],
                      type: 'alert',
                      to: '/topics/${topic[index]}');
                //   await NotificationMethods().sendNotificationTopics(
                //       body: body[index],
                //       title: title[index],
                //       type: 'alert',
                //       to: '/topics/guard-${topic[index]}');
                });
              },
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1,
            ),
          ),
        ],
      ),
    );
  }

  Column _buildUserDetails(UserData? user, User? googleuser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user == null ? googleuser?.displayName ?? "" : user.firstName,
          style: AppTheme.subheading.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          user == null
              ? ""
              : user.type == "guard"
                  ? "SECURITY"
                  : user.type == "user"
                      ? "Not Approved"
                      : "${user.house}, ${user.block}",
          style: AppTheme.smallText,
        )
      ],
    );
  }

  Padding _buildDrawerBack(NavigationController navigationController) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16,
      ),
      child: GestureDetector(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0x003124A1),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color.fromARGB(8, 23, 23, 23),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(80),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: const Color.fromRGBO(57, 75, 123, 0.9),
              width: 1.8,
            ),
          ),
          alignment: const AlignmentDirectional(-0.0, 0),
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        onTap: () {
          navigationController.advancedDrawerController.hideDrawer();
          // refference!.read(drawerControllerProvider).hideDrawer();
        },
      ),
    );
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  BoxWidget(
      IconData icon, String heading, String description, Function() onpressed) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 0),
                blurRadius: 0,
                color: AppTheme.appColor.withOpacity(0))
          ],
          borderRadius: const BorderRadius.all(Radius.circular(26.0)),
          // border: new Border.all(
          //     color: DesignCourseAppTheme.notWhite),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 54,
              width: 54,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                    child: Icon(
                  icon,
                  color: Colors.white,
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading, // "Introduction",

                    style: AppTheme.subheading.copyWith(color: Colors.white),
                  ),
                  Text(
                    description,
                    style: AppTheme.smallText,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
