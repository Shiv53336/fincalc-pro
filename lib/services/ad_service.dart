import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'premium_manager.dart';

class AdService {
  static bool _initialized = false;

  // Test IDs — replace with real IDs from AdMob console before release
  static const String _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Production IDs (set these from AdMob console)
  // static const String _androidProdBannerAdUnitId =
  //     'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get bannerAdUnitId => _androidTestBannerAdUnitId;

  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  static bool get shouldShowAds => !PremiumManager.isPremium;

  static BannerAd createBannerAd({
    required BannerAdListener listener,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    );
  }
}
