import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/models/amenity.dart';
import 'package:urbannest/views/amenities_screen.dart';
import 'package:urbannest/views/pay_upi.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:velocity_x/velocity_x.dart';

import 'amenitiesPayement.dart';
import 'notice_screen.dart';

class BookedAmenitiesScreen extends StatefulWidget {
  const BookedAmenitiesScreen({super.key});

  @override
  State<BookedAmenitiesScreen> createState() => _NoticeState();
}

class _NoticeState extends State<BookedAmenitiesScreen>
    with TickerProviderStateMixin {
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  final TextEditingController date = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),

      //   // mini: true,
      //   backgroundColor: AppTheme.appColor,
      //   foregroundColor: Colors.white,
      //   onPressed: () {
      //     showDialog(
      //         context: context,
      //         builder: (context) => Center(
      //                 child: Container(
      //               decoration: BoxDecoration(
      //                   color: Colors.white,
      //                   borderRadius: BorderRadius.circular(20),
      //                   boxShadow: [
      //                     BoxShadow(
      //                         offset: const Offset(0, 9),
      //                         blurRadius: 7,
      //                         color: Colors.black.withOpacity(0.30))
      //                   ]),
      //               child: Padding(
      //                 padding: const EdgeInsets.all(24),
      //                 child: Material(
      //                   color: Colors.transparent,
      //                   child: SizedBox(
      //                     height: 400,
      //                     width: MediaQuery.of(context).size.width - 120,
      //                     child: Column(
      //                       mainAxisSize: MainAxisSize.min,
      //                       children: [
      //                         Column(
      //                           children: [
      //                             8.heightBox,
      //                             Text(
      //                               'Send Notice',
      //                               style: AppTheme.subheading2,
      //                               textAlign: TextAlign.center,
      //                             ),
      //                             14.heightBox,
      //                             CustomTextField(
      //                                 isForm: true,
      //                                 keyboardType: TextInputType.text,
      //                                 hint: "Enter notice title",
      //                                 validator: (value) {
      //                                   return null;
      //                                 },
      //                                 textController: title),
      //                             12.heightBox,
      //                             CustomTextField(
      //                                 isForm: true,
      //                                 //  expands: true,
      //                                 minLines: 4,
      //                                 maxLines: 4,
      //                                 keyboardType: TextInputType.multiline,
      //                                 hint: "Enter notice body",
      //                                 validator: (value) {
      //                                   return null;
      //                                 },
      //                                 textController: body),
      //                             TextfieldDatePicker(
      //                               cupertinoDatePickerBackgroundColor:
      //                                   Colors.white,
      //                               cupertinoDatePickerMaximumDate:
      //                                   DateTime(2099),
      //                               cupertinoDatePickerMaximumYear: 2099,
      //                               cupertinoDatePickerMinimumYear:
      //                                   DateTime.now().year,
      //                               cupertinoDatePickerMinimumDate:
      //                                   DateTime.now(),
      //                               cupertinoDateInitialDateTime:
      //                                   DateTime.now(),
      //                               materialDatePickerFirstDate: DateTime.now(),
      //                               materialDatePickerInitialDate:
      //                                   DateTime.now(),
      //                               materialDatePickerLastDate: DateTime(2099),
      //                               preferredDateFormat:DateFormat.yMMMEd(),//DateFormat("yyyy-MM-dd hh:mm:ss"),
      //                               textfieldDatePickerController: date,
      //                               style: AppTheme.subheading3,
      //                               textCapitalization:
      //                                   TextCapitalization.sentences,
      //                               cursorColor: Colors.black,
      //                               decoration: InputDecoration(
      //                                 hintStyle: AppTheme
      //                                     .smallText, //TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      //                                 hintText: "Select End Date",
      //                                 contentPadding: EdgeInsets.symmetric(
      //                                     horizontal: 12, vertical: 18),

      //                                 errorStyle: AppTheme.smallText.copyWith(
      //                                   fontSize: 10,
      //                                 ),
      //                                 errorBorder: OutlineInputBorder(
      //                                   borderRadius: BorderRadius.circular(16),
      //                                   borderSide: const BorderSide(
      //                                     color: Color.fromRGBO(105, 110, 116,
      //                                         1), // Colors.red, // Color.fromARGB(255, 206, 63, 53),
      //                                     width: 2,
      //                                   ),
      //                                 ),
      //                                 focusedErrorBorder: OutlineInputBorder(
      //                                   borderRadius: BorderRadius.circular(16),
      //                                   borderSide: const BorderSide(
      //                                     color: Color.fromARGB(255, 105, 110,
      //                                         116), //Colors.red, //Color.fromARGB(255, 210, 81, 71),
      //                                     width: 2,
      //                                   ),
      //                                 ),
      //                                 disabledBorder: OutlineInputBorder(
      //                                   borderRadius: BorderRadius.circular(16),
      //                                   borderSide: const BorderSide(
      //                                     color:
      //                                         Color.fromRGBO(231, 236, 243, 1),
      //                                     width: 2,
      //                                   ),
      //                                 ),
      //                                 // focusColor: MyColors.resolveCompanyCOlour(),
      //                                 enabledBorder: OutlineInputBorder(
      //                                   borderRadius: BorderRadius.circular(16),
      //                                   borderSide: const BorderSide(
      //                                     color:
      //                                         Color.fromRGBO(171, 177, 186, 1),
      //                                     width: 2,
      //                                   ),
      //                                 ),
      //                                 focusedBorder: OutlineInputBorder(
      //                                   borderRadius: BorderRadius.circular(16),
      //                                   borderSide: BorderSide(
      //                                     color: AppTheme.appColor,
      //                                     width: 2,
      //                                   ),
      //                                 ),
      //                                 border: OutlineInputBorder(
      //                                   borderRadius: BorderRadius.circular(16),
      //                                   borderSide: const BorderSide(
      //                                     color:
      //                                         Color.fromRGBO(231, 236, 243, 1),
      //                                     width: 2,
      //                                   ),
      //                                 ),

      //                                 prefixIcon: Padding(
      //                                   child: IconTheme(
      //                                     data: IconThemeData(
      //                                         color: AppTheme.appColor
      //                                             .withOpacity(0.8)),
      //                                     child:
      //                                         Icon(FontAwesomeIcons.calendar),
      //                                   ),
      //                                   padding: const EdgeInsets.only(
      //                                       left: 26, right: 16),
      //                                 ),
      //                               ),
      //                             )
      //                           ],
      //                         ),
      //                         12.heightBox,
      //                         Container(
      //                           height: 58,
      //                           width: 188,
      //                           decoration: BoxDecoration(
      //                             borderRadius: BorderRadius.circular(40),
      //                             color: AppTheme.buttonColor,
      //                           ),
      //                           child: Padding(
      //                             padding: const EdgeInsets.only(
      //                                 left: 8.0, right: 8.0),
      //                             child: Row(
      //                               mainAxisAlignment: MainAxisAlignment.center,
      //                               children:  [
      //                                 Text(
      //                                   'Send',
      //                                   style: TextStyle(
      //                                     color: Colors.white,
      //                                     fontSize: 18,
      //                                     fontWeight: FontWeight.w500,
      //                                   ),
      //                                 ),
      //                                 12.widthBox,
      //                                 Icon(Icons.send_rounded,
      //                                     color: Colors.white),
      //                               ],
      //                             ),
      //                           ),
      //                         ).onTap(() {
      //                           DateTime tempDate =  DateFormat.yMMMEd().parse(date.text);

      //                            FireStoreMethods().createNotice(

      //                 title: title.text,
      //                 body: body.text,
      //                 expiry: tempDate);
      //                            Get.back();
      //                            title.clear();
      //                            body.clear();
      //                            date.clear();
      //                         }),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             )));
      //     // Respond to button press
      //   },
      //   child: Icon(Icons.add),
      // ),
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
                      "Booked Amenities",
                      style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ],
              ).onTap(() {}),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: getMyCourseList(),
              ),
            ),
            Container(
              color: AppTheme.lightBackgroundColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: CustomButton(
                  text: "Book Amenities",
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  onTap: () {
                    Get.to(const AmenitiesScreen());
                  },
                ),
              ),
            )
          ],
        ),
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
  // ignore: library_private_types_in_public_api
  _MyCourseListState createState() => _MyCourseListState();
}

