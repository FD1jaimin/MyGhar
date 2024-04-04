import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../app_theme.dart';
import '../../core/firestore_methods.dart';
import '../../widgets/back_button.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _PrivaeatScreene();
}

class _PrivaeatScreene extends State<SupportScreen> {
  TextEditingController report = TextEditingController();

  bool isIssue = false;

  void _launchEmail() async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'myghar.info@gmail.com',
      queryParameters: {'subject': '', 'body': ''},
    );

    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      throw 'Could not launch $_emailLaunchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
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
                    "Get Support",
                    style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                  ),
                ),
              ],
            ).onTap(() {}),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    15.heightBox,
                    TextField(
                      style: AppTheme.heading2,
                      decoration: InputDecoration(
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 105, 110, 116),
                            width: 2,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(231, 236, 243, 1),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(231, 236, 243, 1),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: AppTheme.appColor,
                            width: 2,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(231, 236, 243, 1),
                            width: 2,
                          ),
                        ),
                        hintStyle: AppTheme.smallText,
                        hintText: "type here ...",
                        contentPadding: const EdgeInsets.all(24),
                        errorStyle: AppTheme.smallText.copyWith(
                          fontSize: 10,
                        ),
                      ),
                      // hint: "type here ...",
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      controller: report,
                      // expands: true,
                      autofocus: false,
                      // textController: report,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          height: 60,
                          width: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppTheme.appColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "    REPORT",
                                  style: AppTheme.subheading2
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 54,
                                width: 54,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    CupertinoIcons.paperplane_fill,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ).onTap(
                          () {
                            if (report.text != "") {
                              FireStoreMethods().report(issue: report.text);
                              report.clear();
                              Fluttertoast.showToast(msg: "Issue noted");
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Issue can't be empty");
                            }
                            isIssue = !isIssue;

                            setState(() {});
                          },
                        )),
                    40.heightBox,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.mail_solid),
                          10.widthBox,
                          const Text(
                            'myghar.info@gmail.com',
                            style: AppTheme.heading3,
                          )
                        ],
                      ),
                    ).onTap(() {
                      _launchEmail();
                    }),
                    20.heightBox,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.link),
                          10.widthBox,
                          Text(
                            'https://www.webinent.com',
                            style: AppTheme.heading3.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          )
                        ],
                      ),
                    ).onTap(() async {
                      String url = 'https://www.webinent.com/';
                      try {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                        // ignore: empty_catches
                      } catch (e) {}
                    }),
                    20.heightBox,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.phone),
                          10.widthBox,
                          const Text(
                            '9327991915',
                            style: AppTheme.heading3,
                          )
                        ],
                      ),
                    ).onTap(() async {
                      Uri phoneno = Uri.parse('tel:+91 9327991915');
                      if (await launchUrl(phoneno)) {
                        //dialer opened
                      } else {
                        //dailer is not opened
                      }
                    }),
                    40.heightBox,
                    Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'project by',
                          style: AppTheme.smallText,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 150,
                            height: 40,
                            child: Image.network(
                                'https://www.webinent.com/wp-content/uploads/2022/12/webinent-logo.png'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}