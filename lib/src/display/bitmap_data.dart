part of stagexl;

// TODO: bring back the old functions that we had before WebGL.

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
    _renderTextureQuad = new RenderTextureQuad(_renderTexture, 0, 0, _width, _height, 0, 0);
  }

  BitmapData.fromImageElement(ImageElement imageElement, [num pixelRatio = 1.0]) {
    _width = _ensureInt(imageElement.width);
    _height = _ensureInt(imageElement.height);
    _renderTexture = new RenderTexture.fromImage(imageElement, pixelRatio);
    _renderTextureQuad = _renderTexture.quad;
  }

  BitmapData.fromBitmapData(BitmapData bitmapData, Rectangle rectangle) {
    _width = _ensureInt(rectangle.width);
    _height = _ensureInt(rectangle.height);
    _renderTexture = bitmapData.renderTexture;
    _renderTextureQuad = bitmapData.renderTextureQuad.cut(rectangle);
  }

  BitmapData.fromRenderTextureQuad(RenderTextureQuad renderTextureQuad, [int width, int height]) {
    if (width == null) width = renderTextureQuad.width + renderTextureQuad.offsetX;
    if (height == null) height = renderTextureQuad.height + renderTextureQuad.offsetY;
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
    var loader = RenderTexture.load(url, autoHiDpi, webpAvailable);

    return loader.then((renderTexture) => new BitmapData.fromRenderTextureQuad(renderTexture.quad));
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Returns a new BitmapData with a copy of this BitmapData's texture.
   */

  BitmapData clone([num pixelRatio]) {
    if (pixelRatio == null) pixelRatio = _renderTexture.storePixelRatio;
    var bitmapData = new BitmapData(_width, _height, true, 0, pixelRatio);
    bitmapData.drawPixels(this, this.rectangle, new Point.zero());
    return bitmapData;
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
   * of this BitmapData.
   */

  List<BitmapData> sliceIntoFrames(int frameWidth, int frameHeight, [int frameCount]) {

    var cols = (width ~/ frameWidth);
    var rows = (height ~/ frameHeight);
    var frames = new List<BitmapData>();

    if (frameCount == null) {
      frameCount = rows * cols;
    } else {
      frameCount = min(frameCount, rows * cols);
    }

    for(var f = 0; f < frameCount; f++) {
      var x = f % cols;
      var y = f ~/ cols;
      var rectangle = new Rectangle(x * frameWidth, y * frameHeight, frameWidth, frameHeight);
      var bitmapData = new BitmapData.fromBitmapData(this, rectangle);
      frames.add(bitmapData);
    }

    return frames;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;

  Rectangle get rectangle => new Rectangle(0, 0, _width, _height);
  RenderTexture get renderTexture => _renderTextureQuad.renderTexture;
  RenderTextureQuad get renderTextureQuad => _renderTextureQuad;

  //-------------------------------------------------------------------------------------------------
/*
  ImageData getImageData(int x, int y, int width, int height, [num pixelRatio]) {

    if (pixelRatio != null && pixelRatio != _pixelRatio) {
      var tempBitmapData = new BitmapData(width, height, true, 0, pixelRatio);
      tempBitmapData.draw(this, new Matrix(1.0, 0.0, 0.0, 1.0, -x, -y));
      return tempBitmapData.getImageData(x, y, width, height);
    }

    var pr = _pixelRatio;
    var prs = _pixelRatioSource;

    if (_backingStorePixelRatio > 1.0) {
      return _context.getImageDataHD(x * pr, y * pr, width * pr, height * pr);
    } else {
      return _context.getImageData(x * prs, y * prs, width * prs, height * prs);
    }
  }
*/
/*
  void putImageData(ImageData imageData, int x, int y) {

    var pr = _pixelRatio;
    var prs = _pixelRatioSource;

    if (_backingStorePixelRatio > 1.0) {
      _context.putImageDataHD(imageData, x * pr, y * pr);
    } else {
      _context.putImageData(imageData, x * prs, y * prs);
    }
  }
*/
/*
  ImageData createImageData(int width, int height) {

    var pr = _pixelRatio;
    var prs = _pixelRatioSource;

    return _context.createImageData(width * pr, height * pr);
  }
*/


  //-------------------------------------------------------------------------------------------------

/*
  void applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, Point destPoint, BitmapFilter filter) {

    filter.apply(sourceBitmapData, sourceRect, this, destPoint);
  }
*/

  //-------------------------------------------------------------------------------------------------

  /*
  void colorTransform(Rectangle rect, ColorTransform transform) {

    int redMultiplier = (1024 * transform.redMultiplier).toInt();
    int greenMultiplier = (1024 * transform.greenMultiplier).toInt();
    int blueMultiplier = (1024 * transform.blueMultiplier).toInt();
    int alphaMultiplier = (1024 * transform.alphaMultiplier).toInt();

    int redOffset = transform.redOffset;
    int greenOffset = transform.greenOffset;
    int blueOffset = transform.blueOffset;
    int alphaOffset = transform.alphaOffset;

    var isLittleEndianSystem = _isLittleEndianSystem;

    int mulitplier0 = isLittleEndianSystem ? redMultiplier : alphaMultiplier;
    int mulitplier1 = isLittleEndianSystem ? greenMultiplier : blueMultiplier;
    int mulitplier2 = isLittleEndianSystem ? blueMultiplier : greenMultiplier;
    int mulitplier3 = isLittleEndianSystem ? alphaMultiplier : redMultiplier;

    int offset0 = isLittleEndianSystem ? redOffset : alphaOffset;
    int offset1 = isLittleEndianSystem ? greenOffset : blueOffset;
    int offset2 = isLittleEndianSystem ? blueOffset : greenOffset;
    int offset3 = isLittleEndianSystem ? alphaOffset : redOffset;

    var imageData = getImageData(rect.x, rect.y, rect.width, rect.height);
    var data = imageData.data;

    for (int i = 0; i <= data.length - 4; i += 4) {
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

    putImageData(imageData, rect.x, rect.y);
  }
  */

  //-------------------------------------------------------------------------------------------------

  void clear() {
    var matrix = _renderTextureQuad.drawMatrix;
    var context = _renderTexture.canvas.context2D;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.clearRect(0, 0, _width, _height);
    _renderTexture.update();
  }

  void fillRect(Rectangle rect, int color) {
    var matrix = _renderTextureQuad.drawMatrix;
    var context = _renderTexture.canvas.context2D;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.fillStyle = _color2rgba(color);
    context.fillRect(rect.x, rect.y, rect.width, rect.height);
    _renderTexture.update();
  }

  void draw(BitmapDrawable source, [Matrix matrix]) {
    var drawMatrix = _renderTextureQuad.drawMatrix;
    if (matrix != null) drawMatrix.prepend(matrix);
    var renderContext = new RenderContextCanvas(_renderTexture.canvas, Color.Transparent);
    var renderState = new RenderState(renderContext, drawMatrix);
    source.render(renderState);
    _renderTexture.update();
  }

  void copyPixels(BitmapData source, Rectangle sourceRect, Point destPoint) {
    var context = _renderTexture.canvas.context2D;
    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderContext = new RenderContextCanvas(_renderTexture.canvas, Color.Transparent);
    var matrix = new Matrix(1.0, 0.0, 0.0, 1.0, destPoint.x, destPoint.y);
    matrix.concat(_renderTextureQuad.drawMatrix);
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.clearRect(0, 0, sourceRect.width, sourceRect.height);
    renderContext.renderQuad(sourceQuad, matrix, 1.0);
    _renderTexture.update();
  }

  void drawPixels(BitmapData source, Rectangle sourceRect, Point destPoint, [String compositeOperation]) {
    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderContext = new RenderContextCanvas(_renderTexture.canvas, Color.Transparent);
    var matrix = new Matrix(1.0, 0.0, 0.0, 1.0, destPoint.x, destPoint.y);
    matrix.concat(_renderTextureQuad.drawMatrix);
    renderContext.renderQuad(sourceQuad, matrix, 1.0);
    _renderTexture.update();
  }

  //-------------------------------------------------------------------------------------------------

  /*
  int getPixel(int x, int y) {
    return getPixel32(x, y) & 0x00FFFFFF;
  }

  void setPixel(int x, int y, int color) {
    setPixel32(x, y, color | 0xFF000000);
  }
  */

  //-------------------------------------------------------------------------------------------------

  /*
  int getPixel32(int x, int y) {

    var imageData = getImageData(x, y, 1, 1);
    var pixels = imageData.width * imageData.height;
    var data = imageData.data;
    var r = 0, g = 0, b = 0, a = 0;

    for(int p = 0; p < pixels; p++) {
      r += _isLittleEndianSystem ? data[p * 4 + 0] : data[p * 4 + 3];
      g += _isLittleEndianSystem ? data[p * 4 + 1] : data[p * 4 + 2];
      b += _isLittleEndianSystem ? data[p * 4 + 2] : data[p * 4 + 1];
      a += _isLittleEndianSystem ? data[p * 4 + 3] : data[p * 4 + 0];
    }

    return ((a ~/ pixels) << 24) + ((r ~/ pixels) << 16) + ((g ~/ pixels) << 8) + ((b ~/ pixels) << 0);
  }
  */

  /*
  void setPixel32(int x, int y, int color) {

    var imageData = createImageData(1, 1);
    var pixels = imageData.width * imageData.height;
    var data = imageData.data;

    var c0 = ((color | 0) >> 24) & 0xFF;
    var c1 = ((color | 0) >> 16) & 0xFF;
    var c2 = ((color | 0) >>  8) & 0xFF;
    var c3 = ((color | 0)      ) & 0xFF;

    for(int p = 0; p < pixels; p++) {
      data[p * 4 + 0] = _isLittleEndianSystem ? c1 : c0;
      data[p * 4 + 1] = _isLittleEndianSystem ? c2 : c3;
      data[p * 4 + 2] = _isLittleEndianSystem ? c3 : c2;
      data[p * 4 + 3] = _isLittleEndianSystem ? c0 : c1;
    }

    putImageData(imageData, x, y);
  }
  */

  //-------------------------------------------------------------------------------------------------

  render(RenderState renderState) {
    renderState.renderQuad(_renderTextureQuad);
  }

  renderClipped(RenderState renderState, Rectangle clipRectangle) {
    if (clipRectangle.width > 0 && clipRectangle.height > 0) {
      renderState.renderQuad(_renderTextureQuad.clip(clipRectangle));
    }
  }
}
