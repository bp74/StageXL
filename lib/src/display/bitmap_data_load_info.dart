part of stagexl.display;

/// The BitmapDataLoadInfo creates information about the best matching image
/// file based on the specified image url, the pixelRatios and the current
/// display configuration.

class BitmapDataLoadInfo {
  final String _sourceUrl;
  String _loaderUrl;
  double _pixelRatio = 1.0;

  BitmapDataLoadInfo(String url, List<double> pixelRatios)
      : _sourceUrl = url,
        _loaderUrl = url {
    final pixelRatioRegexp = RegExp(r'@(\d+(.\d+)?)x');
    final pixelRatioMatch = pixelRatioRegexp.firstMatch(sourceUrl);

    if (pixelRatioMatch != null) {
      final match = pixelRatioMatch;
      final originPixelRatioFractions = (match.group(2) ?? '.').length - 1;
      final originPixelRatio = double.parse(match.group(1)!);
      final devicePixelRatio = env.devicePixelRatio;
      final loaderPixelRatio = pixelRatios.fold<num>(0.0, (num a, num b) {
        final aDelta = (a - devicePixelRatio).abs();
        final bDelta = (b - devicePixelRatio).abs();
        return aDelta < bDelta && a > 0.0 ? a : b;
      });
      final name = loaderPixelRatio.toStringAsFixed(originPixelRatioFractions);
      _loaderUrl = url.replaceRange(match.start + 1, match.end - 1, name);
      _pixelRatio = loaderPixelRatio / originPixelRatio;
    }
  }

  String get sourceUrl => _sourceUrl;
  String get loaderUrl => _loaderUrl;
  double get pixelRatio => _pixelRatio;
}
