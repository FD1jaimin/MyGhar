
// // ignore_for_file: prefer_const_constructors_in_immutables

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:urbannest/app_theme.dart';
// import 'package:urbannest/core/notification_method.dart';
// import 'package:urbannest/core/storage_method.dart';
// import 'package:urbannest/models/user.dart';
// import 'package:urbannest/widgets/back_button.dart';
// import 'package:urbannest/widgets/profile_avatar.dart';
// import 'package:urbannest/widgets/text_fields.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
// import 'package:velocity_x/velocity_x.dart';

// import '../core/constants.dart';

// class GuardMemberScreen extends StatefulWidget {
//   const GuardMemberScreen({super.key});

//   @override
//   State<GuardMemberScreen> createState() => _GuardMemberScreenState();
// }

// var searchText = "".obs;
// var _file = Uint8List(0).obs;
// var isLoading = false.obs;

// class _GuardMemberScreenState extends State<GuardMemberScreen>
//     with TickerProviderStateMixin {
//   late TabController pageController;
//   TextEditingController searchController = TextEditingController();
  
//   AnimationController? animationController;

//   @override
//   void initState() {
//     animationController = AnimationController(
//         duration: const Duration(milliseconds: 800), vsync: this);
//     pageController = TabController(length: 2, vsync: this);
//     super.initState();
//   }


//   pickImage(ImageSource source) async {
//     final ImagePicker imagePicker = ImagePicker();
//     XFile? file = await imagePicker.pickImage(source: source);
//     if (file != null) {
//       return await file.readAsBytes();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.lightBackgroundColor,
//       body: SafeArea(
//           child: DefaultTabController(
//         initialIndex: 0,
//         length: 2,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//                 padding: const EdgeInsets.only(
//                     top: 0, bottom: 12, left: 24, right: 24),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const CustomBackButton(),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 16.8, left: 16),
//                       child: Text(
//                         "Ask members",
//                         style:
//                             AppTheme.subheading.copyWith(letterSpacing: -0.3),
//                       ),
//                     ),
//                   ],
//                 )),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
//               child: CustomTextField(
//                   isForm: true,
//                   textController: searchController,
//                   hint: "Search name",
//                   icon: const Icon(Icons.search),
//                   validator: (value) {
//                     return null;
//                   }),
//             ),
//             TabBar(
//                 indicatorColor: AppTheme.appColor,
//                 labelPadding: const EdgeInsets.all(8),
//                 enableFeedback: false,
//                 dividerColor: Colors.transparent,
//                 labelColor: AppTheme.appColor,
//                 controller: pageController,
//                 overlayColor: MaterialStateProperty.resolveWith((states) {
//                   return Colors.transparent;
//                 }),
//                 labelStyle:
//                     AppTheme.smallText.copyWith(fontWeight: FontWeight.bold),
//                 tabs: const [Text("Members"), Text("Chair persons")]),
//             Expanded(
//               child: TabBarView(controller: pageController, children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 24.0),
//                   child: getMembersList(false),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 24.0),
//                   child: getMembersList(true),
//                 ),
//               ]),
//             )
//           ],
//         ),
//       )),
//     );
//   }

