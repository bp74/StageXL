part of stagexl;

class BitmapData implements BitmapDrawable {

  int _width = 0;
  int _height = 0;

  RenderTexture _renderTexture;
  RenderTextureQuad _renderTextureQuad;

  static BitmapDataLoadOptions defaultLoadOptions = new BitmapDataLoadOptions();

  //-------------------------------------------------------------------------------------------------

  BitmapData(int width, int height, [
      bool transparent = true, int fillColor = 0xFFFFFFFF, num pixelRatio = 1.0]) {

    _width = _ensureInt(width);
    _height = _ensureInt(height);
    _renderTexture = new RenderTexture(_width, _height, transparent, fillColor, pixelRatio);
    _renderTextureQuad = _renderTexture.quad;
  }

  BitmapData.fromImageElement(ImageElement imageElement, [num pixelRatio = 1.0]) {
    _renderTexture = new RenderTexture.fromImage(imageElement, pixelRatio);
    _renderTextureQuad = _renderTexture.quad;
    _width = _ensureInt(_renderTexture.width);
    _height = _ensureInt(_renderTexture.height);
  }

  BitmapData.fromBitmapData(BitmapData bitmapData, Rectangle<int> rectangle) {
    _width = _ensureInt(rectangle.width);
    _height = _ensureInt(rectangle.height);
    _renderTexture = bitmapData.renderTexture;
    _renderTextureQuad = bitmapData.renderTextureQuad.cut(rectangle);
  }

  BitmapData.fromRenderTextureQuad(RenderTextureQuad renderTextureQuad, [int width, int height]) {
    if (width == null) width = renderTextureQuad.textureWidth + renderTextureQuad.offsetX;
    if (height == null) height = renderTextureQuad.textureHeight + renderTextureQuad.offsetY;
    _width = _ensureInt(width);
    _height = _ensureInt(height);
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
    filter.apply(this, rectangle);
    _renderTexture.update();
  }

  //-------------------------------------------------------------------------------------------------

  void colorTransform(Rectangle<int> rect, ColorTransform transform) {

    bool isLittleEndianSystem = BitmapDataChannel.isLittleEndianSystem;

    int redMultiplier = (1024 * transform.redMultiplier).toInt();
    int greenMultiplier = (1024 * transform.greenMultiplier).toInt();
    int blueMultiplier = (1024 * transform.blueMultiplier).toInt();
    int alphaMultiplier = (1024 * transform.alphaMultiplier).toInt();

    int redOffset = transform.redOffset;
    int greenOffset = transform.greenOffset;
    int blueOffset = transform.blueOffset;
    int alphaOffset = transform.alphaOffset;

    int mulitplier0 = isLittleEndianSystem ? redMultiplier : alphaMultiplier;
    int mulitplier1 = isLittleEndianSystem ? greenMultiplier : blueMultiplier;
    int mulitplier2 = isLittleEndianSystem ? blueMultiplier : greenMultiplier;
    int mulitplier3 = isLittleEndianSystem ? alphaMultiplier : redMultiplier;

    int offset0 = isLittleEndianSystem ? redOffset : alphaOffset;
    int offset1 = isLittleEndianSystem ? greenOffset : blueOffset;
    int offset2 = isLittleEndianSystem ? blueOffset : greenOffset;
    int offset3 = isLittleEndianSystem ? alphaOffset : redOffset;

    var renderTextureQuad = _renderTextureQuad.cut(rect);
    var imageData = renderTextureQuad.getImageData();
    var data = imageData.data;

    for(int i = 0; i <= data.length - 4; i += 4) {

      int c0 = data[i + 0];
      int c1 = data[i + 1];
      int c2 = data[i + 2];
      int c3 = data[i + 3];

      if (c0 is! num) continue; // dart2js hint
      if (c1 is! num) continue; // dart2js hint
      if (c2 is! num) continue; // dart2js hint
      if (c3 is! num) continue; // dart2js hint

      data[i + 0] = offset0 + (((c0 * mulitplier0) | 0) >> 10);
      data[i + 1] = offset1 + (((c1 * mulitplier1) | 0) >> 10);
      data[i + 2] = offset2 + (((c2 * mulitplier2) | 0) >> 10);
      data[i + 3] = offset3 + (((c3 * mulitplier3) | 0) >> 10);
    }

    renderTextureQuad.putImageData(imageData);
    renderTextureQuad.renderTexture.update();
  }

