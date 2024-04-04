import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:upi_india/upi_india.dart';
import 'package:urbannest/app_theme.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../widgets/back_button.dart';

class AmenitiesPayement extends StatefulWidget {
  const AmenitiesPayement({super.key, this.amount,this.house,this.note, this.id, this.amenitiesId,this.amenitiesName});
  final double? amount;
  final String? id;
  final String? house;
  final String? note;
  final String? amenitiesName;
  final String? amenitiesId;

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<AmenitiesPayement> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app,String? note) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: widget.id!,
      receiverName: Constants.userData.societyName!,
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: note,
      amount: widget.amount!,
    );
  }

  Widget displayUpiApps(String note) {
    if (apps == null) {
      return  Center(child: Center(
                      child: LoadingAnimationWidget.waveDots(
                                        color: AppTheme.lightText, size: 40),
                    ),);
    } else if (apps!.isEmpty)
      // ignore: curly_braces_in_flow_control_structures
      return const Center(
        child: Text(
          "No apps found to handle transaction.",
          style: AppTheme.smallText,
        ),
      );
    else{
   if(! apps!.contains(UpiApp.csbUpi)){
    apps!.add(UpiApp.csbUpi);
   }
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              if(app == UpiApp.csbUpi){
                return GestureDetector(
                onTap: () {
                   String notificationId =
                                                            const Uuid().v1();
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .where("societyId",
                                                      isEqualTo:
                                                          Constants.societyId)
                                                  .where("type",
                                                      isEqualTo: 'admin')
                                                  .get()
                                                  .then((data) =>
                                                      data.docs.forEach((doc) {
                                                       

                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(doc.id)
                                                            .collection(
                                                                'notifications')
                                                            .doc(notificationId)
                                                            .set({
                                                          'id': notificationId,
                                                          'title':
                                                              "Booking amount paid : ${widget.amenitiesName}",
                                                          'body':
                                                              "${Constants.userData.firstName} : I've already paid for ${widget.amenitiesName} booking  please check",
                                                          'timestamp': FieldValue
                                                              .serverTimestamp(),
                                                          'type':
                                                              "newAmenityPaid",
                                                              'house':Constants.userData.house,
                                                          'uid':
                                                              Constants.userId,
                                                          'amenityId':
                                                              widget
                                                                  .amenitiesId,
                                                        });
                                                        // userIds.add(doc["id"]);
                                                      }));
                                              
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Booking pre-paid request send for Approval");
                                                      Get.back();
                  // _transaction = initiateTransaction(app,note);
                  // setState(() {});
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                                              Icons.handshake,
                                              color: Colors.green[400],
                                              size: 54,
                                            ),
                      ),
                      Text("I have paid"),
                    ],
                  ),
                ),
              );
              }else{

              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app,note);
                  setState(() {});
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
              }
            }).toList(),
          ),
        ),
      );
    }
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        Fluttertoast.showToast(msg: "Receivers UPI is not valid");
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  Future<void> _checkTxnStatus(String status) async {
      print(UpiPaymentStatus.SUCCESS);
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        // if (kDebugMode) {
          print('Transaction Successful');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(Constants.userId)
              .collection('amenities')
              .doc(widget.amenitiesId)
              .update({
            'status': 'Confirmed'});
          String notificationId =
                                                            const Uuid().v1();
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .where("societyId",
                                                      isEqualTo:
                                                          Constants.societyId)
                                                  .where("type",
                                                      isEqualTo: 'admin')
                                                  .get()
                                                  .then((data) =>
                                                      data.docs.forEach((doc) {
                                                       

                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(doc.id)
                                                            .collection(
                                                                'notifications')
                                                            .doc(notificationId)
                                                            .set({
                                                          'id': notificationId,
                                                          'title':
                                                              "Booking payement done: ${widget.amenitiesName}",
                                                          'body':
                                                              "${Constants.userData.firstName} : Paid for ${widget.amenitiesName} booking  please check, and fix the slot.",
                                                          'timestamp': FieldValue
                                                              .serverTimestamp(),
                                                          'type':
                                                              "normal",
                                                              // 'house':Constants.userData.house,
                                                          'uid':
                                                              Constants.userId,
                                                          'amenityId':
                                                              widget
                                                                  .amenitiesId,
                                                        });
                                                        // userIds.add(doc["id"]);
                                                      }));
                                              
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Booking Confirmed!!!");
                                                      Get.back();
        // }
        break;
      case UpiPaymentStatus.SUBMITTED:
        if (kDebugMode) {
          print('Transaction Submitted');
        }
        break;
      case UpiPaymentStatus.FAILURE:
        if (kDebugMode) {
          print('Transaction Failed');
        }
        break;
      default:
        if (kDebugMode) {
          print('Received an Unknown transaction status');
        }
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: AppTheme.heading2),
          Flexible(
              child: Text(
            body,
            style: AppTheme.smallText,
          )),
        ],
      ),
    );
  }

  update(String tId) async {
    await FirebaseFirestore.instance
        .collection('societies')
        .doc(Constants.societyId)
        .collection('maintenances')
        .doc(widget.amenitiesId)
        .update({'transactionId': tId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                      "Payments",
                      style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: displayUpiApps(widget.note!),
            ),
            Divider(indent: 102,endIndent: 102,thickness: 2,color: AppTheme.lightText.withOpacity(0.5),),
            Expanded(
              child: FutureBuilder(
                future: _transaction,
                builder: (BuildContext context,
                    AsyncSnapshot<UpiResponse> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _upiErrorHandler(snapshot.error.runtimeType),
                            style: header,
                          ),
                        ), // Print's text message on screen
                      );
                    }

                    // If we have data then definitely we will have UpiResponse.
                    // It cannot be null
                    UpiResponse upiResponse = snapshot.data!;

                    // Data in UpiResponse can be null. Check before printing
                    String txnId = upiResponse.transactionId ?? 'N/A';
                    String resCode = upiResponse.responseCode ?? 'N/A';
                    String txnRef = upiResponse.transactionRefId ?? 'N/A';
                    String status = upiResponse.status ?? 'N/A';
                    String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
                    _checkTxnStatus(
                      status,
                    );
                    update(txnId);

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          displayTransactionData('Transaction Id', txnId),
                          displayTransactionData('Response Code', resCode),
                          displayTransactionData('Reference Id', txnRef),
                          displayTransactionData(
                              'Status', status.toUpperCase()),
                          displayTransactionData('Approval No', approvalRef),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(''),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