//   Row getSearchBarUI({BuildContext? context}) {
//     return Row(
//       children: <Widget>[
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.only(left: 24, right: 24),
//             child: TextFormField(
//               onChanged: ((value) => searchText.value = value),
//               controller: searchController,
//               onTap: () {},
//               style: AppTheme.subheading3
//                   .copyWith(color: AppTheme.lightBackgroundColor),
//               keyboardType: TextInputType.text,
//               cursorColor: Colors.white,
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 border: InputBorder.none,
//                 helperStyle: AppTheme.subheading3
//                     .copyWith(color: AppTheme.lightBackgroundColor),
//                 labelStyle: AppTheme.subheading3.copyWith(
//                     color: AppTheme.lightBackgroundColor.withOpacity(0.9)),
//               ),
//               onEditingComplete: () {
//                 Fluttertoast.showToast(msg: "Searching ...");
//               },
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 10),
//           child: GestureDetector(
//             onTap: (() {
//               Fluttertoast.showToast(msg: "Searching ...");
//             }),
//             child: const SizedBox(
//               height: 54,
//               width: 54,
//               child: Padding(
//                   padding: EdgeInsets.all(12), child: Icon(Icons.search)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget getMembersList(bool isAdmin) {
//     final user = FirebaseAuth.instance.currentUser;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 0.0),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8),
//         child: StreamBuilder(
//           stream: !isAdmin
//               ? ((searchText.value != "")
//                   ? (FirebaseFirestore.instance
//                       .collection('users')
//                       .where('name',
//                           isGreaterThanOrEqualTo: searchText.value.trim())
//                       .where('name', isLessThan: '${searchText.value.trim()}z')
//                       .limit(8)
//                       .snapshots())
//                   : FirebaseFirestore.instance.collection('users').snapshots())
//               : (FirebaseFirestore.instance
//                   .collection('users')
//                   .where('uid', isEqualTo: user!.uid)
//                   // .orderBy("datePublished",descending: true)
//                   .snapshots()),
//           builder: (BuildContext context,
//               AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//             if (!snapshot.hasData) {
//               return const SizedBox();
//             } else {
//               List<UserData> data = [];
//               for (int i = 0; i < snapshot.data!.docs.length; i++) {
//                 UserData member = UserData.fromSnap(snapshot.data!.docs[i]);
//                 data.add(member);
//               }

//               return data.isEmpty
//                   ? const Center(
//                       child: Text(
//                       "No members found",
//                       style: AppTheme.smallText,
//                     ))
//                   : ListView(
//                       padding: const EdgeInsets.all(0),
//                       // physics: const NeverScrollableScrollPhysics(),
//                       // shrinkWrap: true,
//                       children: List<Widget>.generate(
//                         data.length,
//                         (int index) {
//                           final int count = data.length;
//                           final Animation<double> animation =
//                               Tween<double>(begin: 0.0, end: 1.0).animate(
//                             CurvedAnimation(
//                               parent: animationController!,
//                               curve: Interval((1 / count) * index, 1.0,
//                                   curve: Curves.fastOutSlowIn),
//                             ),
//                           );
//                           animationController?.forward();
//                           return Padding(
//                             padding: const EdgeInsets.only(left: 24.0),
//                             child: CategoryView(
//                               index: index,
//                               memberData: data[index],
//                               snap: snapshot.data!.docs[index].data(),
//                               animation: animation,
//                               animationController: animationController,
//                             ),
//                           );
//                         },
//                       ),
//                     );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

// class MyMembersList extends StatefulWidget {
//   const MyMembersList({super.key, 
//     this.isAdmin = false,
//   });
//   final bool isAdmin;
//   @override
//   // ignore: library_private_types_in_public_api
//   _MyMembersListState createState() => _MyMembersListState();
// }

// class _MyMembersListState extends State<MyMembersList>
//     with TickerProviderStateMixin {
//   AnimationController? animationController;

//   @override
//   void initState() {
//     animationController = AnimationController(
//         duration: const Duration(milliseconds: 800), vsync: this);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     return Padding(
//       padding: const EdgeInsets.only(top: 8),
//       child: StreamBuilder(
//         stream: !widget.isAdmin
//             ? FirebaseFirestore.instance.collection('users').snapshots()
//             : FirebaseFirestore.instance
//                 .collection('users')
//                 .where('uid', isEqualTo: user!.uid)
//                 // .orderBy("datePublished",descending: true)
//                 .snapshots(),
//         builder: (BuildContext context,
//             AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//           if (!snapshot.hasData) {
//             return const SizedBox();
//           } else {
//             List<UserData> data = [];
//             for (int i = 0; i < snapshot.data!.docs.length; i++) {
//               UserData member = UserData.fromSnap(snapshot.data!.docs[i]);
//               data.add(member);
//             }

