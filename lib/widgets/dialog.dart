

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:urbannest/core/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}


class _CustomDialogState extends State<CustomDialog> {

  bool result = false;
  BannerAd? bannerAd;

  @override
  void initState() {
    bannerAd = Constants.initBannerAdd(size: AdSize.banner);
    result = Constants.getProbability(0.9);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
             padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom <90
                        ? MediaQuery.of(context).viewInsets.bottom
                        : MediaQuery.of(context).viewInsets.bottom - 80),
            child: Center(
                    child: Container(
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
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 
                                      MediaQuery.of(context).size.width - 120,
                                      maxWidth:   MediaQuery.of(context).size.width - 120,
                                      maxHeight:   MediaQuery.of(context).size.height - 200,
                      ),
                      
                    
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             Icon( CupertinoIcons.xmark,).onTap(() {Get.back();}),
                             8.widthBox,
                           ],
                         ),
                          Material(
                            color: Colors.transparent,
                            child: widget.child,
                          ),
                          // 40.heightBox,
                        ],
                      ).scrollVertical(),
                    ),
                  ),
                )),
          ),
        ),
            Align(alignment: Alignment.bottomCenter,
            child: 
            Constants.showAd && result ? getAd()  : const SizedBox(),
            )
      ],
    );
  }

  getAd() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(height: 65, child: AdWidget(ad: bannerAd!)),
    );
  }
}
