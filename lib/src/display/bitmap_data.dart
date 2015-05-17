part of stagexl.display;

/// The BitmapData class lets you load or create arbitrarily sized transparent
/// or opaque bitmap images and manipulate them in various ways at runtime.
///
/// Most of the time you will load BitmapDatas from static image files or
/// get them from a texture atlas. You may also create a BitmapData at
/// runtime and draw arbitrary content onto it's surface.
///
/// The BitmapData class is not a display object and therefore can't be added
/// to the display list (the stage or and other container). Use the [Bitmap]
/// class to create display objects which will use and show this BitmapData.
///
/// The BitmapData class contains a series of built-in methods that are
/// useful for creation and manipulation of pixel data. Consider using the
/// [BitmapDataUpdateBatch] for multiple sequential manipulations for better
/// performance.

class BitmapData implements BitmapDrawable {

  final num width;
  final num height;
  final RenderTextureQuad renderTextureQuad;

  static BitmapDataLoadOptions defaultLoadOptions = new BitmapDataLoadOptions();

  BitmapData.fromRenderTextureQuad(RenderTextureQuad renderTextureQuad) :
    this.renderTextureQuad = renderTextureQuad,
    this.width = renderTextureQuad.targetWidth,
    this.height = renderTextureQuad.targetHeight;

  //----------------------------------------------------------------------------

  factory BitmapData(int width, int height, [int fillColor = 0xFFFFFFFF, num pixelRatio = 1.0]) {
    int textureWidth = (width * pixelRatio).round();
    int textureHeight = (height * pixelRatio).round();
    var renderTexture = new RenderTexture(textureWidth, textureHeight, fillColor);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return new BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromImageElement(ImageElement imageElement, [num pixelRatio = 1.0]) {
    var renderTexture = new RenderTexture.fromImageElement(imageElement);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return new BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromVideoElement(VideoElement videoElement, [num pixelRatio = 1.0]) {
    var renderTexture = new RenderTexture.fromVideoElement(videoElement);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return new BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromBitmapData(BitmapData bitmapData, Rectangle<int> rectangle) {
    var renderTextureQuad = bitmapData.renderTextureQuad.cut(rectangle);
    return new BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  //----------------------------------------------------------------------------

  /// Loads a BitmapData from the given url.

  static Future<BitmapData> load(String url, [BitmapDataLoadOptions bitmapDataLoadOptions]) {

    if (bitmapDataLoadOptions == null) {
      bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
    }

    var pixelRatio = 1.0;
    var pixelRatioRegexp = new RegExp(r"@(\d)x");
    var pixelRatioMatch = pixelRatioRegexp.firstMatch(url);
    var maxPixelRatio = bitmapDataLoadOptions.maxPixelRatio;
    var webpAvailable = bitmapDataLoadOptions.webp;
    var corsEnabled = bitmapDataLoadOptions.corsEnabled;

    if (pixelRatioMatch != null) {
      var match = pixelRatioMatch;
      var originPixelRatio = int.parse(match.group(1));
      var devicePixelRatio = env.devicePixelRatio.round();
      var loaderPixelRatio = minInt(devicePixelRatio, maxPixelRatio);
      pixelRatio = loaderPixelRatio / originPixelRatio;
      url = url.replaceRange(match.start, match.end, "@${loaderPixelRatio}x");
    }

    var imageLoader = new ImageLoader(url, webpAvailable, corsEnabled);
    return imageLoader.done.then((image) {
      return new BitmapData.fromImageElement(image, pixelRatio);
    });
  }

  //----------------------------------------------------------------------------

  /// Returns a new BitmapData with a copy of this BitmapData's texture.

  BitmapData clone([num pixelRatio]) {
    if (pixelRatio == null) pixelRatio = renderTextureQuad.pixelRatio;
    var bitmapData = new BitmapData(width, height, Color.Transparent, pixelRatio);
    bitmapData.drawPixels(this, this.rectangle, new Point<int>(0, 0));
    return bitmapData;
  }

  /// Return a dataUrl for this BitmapData.

  String toDataUrl([String type = 'image/png', num quality]) {
    return this.clone().renderTexture.canvas.toDataUrl(type, quality);
  }

  //----------------------------------------------------------------------------

  /// Returns an array of BitmapData based on this BitmapData's texture.
  ///
  /// This function is used to "slice" a spritesheet, tileset, or spritemap into
  /// several different frames. All BitmapData's produced by this method are linked
  /// to this BitmapData's texture for performance.
  ///
  /// The optional frameCount parameter will limit the number of frames generated,
  /// in case you have empty frames you don't care about due to the width / height
  /// of this BitmapData. If your frames are also separated by space or have an
  /// additional margin for each frame, you can specify this with the spacing or
  /// margin parameter (in pixel).

  List<BitmapData> sliceIntoFrames(int frameWidth, int frameHeight, {
    int frameCount: null, int frameSpacing: 0, int frameMargin: 0 }) {

    var cols = (width - frameMargin + frameSpacing) ~/ (frameWidth + frameSpacing);
    var rows = (height - frameMargin + frameSpacing) ~/ (frameHeight + frameSpacing);
    var frames = new List<BitmapData>();

    frameCount = (frameCount == null) ? rows * cols : min(frameCount, rows * cols);

    for(var f = 0; f < frameCount; f++) {
      var x = f % cols;
      var y = f ~/ cols;
      var frameLeft = frameMargin + x * (frameWidth + frameSpacing);
      var frameTop = frameMargin + y * (frameHeight + frameSpacing);
      var rectangle = new Rectangle<int>(frameLeft, frameTop, frameWidth, frameHeight);
      var bitmapData = new BitmapData.fromBitmapData(this, rectangle);
      frames.add(bitmapData);
    }

    return frames;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  Rectangle<num> get rectangle => new Rectangle<num>(0, 0, width, height);
  RenderTexture get renderTexture => renderTextureQuad.renderTexture;

  //----------------------------------------------------------------------------

  void applyFilter(BitmapFilter filter, [Rectangle<int> rectangle]) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.applyFilter(filter, rectangle);
    updateBatch.update();
  }

  void colorTransform(Rectangle<int> rect, ColorTransform transform) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.colorTransform(rect, transform);
    updateBatch.update();
  }

  /// Clear the entire rendering surface.

  void clear() {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.clear();
    updateBatch.update();
  }

  void fillRect(Rectangle<int> rect, int color) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.fillRect(rect, color);
    updateBatch.update();
  }

  void draw(BitmapDrawable source, [Matrix matrix]) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.draw(source, matrix);
    updateBatch.update();
  }

  /// Copy pixels from [source], completely replacing the pixels at [destPoint].
  ///
  /// copyPixels erases the target location specified by [destPoint] and [sourceRect],
  /// then draws over it.
  ///
  /// NOTE: [drawPixels] is more performant.

  void copyPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.copyPixels(source, sourceRect, destPoint);
    updateBatch.update();
  }