//             return data.isEmpty
//                 ? const Center(
//                     child: Text(
//                     "No members found",
//                     style: AppTheme.smallText,
//                   ))
//                 : ListView(
//                     padding: const EdgeInsets.all(0),
//                     // physics: const NeverScrollableScrollPhysics(),
//                     // shrinkWrap: true,
//                     children: List<Widget>.generate(
//                       data.length,
//                       (int index) {
//                         final int count = data.length;
//                         final Animation<double> animation =
//                             Tween<double>(begin: 0.0, end: 1.0).animate(
//                           CurvedAnimation(
//                             parent: animationController!,
//                             curve: Interval((1 / count) * index, 1.0,
//                                 curve: Curves.fastOutSlowIn),
//                           ),
//                         );
//                         animationController?.forward();
//                         return Padding(
//                           padding: const EdgeInsets.only(left: 24.0),
//                           child: CategoryView(
//                             index: index,
//                             memberData: data[index],
//                             snap: snapshot.data!.docs[index].data(),
//                             animation: animation,
//                             animationController: animationController,
//                           ),
//                         );
//                       },
//                     ),
//                   );
//           }
//         },
//       ),
//     );
//   }
// }

// class CategoryView extends StatelessWidget {
//   const CategoryView(
//       {Key? key,
//       this.snap,
//       this.index,
//       this.memberData,
//       this.animationController,
//       this.animation,
//       this.callback})
//       : super(key: key);

//   // ignore: prefer_typing_uninitialized_variables
//   final snap;
//   final int? index;
//   final VoidCallback? callback;
//   final UserData? memberData;
//   final AnimationController? animationController;
//   final Animation<double>? animation;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animationController!,
//       builder: (BuildContext context, Widget? child) {
//         return FadeTransition(
//           opacity: animation!,
//           child: Transform(
//             transform: Matrix4.translationValues(
//                 0.0, 50 * (1.0 - animation!.value), 0.0),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6.0),
//               child: MemberCard(
//                 context,
//                 data: memberData!,
//               ).onTap(() {

//                 _file.value=Uint8List(0);
                
//                 showDialog(
//                   context: context,
//                   builder: (context) => Center(
//                       child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: MemberPopUp(
//                       context,
//                       data: memberData!,
//                     ),
//                   )),
//                 );
//               }),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class MemberPopUp extends StatefulWidget {
//   MemberPopUp(
//     this.context, {
//     required this.data,
//     Key? key,
//   }) : super(key: key);

//   final BuildContext context;
//   final UserData data;

//   @override
//   State<MemberPopUp> createState() => _MemberPopUpState();
// }

// class _MemberPopUpState extends State<MemberPopUp> {
//   TextEditingController name = TextEditingController();
//   List<String> people = ["1 - 2", "3 - 5", "5 +"];
//   String selectedPeople = '';
//   String imageUrl ='';
//   // Future<XFile> compressImage(XFile file, String targetPath) async {
//   //   var result = await FlutterImageCompress.compressAndGetFile(
//   //       file.path, targetPath,
//   //       quality: 20,
//   //       rotate: 180,
//   //     );

