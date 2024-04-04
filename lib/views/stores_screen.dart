// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/models/stores.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:urbannest/widgets/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../widgets/text_fields.dart';

TextEditingController searchController = TextEditingController();
var searchText = ''.obs;

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  TextEditingController name = TextEditingController();
  // TextEditingController type = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController address = TextEditingController();

  TextEditingController typeController = TextEditingController();

  List<String> types = [];
  var selectedType = ''.obs;
  final TextEditingController date = TextEditingController();

  TextEditingController areaController = TextEditingController();
  String selectedArea = '';
  List<String> store = ["Salon", "grocery", "Other"];
  String selectedStoreType = 'Salon';

  @override
  void initState() {
    // getArea();
    super.initState();
  }
  // getArea()async{

  //   data = await FirebaseFirestore.instance
  //                             .collection('societies')
  //                             .doc(Constants.societyId)
  //                             .get();
  
  // }
  String societyArea = '';
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('societies').doc(Constants.societyId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                                snapshot) {
                                  if(!snapshot.hasData){
                                     return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 64.0),
                            child: LoadingAnimationWidget.waveDots(
                                color: AppTheme.lightText, size: 40),
                          ),
                        );
                                  }else{
                                    if((snapshot.data!.data()!['area'] != null && snapshot.data!.data()!['area']!= '')) societyArea = snapshot.data!.data()!['area'];
    return !(snapshot.data!.data()!['area'] != null && snapshot.data!.data()!['area']!= '')
        ? Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Please specify the region where your society is located or the nearest area to it.",
                      style: AppTheme.subheading3,
                    ),
                    12.heightBox,
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('stores')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot1) {
                          List<String> data = [];
                          if (snapshot1.hasData) {
                            for (int i = 0;
                                i < snapshot1.data!.docs.length;
                                i++) {
                              if (!data
                                  .contains(snapshot1.data!.docs[i]["area"])) {
                                    if(snapshot1.data!.docs[i]["area"] != null){

                                    data.add(snapshot1.data!.docs[i]["area"]);
                                    }
                              }
                            }
                          }
                          return DropdownButtonFormField2<String>(
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
                              'Store Type',
                              style: AppTheme.smallText,
                            ),
                            items: data
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item,
                                          style: AppTheme.subheading3),
                                    ))
                                .toList(),
                            validator: (value) {
                              return null;
                            },
                            onChanged: (value) {
                              selectedArea = value.toString();
                              setState(() {});
                              //Do something when selected item is changed.
                            },
                            onSaved: (value) {
                              selectedArea = value.toString();
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
                          );
                        }),
                    12.heightBox,
                    CustomButton(
                        onTap: ()async  {
                          await FirebaseFirestore.instance
                              .collection('societies')
                              .doc(Constants.societyId)
                              .update({'area': selectedArea});
                              setState(() {
                                
                              });
                        },
                        height: 54,
                        width: 108,
                        text: "DONE"),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
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

                selectedType.value = "";
                
                
                name.clear();
                number.clear();
                typeController.clear();
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => CustomDialog(
                          child: SizedBox(
                            // height: 440,
                            width: MediaQuery.of(context).size.width - 120,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  children: [
                                    3.heightBox,
                                    const Text(
                                      'Add Store',
                                      style: AppTheme.subheading2,
                                      textAlign: TextAlign.center,
                                    ),
                                    14.heightBox,

                                    /// store name
                                    CustomTextField(
                                        isForm: true,
                                        keyboardType: TextInputType.text,
                                        hint: "Enter store name",
                                        validator: (value) {
                                          return null;
                                        },
                                        textController: name),
                                    14.heightBox,
                                    StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('stores')
                  .where("area", isEqualTo: 'Motera')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      List<String> data = ["Other ",];
                                      if (snapshot.hasData) {
                                        for (int i = 0;
                                            i < snapshot.data!.docs.length;
                                            i++) {
                                          if (!data.contains(
                                              snapshot.data!.docs[i]["type"])) {
                                            data.add(
                                                snapshot.data!.docs[i]["type"]);
                                          }
                                        }
                                      }
                                      return Obx(() {
                                        return selectedType.value ==
                                                "Other "
                                            ? CustomTextField(
                                                isForm: true,
                                                keyboardType:
                                                    TextInputType.text,
                                                hint: "Enter Store Type",
                                                validator: (value) {
                                                  return null;
                                                },
                                                textController:
                                                    typeController)
                                            : DropdownButtonFormField2<String>(
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  disabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 18),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color.fromRGBO(
                                                          171, 177, 186, 1),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  // Add more decoration..
                                                ),
                                                hint: const Text(
                                                  'Store Type',
                                                  style: AppTheme.smallText,
                                                ),
                                                items: data
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: item,
                                                          child: Text(item,
                                                              style: AppTheme
                                                                  .subheading3),
                                                        ))
                                                    .toList(),
                                                validator: (value) {
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  selectedType.value =
                                                      value.toString();
                                                  setState(() {});
                                                  //Do something when selected item is changed.
                                                },
                                                onSaved: (value) {
                                                  selectedType.value =
                                                      value.toString();
                                                  setState(() {});
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding:
                                                      EdgeInsets.only(right: 8),
                                                ),
                                                iconStyleData:
                                                    const IconStyleData(
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: AppTheme.lightText,
                                                  ),
                                                  iconSize: 24,
                                                ),
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                ),
                                              );
                                      });
                                    }),
                                    
                                    14.heightBox,

                                    /// store number
                                    CustomTextField(
                                        isForm: true,
                                        keyboardType: TextInputType.number,
                                        hint: "Enter contact number",
                                        validator: (value) {
                                          return null;
                                        },
                                        textController: number),
                                    14.heightBox,

                                    /// store address
                                    CustomTextField(
                                        isForm: true,
                                        //  expands: true,
                                        minLines: 3,
                                        maxLines: 3,
                                        keyboardType: TextInputType.multiline,
                                        hint: "Enter store address",
                                        validator: (value) {
                                          return null;
                                        },
                                        textController: address),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Submit',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        12.widthBox,
                                      ],
                                    ),
                                  ),
                                ).onTap(() {
                                  if(name.text!= "" &&  ((selectedType.value == "Other " &&
                                                typeController.text != '') ||
                                            selectedType.value !=
                                                "Other ") && selectedType.value !=""&& number.text!=""&& address.text!="" ){
                                  FireStoreMethods().createStores(
                                    name: name.text,
                                    type: selectedType.value,
                                    number: number.text,
                                    address: address.text,
                                    area: societyArea
                                  );
                                  Get.back();
                                  name.clear();
                                  number.clear();
                                  address.clear();

                                                } else{
                                                  Fluttertoast.showToast(msg: "Please fill all the details");
                                                }
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                      //   // Respond to button press
                    },
                    child: const Icon(Icons.add),
                  )
                : const SizedBox(),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
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
                              "Stores",
                              style: AppTheme.subheading
                                  .copyWith(letterSpacing: -0.3),
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    child: CustomTextField(
                        isForm: true,
                        onChanged: (value) {
                          searchController.text = value;
                          searchText.value = value;
                        },
                        textController: searchController,
                        hint: "Search different store types",
                        icon: const Icon(Icons.search),
                        validator: (value) {
                          return null;
                        }),
                  ),
                  6.heightBox,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: getMyCourseList(snapshot.data!.data()!),
                    ),
                  ),
                ],
              ),
            )),
          );
                                  }
});
  }

  Widget getMyCourseList( dynamic data) {
    return  Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: MyCourseList(societyData: data,),
    );
  }
}

