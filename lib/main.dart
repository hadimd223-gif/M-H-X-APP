// ==============================================================================
// Application ID: com.mhx.ads
// App Title: MHX Ads Pro Dashboard
// Built for Google AdMob SDK with Banner, Interstitial, and Rewarded Ads
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized before calling async plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the Google Mobile Ads SDK
  try {
    await MobileAds.instance.initialize();
    debugPrint('Google Mobile Ads SDK successfully initialized.');
  } catch (e) {
    debugPrint('Failed to initialize MobileAds SDK: $e');
  }

  runApp(const MHXAdsApp());
}

class MHXAdsApp extends StatelessWidget {
  const MHXAdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MHX Ads Rewarder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // User wallet state
  int _userCoins = 150;
  int _adsWatchedCount = 0;

  // Banner Ad State
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  // Interstitial Ad State
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _interstitialLoadAttempts = 0;
  static const int _maxFailedLoadAttempts = 3;

  // Rewarded Ad State
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;
  int _rewardedLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 1. BANNER AD IMPLEMENTATION
  // ---------------------------------------------------------------------------
  void _loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded successfully.');
          if (!mounted) return;
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: ${error.message} [Code: ${error.code}]');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isBannerLoaded = false;
          });
        },
        onAdOpened: (ad) => debugPrint('BannerAd opened.'),
        onAdClosed: (ad) => debugPrint('BannerAd closed.'),
        onAdImpression: (ad) => debugPrint('BannerAd impression recorded.'),
      ),
    );

    _bannerAd!.load();
  }

  // ---------------------------------------------------------------------------
  // 2. INTERSTITIAL AD IMPLEMENTATION
  // ---------------------------------------------------------------------------
  void _loadInterstitialAd() {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    setState(() => _isInterstitialLoading = true);

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded successfully.');
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          if (!mounted) return;
          setState(() => _isInterstitialLoading = false);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: ${error.message}');
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          if (!mounted) return;
          setState(() => _isInterstitialLoading = false);

          if (_interstitialLoadAttempts <= _maxFailedLoadAttempts) {
            // Exponential backoff reload
            Future.delayed(Duration(seconds: _interstitialLoadAttempts * 2), () {
              if (mounted) _loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  void _showInterstitialAd({VoidCallback? onComplete}) {
    if (_interstitialAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interstitial Ad is loading. Please try again in a moment!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('InterstitialAd presented full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAd dismissed.');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd(); // Preload next interstitial ad
        if (onComplete != null) onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
  }

  // ---------------------------------------------------------------------------
  // 3. REWARDED AD IMPLEMENTATION
  // ---------------------------------------------------------------------------
  void _loadRewardedAd() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    setState(() => _isRewardedLoading = true);

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded successfully.');
          _rewardedAd = ad;
          _rewardedLoadAttempts = 0;
          if (!mounted) return;
          setState(() => _isRewardedLoading = false);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: ${error.message}');
          _rewardedLoadAttempts++;
          _rewardedAd = null;
          if (!mounted) return;
          setState(() => _isRewardedLoading = false);

          if (_rewardedLoadAttempts <= _maxFailedLoadAttempts) {
            Future.delayed(Duration(seconds: _rewardedLoadAttempts * 2), () {
              if (mounted) _loadRewardedAd();
            });
          }
        },
      ),
    );
  }

  void _showRewardedAd({int bonusReward = 50}) {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rewarded Ad is preparing. Please try again shortly!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('RewardedAd presented full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('RewardedAd dismissed.');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // Preload next rewarded ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        setState(() {
          _userCoins += bonusReward;
          _adsWatchedCount++;
        });

        _showRewardDialog(bonusReward);
      },
    );
  }

  void _showRewardDialog(int coinsEarned) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Reward Unlocked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Awesome! You received +$coinsEarned Coins for watching the ad.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Total Balance: $_userCoins Coins',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.amber),
            SizedBox(width: 8),
            Text('MHX Ads Hub'),
          ],
        ),
        actions: [
          // Coins balance chip in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: const Icon(Icons.generating_tokens, color: Colors.amber, size: 20),
              label: Text(
                '$_userCoins Coins',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Overview Card
                    _buildWalletCard(theme),
                    const SizedBox(height: 16),

                    // Section Title
                    Text(
                      'Interactive Ad Controls',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Button 1: Interstitial Ad
                    _buildActionButton(
                      title: 'Show Interstitial Ad',
                      subtitle: _interstitialAd != null
                          ? 'Ready to display full screen'
                          : (_isInterstitialLoading ? 'Loading Ad...' : 'Click to preload & show'),
                      icon: Icons.fullscreen,
                      color: Colors.blueAccent,
                      isLoading: _isInterstitialLoading,
                      onPressed: () => _showInterstitialAd(),
                    ),
                    const SizedBox(height: 10),

                    // Button 2: Rewarded Ad
                    _buildActionButton(
                      title: 'Watch Rewarded Ad (+50 Coins)',
                      subtitle: _rewardedAd != null
                          ? 'Watch 5-15s video to claim 50 coins'
                          : (_isRewardedLoading ? 'Preparing Video...' : 'Click to load & watch'),
                      icon: Icons.video_collection,
                      color: Colors.green,
                      isLoading: _isRewardedLoading,
                      onPressed: () => _showRewardedAd(bonusReward: 50),
                    ),
                    const SizedBox(height: 10),

                    // Button 3: Refresh Banner Ad
                    _buildActionButton(
                      title: 'Reload Banner Ad',
                      subtitle: _isBannerLoaded ? 'Active at screen bottom' : 'Reload banner stream',
                      icon: Icons.view_stream,
                      color: Colors.purple,
                      isLoading: false,
                      onPressed: () {
                        setState(() => _isBannerLoaded = false);
                        _loadBannerAd();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reloading banner ad...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Extra Interactive Offers Section
                    Text(
                      'Special Offers & Bonus Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Extra Offer Button 1
                    _buildActionButton(
                      title: 'Extra Offer 1: Claim Mystery Chest',
                      subtitle: 'Plays interstitial ad then unlocks prize',
                      icon: Icons.card_giftcard,
                      color: Colors.deepOrange,
                      isLoading: false,
                      onPressed: () {
                        _showInterstitialAd(onComplete: () {
                          setState(() => _userCoins += 25);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mystery Chest Unlocked! +25 Coins!'),
                              backgroundColor: Colors.deepOrange,
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Extra Offer Button 2
                    _buildActionButton(
                      title: 'Extra Offer 2: Mega Double Boost',
                      subtitle: 'Watch video for 2x coin multiplier (+100)',
                      icon: Icons.bolt,
                      color: Colors.amber.shade800,
                      isLoading: false,
                      onPressed: () => _showRewardedAd(bonusReward: 100),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Bottom Banner Ad Area
            _buildBottomBannerWidget(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET HELPERS
  // ---------------------------------------------------------------------------
  Widget _buildWalletCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rewards Wallet',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.lightGreenAccent, size: 14),
                    SizedBox(width: 4),
                    Text('AdMob Active', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 36),
              const SizedBox(width: 10),
              Text(
                '$_userCoins',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Text('COINS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ads Completed: $_adsWatchedCount',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                'App ID: ${AdHelper.adMobAppId.substring(0, 15)}...',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 24,
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
                      )
                    : Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBannerWidget() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isBannerLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          else
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading Google AdMob Banner...',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