class _MyCourseListState extends State<MyCourseList>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
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
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection("amenities")
            .orderBy("createdOn", descending: true)
            .limit(8)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            List<Amenity> data = [];
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              Amenity amenity = Amenity.fromSnap(snapshot.data!.docs[i]);

              //  DateTime tempDate =  DateFormat.yMMMEd().fr(userVisitor.expiry!);
              DateTime cardDate =
                  DateTime(amenity.to.year, amenity.to.month, amenity.to.day);

              if (today.isBefore(cardDate) ||
                  today.isAtSameMomentAs(cardDate)) {
                data.add(amenity);
              }
            }

            return data.isEmpty
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      "No Booked Amenities",
                      style: AppTheme.smallText,
                    ),
                  ))
                : ListView(
                    padding: const EdgeInsets.all(0),
                    // physics: const NeverScrollableScrollPhysics(),
                    // shrinkWrap: true,
                    children: List<Widget>.generate(
                      data.length,
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
                        return Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: CategoryView(
                            index: index,
                            amenityData: data[index],
                            snap: snapshot.data!.docs[index].data(),
                            animation: animation,
                            animationController: animationController,
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

class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key? key,
      this.snap,
      this.index,
      this.amenityData,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  final snap;
  final int? index;
  final VoidCallback? callback;
  final Amenity? amenityData;
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
                  // child: Container(color: Colors.red,height: 40,),
                  child: BookedCard(
                    context,
                    amenityData: amenityData,

                    // dateTime: DateFormat.MMMEd()
                    //     .add_jm()
                    //     .format(amenityData!.from!),
                  )).onTap(() {
                // showDialog(
                //   context: context,
                //   builder: (context) => Center(
                //       child: Padding(
                //     padding: const EdgeInsets.all(24.0),
                //     child: BookedCard(
                //       isExpanded: true,
                //       height: 450,
                //       context,
                //       title: noticeData!.title!,
                //       body: noticeData!.body!,
                //       name: noticeData!.username ?? "Unknown",
                //       dateTime: DateFormat.MMMEd()
                //           .add_jm()
                //           .format(noticeData!.createdOn),
                //     ),
                //   )),
                // );
              }),
            ),
          ),
        );
      },
    );
  }
}

