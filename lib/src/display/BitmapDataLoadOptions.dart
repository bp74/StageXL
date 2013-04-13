part of stagexl;

class BitmapDataLoadOptions {
  
  /**
   *  The application provides *png* files for lossless images.
   */
  bool png;

  /**
   * The application provides *jpg* files for lossy images.
   */
  bool jpg;

  /**
   * The application provides *webp* files for lossless and lossy images.
   * 
   * If *webp* is supported, the loader will automatically switch from *png*
   * and *jpg* files to this more efficient file format.
   */
  bool webp;

  BitmapDataLoadOptions({
    this.png: true, 
    this.jpg: true, 
    this.webp: false
  });
}

