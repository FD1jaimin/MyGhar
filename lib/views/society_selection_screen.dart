// ignore_for_file: avoid_function_literals_in_foreach_calls, depend_on_referenced_packages, deprecated_member_use, prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/views/user_guide_screen.dart';
import 'package:urbannest/widgets/background.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

import '../core/firestore_methods.dart';
import '../core/user_provider.dart';
import '../main.dart';
import '../models/user.dart';

class SocietySelectScreen extends StatefulWidget {
  const SocietySelectScreen({super.key});

  @override
  State<SocietySelectScreen> createState() => _SocietySelectScreenState();
}

class _SocietySelectScreenState extends State<SocietySelectScreen>
    with TickerProviderStateMixin {
  late AnimationController bgController;
  late PageController pageController;
  String societyName = "";
  List<String> suggestons = [
    "USA",
    "UK",
    "Uganda",
    "Uruguay",
    "United Arab Emirates"
  ];
  final Random _random =
      Random(); // Create a Random object for generating random numbers

  TextEditingController societyCode = TextEditingController();
  var code = ''.obs;
  TextEditingController soceityNameController = TextEditingController();

  var checkedValue = false;
  var checkedTenant = false;
  bool newHouse = true;
  bool newBlock = true;
  TextEditingController phone = TextEditingController();

  TextEditingController house = TextEditingController();
  TextEditingController block = TextEditingController();

  bool page = false;
  String societyGroupId = '';
  String societyAdminGroupId = '';

  Color left = Colors.black;
  Color right = Colors.white;
  bool societyValid = false;
  String societyId = '';
  @override
  void initState() {
    pageController = PageController();
    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    // bgController.animateTo(0.2);
    try {
      bgController.forward(from: 0.3).whenCompleteOrCancel(() {
        bgController.forward(from: 0.3).whenCompleteOrCancel(() {
          bgController.forward(from: 0.3).whenCompleteOrCancel(() {
            bgController.forward(from: 0.3);
          });
        });
      });
    } catch (e) {
      debugPrint('nothing');
    }
    super.initState();
  }

  @override
  void dispose() {
    // bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        const CustomCloudBackground(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Lottie.asset('assets/city_bg.json', controller: bgController),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 36, bottom: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom < 100
                        ? MediaQuery.of(context).viewInsets.bottom
                        : MediaQuery.of(context).viewInsets.bottom - 120),
                child: Column(
                  children: [
                    Text("Join your society",
                        style: AppTheme.heading.copyWith(fontSize: 24)),
                    _buildLoginToggle(),
                    _buildTabViews(context),
                  ],
                ),
              ),
              // 8.heightBox,
              // _buildDivider(),
              // 20.heightBox,
              // _buildGoogleButton(context),
              _buildContinueButton(),
              8.heightBox,
              Center(
                child: GestureDetector(
                        child: RichText(
                          text: TextSpan(
                            style: AppTheme.smallText.copyWith(fontWeight: FontWeight.bold),
                            text: 'Need help?',
                            children: [
                              TextSpan(
                                  text:  
                                  ' Learn how to use app.',style: AppTheme.smallText.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        onTap: () {
                          Get.to(const UserGuideScreen());
                        },
                      ),
              ),
              0.heightBox,
            ],
          ),
        ),
      ]),
    );
  }

  GestureDetector _buildLoginToggle() {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          left: 34,
          right: 34,
        ),
        child: RichText(
          text: TextSpan(
            style: AppTheme.smallText,
            text: page == false
                ? "Don't have an society Code?"
                : "Already have an society Code?",
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    page == false
                        ? pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.decelerate)
                        : pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.decelerate);
                  },
                text: page == false ? "  Create new  " : "  Join now  ",
                style: AppTheme.smallText.copyWith(
                    fontWeight: FontWeight.bold, color: AppTheme.appColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _buildTabViews(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 365,
      child: PageView(
        controller: pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) {
          if (i == 0) {
            setState(() {
              page = false;
              right = Colors.white;
              left = Colors.black;
            });
          } else if (i == 1) {
            setState(() {
              page = true;
              right = Colors.black;
              left = Colors.white;
            });
          }
        },
        children: <Widget>[
          _buildSignIn(context),
          _buildSignUp(context),
        ],
      ),
    );
  }

  final signInFormKey = GlobalKey<FormState>();

  final signUpFormKey = GlobalKey<FormState>();
  Widget _buildSignIn(BuildContext context) {
    return Form(

        key: signInFormKey,
      child: Container(
        padding: const EdgeInsets.only(top: 23.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 300.0,
              child: Column(
                children: <Widget>[
                  Obx(() {
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('societies')
                            .where('societyCode', isEqualTo: code.value)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          return CustomTextField(
                            hint: "Society Code",
                            icon: const Icon(Icons.badge_rounded, size: 28),
                            obsecure: false,
                            autofocus: false,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              Future.delayed(const Duration(milliseconds: 1),
                                  () async {
                                code.value = value!;
                              });
      
                              if (value != null && value.isEmpty) {
                                societyValid = false;
                                return "Please enter Society Code";
                              } else if (snapshot.data!.docs.isNotEmpty) {
                                societyValid = true;
                                societyId =
                                    snapshot.data!.docs[0].data()['societyId'];
                                societyName = snapshot.data!.docs[0]
                                        .data()['societyName'] ??
                                    "";
                                    if( phone.text == ""){

                                return snapshot.data!.docs[0]
                                        .data()['societyName'] ??
                                    "";
                                    }else{

                                    }
                                
                              } else {
                                societyValid = false;
                                return "Please enter valid Society Code";
                              }
                            },
                            textController: societyCode,
                          );
                        });
                  }),
                  12.heightBox,
                  CustomTextField(
                    hint: "Your Phone number",
                    icon: const Icon(CupertinoIcons.phone_fill, size: 28),
                    obsecure: false,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return "Please enter your number";
                      } else if (value!.length < 10) {
                        return "number must be longer than 10 digits";
                      }
                      return null;
                    },
                    textController: phone,
                  ),
                  !checkedValue ? 12.heightBox : 0.heightBox,
                  !checkedValue
                      ? Column(
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: StreamBuilder(
                                      stream: societyValid && societyId!=""
                                          ? FirebaseFirestore.instance
                                              .collection('societies')
                                              .doc(societyId)
                                              .collection("houses")
                                              .snapshots()
                                          : null,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<
                                                  QuerySnapshot<Map<String, dynamic>>>
                                              snapshot) {
                                        // if (snapshot.hasData) {
                                        List<String> sugges = [];
                                        if (snapshot.hasData) {
                                          for (int i = 0;
                                              i < snapshot.data!.docs.length;
                                              i++) {
                                            sugges.add(snapshot.data!.docs[i]
                                                .data()['houseName']);
                                          }
                                        }
                          
                                        return TypeAheadField(
                                          animationStart: 0,
                                          animationDuration: Duration.zero,
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                            controller: house,
                                            autofocus: false,
                                            expands: false,
                                            // maxLines: 1,
                          
                                            enableInteractiveSelection: true,
                                            enabled: snapshot.hasData &&
                                                snapshot.data!.docs.isNotEmpty,
                          
                                            enableSuggestions: snapshot.hasData &&
                                                snapshot.data!.docs.isNotEmpty,
                                            // enabled: societyId!="",
                                            style: AppTheme.subheading3,
                                            decoration: InputDecoration(
                                                hintStyle: AppTheme
                                                    .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                                hintText: "House",
                                                contentPadding: const EdgeInsets.only(
                                                    left: 24,
                                                    top: 24,
                                                    bottom: 24,
                                                    right: 12),
                                                errorStyle:
                                                    AppTheme.smallText.copyWith(
                                                  fontSize: 10,
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        105,
                                                        110,
                                                        116,
                                                        1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
                                                    width: 2,
                                                  ),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255,
                                                        105,
                                                        110,
                                                        116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                                    width: 2,
                                                  ),
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        231, 236, 243, 1),
                                                    width: 2,
                                                  ),
                                                ),
                                                // focusColor: MyColors.resolveCompanyCOlour(),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        171, 177, 186, 1),
                                                    width: 2,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: BorderSide(
                                                    color: AppTheme.appColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        231, 236, 243, 1),
                                                    width: 2,
                                                  ),
                                                ),
                                                // suffixIcon:  suffix ?? null,
                          
                                                prefixIcon: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 26, right: 16),
                                                  child: IconTheme(
                                                    data: IconThemeData(
                                                        color: AppTheme.appColor
                                                            .withOpacity(0.8)),
                                                    child: const Icon(
                                                        FontAwesomeIcons.home),
                                                  ),
                                                )),
                                          ),
                                          suggestionsBoxDecoration:
                                              SuggestionsBoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  elevation: 0,
                                                  color: Colors.white),
                                          suggestionsCallback: (pattern) {
                                            newBlock = false;
                                            List<String> matches = <String>[];
                                            matches.addAll(sugges);
                          
                                            matches.retainWhere((s) {
                                              return s
                                                  .toLowerCase()
                                                  .contains(pattern.toLowerCase());
                                            });
                                            return matches;
                                          },
                                          minCharsForSuggestions: 1,
                                          getImmediateSuggestions: false,
                                          hideKeyboardOnDrag: true,
                                          hideOnEmpty: true,
                                          hideOnError: true,
                                          hideSuggestionsOnKeyboardHide: false,
                                          itemBuilder: (context, sone) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 8),
                                              child: Text(sone.toString()),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            newHouse = false;
                                            house.text = suggestion;
                                          },
                                        );
                                        // } else {
                                        //   return SizedBox();
                                        // }
                                      }),
                                  // }),
                                ),
                                12.widthBox,
                                Expanded(
                                  flex: 1,
                                  child: StreamBuilder(
                                      stream: societyValid && societyId!=""
                                          ? FirebaseFirestore.instance
                                              .collection('societies')
                                              .doc(societyId)
                                              .collection("blocks")
                                              .snapshots()
                                          : null,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<
                                                  QuerySnapshot<Map<String, dynamic>>>
                                              snapshot) {
                                        List<String> sugges = [];
                                        if (snapshot.hasData) {
                                          for (int i = 0;
                                              i < snapshot.data!.docs.length;
                                              i++) {
                                            sugges.add(snapshot.data!.docs[i]
                                                .data()['blockName']);
                                          }
                                        }
                                        return TypeAheadField(
                                          animationStart: 0,
                                          animationDuration: Duration.zero,
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                            controller: block,
                                            autofocus: false,
                                            expands: false,
                                            enableInteractiveSelection: true,
                                            enabled: snapshot.hasData &&
                                                snapshot.data!.docs.isNotEmpty,
                                            enableSuggestions: snapshot.hasData &&
                                                snapshot.data!.docs.isNotEmpty,
                                            style: AppTheme.subheading3,
                                            decoration: InputDecoration(
                                                hintStyle: AppTheme
                                                    .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                                hintText: "Block",
                                                contentPadding: const EdgeInsets.only(
                                                    left: 24,
                                                    top: 24,
                                                    bottom: 24,
                                                    right: 12),
                                                errorStyle:
                                                    AppTheme.smallText.copyWith(
                                                  fontSize: 10,
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        105,
                                                        110,
                                                        116,
                                                        1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
                                                    width: 2,
                                                  ),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255,
                                                        105,
                                                        110,
                                                        116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
                                                    width: 2,
                                                  ),
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        231, 236, 243, 1),
                                                    width: 2,
                                                  ),
                                                ),
                                                // focusColor: MyColors.resolveCompanyCOlour(),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        171, 177, 186, 1),
                                                    width: 2,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: BorderSide(
                                                    color: AppTheme.appColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        231, 236, 243, 1),
                                                    width: 2,
                                                  ),
                                                ),
                                                // suffixIcon:  suffix ?? null,
                          
                                                prefixIcon: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 26, right: 16),
                                                  child: IconTheme(
                                                    data: IconThemeData(
                                                        color: AppTheme.appColor
                                                            .withOpacity(0.8)),
                                                    child: const Icon(
                                                        FontAwesomeIcons.building),
                                                  ),
                                                )),
                                          ),
                                          suggestionsBoxDecoration:
                                              SuggestionsBoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  elevation: 0,
                                                  color: Colors.white),
                                          suggestionsCallback: (pattern) {
                                            List<String> matches = <String>[];
                                            matches.addAll(sugges);
                          
                                            matches.retainWhere((s) {
                                              return s
                                                  .toLowerCase()
                                                  .contains(pattern.toLowerCase());
                                            });
                                            return matches;
                                          },
                                          hideKeyboardOnDrag: true,
                                          minCharsForSuggestions: 1,
                                          getImmediateSuggestions: false,
                                          hideSuggestionsOnKeyboardHide: false,
                                          hideOnEmpty: true,
                                          hideOnError: true,
                                          hideOnLoading: true,
                                          itemBuilder: (context, sone) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 8),
                                              child: Text(sone.toString()),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            block.text = suggestion;
                                            newBlock = false;
                                          },
                                        );
                                      }),
                                  // }),
                                ),
                                // Expanded(
                                //   flex: 1,
                                //   child: CustomTextField(
                                //     expands: false,
                                //     hint: "Sector",
                                //     icon: const Icon(FontAwesomeIcons.building,
                                //         size: 22),
                                //     obsecure: false,
                                //     autofocus: false,
                                //     keyboardType: TextInputType.text,
                                //     validator: (value) {
                                //       if (value != null && value.isEmpty) {
                                //         return "Please enter sector";
                                //       }
                                //       return null;
                                //     },
                                //     textController: sector,
                                //   ),
                                // ),
                              ],
                            ),
                             Center(
                               child: Theme(
                                                 data: ThemeData(
                                                     splashColor: Colors.transparent,
                                                     highlightColor: Colors.transparent),
                                                 child: SizedBox(
                                                   width: 240,
                                                    height: 30,
                                                   child: Center(
                                                     
                                                     child: CheckboxListTile(
                                                       dense: true,
                                                       title: const Text(
                                                         "are you a tenant?",
                                                         style: AppTheme.smallText,
                                                         textAlign: TextAlign.start
                                                       ),
                                                       value: checkedTenant,
                                                       hoverColor: Colors.transparent,
                                                       splashRadius: 0,
                                                       overlayColor:
                                const MaterialStatePropertyAll(Colors.white),
                               
                                                       onChanged: (newValue) {
                                                         checkedTenant = newValue!;
                                                         setState(() {});
                                                       },
                                                       activeColor: AppTheme.appColor,
                                                       controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                                                     ),
                                                   ),
                                                 ),
                                               ),
                             ),
                        ],
                      )
                      : const SizedBox(),
                  Theme(
                    data: ThemeData(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent),
                    child: SizedBox(
                      width: 220,
                      height: 30,
                      child: Center(
                        child: CheckboxListTile(
                          dense: true,
                          title: const Text(
                            "not a member?",
                            style: AppTheme.smallText,
                            textAlign: TextAlign.start
                          ),
                          value: checkedValue,
                          hoverColor: Colors.transparent,
                          splashRadius: 0,
                          overlayColor:
                              const MaterialStatePropertyAll(Colors.white),
      
                          onChanged: (newValue) {
                            checkedValue = newValue!;
                            setState(() {});
                          },
                          activeColor: AppTheme.appColor,
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  var isLoading = false.obs;

  Container _buildContinueButton() {
    final UserData? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      height: 58,
      width: 188,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: AppTheme.buttonColor,
      ),
      child: InkWell(
        onTap: (() async{
          
          if (isLoading.value == false) {
            isLoading.value = true;

            if (page == false) {
              await join(user!);
            } else {
              await create(user!);
            }
          }
          isLoading.value = false;
        }),
        child: Obx(() {
          return Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Center(
              child: isLoading.value
                  ? LoadingAnimationWidget.waveDots(
                      color: Colors.white, size: 40)
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  addData() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  Future join(UserData? user) async {
    
    final isValid = signInFormKey.currentState!.validate();
    if (!isValid) return;
    if(!checkedTenant) {
      if(newHouse || newBlock){
        Fluttertoast.showToast(msg: 'Must select preowned house');
        return;
      }
    } 
    if (!checkedValue) {
      
      dynamic res = await FirebaseFirestore.instance
          .collection('societies')
          .doc(societyId)
          .collection('houses')
          .doc(house.text.trim())
          .get();

      if (res != null) {
        newHouse =true;
        await FirebaseFirestore.instance
            .collection('societies')
            .doc(societyId)
            .collection('houses')
            .doc(house.text.trim())
            .set({
          'houseName': house.text.trim(),
          'ownerId': FirebaseAuth.instance.currentUser!.uid,
          'societyName': soceityNameController.text.trim(),
          'societyId': societyId,
          'societyCode': code.toString(),
        });
      }

      dynamic res2 = await FirebaseFirestore.instance
          .collection('societies')
          .doc(societyId)
          .collection('blocks')
          .doc(block.text.trim())
          .get();

      if (res2 != null) {
        newBlock = true;
        await FirebaseFirestore.instance
            .collection('societies')
            .doc(societyId)
            .collection('blocks')
            .doc(block.text.trim())
            .set({
          'blockName': block.text.trim(),
          'societyName': soceityNameController.text.trim(),
          'societyId': societyId,
          'societyCode': code.toString(),
        });
      }
    }
    bool isOwner = newHouse || newBlock;
    if (Constants.societyId == "") {
      String homeId = const Uuid().v1();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .update({
        'type': "user",
        'house': checkedValue ? "" : house.text.trim(),
        'block': checkedValue ? "zzzzz" : block.text.trim(),
        'address':
            checkedValue ? "" : '${house.text}, ${block.text}, $societyName',
        'phone': phone.text.trim(),
        'societyCode': societyCode.text.trim(),
        'societyId': societyId,
        'societyName': societyName,
        'isSuperAdmin': false,
        'houseOwner': isOwner,
        'isTenant': checkedTenant,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .collection('homes')
          .doc(homeId)
          .set({
        'house': checkedValue ? "" : house.text.trim(),
        'block': checkedValue ? "zzzzz" : block.text.trim(),
        'address':
            checkedValue ? "" : '${house.text}, ${block.text}, $societyName',
        'societyCode': societyCode.text.trim(),
        'societyId': societyId,
        'type': "user",
        'societyName': societyName,
        'isTenant': checkedTenant,
      });

      addData();
      sendNotification(user!);
      Constants.societyId = societyId;
    } else {
      String homeId = const Uuid().v1();
      FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.userId)
          .collection('homes')
          .doc(homeId)
          .set({
        'type': "user",
        'house': checkedValue ? "" : house.text.trim(),
        'block': checkedValue ? "zzzzz" : block.text.trim(),
        'address':
            checkedValue ? "" : '${house.text}, ${block.text}, $societyName',
        'societyCode': societyCode.text.trim(),
        'societyId': societyId,
        'societyName': societyName,
        'isTenant': checkedTenant,
      });
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(Constants.userId)
      //     .collection('homes')
      //     .doc(homeId)
      //     .set({
      //   'house': checkedValue ? "" : house.text.trim(),
      //   'block': checkedValue ? "zzzzz" : block.text.trim(),
      //   'address':
      //       checkedValue ? "" : '${house.text}, ${block.text}, $societyName',
      //   'societyCode': societyCode.text.trim(),
      //   'societyId': societyId,
      //   'type': "user",
      //   'societyName': societyName,
      // });

      addData();
      sendNotification(user!);
      Constants.societyId = societyId;
      
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    // await FirebaseMessaging.instance.subscribeToTopic(societyId);
  }

  void sendNotification(UserData user) async {
    dynamic societyData = await FirebaseFirestore.instance
        .collection('societies')
        .doc(societyId)
        .get();
    // NotificationMethods().sendNotificationTopics(
    //     to: '/topics/', title: "Notice : ${title.text}", body: body.text);

              String notificationId = const Uuid().v1();
    await FirebaseFirestore.instance
        .collection('users')
        .where("societyId", isEqualTo: Constants.societyId)
        .where('type', isEqualTo: 'admin')
        .get()
        .then((data) => data.docs.forEach((doc) {
              if (checkedValue) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .collection('notifications')
                    .doc(notificationId)
                    .set({
                  'title': "New Join : ${user.firstName}",
                  'body':
                      "A new user wants to joined your society;\nNot identified as the Society Member\nkindly authenticate their identity and grant approval for their request.",
                  'uid': Constants.userId,
                  'id': notificationId,
                  'type': "newextra",
                  'timestamp': FieldValue.serverTimestamp(),
                });
              } else {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .collection('notifications')
                    .doc(notificationId)
                    .set({
                  'title': "New Join : ${user.firstName}",
                  'body': "A new member has joined your society;" +
                      "\n" +
                      "House No. : ${house.text} & Block : ${block.text}" +
                      "\n" +
                      "Kindly authenticate their identity and grant approval for their request.",
                  'uid': Constants.userId,
                  'id': notificationId,
                  'type': "newuser",
                  'societyGroupId': societyData['societyGroupId'],
                  'societyAdminGroupId': societyData['societyAdminGroupId'],
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }
            }));
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

  int generateRandomNumber() {
    int randomNumber =
        100000 + _random.nextInt(900000); // Generates a random 4-digit number
    return randomNumber;
  }

  Future create(UserData userData) async {

    final isValid = signUpFormKey.currentState!.validate();
    if (!isValid) return;
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => Center(
    //           child: LoadingAnimationWidget.waveDots(
    //               color: Colors.white, size: 40),
    //         ));
    int code = generateRandomNumber();
    types.User user = changeUserChat(userData);

    types.Room societyGroup = await FirebaseChatCore.instance.createGroupRoom(
      name: "${soceityNameController.text.trim()} group",
      users: [user],
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/urbannest-a43be.appspot.com/o/office-materials_2809192.png?alt=media&token=6d60c597-d82b-44a2-ab91-c2f5b5108b0c",
    );
    types.Room societyAdminGroup =
        await FirebaseChatCore.instance.createGroupRoom(
      name: "Chairmen Only",
      users: [user],
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/urbannest-a43be.appspot.com/o/tie_4036644.png?alt=media&token=86e4a7d0-a70f-4905-bf97-4a4d04892269",
    );
    String societyId = const Uuid().v1();
    await FirebaseFirestore.instance
        .collection('societies')
        .doc(societyId)
        .set({
      'societyName': soceityNameController.text.trim(),
      'societyId': societyId,
      'societyAdmin': FirebaseAuth.instance.currentUser!.uid,
      'societyCode': code.toString(),
      'societyGroupId': societyGroup.id,
      'societyAdminGroupId': societyAdminGroup.id,
      'area':'',
      'funds':0,
    });
    await FirebaseFirestore.instance
        .collection('societies')
        .doc(societyId)
        .collection('houses')
        .doc(house.text.trim())
        .set({
      'houseName': house.text.trim(),
      'ownerId': FirebaseAuth.instance.currentUser!.uid,
      'societyName': soceityNameController.text.trim(),
      'societyId': societyId,
      'societyCode': code.toString(),
      'houseOwner': FirebaseAuth.instance.currentUser!.uid,
    });

    await FirebaseFirestore.instance
        .collection('societies')
        .doc(societyId)
        .collection('blocks')
        .doc(block.text.trim())
        .set({
      'blockName': block.text.trim(),
      'societyName': soceityNameController.text.trim(),
      'societyId': societyId,
      'societyCode': code.toString(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'house': house.text.trim(),
      'block': block.text.trim(),
      'address':
          '${house.text.trim()}, ${block.text.trim()}, ${soceityNameController.text}',
      'phone': phone.text.trim(),
      'societyCode': code.toString(),
      'societyId': societyId,
      'societyName': soceityNameController.text,
      'type': 'admin',
      'isSuperAdmin': true,
      'houseOwner': true,
      'isTenant': false,
    });

    addData();
    Constants.societyId = societyId;
    Future.delayed(Duration(seconds: 2)).then((value) async {
      
    await FirebaseMessaging.instance.subscribeToTopic(societyId);
    await FirebaseMessaging.instance.subscribeToTopic('admin-$societyId}');
    });

    Get.back();
  }

  Widget _buildSignUp(BuildContext context) {
    return Form(
      key: signUpFormKey,
      child: Container(
        padding: const EdgeInsets.only(top: 23.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CustomTextField(
                    hint: "Society Name",
                    icon: const Icon(FontAwesomeIcons.city, size: 22),
                    obsecure: false,
                    autofocus: false,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return "Please enter society name";
                      } else if (value!.length < 3) {
                        return "Name must be longer than 2 characters";
                      }
      
                      return null;
                    },
                    textController: soceityNameController,
                  ),
                  12.heightBox,
                  CustomTextField(
                    hint: "Your Phone number",
                    icon: const Icon(CupertinoIcons.phone_fill, size: 28),
                    obsecure: false,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return "Please enter your number";
                      } else if (value!.length < 10) {
                        return "number must be longer than 10 digits";
                      }
                      return null;
                    },
                    textController: phone,
                  ),
                  12.heightBox,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: CustomTextField(
                          hint: "House",
                          icon: const Icon(FontAwesomeIcons.house, size: 22),
                          obsecure: false,
                          autofocus: false,
                          expands: false,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Enter house no.";
                            }
                            return null;
                          },
                          textController: house,
                        ),
                      ),
                      12.widthBox,
                      Expanded(
                        flex: 1,
                        child: CustomTextField(
                          expands: false,
                          hint: "Block",
                          icon: const Icon(FontAwesomeIcons.building, size: 22),
                          obsecure: false,
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Enter block";
                            }
                            return null;
                          },
                          textController: block,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
