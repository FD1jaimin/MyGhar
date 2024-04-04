// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/core/notification_method.dart';
import 'package:urbannest/main.dart';
import 'package:urbannest/models/notices.dart';
import 'package:urbannest/views/helpdesk_screen.dart';
import 'package:urbannest/views/notice_screen.dart';
import 'package:urbannest/views/rules_screen.dart';
import 'package:urbannest/views/settings_screen.dart';
import 'package:urbannest/views/stores_screen.dart';
import 'package:urbannest/views/vehicle_screen.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../app_theme.dart';
import '../controllers/navigation_controller.dart';
import '../core/constants.dart';
import '../core/user_provider.dart';
import '../models/user.dart' as model;
import '../models/user.dart';
import '../widgets/notice_card.dart';
import '../widgets/profile_avatar.dart';
import 'handymen_screen.dart';
import 'in_out_screen.dart';
import 'member_screen.dart';
import 'notification_screen.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with TickerProviderStateMixin {
  final navigationController = Get.put(NavigationController(), permanent: true);
  late AnimationController _animationController;
  

  @override
  void initState() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {

      // if (message.data["navigation"] == "/your_route") {
      // int _yourId = int.tryParse(message.data["id"]) ?? 0;
      Navigator.push(
          navigatorKey.currentState!.context,
          MaterialPageRoute(
              builder: (context) => const NoticeScreen(
                  // yourId:_yourId,
                  )));
      // }
    });

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animationController.animateTo(0.2);
    
    super.initState();
    addData();
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
  }

  addData() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

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
    "Fire detected in the vicinity. Evacuate immediately. Use stairwells. Follow safety procedures. Stay calm.",
    "Someone is stuck in the elevator. Please check and help them as soon as possible",
    "An animal has been spotted in the vicinity. For your safety, please avoid approaching. ",
    "A potential security threat posed by a visitor has been identified. Please remain vigilant and report any suspicious activity immediately to guards."
  ];
  List<String> icons = ["🧯", "🛗", "🦖", "🥷🏿"];
  // List<Widget> screens = [MemberScreen(), NoticeScreen(),GalleryScreen()];

  @override
  Widget build(BuildContext context) {
    final UserData? user = Provider.of<UserProvider>(context).getUser;
    final googleuser = FirebaseAuth.instance.currentUser;

    return 
   AdvancedDrawer(
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
                                left: 36, top: 24, bottom: 24),
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppTheme.lightBackgroundColor,
                                      width: 2),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        offset: const Offset(0, 0),
                                        blurRadius: 8,
                                        color:
                                            AppTheme.appColor.withOpacity(0.08))
                                  ],
                                  // image: DecorationImage(
                                  //     fit: BoxFit.contain,
                                  //     image: user != null
                                  //         ? user.photoUrl == "" ||
                                  //                 user.photoUrl == null
                                  //             ? AssetImage("assets/me.jpeg")
                                  //             : AssetImage(user.photoUrl) //NetworkImage
                                  //         : AssetImage("assets/me.jpeg"))
                                ),
                                width: 124,
                                height: 124,
                                child: Lottie.asset("assets/profile.json"),
                              ),
                              36.heightBox,
                              _buildUserDetails(user, googleuser),
                              24.heightBox,
                              Container(
                                child: BoxWidget(Icons.shield, "Security Alert",
                                    "Alert everyone of threats", () {}),
                              ).onTap(() {
                                navigationController.advancedDrawerController
                                    .hideDrawer();

                                showDialog(
                                  context: context,
                                  
                                  builder: (context) => CustomDialog(
                                     
                                        child: SizedBox(
                                          height: 320,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              120,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
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
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    mainAxisSpacing: 8.0,
                                                    crossAxisSpacing: 8.0,
                                                    childAspectRatio: 1,
                                                  ),
                                                  children:
                                                      List<Widget>.generate(
                                                    items.length,
                                                    (int index) {
                                                      return Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: AppTheme
                                                                  .lightText
                                                                  .withOpacity(
                                                                      0.2),
                                                              width: 2),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          24)),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16,
                                                                    horizontal:
                                                                        8),
                                                                child: Text(
                                                                  items[index],
                                                                  style: AppTheme
                                                                      .subheading3
                                                                      .copyWith(
                                                                          color: AppTheme
                                                                              .appColor,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                            Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              16.0),
                                                                  child: Text(
                                                                    icons[
                                                                        index],
                                                                    style: AppTheme
                                                                        .heading
                                                                        .copyWith(
                                                                            fontSize:
                                                                                50),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ).onTap(() {
                                                        NotificationMethods()
                                                            .sendNotificationTopics(
                                                                body:
                                                                    body[index],
                                                                title: title[
                                                                    index],
                                                                to: '/topics/all');
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Alert Sent! Be Safe.");
                                                        Get.back();
                                                        // Get.to(screens[index]);
                                                      });
                                                    },
                                                  ),
                                                ),

                                                // 16.heightBox,
                                                // CustomTextField(
                                                //     icon: Icon(Icons.gite_rounded),
                                                //     isForm: true,
                                                //     keyboardType: TextInputType.name,
                                                //     hint: "Enter Amenity name",
                                                //     validator: (value) {
                                                //       return null;
                                                //     },
                                                //     textController: name),
                                                // 12.heightBox,
                                              ]),
                                        ),
                                      ),
                                    );
                                
                              }),
                              Container(
                                child: BoxWidget(Icons.rule, "Society Rules",
                                    "Follow this rules", () {}),
                              ).onTap(() {
                                navigationController.advancedDrawerController
                                    .hideDrawer();
                                Get.to(const RulesScreen());
                              }),
                              Container(
                                child: BoxWidget(Icons.settings, "Settings",
                                    "Setup you app here", () {}),
                              ).onTap(() {
                                navigationController.advancedDrawerController
                                    .hideDrawer();
                                Get.to(const SettingsScreen());
                              }),
                              Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: CustomButton(
                                    height: 58,
                                    width: 140,
                                    onTap: () {
                                      navigationController
                                          .advancedDrawerController
                                          .hideDrawer();
                                         _deleteCacheDir();
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          Constants.societyId);
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'admin-${Constants.societyId}');
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'member-${Constants.societyId}');
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          'guard-${Constants.societyId}');

                                      FirebaseAuth.instance.signOut();
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
                                  colors: [
                                HexColorNew("#c0eaf8"),
                                Colors.white
                              ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter)),
                        ),
                        Image.asset("assets/bg.png",
                            fit: BoxFit.cover, width: double.infinity),
                        SizedBox.expand(
                          child: Home(user!),
                              
                        ),
                      ],
                    ),
                    
                    
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
          user == null ?  "" : user.type =="guard" ? "SECURITY" :"${user.house}, ${user.block}",
          style: AppTheme.smallText,
        )
      ],
    );
  }
  Future<void> _deleteCacheDir() async {
                                    final cacheDir =
                                        await getTemporaryDirectory();

                                    if (cacheDir.existsSync()) {
                                      cacheDir.deleteSync(recursive: true);
                                    }
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

  BoxWidget(
      IconData icon, String heading, String description, Function onpressed) {
    return GestureDetector(
      onTap: onpressed(),
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

class Home extends StatefulWidget {
  const Home(this.user, {super.key});

  final UserData user;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController animationController;
  int selectIndex = 0;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
  List<String> items =  widget.user.type == "guard" ? ["Members", "Notices","Handymen",'Vehicles','Help Desk',"In & Outs"] :["Members", "Notices","Handymen",'Stores',];
  List<Widget> screens = widget.user.type == "guard" ? [const MemberScreen(), const NoticeScreen(),const HandymenScreen(),const VehicleScreen(),const HelpDeskScreen(), InOutScreen()]:[const MemberScreen(), const NoticeScreen(),const HandymenScreen(),const StoresScreen(),];

  List<EdgeInsets> padd = [const EdgeInsets.all(0),const EdgeInsets.only(top: 24,bottom: 0,left: 12,right: 12),const EdgeInsets.all(0),const EdgeInsets.only(left: 24,right: 24,top: 24),const EdgeInsets.only(left: 24,right: 24,top: 24),const EdgeInsets.only(top: 24,bottom: 0,left: 12,right: 12)];
    

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getAppBarUI(),
              12.heightBox,
              getNotices(),
              Column(
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 1,
                    ),
                    children: List<Widget>.generate(
                      items.length,
                      (int index) {
                        animationController.forward();
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
                                    items[index],
                                    style: AppTheme.subheading2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:  padd[index],
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Lottie.asset(
                                        "assets/${items[index]}.json",
                                        fit: BoxFit.fitWidth,
                                        height: 150)),
                              ),
                            ],
                          ),
                        ).onTap(() {
                          Get.to(screens[index]);
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> getNotices() {
    final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .where("societyId",isEqualTo:  userinfo!.societyId)
            .orderBy("datePublished", descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(height: 164);
          } else {
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

  Widget getAppBarUI() {
    final user = FirebaseAuth.instance.currentUser;

    final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    
                  },
                  // onTap: () => Get.to(ProfilePage()),
                  child: ProfileAvatar(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                    height: 50,
                    width: 50,
                    data: userinfo,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
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
                          userinfo!.type =="guard" ? "SECURITY" :"-",
                       overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppTheme.smallText),
                    )
                    // Text('Hey',
                    //     textAlign: TextAlign.left, style: AppTheme.subheading3),
                   
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.bell_fill,
            color: Colors.black87,
            size: 26,
          ).onTap(() {
            Get.to(const NotificationPage());
          }),
          // const SizedBox(
          //   width: 16,
          // ),
          // const Icon(
          //   Icons.speaker_notes,
          //   color: Colors.black87,
          //   size: 30,
          // ).onTap(() {
          //   Get.to(const GuardMemberScreen());
          // }),
          const SizedBox(
            width: 12,
          ),
        ],
      ),
    );
  }


}

