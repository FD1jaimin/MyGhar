
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/core/notification_method.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import 'package:urbannest/widgets/text_fields.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/notices.dart';
import '../widgets/date_picker.dart';
import '../widgets/dialog.dart';
import '../widgets/floating_action_button.dart';
import '../widgets/notice_card.dart';
import '../widgets/topbar.dart';

class FundsScreen extends StatefulWidget {
  const FundsScreen({super.key});

  @override
  State<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  // const FundsScreen({super.key});
  TextEditingController title = TextEditingController();

  TextEditingController body = TextEditingController();

  TextEditingController price = TextEditingController();

  final TextEditingController date = TextEditingController();

  var type = true.obs;
  int total  = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton: Constants.type == "admin"
          ? CustomFloatingActionButton(
              onTap: () async {
                _addTransactionPopUp(context);
              },
            )
          : const SizedBox(),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CreateTopBar(title: "Society Funds"),
          getTotalAmount(),
          Divider(indent: 154,endIndent: 154,thickness: 2,color: AppTheme.lightText.withOpacity(0.3),),
          getNoticesList(),
          
        ],
      )),
    );
  }

  Future<dynamic> _addTransactionPopUp(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              8.heightBox,
              const Text(
                'Add Transaction',
                style: AppTheme.subheading2,
                textAlign: TextAlign.center,
              ),
              14.heightBox,
              CustomTextField(
                  isForm: true,
                  keyboardType: TextInputType.text,
                  hint: "Enter transaction Name",
                  validator: (value) {
                    return null;
                  },
                  textController: title),
              12.heightBox,
              // CustomTextField(
              //     isForm: true,
              //     minLines: 2,
              //     maxLines: 2,
              //     keyboardType: TextInputType.multiline,
              //     hint: "Enter transaction description",
              //     validator: (value) {
              //       return null;
              //     },
              //     textController: body),
              //     12.heightBox,
               Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: CustomTextField(
                                                isForm: true,
                                                icon: const Icon(Icons
                                                    .currency_rupee_rounded),
                                                keyboardType:
                                                    TextInputType.number,
                                                hint: "Amount",
                                                validator: (value) {
                                                  return null;
                                                },
                                                textController: price),
                                          ),
                                      12.widthBox,
                                      Obx(() {return type.value ?  Expanded(
                                        flex: 1,
                                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.green[400],),height: 56, child: Center(child:
                                          Icon(Icons.add_rounded,size: 32,color: Colors.white,),
                                        )),
                                      ): Expanded(
                                        flex: 1,
                                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(color:Colors.green[400]!,width: 2 )),height: 56, child: Center(child:
                                          Icon(Icons.add_rounded,size: 32,color: Colors.green[400],),
                                        )).onTap(() {
                                          setState(() {
                                            type.value =!type.value;
                                          }); 
                                        }),
                                      );}),
                                      6.widthBox,
                                      Obx((){
                                        return 
                                      !type.value ?  Expanded(
                                        flex: 1,
                                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.red[400],),height: 56, child: Center(child:
                                          Icon(Icons.remove_rounded,size: 32,color: Colors.white,),
                                        )),
                                      ): Expanded(
                                        flex: 1,
                                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(color:Colors.red[400]!,width: 2 )),height: 56, child: Center(child:
                                          Icon(Icons.remove_rounded,size: 32,color: Colors.red[400],),
                                        )).onTap(() {
                                          setState(() {
                                            type.value =!type.value;
                                          });
                                        }),
                                      
                                        );
                                      })
                                      
                                      
                                      
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: Container(color: Colors.amber,)
                                      // ),
                                    ],
                                  ),
              12.heightBox,
              CustomButton(
                  onTap: () async {

                    if(price.text != ''&& title.text!=''){
                    if(!type.value && total < int.parse(price.text)){
                      Fluttertoast.showToast(msg: "You don't have this much fund left");
                    // Get.back();
                    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                    else{ Get.back();
                    
                    
                    
                    String res = await FireStoreMethods().createTransaction(
                      title: title.text,
                      // body: body.text,
                      amount: int.parse(price.text),
                      type: type.value,
                      societyId: Constants.societyId,                                                                                                                                                                                                                                                                                                                                                                                      
                      
                    );}

                    // if (res == "success") {
                    //   sendNotification();
                    // }
                    // }else{
                    //   Fluttertoast.showToast(msg: "Please fill all the details");
                    // }
                    title.clear();
    body.clear();
    price.clear();
                  };},
                  height: 58,
                  width: 188,
                  text: "Add"),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget getTotalAmount(){
    return Container(
      child: Column(
        children: [
          24.heightBox,
          Text("Total fund",style: AppTheme.smallText,),
         Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(
                                          Icons.currency_rupee_outlined,
                                          color: AppTheme.lightText,
                                          weight: 100.0,
                                          fill: 1.0,
                                          size: 30,
                                        ),
          Center(child: StreamBuilder(
             stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
              if(!snapshot.hasData){
                return Text(" - ",style: AppTheme.heading.copyWith(fontSize: 60),);
              }else{
              total =snapshot.data!.data()!['funds'];
              return Text(NumberFormat.compact().format(snapshot.data!.data()!['funds'])+ "  ",style: AppTheme.heading.copyWith(fontSize: 60),);
              }
            }
          )),
          12.heightBox,
         ],)
        ],
      ),
    );
  }

  void sendNotification() async {
   await  NotificationMethods().sendNotificationTopics(
      to: '/topics/${Constants.societyId}',
      title: "Notice : ${title.text}",
      body: body.text,
      type: 'notice',
    );
    // await  NotificationMethods().sendNotificationTopics(
    //   to: '/topics/guard-${Constants.societyId}',
    //   title: "Notice : ${title.text}",
    //   body: body.text,
    //   type: 'notice',
    // );
    Fluttertoast.showToast(msg: 'Notice Send');
    title.clear();
    body.clear();
    date.clear();
  }

  Widget getNoticesList() {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 24.0),
        child: NoticeList(),
      ),
    );
  }
}