  //-------------------------------------------------------------------------------------------------

  void clear() {
    var matrix = _renderTextureQuad.drawMatrix;
    var context = _renderTexture.canvas.context2D;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.clearRect(0, 0, _width, _height);
    _renderTexture.update();
  }

  void fillRect(Rectangle<int> rect, int color) {
    var matrix = _renderTextureQuad.drawMatrix;
    var context = _renderTexture.canvas.context2D;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.fillStyle = _color2rgba(color);
    context.fillRect(rect.left, rect.top, rect.width, rect.height);
    _renderTexture.update();
  }

  void draw(BitmapDrawable source, [Matrix matrix]) {
    var drawMatrix = _renderTextureQuad.drawMatrix;
    if (matrix != null) drawMatrix.prepend(matrix);
    var renderContext = new RenderContextCanvas(_renderTexture.canvas);
    var renderState = new RenderState(renderContext, drawMatrix);
    source.render(renderState);
    _renderTexture.update();
  }

  void copyPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint) {
    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderContext = new RenderContextCanvas(_renderTexture.canvas);
    var matrix = _renderTextureQuad.drawMatrix..prependTranslation(destPoint.x, destPoint.y);
    var renderState = new RenderState(renderContext, matrix);
    renderContext.rawContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    renderContext.rawContext.clearRect(0, 0, sourceRect.width, sourceRect.height);
    renderContext.renderQuad(renderState, sourceQuad);
    _renderTexture.update();
  }

  void drawPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint,
                  [String compositeOperation]) {
    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderContext = new RenderContextCanvas(_renderTexture.canvas);
    var matrix = _renderTextureQuad.drawMatrix..prependTranslation(destPoint.x, destPoint.y);
    var renderState = new RenderState(renderContext, matrix, 1.0, compositeOperation);
    renderContext.renderQuad(renderState, sourceQuad);
    _renderTexture.update();
  }

  //-------------------------------------------------------------------------------------------------

  int getPixel(int x, int y) => getPixel32(x, y) & 0x00FFFFFF;

  int getPixel32(int x, int y) {

    int r = 0, g = 0, b = 0, a = 0;

    var rectangle = new Rectangle<int>(x, y, 1, 1);
    var renderTextureQuad = _renderTextureQuad.clip(rectangle);
    if (renderTextureQuad.textureWidth == 0) return 0;
    if (renderTextureQuad.textureHeight == 0) return 0;

    var isLittleEndianSystem = BitmapDataChannel.isLittleEndianSystem;
    var imageData = renderTextureQuad.getImageData();
    var pixels = imageData.width * imageData.height;
    var data = imageData.data;

    for(int i = 0; i <= data.length - 4; i += 4) {
      r += isLittleEndianSystem ? data[i + 0] : data[i + 3];
      g += isLittleEndianSystem ? data[i + 1] : data[i + 2];
      b += isLittleEndianSystem ? data[i + 2] : data[i + 1];
      a += isLittleEndianSystem ? data[i + 3] : data[i + 0];
    }

    r = r ~/ pixels;
    g = g ~/ pixels;
    b = b ~/ pixels;
    a = a ~/ pixels;

    return (a << 24) + (r  << 16) + (g << 8) + b;
  }


  //-------------------------------------------------------------------------------------------------

  void setPixel(int x, int y, int color) {
    setPixel32(x, y, color | 0xFF000000);
  }

  void setPixel32(int x, int y, int color) {
    var matrix = _renderTextureQuad.drawMatrix;
    var context = _renderTexture.canvas.context2D;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.fillStyle = _color2rgba(color);
    context.clearRect(x, y, 1, 1);
    context.fillRect(x, y, 1, 1);
    _renderTexture.update();
  }

  //-------------------------------------------------------------------------------------------------

  render(RenderState renderState) {
    renderState.renderQuad(_renderTextureQuad);
  }

}
