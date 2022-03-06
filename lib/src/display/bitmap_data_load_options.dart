part of stagexl.display;

/// The BitmapDataLoadOptions class contains different options to configure
/// how BitmapDatas are loaded from the server.
///
/// The [BitmapData.defaultLoadOptions] object is the default for all
/// loading operations if no BitmapDataLoadOptions are provided to the
/// [BitmapData.load] function.

class BitmapDataLoadOptions {
  /// The application provides *png* files for lossless images.

  bool png = true;

  /// The application provides *jpg* files for lossy images.

  bool jpg = true;

  /// The application provides *webp* files for lossless and lossy images.
  ///
  /// If *webp* is supported, the loader will automatically switch from *png*
  /// and *jpg* files to this more efficient file format.

  bool webp = false;

  /// The maximum pixel ratio for images on HiDPI displays.
  ///
  /// The loader automatically detects the device's display pixel ratio
  /// and accordingly loads high resolution images. The application has
  /// to provide images with the following naming schema:
  ///
  /// 1x resolution files are named "{imageName}@1x.png"
  /// 2x resolution files are named "{imageName}@2x.png"
  /// 3x resolution files are named "{imageName}@3x.png"
  ///
  /// The default maximum pixel ratio is 2. Therefore the application has
  /// to provide images with the @1x and @2x suffix (or images with no
  /// name suffix to ignore this feature entirely).
  ///
  ///     var resourceManager = new ResourceManager();
  ///     resourceManager.addBitmapData("test", "images/test@1x.png");

  @Deprecated('Use pixelRatios instead')
  int get maxPixelRatio =>
      pixelRatios.fold<double>(0, (a, b) => a > b ? a : b).round();

  @Deprecated('Use pixelRatios instead')
  set maxPixelRatio(int value) {
    pixelRatios = List<double>.generate(value, (v) => 1.0 + v);
  }

  /// The available pixel ratios for images on HiDPI displays.
  ///
  /// The loader automatically detects the device's display pixel ratio
  /// and accordingly loads high resolution images. The application has
  /// to provide images with the following naming schema:
  ///
  /// 1.00x resolution files are named "{imageName}@1.00x.png"
  /// 1.25x resolution files are named "{imageName}@1.25x.png"
  /// 1.50x resolution files are named "{imageName}@1.50x.png"
  /// 2.00x resolution files are named "{imageName}@2.00x.png"
  /// 3.00x resolution files are named "{imageName}@3.00x.png"
  ///
  /// The default ist [1.0, 2.0]. Therefore the application has to provide
  /// images with the @1.00x and @2.00x suffix (or images with no name suffix
  /// to ignore this feature entirely).
  ///
  ///     var resourceManager = new ResourceManager();
  ///     resourceManager.addBitmapData("test", "images/test@1.00x.png");

  List<double> pixelRatios = <double>[1, 2];

  /// Use CORS to download the image. This is often necessary when you have
  /// to download images from a third party server.

  bool corsEnabled = false;

  //---------------------------------------------------------------------------

  /// Create a deep clone of this [BitmapDataLoadOptions].

  BitmapDataLoadOptions clone() {
    final options = BitmapDataLoadOptions();
    options.png = png;
    options.jpg = jpg;
    options.webp = webp;
    options.pixelRatios = List<double>.from(pixelRatios);
    options.corsEnabled = corsEnabled;
    return options;
  }
}
