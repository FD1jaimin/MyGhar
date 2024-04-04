// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/user.dart';

class Constants {
  static String societyId = '';
  static String userId = '';
  static String type = '';
  static bool showAd = false;

  static String? FCM = "";
  static UserData userData = UserData(firstName: "New", uid: userId, email: '');

  static types.User changeUserChat(UserData userData) {
    types.User chatUser = types.User(
        id: userData.uid,
        createdAt: userData.createdAt,
        firstName: userData.firstName,
        imageUrl: userData.imageUrl,
        lastName: userData.lastName,
        lastSeen: userData.lastSeen,
        metadata: userData.metadata,
        role: userData.role,
        updatedAt: userData.updatedAt);
    return chatUser;
  }

  static Future<Uint8List> compressImage(
      Uint8List list, int height, int width, int quality) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: height,
      minWidth: width,
      quality: quality,
    );
    return result;
  }

  // static showRewardAdd() {
  //   RewardedAd? rewardedAd;
  //   RewardedAd.load(
  //       adUnitId: Platform.isAndroid
  //           ? 'ca-app-pub-8834577466514734/4001340012'
  //           : 'ca-app-pub-8834577466514734/4001340012',
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (ad) {
  //           rewardedAd = ad;
  //           rewardedAd?.show(onUserEarnedReward: (ad, reward) {
  //             debugPrint("${reward.amount}");
  //           });
  //           rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
  //             onAdFailedToShowFullScreenContent: (ad, error) {
  //               ad.dispose();
  //             },
  //             onAdDismissedFullScreenContent: (ad) {
  //               ad.dispose();
  //               Get.back();
  //             },
  //           );
  //         },
  //         onAdFailedToLoad: (error) {
  //           debugPrint(error.message);
  //         },
  //       ));
  // }

  static BannerAd initBannerAdd({AdSize? size}) {
    AdRequest? adRequest;
    BannerAd? bannerAd;
    String bannerId = Platform.isAndroid
        ? 'ca-app-pub-8834577466514734/1973942475'
        : 'ca-app-pub-8834577466514734/1993854275';
    adRequest = const AdRequest(
        //keywords: [ "Mobile" , "Grocery" , "Lifestyle" ],
        nonPersonalizedAds: true);

    BannerAdListener bannerAdListener = BannerAdListener(
      onAdClosed: (ad) {
        bannerAd!.load();
      },
      onAdFailedToLoad: (ad, error) {
        bannerAd!.load();
      },
    );
    bannerAd = BannerAd(
        size: size!,
        adUnitId: bannerId,
        listener: bannerAdListener,
        request: adRequest);
    bannerAd.load();

    return bannerAd;
  }

  static bool getProbability(double value) {
    Random ran = Random();
    bool result = ran.nextDouble() <= value;
    // return result;
    return true;
  }
 

  static  showIntertitialAd() {
    InterstitialAd? interstitialAd;
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? "ca-app-pub-8834577466514734/1838797836"
            : "ca-app-pub-8834577466514734/9323170640",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialAd = ad;
            interstitialAd!.show();
            interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
                    onAdFailedToShowFullScreenContent: ((ad, error) {
              ad.dispose();
              interstitialAd!.dispose();
              debugPrint(error.message);
            }), onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              interstitialAd!.dispose();
            });
          },
          onAdFailedToLoad: (err) {
            debugPrint(err.message);
          },
        ));
  }
}
