part of stagexl.display;

/// The BitmapData class lets you load or create arbitrarily sized transparent
/// or opaque bitmap images and manipulate them in various ways at runtime.
///
/// Most of the time you will load BitmapDatas from static image files or
/// get them from a texture atlas. You may also create a BitmapData at
/// runtime and draw arbitrary content onto it's surface.
///
/// The BitmapData class is not a display object and therefore can't be added
/// to the display list (the stage or any other container). Use the [Bitmap]
/// class to create a display object which will show this BitmapData.
///
/// The BitmapData class contains a series of built-in methods that are
/// useful for creation and manipulation of pixel data. Consider using the
/// [BitmapDataUpdateBatch] for multiple sequential manipulations for better
/// performance.

class BitmapData implements BitmapDrawable {
  final num width;
  final num height;
  final RenderTextureQuad renderTextureQuad;

  static BitmapDataLoadOptions defaultLoadOptions = BitmapDataLoadOptions();

  BitmapData.fromRenderTextureQuad(RenderTextureQuad renderTextureQuad)
      : renderTextureQuad = renderTextureQuad,
        width = renderTextureQuad.targetWidth,
        height = renderTextureQuad.targetHeight;

  //----------------------------------------------------------------------------

  factory BitmapData(num width, num height,
      [int fillColor = 0xFFFFFFFF, num pixelRatio = 1.0]) {
    var textureWidth = (width * pixelRatio).round();
    var textureHeight = (height * pixelRatio).round();
    var renderTexture = RenderTexture(textureWidth, textureHeight, fillColor);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromImageElement(ImageElement imageElement,
      [num? pixelRatio = 1.0]) {
    var renderTexture = RenderTexture.fromImageElement(imageElement);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromVideoElement(VideoElement videoElement,
      [num pixelRatio = 1.0]) {
    var renderTexture = RenderTexture.fromVideoElement(videoElement);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromBitmapData(
      BitmapData bitmapData, Rectangle<num> rectangle) {
    var renderTextureQuad = bitmapData.renderTextureQuad.cut(rectangle);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  //----------------------------------------------------------------------------

  /// Loads a BitmapData from the given url.

  static Future<BitmapData> load(String url, [BitmapDataLoadOptions? options]) {
    options = options ?? BitmapData.defaultLoadOptions;
    var bitmapDataFileInfo = BitmapDataLoadInfo(url, options.pixelRatios);
    var targetUrl = bitmapDataFileInfo.loaderUrl;
    var pixelRatio = bitmapDataFileInfo.pixelRatio;
    var loader = ImageLoader(targetUrl, options.webp, options.corsEnabled);
    return loader.done.then((i) => BitmapData.fromImageElement(i, pixelRatio));
  }

  //----------------------------------------------------------------------------

  /// Returns a new BitmapData with a copy of this BitmapData's texture.

  BitmapData clone([num? pixelRatio]) {
    pixelRatio ??= renderTextureQuad.pixelRatio;
    var bitmapData = BitmapData(width, height, Color.Transparent, pixelRatio!);
    bitmapData.drawPixels(this, rectangle, Point<num>(0, 0));
    return bitmapData;
  }

  /// Return a dataUrl for this BitmapData.

  String toDataUrl([String type = 'image/png', num? quality]) {
    return clone().renderTexture.canvas.toDataUrl(type, quality);
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

  List<BitmapData> sliceIntoFrames(num frameWidth, num frameHeight,
      {int? frameCount, num frameSpacing = 0, num frameMargin = 0}) {
    var cols =
        (width - frameMargin + frameSpacing) ~/ (frameWidth + frameSpacing);
    var rows =
        (height - frameMargin + frameSpacing) ~/ (frameHeight + frameSpacing);
    var frames = <BitmapData>[];

    frameCount =
        (frameCount == null) ? rows * cols : min(frameCount, rows * cols);

    for (var f = 0; f < frameCount; f++) {
      var x = f % cols;
      var y = f ~/ cols;
      var frameLeft = frameMargin + x * (frameWidth + frameSpacing);
      var frameTop = frameMargin + y * (frameHeight + frameSpacing);
      var rectangle =
          Rectangle<num>(frameLeft, frameTop, frameWidth, frameHeight);
      var bitmapData = BitmapData.fromBitmapData(this, rectangle);
      frames.add(bitmapData);
    }

    return frames;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  Rectangle<num> get rectangle => Rectangle<num>(0, 0, width, height);
  RenderTexture get renderTexture => renderTextureQuad.renderTexture;

  //----------------------------------------------------------------------------

  void applyFilter(BitmapFilter filter, [Rectangle<num>? rectangle]) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.applyFilter(filter, rectangle);
    updateBatch.update();
  }

  void colorTransform(Rectangle<num> rect, ColorTransform transform) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.colorTransform(rect, transform);
    updateBatch.update();
  }

  /// Clear the entire rendering surface.

  void clear() {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.clear();
    updateBatch.update();
  }

  void fillRect(Rectangle<num> rectangle, int color) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.fillRect(rectangle, color);
    updateBatch.update();
  }

  void draw(BitmapDrawable source, [Matrix? matrix]) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.draw(source, matrix);
    updateBatch.update();
  }

  /// Copy pixels from [source], completely replacing the pixels at [destPoint].
  ///
  /// copyPixels erases the target location specified by [destPoint] and [sourceRect],
  /// then draws over it.
  ///
  /// NOTE: [drawPixels] is more performant.

  void copyPixels(
      BitmapData source, Rectangle<num> sourceRect, Point<num> destPoint) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.copyPixels(source, sourceRect, destPoint);
    updateBatch.update();
  }

  /// Draws pixels from [source] onto this object.
  ///
  /// Unlike [copyPixels], the target location is not erased first. That means pixels on this
  /// BitmapData may be visible if pixels from [source] are transparent. Select a [blendMode]
  /// to customize how two pixels are blended.

  void drawPixels(
      BitmapData source, Rectangle<num> sourceRect, Point<num> destPoint,
      [BlendMode? blendMode]) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.drawPixels(source, sourceRect, destPoint, blendMode);
    updateBatch.update();
  }

  //----------------------------------------------------------------------------

  /// Get a single RGB pixel

  int getPixel(num x, num y) {
    var updateBatch = BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y) & 0x00FFFFFF;
  }

  /// Get a single RGBA pixel

  int getPixel32(num x, num y) {
    var updateBatch = BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y);
  }

  /// Draw an RGB pixel at the given coordinates.
  ///
  /// setPixel updates the underlying texture. If you need to make multiple calls,
  /// use [BitmapDataUpdateBatch] instead.

  void setPixel(num x, num y, int color) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color | 0xFF000000);
    updateBatch.update();
  }

  /// Draw an RGBA pixel at the given coordinates.
  ///
  /// setPixel32 updates the underlying texture. If you need to make multiple calls,
  /// use [BitmapDataUpdateBatch] instead.

  void setPixel32(num x, num y, int color) {
    var updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color);
    updateBatch.update();
  }

  //----------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {
    renderState.renderTextureQuad(renderTextureQuad);
  }
}
