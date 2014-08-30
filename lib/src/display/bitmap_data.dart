part of stagexl.display;

/**
 * A drawable Bitmap surface
 *
 * If you need to batch drawing operations for better performance,
 * please use [BitmapDataUpdateBatch] instead.
 **/
class BitmapData implements BitmapDrawable {

  int _width = 0;
  int _height = 0;

  RenderTexture _renderTexture;
  RenderTextureQuad _renderTextureQuad;

  static BitmapDataLoadOptions defaultLoadOptions = new BitmapDataLoadOptions();

  //-------------------------------------------------------------------------------------------------

  BitmapData(int width, int height, [
      bool transparent = true, int fillColor = 0xFFFFFFFF, num pixelRatio = 1.0]) {

    _width = ensureInt(width);
    _height = ensureInt(height);
    _renderTexture = new RenderTexture(_width, _height, transparent, fillColor, pixelRatio);
    _renderTextureQuad = _renderTexture.quad;
  }

  BitmapData.fromImageElement(ImageElement imageElement, [num pixelRatio = 1.0]) {
    _renderTexture = new RenderTexture.fromImage(imageElement, pixelRatio);
    _renderTextureQuad = _renderTexture.quad;
    _width = ensureInt(_renderTexture.width);
    _height = ensureInt(_renderTexture.height);
  }

  BitmapData.fromBitmapData(BitmapData bitmapData, Rectangle<int> rectangle) {
    _width = ensureInt(rectangle.width);
    _height = ensureInt(rectangle.height);
    _renderTexture = bitmapData.renderTexture;
    _renderTextureQuad = bitmapData.renderTextureQuad.cut(rectangle);
  }

  BitmapData.fromRenderTextureQuad(RenderTextureQuad renderTextureQuad, [int width, int height]) {
    if (width == null) width = renderTextureQuad.textureWidth + renderTextureQuad.offsetX;
    if (height == null) height = renderTextureQuad.textureHeight + renderTextureQuad.offsetY;
    _width = ensureInt(width);
    _height = ensureInt(height);
    _renderTexture = renderTextureQuad.renderTexture;
    _renderTextureQuad = renderTextureQuad;
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Loads a BitmapData from the given url.
   */

  static Future<BitmapData> load(String url, [BitmapDataLoadOptions bitmapDataLoadOptions]) {

    if (bitmapDataLoadOptions == null) {
      bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
    }

    var autoHiDpi = bitmapDataLoadOptions.autoHiDpi;
    var webpAvailable = bitmapDataLoadOptions.webp;
    var corsEnabled = bitmapDataLoadOptions.corsEnabled;
    var loader = RenderTexture.load(url, autoHiDpi, webpAvailable, corsEnabled);

    return loader.then((renderTexture) => new BitmapData.fromRenderTextureQuad(renderTexture.quad));
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Returns a new BitmapData with a copy of this BitmapData's texture.
   */

  BitmapData clone([num pixelRatio]) {
    if (pixelRatio == null) pixelRatio = _renderTexture.storePixelRatio;
    var bitmapData = new BitmapData(_width, _height, true, 0, pixelRatio);
    bitmapData.drawPixels(this, this.rectangle, new Point<int>(0, 0));
    return bitmapData;
  }

  /**
   * Return a dataUrl for this BitmapData.
   */

  String toDataUrl([String type = 'image/png', num quality]) {
    if (identical(_renderTextureQuad, _renderTexture.quad)) {
      return _renderTexture.canvas.toDataUrl(type, quality);
    } else {
      return clone().toDataUrl(type, quality);
    }
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Returns an array of BitmapData based on this BitmapData's texture.
   *
   * This function is used to "slice" a spritesheet, tileset, or spritemap into
   * several different frames. All BitmapData's produced by this method are linked
   * to this BitmapData's texture for performance.
   *
   * The optional frameCount parameter will limit the number of frames generated,
   * in case you have empty frames you don't care about due to the width / height
   * of this BitmapData. If your frames are also separated by space or have an
   * additional margin for each frame, you can specify this with the spacing or
   * margin parameter (in pixel).
   */

  List<BitmapData> sliceIntoFrames(int frameWidth, int frameHeight, {
    int frameCount: null, int frameSpacing: 0, int frameMargin: 0 }) {

    var cols = (_width - frameMargin + frameSpacing) ~/ (frameWidth + frameSpacing);
    var rows = (_height - frameMargin + frameSpacing) ~/ (frameHeight + frameSpacing);
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

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;

  Rectangle<int> get rectangle => new Rectangle<int>(0, 0, _width, _height);
  RenderTexture get renderTexture => _renderTextureQuad.renderTexture;
  RenderTextureQuad get renderTextureQuad => _renderTextureQuad;

  //-------------------------------------------------------------------------------------------------

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

  /**
   * Clear the entire rendering surface.
   */
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

  /**
   * Copy pixels from [source], completely replacing the pixels at [destPoint].
   *
   * copyPixels erases the target location specified by [destPoint] and [sourceRect],
   * then draws over it.
   *
   * NOTE: [drawPixels] is more performant.
   */
  void copyPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.copyPixels(source, sourceRect, destPoint);
    updateBatch.update();
  }

  /**
   * Draws pixels from [source] onto this object.
   *
   * Unlike [copyPixels], the target location is not erased first. That means pixels on this
   * BitmapData may be visible if pixels from [source] are transparent. Select a [blendMode]
   * to customize how two pixels are blended.
   */
  void drawPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint, [BlendMode blendMode]) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.drawPixels(source, sourceRect, destPoint);
    updateBatch.update();
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Get a single RGB pixel
   */
  int getPixel(int x, int y) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y) & 0x00FFFFFF;
  }

  /**
   * Get a single RGBA pixel
   */
  int getPixel32(int x, int y) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    return updateBatch.getPixel32(x, y);
  }

  /**
   * Draw an RGB pixel at the given coordinates.
   *
   * setPixel updates the underlying texture. If you need to make multiple calls,
   * use [BitmapDataUpdateBatch] instead.
   */
  void setPixel(int x, int y, int color) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color | 0xFF000000);
    updateBatch.update();
  }

  /**
   * Draw an RGBA pixel at the given coordinates.
   *
   * setPixel32 updates the underlying texture. If you need to make multiple calls,
   * use [BitmapDataUpdateBatch] instead.
   */
  void setPixel32(int x, int y, int color) {
    var updateBatch = new BitmapDataUpdateBatch(this);
    updateBatch.setPixel32(x, y, color);
    updateBatch.update();
  }

  //-------------------------------------------------------------------------------------------------

  render(RenderState renderState) {
    renderState.renderQuad(_renderTextureQuad);
  }

}
