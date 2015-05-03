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
  /// and accordingly loads high resoltion images. The application has
  /// to provide images with the following naming schema:
  ///
  /// 1x resolution files are named "{imageName}@1x.png"
  /// 2x resoultion files are named "{imageName}@2x.png"
  /// 3x resoultion files are named "{imageName}@3x.png"
  ///
  /// The default maximum pixel ratio is 2. Therefore the application has
  /// to provide images with the @1x and @2x suffix (or images with no
  /// name suffix to ignore this feature entirely).
  ///
  ///     var resourceManager = new ResourceManager();
  ///     resourceManager.addBitmapData("test", "images/test@1x.png");

  int maxPixelRatio = 2;

  /// Use CORS to download the image. This is often necessary when you have
  /// to download images from a third party server.

  bool corsEnabled = false;

  //---------------------------------------------------------------------------

  /// Create a deep clone of this [BitmapDataLoadOptions].

  BitmapDataLoadOptions clone() {
    var options = new BitmapDataLoadOptions();
    options.png = this.png;
    options.jpg = this.jpg;
    options.webp = this.webp;
    options.maxPixelRatio = this.maxPixelRatio;
    options.corsEnabled = this.corsEnabled;
    return options;
  }

}