//   //   return result!;
//   // }
//   Future<Uint8List> compressImage(Uint8List list) async {
//     var result = await FlutterImageCompress.compressWithList(
//       list,
//       minHeight: 450,
//       minWidth: 450,
//       quality: 60,
//     );
//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         clipBehavior: Clip.antiAlias,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(32)),
//         ),
//         child: Obx(() {
//           return _file.value.isNotEmpty
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       24.heightBox,
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(30),
//                         child: Container(
//                           clipBehavior: Clip.antiAliasWithSaveLayer,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(30),
//                             // border:
//                             // Border.all(color: Colors.white, width: 2),
//                             // shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                   offset: const Offset(0, 0),
//                                   blurRadius: 8,
//                                   color: AppTheme.appColor.withOpacity(0.1))
//                             ],
//                           ),
//                           width: 144,
//                           height: 144,
//                           child: _file.value.isEmpty
//                               ? Container(
//                                   decoration: BoxDecoration(
//                                       color: HexColorNew('#F8FAFB'),
//                                       borderRadius: BorderRadius.circular(12)),
//                                   child: const Icon(
//                                     FontAwesomeIcons.images,
//                                     color: AppTheme.lightText,
//                                     size: 34,
//                                   ))
//                               : Image.memory(
//                                   _file.value,
//                                   fit: BoxFit.cover,
//                                 ), //'images/glimpselogo.png'),
//                         ),
//                       ),
//                       20.heightBox,
//                       Material(
//                         color: Colors.white,
//                         child: CustomTextField(
//                             icon: const Icon(Icons.person),
//                             isForm: true,
//                             keyboardType: TextInputType.name,
//                             hint: "Enter Guest Name",
//                             validator: (value) {
//                               return null;
//                             },
//                             textController: name),
//                       ),
//                       12.heightBox,
//                       Material(
//                         color: Colors.white,
//                         child: DropdownButtonFormField2<String>(
//                           isExpanded: true,
//                           decoration: InputDecoration(
//                             disabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(
//                                 color: Color.fromRGBO(171, 177, 186, 1),
//                                 width: 2,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(
//                                 color: Color.fromRGBO(171, 177, 186, 1),
//                                 width: 2,
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(
//                                 color: Color.fromRGBO(171, 177, 186, 1),
//                                 width: 2,
//                               ),
//                             ),
//                             contentPadding:
//                                 const EdgeInsets.symmetric(vertical: 18),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: const BorderSide(
//                                 color: Color.fromRGBO(171, 177, 186, 1),
//                                 width: 2,
//                               ),
//                             ),
//                             // Add more decoration..
//                           ),
//                           hint: const Text(
//                             'Number of People',
//                             style: AppTheme.smallText,
//                           ),
//                           items: people
//                               .map((item) => DropdownMenuItem<String>(
//                                     value: item,
//                                     child:
//                                         Text(item, style: AppTheme.subheading3),
//                                   ))
//                               .toList(),
//                           validator: (value) {
//                             if (value == null) {
//                               return 'Please select number of people';
//                             }
//                             return null;
//                           },
//                           onChanged: (value) {
//                             selectedPeople = value.toString();
//                             setState(() {});
//                             //Do something when selected item is changed.
//                           },
//                           onSaved: (value) {
//                             selectedPeople = value.toString();
//                             setState(() {});
//                           },
//                           buttonStyleData: const ButtonStyleData(
//                             padding: EdgeInsets.only(right: 8),
//                           ),
//                           iconStyleData: const IconStyleData(
//                             icon: Icon(
//                               Icons.arrow_drop_down,
//                               color: AppTheme.lightText,
//                             ),
//                             iconSize: 24,
//                           ),
//                           dropdownStyleData: DropdownStyleData(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                           menuItemStyleData: const MenuItemStyleData(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                           ),
//                         ),
//                       ),
//                       // 12.heightBox,
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 24, right: 24, top: 12, bottom: 24),
//                         child: Container(
//                           height: 54,
//                           width: 112,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(40),
//                             color: AppTheme.buttonColor,
//                           ),
//                           child: GestureDetector(
//                             onTap: () async {
//                               print(imageUrl);
//                               if(!isLoading.value){
//                                 isLoading.value = true;
//                               _file.value = await compressImage(_file.value);
//                                 String guestID = const Uuid().v1();
//                                  imageUrl = await StorageMethods()
//                                     .uploadImageToStorage(
//                                         'amenities', _file.value, guestID);
                         
//                               await NotificationMethods().sendGuardAskNotification(imageUrl: imageUrl,name:name.text, count:selectedPeople,targetId :widget.data.token);
                          
