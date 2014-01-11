part of stagexl;

class BitmapDataLoadOptions {

  /**
   *  The application provides *png* files for lossless images.
   */
  bool png = true;

  /**
   * The application provides *jpg* files for lossy images.
   */
  bool jpg = true;

  /**
   * The application provides *webp* files for lossless and lossy images.
   *
   * If *webp* is supported, the loader will automatically switch from *png*
   * and *jpg* files to this more efficient file format.
   */
  bool webp = false;

  /**
   * If the file name contains "@1x." it will be replaced by "@2x." when the
   * context is high density.
   */
  bool autoHiDpi = true;

  BitmapDataLoadOptions({
    this.png: true,
    this.jpg: true,
    this.webp: false,
    this.autoHiDpi: true
  });
}

