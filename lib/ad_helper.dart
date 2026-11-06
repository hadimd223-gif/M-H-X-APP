// ==============================================================================
// Google AdMob Unit IDs Helper
// Application ID: com.mhx.ads
// ==============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Google AdMob Application ID
  static const String adMobAppId = 'ca-app-pub-9467019896900554~2608224645';

  // Toggle this to true during development to avoid AdMob account suspension!
  // Google AdMob strictly penalizes clicking or testing with production ad IDs.
  static const bool useTestAds = kDebugMode;

  // 1. Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (useTestAds) {
      // Official Google Sample Banner Ad Unit ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9467019896900554/3083876525';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9467019896900554/3083876525';
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  // 2. Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (useTestAds) {
      // Official Google Sample Interstitial Ad Unit ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9467019896900554/6355897969';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9467019896900554/6355897969';
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  // 3. Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (useTestAds) {
      // Official Google Sample Rewarded Video Ad Unit ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9467019896900554/3355551299';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9467019896900554/3355551299';
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }
}
