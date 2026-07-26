import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/services/ad_service.dart';

/// Adaptive banner that scales down when the slot is narrower than 320dp.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({
    super.key,
    required this.adUnitId,
    this.maxWidth,
    this.padding,
    this.onLoadStateChanged,
    this.lazy = false,
  });

  final String adUnitId;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<bool>? onLoadStateChanged;

  /// When true, the ad request starts only after the slot is on screen.
  final bool lazy;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  double? _slotWidth;
  bool _loadRequested = false;
  bool _initListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _attachInitListener();
    if (!widget.lazy) {
      _scheduleLoad();
    }
  }

  @override
  void didUpdateWidget(covariant AdBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.maxWidth != widget.maxWidth) {
      _disposeAd(notify: false);
      _loadRequested = false;
      if (!widget.lazy) {
        _scheduleLoad();
      }
    }
  }

  void _attachInitListener() {
    if (_initListenerAttached || AdService.isInitialized) return;
    _initListenerAttached = true;
    AdService.whenInitialized.then((_) {
      if (!mounted || _loadRequested) return;
      if (!widget.lazy) {
        _scheduleLoad();
      }
    });
  }

  void _scheduleLoad() {
    if (_loadRequested) return;
    _loadRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0 && !_loadRequested) {
      _scheduleLoad();
    }
  }

  Future<void> _loadAd() async {
    if (!mounted) return;

    await AdService.whenInitialized;
    if (!AdService.adsEnabled || !AdService.isSupported || !mounted) {
      return;
    }

    final preloaded = AdService.takePreloadedBanner(widget.adUnitId);
    if (preloaded != null) {
      final width = widget.maxWidth ?? MediaQuery.sizeOf(context).width;
      setState(() {
        _bannerAd = preloaded.ad;
        _adSize = preloaded.size;
        _slotWidth = width;
        _isLoaded = true;
      });
      widget.onLoadStateChanged?.call(true);
      if (kDebugMode) {
        debugPrint('Ad ready (preloaded): ${widget.adUnitId}');
      }
      return;
    }

    final width = widget.maxWidth ?? MediaQuery.sizeOf(context).width;
    _slotWidth = width;
    final size = await AdService.resolveBannerSize(width.truncate());
    if (!mounted) return;

    final banner = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _adSize = size;
            _isLoaded = true;
          });
          widget.onLoadStateChanged?.call(true);
          if (kDebugMode) {
            debugPrint(
              'Ad loaded: ${widget.adUnitId} (${size.width}x${size.height})',
            );
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            debugPrint(
              'Ad failed (${widget.adUnitId}): '
              '${error.code} ${error.message}',
            );
          }
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
            widget.onLoadStateChanged?.call(false);
          }
        },
      ),
    );

    await banner.load();
  }

  void _disposeAd({bool notify = true}) {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
    _adSize = null;
    if (notify) widget.onLoadStateChanged?.call(false);
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  Widget _buildAdContent() {
    if (!AdService.adsEnabled || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final ad = _bannerAd!;
    final size = _adSize ?? ad.size;
    final slotWidth = _slotWidth ?? size.width.toDouble();

    Widget adContent = SizedBox(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: AdWidget(ad: ad),
    );

    if (slotWidth < size.width) {
      adContent = SizedBox(
        width: slotWidth,
        height: size.height * (slotWidth / size.width),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          alignment: Alignment.center,
          child: SizedBox(
            width: size.width.toDouble(),
            height: size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ),
      );
    }

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Align(
        alignment: Alignment.center,
        child: adContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.lazy) {
      return _buildAdContent();
    }

    return VisibilityDetector(
      key: Key('ad_banner_${widget.adUnitId}_${widget.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: _buildAdContent(),
    );
  }
}
