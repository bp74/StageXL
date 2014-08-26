part of stagexl;

/// The BitmapDataUpdateBatch class provides all the BitmapData update
/// methods, but does not automatically update the underlying WebGL
/// texture. This improves the performance for multiple updates
/// to the BitmapData. Once all updates are done, call the [update]
/// method to update the underlying WebGL texture.
///
class BitmapDataUpdateBatch {

  final BitmapData bitmapData;

  final RenderTexture _renderTexture;
  final RenderTextureQuad _renderTextureQuad;
  final Matrix _matrix;
  final CanvasElement _canvas;
  final CanvasRenderingContext2D _context;

  BitmapDataUpdateBatch(BitmapData bitmapData) : bitmapData = bitmapData,
    _renderTexture = bitmapData.renderTexture,
    _renderTextureQuad = bitmapData.renderTextureQuad,
    _matrix = bitmapData.renderTextureQuad.drawMatrix,
    _canvas = bitmapData.renderTexture.canvas,
    _context = bitmapData.renderTexture.canvas.context2D;

  //-----------------------------------------------------------------------------------------------

  /**
   * Update the underlying rendering surface.
   */
  update() => _renderTexture.update();

  //-----------------------------------------------------------------------------------------------

  void applyFilter(BitmapFilter filter, [Rectangle<int> rectangle]) {
    filter.apply(this.bitmapData, rectangle);
  }

  //-----------------------------------------------------------------------------------------------

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
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.clear]
   */
  void clear() {
    _context.setTransform(_matrix.a, _matrix.b, _matrix.c, _matrix.d, _matrix.tx, _matrix.ty);
    _context.clearRect(0, 0, this.bitmapData.width, this.bitmapData.height);
  }

  //-----------------------------------------------------------------------------------------------

  void fillRect(Rectangle<int> rect, int color) {
    _context.setTransform(_matrix.a, _matrix.b, _matrix.c, _matrix.d, _matrix.tx, _matrix.ty);
    _context.fillStyle = _color2rgba(color);
    _context.fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  //-----------------------------------------------------------------------------------------------

  void draw(BitmapDrawable source, [Matrix matrix]) {

    if (matrix == null) {
      matrix = _matrix.clone();
    } else {
      matrix.concat(_matrix);
    }

    var renderContext = new RenderContextCanvas(_canvas);
    var renderState = new RenderState(renderContext, matrix);
    source.render(renderState);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.copyPixels]
   */
  void copyPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint) {

    var matrix = new Matrix(1, 0, 0, 1, destPoint.x, destPoint.y);
    matrix.concat(_matrix);

    _context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    _context.clearRect(0, 0, sourceRect.width, sourceRect.height);

    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderContext = new RenderContextCanvas(_canvas);
    var renderState = new RenderState(renderContext, matrix);
    renderContext.renderQuad(renderState, sourceQuad);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.drawPixels]
   */
  void drawPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint,
                  [BlendMode blendMode]) {

    var matrix = new Matrix(1, 0, 0, 1, destPoint.x, destPoint.y);
    matrix.concat(_matrix);

    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderContext = new RenderContextCanvas(_canvas);
    var renderState = new RenderState(renderContext, matrix, 1.0, blendMode);
    renderContext.renderQuad(renderState, sourceQuad);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.getPixel32]
   */
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

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.setPixel32]
   */
  void setPixel32(int x, int y, int color) {
     _context.setTransform(_matrix.a, _matrix.b, _matrix.c, _matrix.d, _matrix.tx, _matrix.ty);
     _context.fillStyle = _color2rgba(color);
     _context.clearRect(x, y, 1, 1);
     _context.fillRect(x, y, 1, 1);
   }

}