class NoticeList extends StatefulWidget {
  const NoticeList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> with TickerProviderStateMixin {
  AnimationController? animationController;

  bool result = false;
  bool resultShare = false;
  BannerAd? bannerAd;
  bool isFirst = true;



  getAd() {
    if(isFirst && bannerAd!=null){

    isFirst = false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(height: 65, child: AdWidget(ad: bannerAd!)),
    );
    }
    return Container();
  }
  
  @override
  void initState() {
    // bannerAd = Constants.initBannerAdd(size: AdSize.banner);
    result = Constants.getProbability(0.9);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('transactions')
            .orderBy("createdOn", descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            List<dynamic> data = [];
            
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              dynamic transaction = snapshot.data!.docs[i];
               data.add(transaction);
              
            }

            return data.isEmpty
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      "No Transitions Records",
                      style: AppTheme.smallText,
                    ),
                  ))
                : ListView(
                    children: List<Widget>.generate(
                      data.length  +1,
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
                        return index == data.length  ? Constants.showAd && result ? getAd() : const SizedBox()
              :Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: 
                TransactionItem(
                  transactionData: data[index],
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

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    Key? key,
    this.transactionData,
    this.animationController,
    this.animation,
  }) : super(key: key);

  final dynamic? transactionData;
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
              child: transactionCard(transactionData,context)
            ),
          ),
        );
      },
    );
  }
}

Widget transactionCard(dynamic transactionData,BuildContext context){
  return Container(
      clipBehavior: Clip.antiAlias,
      // height: 164,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width/2.2,
                        child: Text(
                                                        transactionData!['title'].toString(),
                                                        style: AppTheme.heading2,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                      ),
                      // const SizedBox(height: 8),
                      Text(
                        "by " +transactionData!['username'],
                        maxLines:  2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.smallText,
                      )
                    ],
                  ),
                ),
                // MySeparator(
                //   color: AppTheme.lightText.withOpacity(0.4),
                //   height: 2,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 20, vertical: 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Post by : ${name ?? 'Unknown'}",
                //         style: AppTheme.smallText.copyWith(fontSize: 10),
                //       ),
                //       Text(dateTime ?? "",
                //           style:
                //               AppTheme.smallText.copyWith(fontSize: 10))
                //     ],
                //   ),
                // )
                
              ],
            ),
          ),
           Padding(
             padding: const EdgeInsets.only(right: 24),
             child: Text(
                                                          (transactionData['type'] ? "+" : "-" )+NumberFormat.compact().format(transactionData!['amount']),
                                                          style: AppTheme.heading.copyWith(color: transactionData['type'] ? Colors.green[400]:Colors.red[400]),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
           ),
                                                      

          // Image.asset(data.icon),
        ],
      ),
    );
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 8.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          // ignore: sort_child_properties_last
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(20)),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
