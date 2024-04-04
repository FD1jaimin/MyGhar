// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/views/gallery_screen.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/constants.dart';
import '../core/user_provider.dart';
import '../models/user.dart' as model;
import '../widgets/text_fields.dart';

TextEditingController searchController = TextEditingController();
var searchText = ''.obs;

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen>
    with TickerProviderStateMixin {
  TextEditingController name = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController service_controller = TextEditingController();

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
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
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
                      "Vehicles",
                      style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            child: CustomTextField(
                isForm: true,
                onChanged: (value) {
                  searchController.text = value;
                  searchText.value = value;
                },
                textController: searchController,
                hint: "Enter vehicle's last four number",
                icon: const Icon(Icons.search),
                validator: (value) {
                  return null;
                }),
          ),
          6.heightBox,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: getMyCourseList(),
            ),
          ),
        ],
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
  BannerAd? bannerAd;

  @override
  void initState() {
    bannerAd = Constants.initBannerAdd(size: AdSize.banner);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    return true;
  }
  getAd() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12,top: 12,left: 24),
      child: SizedBox(height: 65, child: AdWidget(ad: bannerAd!)),
    );
  }
  @override
  Widget build(BuildContext context) {
    final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: StreamBuilder(
          stream: (((searchText.value != "" && searchText.value != null)
              ? FirebaseFirestore.instance
                  .collection('societies').doc(Constants.societyId).collection('vehicles')
                  .where('lastDigits',
                      isGreaterThanOrEqualTo: searchText.value.trim())
                  .where('lastDigits', isLessThan: searchText.value.trim() + 'z')
                  .limit(8)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('societies').doc(Constants.societyId).collection('vehicles')
                  .snapshots())), //FirebaseFirestore.instance.collection('vehicles').snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              List<String> names = [];
              Map<String, List<dynamic>> data = {};
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                if (data.containsKey(snapshot.data!.docs[i]['vehicleWheel'])) {
                  List<dynamic> newValue =
                      data[snapshot.data!.docs[i]['vehicleWheel']]!;
                  newValue.add(snapshot.data!.docs[i]);
                  data[snapshot.data!.docs[i]['vehicleWheel']!] = newValue;
                } else {
                  names.add(snapshot.data!.docs[i]['vehicleWheel']!);
                  data[snapshot.data!.docs[i]['vehicleWheel']!] = [
                    snapshot.data!.docs[i]
                  ];
                }
              }

              return data.isEmpty
                  ? const Center(
                      child: Text(
                      "No Vehicle here",
                      style: AppTheme.smallText,
                    ))
                  : ListView(
                      children: List<Widget>.generate(names.length+1, (i) {
                        List<dynamic> temp = i==0 ? data[names[i]]!:data[names[i-1]]!;
                        return i==0 ? Constants.showAd ? getAd() : const SizedBox(): Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24, right: 24, bottom: 8, top: 16),
                              child: Text(
                               i==0 ? names[i]: names[i-1],
                                style: AppTheme.subheading,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: List<Widget>.generate(
                                temp.length,
                                (int index) {
                                  const int count = 15;
                                  final Animation<double> animation =
                                      Tween<double>(begin: 0.0, end: 1.0)
                                          .animate(
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
                                      extentRatio: userinfo!.type == "admin"
                                          ? 0.35
                                          : 0.24,
                                      motion: const StretchMotion(),
                                      children: userinfo.type == "admin"
                                          ? [
                                              SlidableAction(
                                                flex: 2,
                                                onPressed: (context) async {
                                                  var number = snapshot
                                                      .data!.docs[index]
                                                      .data()['number'];
                                                  Uri phoneno = Uri.parse(
                                                      'tel:+91 $number');
                                                  if (await launchUrl(
                                                      phoneno)) {
                                                    //dialer opened
                                                  } else {
                                                    //dailer is not opened
                                                  }
                                                },
                                                icon: Icons.call_rounded,
                                                autoClose: true,
                                                label: "Call",
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                backgroundColor: AppTheme
                                                    .lightBackgroundColor,
                                              ),
                                              SlidableAction(
                                                flex: 2,
                                                onPressed: (context) {
                                                  FireStoreMethods()
                                                      .deleteVehicle(
                                                          temp[index].id!);
                                                },
                                                icon: Icons.delete,
                                                autoClose: true,
                                                label: "Delete",
                                                padding:
                                                    const EdgeInsets.all(0),
                                                backgroundColor: AppTheme
                                                    .lightBackgroundColor,
                                              ),
                                            ]
                                          : [
                                              SlidableAction(
                                                flex: 2,
                                                onPressed: (context) async {
                                                  var number = snapshot
                                                      .data!.docs[index]
                                                      .data()['number'];
                                                  Uri phoneno = Uri.parse(
                                                      'tel:+91 $number');
                                                  if (await launchUrl(
                                                      phoneno)) {
                                                    //dialer opened
                                                  } else {
                                                    //dailer is not opened
                                                  }
                                                },
                                                icon: Icons.call_rounded,
                                                autoClose: true,
                                                label: "Call",
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                backgroundColor: AppTheme
                                                    .lightBackgroundColor,
                                              ),
                                            ],
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 24.0),
                                      child: CategoryView(
                                        index: index,
                                        data: temp[index],
                                        snap: snapshot.data!.docs[index].data(),
                                        animation: animation,
                                        animationController:
                                            animationController,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    );
            }
          },
        ),
      );
    });
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key? key,
      this.snap,
      this.index,
      this.data,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final snap;
  final int? index;
  final VoidCallback? callback;
  final dynamic data;
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
                  // height: 145,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          24.widthBox,
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              // border: Border.all(
                              //     color: Colors.white, width: 2),
                              // shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 0),
                                    blurRadius: 8,
                                    color: AppTheme.appColor.withOpacity(0.1))
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: const BoxDecoration(),
                                width: 64,
                                height: 64,
                                child: CachedNetworkImage(
                                  imageUrl: data['image'] ?? "",
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const skeleton(
                                    height: 64,
                                    width: 64,
                                    colors: Colors.white,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const skeleton(
                                    height: 64,
                                    width: 64,
                                    colors: Colors.white,
                                  ),
                                ), //'images/glimpselogo.png'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 0),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// name
                                  4.heightBox,
                                  Text(data['name'],
                                      style: AppTheme.subheading2),

                                  Text(
                                    data["role"],
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.smallText,
                                  ),
                                  Text(
                                    data["username"],
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.smallText,
                                  ),
                                  8.heightBox,

                                  /// number
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.call_rounded,
                                        color: Colors.green[400],
                                        size: 20,
                                      ),
                                      8.widthBox,
                                      Text(
                                        data['number'],
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.heading2,
                                      ),
                                    ],
                                  ),
                                  // 8.heightBox,
                                  // Row(
                                  //   children: [
                                  //     const Icon(
                                  //       Icons.call_rounded,
                                  //       size: 20,
                                  //     ),
                                  //     8.widthBox,
                                  //     Text(
                                  //       handyData!.!,
                                  //       overflow: TextOverflow.ellipsis,
                                  //       style: AppTheme.heading2,
                                  //     ),
                                  //   ],
                                  // ),
                                  16.heightBox,

                                  /// address
                                  // Row(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     const Icon(Icons.home_outlined, size: 16),
                                  //     const SizedBox(width: 8),
                                  //     SizedBox(
                                  //       width: 250,
                                  //       child: Text(
                                  //         handyData!.type!,
                                  //         style: AppTheme.smallText,
                                  //         overflow: TextOverflow.ellipsis,
                                  //         maxLines: 2,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }
}
