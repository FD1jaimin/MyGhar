

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../views/notice_screen.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard(
    this.context, {
    required this.title,
    required this.body,
    required this.height,
    this.isExpanded = false,
    this.name,
    this.dateTime,
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final String title;
  final String body;
  final String? name;
  final double height;
  final bool isExpanded;
  final String? dateTime;

  @override
  Widget build(BuildContext context) {
    DateTime tempDate = DateFormat.MMMEd().add_jm().parse(dateTime!);
    final now = DateTime.now();
    DateTime cardDate = DateTime(now.year, tempDate.month, tempDate.day);
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      clipBehavior: Clip.antiAlias,
      height: height,
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
                  padding: const EdgeInsets.only(top: 16, bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 60),
                              child: Text(
                                                              title,
                                                              style: AppTheme.subheading2,
                                                              maxLines: isExpanded ? 10 : 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: isExpanded
                                  ? (title.length >= 20
                                      ? height - 110
                                      : height - 90)
                                  : (height - 90),
                              child: SingleChildScrollView(
                                child: Text(
                                  body,
                                  maxLines: isExpanded ? 200 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.smallText,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
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
                            Text(
                              "Post by : ${name ?? 'Unknown'}",
                              style: AppTheme.smallText.copyWith(fontSize: 10),
                            ),
                            Text(dateTime ?? "",
                                style:
                                    AppTheme.smallText.copyWith(fontSize: 10))
                          ],
                        ),
                      )
                      
                    ],
                  ),
                ),
                cardDate == today
                    ? Padding(
                        padding: const EdgeInsets.only(right: 34),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12)),
                                color: AppTheme.appColor),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text(
                                "new",
                                style: AppTheme.smallText
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const  SizedBox(),
              ],
            ),
          ),
          // Image.asset(data.icon),
        ],
      ),
    );
  }
}