class BookedCard extends StatelessWidget {
  const BookedCard(
    this.context, {
    this.amenityData,
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final Amenity? amenityData;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 164,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          color: amenityData!.status == 'Confirmed' ?Colors.blue[400] :amenityData!.status! == "Approved"
                              ? Colors.green[400]
                              : amenityData!.status! == "Pending"
                                  ? Colors.orange[400]
                                  : Colors.red[400]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Text(
                          amenityData!.status!,
                          style:
                              AppTheme.smallText.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                // : SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  // shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        offset: const Offset(0, 0),
                                        blurRadius: 8,
                                        color:
                                            AppTheme.appColor.withOpacity(0.1))
                                  ],
                                ),
                                width: 84,
                                height: 84,
                                child: Image.network(
                                  amenityData!.image ?? "",
                                  fit: BoxFit.cover,
                                ), //'images/glimpselogo.png'),
                              ),
                            ),
                            12.widthBox,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  amenityData!.name!,
                                  style: AppTheme.subheading,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    style: AppTheme.smallText,
                                    children: [
                                      WidgetSpan(
                                        child: const Icon(
                                          CupertinoIcons.calendar,
                                          color: AppTheme.lightText,
                                          size: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "  From : ${DateFormat.MMMEd().add_jm().format(amenityData!.from!)}",
                                        style: AppTheme.smallText,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    style: AppTheme.smallText,
                                    children: [
                                      WidgetSpan(
                                        child: const Icon(
                                          CupertinoIcons.calendar,
                                          color: AppTheme.lightText,
                                          size: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "  To : ${DateFormat.MMMEd().add_jm().format(amenityData!.to!)}",
                                        style: AppTheme.smallText,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      12.heightBox,
                      MySeparator(
                        color: AppTheme.lightText.withOpacity(0.4),
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            amenityData!.status == "Pending" ||
                                    amenityData!.status == ''
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.pending,
                                        color: Colors.green[400],
                                      ),
                                      const Text(
                                        " Wait till approval",
                                        style: AppTheme.smallText,
                                      ),
                                    ],
                                  )
                                : amenityData!.status == "Approved"
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.money,
                                            color: Colors.green[400],
                                          ),
                                          4.widthBox,
                                          Text(
                                            "Pay now >",
                                            style: AppTheme.subheading3
                                                .copyWith(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        AppTheme.darkText),
                                          ),
                                        ],
                                      ).onTap(() {
                                        Get.to(() => AmenitiesPayement(
                                          amenitiesName: amenityData!.name!,
                                          note: "Confirm Booking for ${amenityData!.name!}",
                                              amount: double.parse(
                                                amenityData!.amount!,
                                              ),
                                              
                                              amenitiesId: amenityData!.id,
                                              id: amenityData!.upi!,
                                            ));
                                      })
                                    : Row(
                                        children: [
                                          Icon(
                                            Icons.check_rounded,
                                            color: Colors.transparent,
                                          ),
                                          const Text(
                                            "-",
                                            style: AppTheme.smallText,
                                          ),
                                        ],
                                      ),
                            amenityData!.amount == "0"
                                ? const Text("FREE", style: AppTheme.smallText)
                                : amenityData!.status == 'Approved' ||
                                        amenityData!.status == 'Booked'
                                    ? Text("₹ ${amenityData!.amount}",
                                        style: AppTheme.smallText)
                                    : amenityData!.status == 'Denied'
                                        ? Text("Try Again",
                                            style: AppTheme.smallText)
                                        : Text(
                                            "Est. ₹ ${amenityData!.amount} ${amenityData!.type}",
                                            style: AppTheme.smallText)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Image.asset(data.icon),
        ],
      ),
    );
  }
}