class MyCourseList extends StatefulWidget {
   MyCourseList({super.key,this.societyData});
  final dynamic societyData;

  @override
  _MyCourseListState createState() => _MyCourseListState();
}

class _MyCourseListState extends State<MyCourseList>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  bool result = false;

  bool _isAdLoaded = false;
  int selectIndex = 0;

  List<BannerAd> bannerAds = [];

  @override
  void initState() {
    result = Constants.getProbability(0.6);
    for (int i = 0; i < 3; i++) {
      BannerAd? bannerAdTemp;
      bannerAdTemp = BannerAdd(size: AdSize.largeBanner);
      bannerAds.add(bannerAdTemp);
    }
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
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

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // final UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: StreamBuilder(
          stream: (((searchText.value != "" && searchText.value != null)
              ? FirebaseFirestore.instance
                  .collection('stores')
                  .where("area", isEqualTo: widget.societyData['area'])
                  .where('type',
                      isGreaterThanOrEqualTo:
                          searchText.value.capitalizeFirst!.trim())
                  .where('type',
                      isLessThan:
                          searchText.value.capitalizeFirst!.trim() + 'z')
                  .limit(10)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('stores')
                  .where("area", isEqualTo: widget.societyData['area'])
                  .limit(20)
                  .snapshots())),
          // FirebaseFirestore.instance
          //     .collection('stores').where("area",isEqualTo: 'sola')
          //     // .orderBy('createdOn', descending: true)
          //     .limit(10)
          // .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: LoadingAnimationWidget.waveDots(
                    color: AppTheme.lightText, size: 40),
              );
            } else {
              List<String> names = [];
              Map<String, List<Stores>> data = {};
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                Stores stores = Stores.fromSnap(snapshot.data!.docs[i]);
                if (data.containsKey(stores.type)) {
                  List<Stores> newValue = data[stores.type]!;
                  newValue.add(stores);
                  data[stores.type!] = newValue;
                } else {
                  names.add(stores.type!);
                  data[stores.type!] = [stores];
                }
              }
              // List<Stores> data = [];
              // final now = DateTime.now();
              // final today = DateTime(now.year, now.month, now.day);

              // for (int i = 0; i < snapshot.data!.docs.length; i++) {
              //   Stores userVisitor = Stores.fromSnap(snapshot.data!.docs[i]);

              //   data.add(userVisitor);
              // }
              return data.isEmpty
                  ? const Center(
                      child: Text(
                      "No Active Stores",
                      style: AppTheme.smallText,
                    ))
                  : ListView(
                      children: List<Widget>.generate(names.length + 1, (i) {
                        List<Stores> temp =
                            i == 0 ? data[names[0]]! : data[names[i - 1]]!;
                        return i == 0
                            ? Constants.showAd && _isAdLoaded
                                ? getBanner()
                                : SizedBox()
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24,
                                        right: 24,
                                        bottom: 8,
                                        top: 16),
                                    child: Text(
                                      i == 0 ? names[i] : names[i - 1],
                                      style: AppTheme.subheading,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  ListView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                            curve: Interval(
                                                (1 / count) * index, 1.0,
                                                curve: Curves.fastOutSlowIn),
                                          ),
                                        );
                                        animationController?.forward();
                                        return Slidable(
                                          closeOnScroll: true,
                                          enabled: true,
                                          endActionPane: ActionPane(
                                            extentRatio:
                                                Constants.type == "admin"
                                                    ? 0.35
                                                    : 0.24,
                                            motion: const StretchMotion(),
                                            children: Constants.type == "admin"
                                                ? [
                                                    SlidableAction(
                                                      flex: 2,
                                                      onPressed:
                                                          (context) async {
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
                                                        if (Constants.showAd &&
                                                            result)
                                                          Constants
                                                              .showIntertitialAd();
                                                      },
                                                      icon: Icons.call_rounded,
                                                      autoClose: true,
                                                      label: "Call",
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8),
                                                      backgroundColor: AppTheme
                                                          .lightBackgroundColor,
                                                    ),
                                                    SlidableAction(
                                                      flex: 2,
                                                      onPressed: (context) {
                                                        FireStoreMethods()
                                                            .deleteStore(
                                                                temp[index]
                                                                    .storeId!);
                                                      },
                                                      icon: Icons.delete,
                                                      autoClose: true,
                                                      label: "Delete",
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      backgroundColor: AppTheme
                                                          .lightBackgroundColor,
                                                    ),
                                                  ]
                                                : [
                                                    SlidableAction(
                                                      flex: 2,
                                                      onPressed:
                                                          (context) async {
                                                        var number = snapshot
                                                            .data!.docs[index]
                                                            .data()['number'];
                                                        Uri phoneno = Uri.parse(
                                                            'tel:$number');
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
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8),
                                                      backgroundColor: AppTheme
                                                          .lightBackgroundColor,
                                                    ),
                                                  ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 24.0),
                                            child: CategoryView(
                                              index: index,
                                              storesData: temp[index],
                                              snap: snapshot.data!.docs[index]
                                                  .data(),
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

  Widget getBanner() {
    // final model.UserData? userinfo = Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Stack(children: [
        Container(
          clipBehavior: Clip.antiAlias,
          height: 140,
          decoration: const BoxDecoration(
            // color: Colors.white,
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
          // Get.to(const NoticeScreen());
        }),
        _buildPageIndicator(3)
      ]),
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
}

class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key? key,
      this.snap,
      this.index,
      this.storesData,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final snap;
  final int? index;
  final VoidCallback? callback;
  final Stores? storesData;
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
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// name
                                Text(storesData!.name!,
                                    style: AppTheme.subheading2),
                                //const SizedBox(height: 8),

                                /// type
                                Text(
                                  storesData!.type!,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.smallText,
                                ),
                                8.heightBox,

                                /// number
                                Row(
                                  children: [
                                    const Icon(Icons.call_rounded, size: 20),
                                    8.widthBox,
                                    Text(
                                      storesData!.number!,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.heading2,
                                    ),
                                  ],
                                ),
                                8.heightBox,

                                /// address
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.home_rounded,
                                      size: 20,
                                    ),
                                    8.widthBox,
                                    Expanded(
                                      child: Text(
                                        storesData!.address!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: AppTheme.heading3.copyWith(
                                            color: AppTheme.lightText,
                                            height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),

                                16.heightBox,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