//                               imageUrl ="";
//                               _file.value = Uint8List(0);
//                               name.clear();
//                               Get.back();
//                               }
                              
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 16.0, right: 16.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                  isLoading.value
//                                             ? LoadingAnimationWidget.waveDots(
//                                                 color: Colors.white, size: 40)
//                                             : const Text(
//                                                 'ASK',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                   12.widthBox,
//                                   const Icon(
//                                     Icons.announcement,
//                                     color: Colors.white,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     24.heightBox,
//                     ProfileAvatar(
//                       uid: widget.data.uid,
//                       height: 70,
//                       width: 70,
//                     ),
//                     12.heightBox,
//                     Text(widget.data.firstName, style: AppTheme.subheading2),
//                     4.heightBox,
//                     Text(
//                       widget.data.email,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTheme.smallText,
//                     ),
//                     16.heightBox,
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       child: Row(
//                         // mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: AppTheme.lightBackgroundColor,
//                                 ),
//                                 child: const Padding(
//                                   padding: EdgeInsets.all(20.0),
//                                   child: Icon(
//                                     FontAwesomeIcons.city,
//                                     size: 24,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(
//                                   width: 70,
//                                   child: Text(
//                                     "SevenGeth Society",
//                                     style: AppTheme.smallText,
//                                     textAlign: TextAlign.center,
//                                   ))
//                             ],
//                           ),
//                           Container(
//                             width: 2,
//                             height: 52,
//                             decoration: BoxDecoration(
//                                 color: AppTheme.lightText.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(10)),
//                           ),
//                           Column(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: AppTheme.lightBackgroundColor,
//                                 ),
//                                 child: const Padding(
//                                   padding: EdgeInsets.all(20.0),
//                                   child: Icon(
//                                     // ignore: deprecated_member_use
//                                     FontAwesomeIcons.home,
//                                     size: 24,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(
//                                   width: 70,
//                                   child: Text(
//                                     "603",
//                                     style: AppTheme.smallText,
//                                     textAlign: TextAlign.center,
//                                   ))
//                             ],
//                           ),
//                           Container(
//                             width: 2,
//                             height: 52,
//                             decoration: BoxDecoration(
//                                 color: AppTheme.lightText.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(10)),
//                           ),
//                           Column(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: AppTheme.lightBackgroundColor,
//                                 ),
//                                 child: const Padding(
//                                   padding: EdgeInsets.all(20.0),
//                                   child: Icon(
//                                     FontAwesomeIcons.building,
//                                     size: 24,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(
//                                   width: 70,
//                                   child: Text(
//                                     "Block 3",
//                                     style: AppTheme.smallText,
//                                     textAlign: TextAlign.center,
//                                   ))
//                             ],
//                           )

//                           // Image.asset(data.icon),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             height: 54,
//                             width: 112,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(40),
//                               color: AppTheme.buttonColor,
//                             ),
//                             child: GestureDetector(
//                               onTap: () async {
//                                 Uri phoneno = Uri.parse('tel:+919106390823');
//                                 if (await launchUrl(phoneno)) {
//                                   //dialer opened
//                                 } else {
//                                   //dailer is not opened
//                                 }
//                               },
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 16.0, right: 16.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Text(
//                                       "Call",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     12.widthBox,
//                                     const Icon(
//                                       CupertinoIcons.phone,
//                                       color: Colors.white,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           12.widthBox,
//                           Container(
//                             height: 54,
//                             width: 112,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(40),
//                               color: AppTheme.buttonColor,
//                             ),
//                             child: GestureDetector(
//                               onTap: () async {
//                                 _file.value =
//                                     await pickImage(ImageSource.camera);
                                    
                                

//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                     left: 16.0, right: 16.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Text(
//                                       "ASK",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     12.widthBox,
//                                     const Icon(
//                                       Icons.announcement,
//                                       color: Colors.white,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // CustomButton(
//                           //     onTap: () async  {
//                           //       Uint8List file = await pickImage(ImageSource.camera);
//                           //     },
//                           //     height: 54,
//                           //     width: 112,
//                           //     text: "Ask",
//                           //     iconData: Icons.announcement),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//         }));
//   }

//   pickImage(ImageSource source) async {
//     final ImagePicker imagePicker = ImagePicker();
//     XFile? file = await imagePicker.pickImage(source: source);
//     if (file != null) {
//       return await file.readAsBytes();
//     }
//   }
// }

// class MemberCard extends StatelessWidget {
//   const MemberCard(
//     this.context, {
//     required this.data,
//     Key? key,
//   }) : super(key: key);

//   final BuildContext context;
//   final UserData data;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       clipBehavior: Clip.antiAlias,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.all(Radius.circular(32)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           16.widthBox,
//           GestureDetector(
//             onTap: () {
//               // user_card(userinfo == null
//               //     ? user!.displayName ?? "Newbie"
//               //     : userinfo.firstName ?? "Newbie");
//             },
//             // onTap: () => Get.to(ProfilePage()),
//             child: ProfileAvatar(
//               uid: data.uid,
//               height: 50,
//               width: 50,
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(data.firstName, style: AppTheme.subheading2),
//                   const SizedBox(height: 8),
//                   Text(
//                     data.email,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: AppTheme.smallText,
//                   )
//                 ],
//               ),
//             ),
//           ),
//           // Image.asset(data.icon),
//         ],
//       ),
//     );
//   }
// }
