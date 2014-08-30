part of stagexl.display;

class BitmapDataLoadOptions {

  /// The application provides *png* files for lossless images.
  ///
  bool png = true;

  /// The application provides *jpg* files for lossy images.
  ///
  bool jpg = true;

  /// The application provides *webp* files for lossless and lossy images.
  /// If *webp* is supported, the loader will automatically switch from *png*
  /// and *jpg* files to this more efficient file format.
  ///
  bool webp = false;

  /// If the file name contains "@1x." it will be replaced by "@2x." when the
  /// context is high density.
  ///
  bool autoHiDpi = true;

  /// Use CORS to download the image. This is often necessary when you have
  /// to download images from a third party server.
  ///
  bool corsEnabled = false;

  /// The BitmapDataLoadOptions define how a BitmapData is loaded from
  /// the server. The global [BitmapData.defaultLoadOptions] object
  /// it the default for all loading operations.
  ///
  BitmapDataLoadOptions({
    this.png: true,
    this.jpg: true,
    this.webp: false,
    this.autoHiDpi: true,
    this.corsEnabled: false
  });
}