  /// Draws pixels from [source] onto this object.
  ///
  /// Unlike [copyPixels], the target location is not erased first. That means pixels on this
  /// BitmapData may be visible if pixels from [source] are transparent. Select a [blendMode]
  /// to customize how two pixels are blended.

  void drawPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint, [BlendMode blendMode]) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.drawPixels(source, sourceRect, destPoint, blendMode);
    updateBatch.update();
  }

  //----------------------------------------------------------------------------

  /// Get a single RGB pixel

  int getPixel(int x, int y) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y) & 0x00FFFFFF;
  }

  /// Get a single RGBA pixel

  int getPixel32(int x, int y) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y);
  }

  /// Draw an RGB pixel at the given coordinates.
  ///
  /// setPixel updates the underlying texture. If you need to make multiple calls,
  /// use [BitmapDataUpdateBatch] instead.

  void setPixel(int x, int y, int color) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color | 0xFF000000);
    updateBatch.update();
  }

  /// Draw an RGBA pixel at the given coordinates.
  ///
  /// setPixel32 updates the underlying texture. If you need to make multiple calls,
  /// use [BitmapDataUpdateBatch] instead.

  void setPixel32(int x, int y, int color) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color);
    updateBatch.update();
  }

  //----------------------------------------------------------------------------

  render(RenderState renderState) {
    renderState.renderQuad(renderTextureQuad);
  }
}
