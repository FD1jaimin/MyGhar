import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:quantupi/quantupi.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/widgets/button.dart';
import 'package:velocity_x/velocity_x.dart';

class ScreenPayment extends StatefulWidget {
  const ScreenPayment(
      {Key? key,
      this.amount,
      this.id,
      this.house,
      this.note,
      this.maintenanceId})
      : super(key: key);
  final double? amount;
  final String? id;
  final String? house;
  final String? note;
  final String? maintenanceId;

  @override
  State<ScreenPayment> createState() => _ScreenPaymentState();
}

class _ScreenPaymentState extends State<ScreenPayment> {
  String data = 'Testing plugin';

  String appname = paymentappoptions[0];

  @override
  void initState() {
    super.initState();
  }

  Future<String> initiateTransaction({QuantUPIPaymentApps? app}) async {
    Quantupi upi = Quantupi(
      receiverUpiId: widget.id!,

      receiverName: Constants.userData.societyName!,
      // merchantId: '9429942277@okbizaxis',
      transactionRefId: '',
      transactionNote: widget.note!,
      amount: widget.amount!,
      appname: app,
    );
    String response = await upi.startTransaction();
    if (response.contains('success')){

    print('Transaction Successful');
    Get.back();
    await FirebaseFirestore.instance
        .collection('societies')
        .doc(Constants.societyId)
        .collection('maintenances')
        .doc(widget.maintenanceId)
        .update({
      'isPaidArray': FieldValue.arrayUnion([widget.house])
    });
    } 
    return response;
  }

  @override
  Widget build(BuildContext context) {
    bool isios = !kIsWeb && Platform.isIOS;
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Text("Select the payement app suitable for you from below",style: AppTheme.smallText,),
                12.heightBox,
                DropdownButton<String>(
                  value: appname,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    height: 0,
                    // color: ,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      appname = newValue!;
                    });
                  },
                  items: paymentappoptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Center(
                          child: Text(
                            value,
                            style: AppTheme.smallText,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            const SizedBox(height: 20),

              CustomButton(
                height: 54,
                width: 168,
                text: "Tap to pay",
                onTap: () async {
                  String value = await initiateTransaction(
                    app: isios ? appoptiontoenum(appname) : null,
                  );
                  setState(() {
                    data = value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: Text(
              //     data,
              //     style: const TextStyle(fontSize: 20),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  QuantUPIPaymentApps appoptiontoenum(String appname) {
    switch (appname) {
      case 'Amazon Pay':
        return QuantUPIPaymentApps.amazonpay;
      case 'BHIMUPI':
        return QuantUPIPaymentApps.bhimupi;
      case 'Google Pay':
        return QuantUPIPaymentApps.googlepay;
      case 'Mi Pay':
        return QuantUPIPaymentApps.mipay;
      case 'Mobikwik':
        return QuantUPIPaymentApps.mobikwik;
      case 'Airtel Thanks':
        return QuantUPIPaymentApps.myairtelupi;
      case 'Paytm':
        return QuantUPIPaymentApps.paytm;

      case 'PhonePe':
        return QuantUPIPaymentApps.phonepe;
      case 'SBI PAY':
        return QuantUPIPaymentApps.sbiupi;
      default:
        return QuantUPIPaymentApps.googlepay;
    }
  }
}

const List<String> paymentappoptions = [
  'Amazon Pay',
  'BHIMUPI',
  'Google Pay',
  'Mi Pay',
  'Mobikwik',
  'Airtel Thanks',
  'Paytm',
  'PhonePe',
  'SBI PAY',
];
