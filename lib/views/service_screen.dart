// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/main.dart';
import 'package:urbannest/models/notices.dart';
import 'package:urbannest/models/user.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:urbannest/views/booked_amenities_screen.dart';
import 'package:urbannest/views/handymen_screen.dart';
import 'package:urbannest/views/maintenance_new.dart';
import 'package:urbannest/views/notice_screen.dart';
import 'package:urbannest/views/stores_screen.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:velocity_x/velocity_x.dart';

import '../widgets/profile_avatar.dart';
import 'funds_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  AdRequest? adRequest;
  List<BannerAd> bannerAds = [];
  RewardedAd? rewardedAd;
  TextEditingController guestname = TextEditingController();

  final List<SpecialOffer> specials = homeSpecialOffers;
  int selectIndex = 0;
  List<String> dates = ["Today", "Tomorrow", "Other"];
  String selectedDate = 'Today';
  List<String> people = ["1 - 2", "3 - 5", "5 +"];
  String selectedPeople = '';
  String QRUserText = "";
  bool _isAdLoaded = false;

  List<String> company = ["Amazon", "Flipkart", "Zomato", "Myntra", "Other"];
  String selectedCompany = 'Amazon';
  late TabController pageController;

  @override
  void initState() {
    pageController = TabController(length: 2, vsync: this);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);


    for (int i = 0; i < 3; i++) {
      BannerAd? bannerAdTemp;
      bannerAdTemp = BannerAdd(size: AdSize.largeBanner);
      bannerAds.add(bannerAdTemp);
    }

    super.initState();
  }

   BannerAd BannerAdd({AdSize? size}) {
    AdRequest? adRequest;
    BannerAd? bannerAd;
    String bannerId = Platform.isAndroid
        ? 'ca-app-pub-8834577466514734/1973942475'
        : 'ca-app-pub-8834577466514734/1973942475';
    adRequest = const AdRequest(
        //keywords: [ "Mobile" , "Grocery" , "Lifestyle" ],
        nonPersonalizedAds: true);

    BannerAdListener bannerAdListener = BannerAdListener(
      onAdLoaded: (ad){
         setState(() {
            _isAdLoaded = true;
          });
      },
      onAdClosed: (ad) {
        bannerAd!.load();
      },
      onAdFailedToLoad: (ad, error) {
        bannerAd!.load();
      },
    );
    bannerAd = BannerAd(
        size: size!,
        adUnitId: bannerId,
        listener: bannerAdListener,
        request: adRequest);
    bannerAd.load();

    return bannerAd;
  }

  @override
  void dispose() {
    for (int i = 0; i < 3; i++) {
      bannerAds[i].dispose();
    }
    // bannerAd!.dispose();
    super.dispose();
  }

  List<String> items = ["Handymen", "Stores", "Maintenance", "Book Amenities","Funds"];
  List<Widget> screens = [
    const HandymenScreen(),
    const StoresScreen(),
    const MaintenanceScreen(),
    const BookedAmenitiesScreen(),
    const FundsScreen(),
    
  ];
  List<EdgeInsets> padd = [const EdgeInsets.all(0),const EdgeInsets.only(top: 36,bottom: 0,left: 20,right: 20),const EdgeInsets.only(top: 24,bottom: 0,left: 20,right: 20),const EdgeInsets.only(top: 24,bottom: 0,left: 20,right: 20),const EdgeInsets.only(top: 24,bottom: 0,left: 20,right: 20),];
    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getAppBarUI(),
              8.heightBox,
               Constants.showAd && _isAdLoaded
                                ? getBanner()
                                : SizedBox(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Center(
                  //   child: SizedBox(
                  //     child: CustomButton(
                  //         onTap: () {
                  //           RewardedAd.load(
                  //               adUnitId: Platform.isAndroid
                  //                   ? 'ca-app-pub-3940256099942544/5224354917'
                  //                   : 'ca-app-pub-3940256099942544/6978759866',
                  //               request: const AdRequest(),
                  //               rewardedAdLoadCallback: RewardedAdLoadCallback(
                  //                 onAdLoaded: (ad) {
                  //                   rewardedAd = ad;
                  //                   rewardedAd?.show(
                  //                       onUserEarnedReward: (ad, reward) {
                  //                     debugPrint("${reward.amount}");
                  //                   });
                  //                   rewardedAd?.fullScreenContentCallback =
                  //                       FullScreenContentCallback(
                  //                     onAdFailedToShowFullScreenContent:
                  //                         (ad, error) {
                  //                       ad.dispose();
                  //                     },
                  //                     onAdDismissedFullScreenContent: (ad) {
                  //                       ad.dispose();
                  //                       Get.back();
                  //                       // Get.to(const ServiceScreen());
                  //                       // Navigator.pop(context);
                  //                     },
                  //                   );
                  //                 },
                  //                 onAdFailedToLoad: (error) {
                  //                   debugPrint(error.message);
                  //                 },
                  //               ));
                  //         },
                  //         height: 30,
                  //         width: 100,
                  //         text: " Ads"),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 24.0, top: 16),
                  //   child: Text(
                  //     "Community",
                  //     style: AppTheme.subheading2,
                  //   ),
                  // ),
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
                                    textAlign: TextAlign.center,
                                    style: AppTheme.subheading2
                                        .copyWith(fontSize: 19),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: padd[index],
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

  Widget getBanner() {
    // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(children: [
        Container(
          clipBehavior: Clip.antiAlias,
          height: 140,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          child: PageView.builder(
            itemBuilder: (context, index) {
              return Constants.showAd
                  ? SizedBox(height: 140, child: AdWidget(ad: bannerAds[index]))
                  : SizedBox();
            },
            itemCount: 3,
            allowImplicitScrolling: true,
            onPageChanged: (value) {
              setState(() => selectIndex = value);
            },
          ),
        ).onTap(() {
          Get.to(const NoticeScreen());
        }),
        _buildPageIndicator(3)
      ]),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> getServices() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notices')
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
                      return Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/shop.jpg"),
                                fit: BoxFit.cover)),
                      );
                      // NoticeCard(context,
                      //     height: 164,
                      //     dateTime: DateFormat.MMMEd()
                      //         .add_jm()
                      //         .format(data[index].createdOn),
                      //     name: data[index].username ?? "Unknown",
                      //     title: data[index].title!,
                      //     body: data[index].body!);
                    },
                    itemCount: data.length,
                    allowImplicitScrolling: true,
                    onPageChanged: (value) {
                      setState(() => selectIndex = value);
                    },
                  ),
                ).onTap(() {}),
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
      height: 140,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list,
      ),
    );
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
            DropdownButtonFormField2<String>(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                        child: Text(item, style: AppTheme.subheading3),
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
                setState(() {});
                //Do something when selected item is changed.
              },
              onSaved: (value) {
                selectedPeople = value.toString();
                setState(() {});
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
            12.heightBox,
            DropdownButtonFormField2<String>(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                'Enter Date',
                style: AppTheme.smallText,
              ),
              value: "Today",
              items: dates
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: AppTheme.subheading3),
                      ))
                  .toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select date of entry';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  selectedDate = value.toString();
                });
                //Do something when selected item is changed.
              },
              onSaved: (value) {
                selectedDate = value.toString();
                setState(() {});
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

            // DropdownButton<String>(
            //   value: selectedDate,
            //   items: dates.map((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value,style: AppTheme.smallText,),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {

            //     selectedDate = value!;
            //     });
            //   }
            // )
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
            DropdownButtonFormField2<String>(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                'Delivery company name',
                style: AppTheme.smallText,
              ),
              value: "Amazon",
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
                selectedCompany = value.toString();
                setState(() {});
                //Do something when selected item is changed.
              },
              onSaved: (value) {
                selectedCompany = value.toString();
                setState(() {});
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
            12.heightBox,
            DropdownButtonFormField2<String>(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                'Enter Date',
                style: AppTheme.smallText,
              ),
              value: "Today",
              items: dates
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: AppTheme.subheading3),
                      ))
                  .toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select date of entry';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  selectedDate = value.toString();
                });
                //Do something when selected item is changed.
              },
              onSaved: (value) {
                selectedDate = value.toString();
                setState(() {});
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

            // DropdownButton<String>(
            //   value: selectedDate,
            //   items: dates.map((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value,style: AppTheme.smallText,),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {

            //     selectedDate = value!;
            //     });
            //   }
            // )
          ],
        ),
      ),
    );
  }

  Widget getAppBarUI() {
    return const Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 4),
      child:
          Text('Services', textAlign: TextAlign.left, style: AppTheme.heading),
    );
  }

  types.User changeUserChat(UserData userData) {
    types.User chatUser = types.User(
        id: userData.uid,
        createdAt: userData.createdAt,
        firstName: userData.firstName,
        imageUrl: userData.imageUrl,
        lastName: userData.lastName,
        lastSeen: userData.lastSeen,
        metadata: userData.metadata,
        role: userData.role,
        updatedAt: userData.updatedAt);
    return chatUser;
  }

  Future _shareQRImage(String url) async {
    final image = await QrPainter(
      data: url,
      version: QrVersions.auto,
      //
      // embeddedImage: Image.asset("name"),

      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
      // embeddedImage: const Image(image: AssetImage("assetName")),
     dataModuleStyle: QrDataModuleStyle(color: AppTheme.lightBackgroundColor,dataModuleShape: QrDataModuleShape.square),
      color: Color.fromARGB(255, 37, 71, 84),
      
      emptyColor: Colors.white,
    ).toImageData(200.0); // Generate QR code image data

    const filename = 'qr_code.png';
    final tempDir =
        await getTemporaryDirectory(); // Get temporary directory to store the generated image
    final file = await File('${tempDir.path}/$filename')
        .create(); // Create a file to store the generated image
    var bytes = image!.buffer.asUint8List(); // Get the image bytes
    await file.writeAsBytes(bytes); // Write the image bytes to the file
// Share the generated image using the share_plus package
    //print('QR code shared to: $path');
  }

  Future<dynamic> user_card(String name) {
    return showDialog(context: context, builder: (context) => QRCard(name));
  }

  Center QRCard(String name) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 6,
            width: 70,
            decoration: BoxDecoration(
                color: HexColorNew("#2a4634"),
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
                        color: HexColorNew("#2a4634"),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22)))),
                // SizedBox(height: 24,),
                // Container(width: 53,decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.grey.withOpacity(0.5)),height: 7,),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: QrImageView(
                      data:
                          name, //"owner firstName: $name\nlocation: 623, Block 3\nguest firstName: Bhargav Singh Barad\nvisit data: 20/12/2023",
                      version: QrVersions.auto,
                      // size: 100.0,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProfileAvatar(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                      width: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${name}Bhargav",
                              textAlign: TextAlign.left,
                              style: AppTheme.subheading2),
                          const Text('623, Block 3',
                              textAlign: TextAlign.left,
                              style: AppTheme.smallText)
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.share_rounded,
                      color: AppTheme.darkText,
                      size: 28,
                    ).onTap(() {
                      _shareQRImage(
                          "Guest name : $name\nAddress : 623, Block 3\nEntry Date : 26/12/2023\nOwner Name : ${FirebaseAuth.instance.currentUser!.displayName}");
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

// class NoticeCard extends StatelessWidget {
//   const NoticeCard(
//     this.context, {
//     required this.title,
//     required this.body,
//     required this.height,
//     this.isExpanded = false,
//     this.name,
//     this.dateTime,
//     Key? key,
//   }) : super(key: key);

//   final BuildContext context;
//   final String title;
//   final String body;
//   final String? name;
//   final double height;
//   final bool isExpanded;
//   final String? dateTime;

//   @override
//   Widget build(BuildContext context) {
//     DateTime tempDate = DateFormat.MMMEd().add_jm().parse(dateTime!);
//     final now = DateTime.now();
//     DateTime cardDate = DateTime(now.year, tempDate.month, tempDate.day);
//     final today = DateTime(now.year, now.month, now.day);

//     return Container(
//       clipBehavior: Clip.antiAlias,
//       height: height,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.all(Radius.circular(32)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 cardDate == today
//                     ? Padding(
//                         padding: const EdgeInsets.only(right: 34),
//                         child: Align(
//                           alignment: Alignment.topRight,
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//                                     bottomLeft: Radius.circular(12),
//                                     bottomRight: Radius.circular(12)),
//                                 color: AppTheme.appColor),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               child: Text(
//                                 "new",
//                                 style: AppTheme.smallText
//                                     .copyWith(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     : SizedBox(),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16, bottom: 0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(left: 20, right: 20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(title, style: AppTheme.subheading2),
//                             const SizedBox(height: 8),
//                             SizedBox(
//                               height: height - 90,
//                               child: SingleChildScrollView(
//                                 child: Text(
//                                   body,
//                                   maxLines: isExpanded ? 200 : 3,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: AppTheme.smallText,
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       MySeparator(
//                         color: AppTheme.lightText.withOpacity(0.4),
//                         height: 2,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Post by : ${name ?? 'Unknown'}",
//                               style: AppTheme.smallText.copyWith(fontSize: 10),
//                             ),
//                             Text(dateTime ?? "",
//                                 style:
//                                     AppTheme.smallText.copyWith(fontSize: 10))
//                           ],
//                         ),
//                       )
//                       // const SizedBox(height: 12),
//                       // Text(
//                       //   data.detail,
//                       //   style: const TextStyle(
//                       //       fontWeight: FontWeight.w500, fontSize: 12),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Image.asset(data.icon),
//         ],
//       ),
//     );
//   }
// }

// class MySeparator extends StatelessWidget {
//   const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
//       : super(key: key);
//   final double height;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (BuildContext context, BoxConstraints constraints) {
//         final boxWidth = constraints.constrainWidth();
//         const dashWidth = 8.0;
//         final dashHeight = height;
//         final dashCount = (boxWidth / (2 * dashWidth)).floor();
//         return Flex(
//           children: List.generate(dashCount, (_) {
//             return SizedBox(
//               width: dashWidth,
//               height: dashHeight,
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                     color: color, borderRadius: BorderRadius.circular(20)),
//               ),
//             );
//           }),
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           direction: Axis.horizontal,
//         );
//       },
//     );
//   }
// }

class SpecialOffer {
  final String discount;
  final String title;
  final String detail;
  final String icon;

  SpecialOffer({
    required this.discount,
    required this.title,
    required this.detail,
    required this.icon,
  });
}

final homeSpecialOffers = <SpecialOffer>[
  SpecialOffer(
    discount: '3',
    title: "Sofa left",
    detail: "Don't forgot to add some new stuff...",
    icon: 'assets/icons/products/sofa.png',
  ),
  SpecialOffer(
    discount: '1',
    title: "Chair left",
    detail: 'Get it now!!!',
    icon: 'assets/icons/products/plastic_chair@2x.png',
  ),
  SpecialOffer(
    discount: '33%',
    title: "cut off",
    detail: 'Kinda greedy...',
    icon: 'assets/icons/products/book_case@2x.png',
  ),
];
