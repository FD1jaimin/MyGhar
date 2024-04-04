import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:urbannest/app_theme.dart';
import 'package:urbannest/core/constants.dart';
import 'package:urbannest/core/firestore_methods.dart';
import 'package:urbannest/widgets/back_button.dart';
import 'package:urbannest/widgets/button.dart';

import 'package:urbannest/widgets/text_fields.dart';
import 'package:velocity_x/velocity_x.dart';

import '../widgets/dialog.dart';
import '../widgets/floating_action_button.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _NoticeState();
}

class _NoticeState extends State<RulesScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      floatingActionButton:  Constants.type =="admin"  ?CustomFloatingActionButton(onTap: () {
        showDialog(
          barrierDismissible: false,
            context: context,
            builder: (context) => CustomDialog(child:_buildPopUp(context)));
      },) : const SizedBox(),
      body: SafeArea(
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
                      "Rules",
                      style: AppTheme.subheading.copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ],
              )),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 24.0, bottom: 16.0),
              child: RulesList(),
            ),
          ),
        ],
      )),
    );
  }
    TextEditingController rule = TextEditingController();
  SizedBox _buildPopUp(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Rule',
            style: AppTheme.subheading2,
            textAlign: TextAlign.center,
          ),
          12.heightBox,
          CustomTextField(
              isForm: true,
              minLines: 3,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              hint: "Enter rule",
              validator: (value) {
                return null;
              },
              textController: rule),
          12.heightBox,
          CustomButton(
              onTap: () async {
                if(rule.text!= ''){

                Get.back();
                await FireStoreMethods().addRule(
                  text: rule.text,
                );
                rule.clear();
                }else{
                  Fluttertoast.showToast(msg: "Please fill all the fields");
                }
              },
              height: 58,
              width: 188,
              text: "Add"),
        ],
      ),
    );
  }
}

class RulesList extends StatefulWidget {
  const RulesList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RulesListState createState() => _RulesListState();
}

class _RulesListState extends State<RulesList> with TickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('societies')
            .doc(Constants.societyId)
            .collection('rules')
            .orderBy("createdOn", descending: false)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: LoadingAnimationWidget.waveDots(
                  color: AppTheme.lightText, size: 40),
            );
          } else {
            dynamic data = snapshot.data!.docs;
            return data.length == 0
                ? const Center(
                    child: Text(
                    "No rules added",
                    style: AppTheme.smallText,
                  ))
                : ListView(
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
                        return Slidable(
                          closeOnScroll: true,
                          enabled: true,
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                flex: 2,
                                onPressed: (context) {
                                  FireStoreMethods()
                                      .deleteRule(data[index].data()['ruleId']);
                                },
                                icon: Icons.delete,
                                autoClose: true,
                                label: "Delete",
                                padding: const EdgeInsets.all(12),
                                backgroundColor: AppTheme.lightBackgroundColor,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: RuleCard(
                              index: index,
                              snap: snapshot.data!.docs[index].data(),
                              animation: animation,
                              animationController: animationController,
                            ),
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

class RuleCard extends StatelessWidget {
  const RuleCard({
    Key? key,
    this.index,
    this.snap,
    this.animationController,
    this.animation,
  }) : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  final snap;
  final int? index;
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        "${index! + 1}. ${snap['text']}",
                        style: AppTheme.smallText
                            .copyWith(fontWeight: FontWeight.bold),
                      ),),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
