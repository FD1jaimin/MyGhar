import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../app_theme.dart';
import '../../widgets/back_button.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivaeatScreene();
}

class _PrivaeatScreene extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 0, bottom: 12, left: 24, right: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomBackButton(),
                Padding(
                  padding: const EdgeInsets.only(top: 16.8, left: 16),
                  child: Text(
                    "Privacy Policy",
                    style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                  ),
                ),
              ],
            ).onTap(() {}),
          ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                  url: WebUri('https://www.webinent.com/privacy-policy/')),
              // ignore: deprecated_member_use
              initialOptions: InAppWebViewGroupOptions(
                // ignore: deprecated_member_use
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                ),
              ),
              onWebViewCreated: (controller) {},
              // ignore: deprecated_member_use
              onLoadError: (controller, url, code, message) {
                Fluttertoast.showToast(msg: "Please try again later.");
                print("WebView error: $code, $message");
              },
              onLoadStart: (controller, url) {
                Center(
                  child: LoadingAnimationWidget.waveDots(
                      color: AppTheme.lightText, size: 40),
                );
                //Fluttertoast.showToast(msg: "Loader Start");
              },
            ),
          ),
        ],
      )),
    );
  }
}