import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:urbannest/app_theme.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/back_button.dart';


class Video {
  final String title;
  final String description;
  final String videoId;

  Video({
    required this.title,
    required this.description,
    required this.videoId,
  });
}

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int index = 0;
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
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
                        "User Guide",
                        style:
                            AppTheme.subheading.copyWith(letterSpacing: -0.3),
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('links').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 64.0),
                            child: LoadingAnimationWidget.waveDots(
                                color: AppTheme.lightText, size: 40),
                          ),
                        );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      index++;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return VideoItem(
                        index: index,
                        video: Video(
                          title: data['title'],
                          description: data['des'],
                          videoId: data['videoId'],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoItem extends StatelessWidget {
  final Video video;
  final int? index;

  const VideoItem({required this.video, this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${index!}. ' + video.title, style: AppTheme.subheading),
        const SizedBox(height: 2.0),
        Text(
          video.description,
          style: AppTheme.smallText,
        ),
        const SizedBox(height: 8.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: YoutubePlayer(
            aspectRatio: 16/9,
            controller: YoutubePlayerController(
              initialVideoId: video.videoId,

              flags: const YoutubePlayerFlags(
                loop: false,
                
                autoPlay: false,
              ),
            ),
            showVideoProgressIndicator: true,
          ),
        ),
        16.heightBox,
        Center(
          child: const SizedBox(
            width: 56,
            child: VxDivider(
              width: 2,
              color: AppTheme.lightText,
            ),
          ),
        ),
        16.heightBox,
      ],
    );
  }
}