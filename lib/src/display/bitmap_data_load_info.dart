part of stagexl.display;

/// The BitmapDataLoadInfo creates information about the best matching image
/// file based on the specified image url, the pixelRatios and the current
/// display configuration.

class BitmapDataLoadInfo {
  String _sourceUrl;
  String _loaderUrl;
  double _pixelRatio;

  BitmapDataLoadInfo(String url, List<double> pixelRatios) {
    _sourceUrl = url;
    _loaderUrl = url;
    _pixelRatio = 1.0;

    var pixelRatioRegexp = new RegExp(r"@(\d+(.\d+)?)x");
    var pixelRatioMatch = pixelRatioRegexp.firstMatch(sourceUrl);

    if (pixelRatioMatch != null) {
      var match = pixelRatioMatch;
      var originPixelRatioFractions = (match.group(2) ?? ".").length - 1;
      var originPixelRatio = double.parse(match.group(1));
      var devicePixelRatio = env.devicePixelRatio;
      var loaderPixelRatio = pixelRatios.fold<num>(0.0, (num a, num b) {
        var aDelta = (a - devicePixelRatio).abs();
        var bDelta = (b - devicePixelRatio).abs();
        return aDelta < bDelta && a > 0.0 ? a : b;
      });
      var name = loaderPixelRatio.toStringAsFixed(originPixelRatioFractions);
      _loaderUrl = url.replaceRange(match.start + 1, match.end - 1, name);
      _pixelRatio = loaderPixelRatio / originPixelRatio;
    }
  }

  String get sourceUrl => _sourceUrl;
  String get loaderUrl => _loaderUrl;
  double get pixelRatio => _pixelRatio;
}
