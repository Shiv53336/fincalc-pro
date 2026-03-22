import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'premium_manager.dart';

class AdService {
  static bool _initialized = false;

  static const String _androidBannerAdUnitId =
      'ca-app-pub-6717135600615771/3804209403';

  static String get bannerAdUnitId => _androidBannerAdUnitId;

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
