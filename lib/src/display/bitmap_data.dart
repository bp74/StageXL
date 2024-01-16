part of '../display.dart';

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

  factory BitmapData(num width, num height,
      [int fillColor = 0xFFFFFFFF, num pixelRatio = 1.0]) {
    final textureWidth = (width * pixelRatio).round();
    final textureHeight = (height * pixelRatio).round();
    final renderTexture = RenderTexture(textureWidth, textureHeight, fillColor);
    final renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  BitmapData.fromRenderTextureQuad(this.renderTextureQuad)
      : width = renderTextureQuad.targetWidth,
        height = renderTextureQuad.targetHeight;

  factory BitmapData.fromImageElement(ImageElement imageElement,
      [num pixelRatio = 1.0]) {
    final renderTexture = RenderTexture.fromImageElement(imageElement);
    final renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromImageBitmap(ImageBitmap imageBitmap,
      [num pixelRatio = 1.0]) {
    var renderTexture = RenderTexture.fromImageBitmap(imageBitmap);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromVideoElement(VideoElement videoElement,
      [num pixelRatio = 1.0]) {
    final renderTexture = RenderTexture.fromVideoElement(videoElement);
    final renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  factory BitmapData.fromBitmapData(
      BitmapData bitmapData, Rectangle<num> rectangle) {
    final renderTextureQuad = bitmapData.renderTextureQuad.cut(rectangle);
    return BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

  //----------------------------------------------------------------------------

  /// Loads a BitmapData from the given url.

  static Future<BitmapData> load(String url,
      [BitmapDataLoadOptions? options]) async {
    options = options ?? BitmapData.defaultLoadOptions;
    final bitmapDataFileInfo = BitmapDataLoadInfo(url, options.pixelRatios);
    final targetUrl = bitmapDataFileInfo.loaderUrl;
    final pixelRatio = bitmapDataFileInfo.pixelRatio;

    if (env.isImageBitmapSupported) {
      final loader = ImageBitmapLoader(targetUrl, options.webp);
      final imageBitmap = await loader.done;
      return BitmapData.fromImageBitmap(imageBitmap, pixelRatio);
    }

    final loader = ImageLoader(targetUrl, options.webp, options.corsEnabled);
    return loader.done.then((i) => BitmapData.fromImageElement(i, pixelRatio));
  }

  //----------------------------------------------------------------------------

  /// Returns a new BitmapData with a copy of this BitmapData's texture.

  BitmapData clone([num? pixelRatio]) {
    pixelRatio ??= renderTextureQuad.pixelRatio;
    final bitmapData = BitmapData(width, height, Color.Transparent, pixelRatio);
    bitmapData.drawPixels(this, rectangle, Point<num>(0, 0));
    return bitmapData;
  }

  /// Return a dataUrl for this BitmapData.

  String toDataUrl([String type = 'image/png', num? quality]) =>
      clone().renderTexture.canvas.toDataUrl(type, quality);

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
    final cols =
        (width - frameMargin + frameSpacing) ~/ (frameWidth + frameSpacing);
    final rows =
        (height - frameMargin + frameSpacing) ~/ (frameHeight + frameSpacing);
    final frames = <BitmapData>[];

    frameCount =
        (frameCount == null) ? rows * cols : min(frameCount, rows * cols);

    for (var f = 0; f < frameCount; f++) {
      final x = f % cols;
      final y = f ~/ cols;
      final frameLeft = frameMargin + x * (frameWidth + frameSpacing);
      final frameTop = frameMargin + y * (frameHeight + frameSpacing);
      final rectangle =
          Rectangle<num>(frameLeft, frameTop, frameWidth, frameHeight);
      final bitmapData = BitmapData.fromBitmapData(this, rectangle);
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
    final updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.applyFilter(filter, rectangle);
    updateBatch.update();
  }

  void colorTransform(Rectangle<num> rect, ColorTransform transform) {
    final updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.colorTransform(rect, transform);
    updateBatch.update();
  }

  /// Clear the entire rendering surface.

  void clear() {
    final updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.clear();
    updateBatch.update();
  }

  void fillRect(Rectangle<num> rectangle, int color) {
    final updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.fillRect(rectangle, color);
    updateBatch.update();
  }

  void draw(BitmapDrawable source, [Matrix? matrix]) {
    final updateBatch = BitmapDataUpdateBatch(this);
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
    final updateBatch = BitmapDataUpdateBatch(this);
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
    final updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.drawPixels(source, sourceRect, destPoint, blendMode);
    updateBatch.update();
  }

  //----------------------------------------------------------------------------

  /// Get a single RGB pixel

  int getPixel(num x, num y) {
    final updateBatch = BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y) & 0x00FFFFFF;
  }

  /// Get a single RGBA pixel

  int getPixel32(num x, num y) {
    final updateBatch = BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y);
  }

  /// Draw an RGB pixel at the given coordinates.
  ///
  /// setPixel updates the underlying texture. If you need to make multiple calls,
  /// use [BitmapDataUpdateBatch] instead.

  void setPixel(num x, num y, int color) {
    final updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color | 0xFF000000);
    updateBatch.update();
  }

  /// Draw an RGBA pixel at the given coordinates.
  ///
  /// setPixel32 updates the underlying texture. If you need to make multiple calls,
  /// use [BitmapDataUpdateBatch] instead.

  void setPixel32(num x, num y, int color) {
    final updateBatch = BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color);
    updateBatch.update();
  }

  //----------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {
    renderState.renderTextureQuad(renderTextureQuad);
  }
}
