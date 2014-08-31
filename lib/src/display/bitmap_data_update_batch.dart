part of stagexl.display;

/// The [BitmapDataUpdateBatch] class provides all the [BitmapData] update
/// methods, but does not automatically update the underlying WebGL texture.
/// This improves the performance for multiple updates to the BitmapData.
/// Once all updates are done, call the [update] method to update the
/// underlying WebGL texture.
///
class BitmapDataUpdateBatch {

  final BitmapData bitmapData;
  final RenderContextCanvas _renderContext;
  final Matrix _drawMatrix;

  BitmapDataUpdateBatch(BitmapData bitmapData) : bitmapData = bitmapData,
    _renderContext = new RenderContextCanvas(bitmapData.renderTexture.canvas),
    _drawMatrix = bitmapData.renderTextureQuad.drawMatrix;

  //-----------------------------------------------------------------------------------------------

  /**
   * Update the underlying rendering surface.
   */
  update() => this.bitmapData.renderTexture.update();

  //-----------------------------------------------------------------------------------------------

  void applyFilter(BitmapFilter filter, [Rectangle<int> rectangle]) {
    filter.apply(this.bitmapData, rectangle);
  }

  //-----------------------------------------------------------------------------------------------

  void colorTransform(Rectangle<int> rect, ColorTransform transform) {

    bool isLittleEndianSystem = env.isLittleEndianSystem;

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

    var renderTextureQuad = this.bitmapData.renderTextureQuad.cut(rect);
    var imageData = renderTextureQuad.getImageData();
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

    renderTextureQuad.putImageData(imageData);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.clear]
   */
  void clear() {

    _renderContext.setTransform(_drawMatrix);
    _renderContext.rawContext.clearRect(0, 0, this.bitmapData.width, this.bitmapData.height);
  }

  //-----------------------------------------------------------------------------------------------

  void fillRect(Rectangle<int> rect, int color) {

    _renderContext.setTransform(_drawMatrix);
    _renderContext.rawContext.fillStyle = color2rgba(color);
    _renderContext.rawContext.fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  //-----------------------------------------------------------------------------------------------

  void draw(BitmapDrawable source, [Matrix matrix]) {

    var renderState = new RenderState(_renderContext, _drawMatrix);
    if (matrix != null) renderState.globalMatrix.prepend(matrix);
    source.render(renderState);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.copyPixels]
   */
  void copyPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint) {

    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderState = new RenderState(_renderContext, _drawMatrix);
    renderState.globalMatrix.prependTranslation(destPoint.x, destPoint.y);
    _renderContext.setTransform(renderState.globalMatrix);
    _renderContext.rawContext.clearRect(0, 0, sourceRect.width, sourceRect.height);
    _renderContext.renderQuad(renderState, sourceQuad);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.drawPixels]
   */
  void drawPixels(BitmapData source, Rectangle<int> sourceRect, Point<int> destPoint,
                  [BlendMode blendMode]) {

    var sourceQuad = source.renderTextureQuad.cut(sourceRect);
    var renderState = new RenderState(_renderContext, _drawMatrix, 1.0, blendMode);
    renderState.globalMatrix.prependTranslation(destPoint.x, destPoint.y);
    renderState.renderQuad(sourceQuad);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.getPixel32]
   */
  int getPixel32(int x, int y) {

    int r = 0, g = 0, b = 0, a = 0;

    var rectangle = new Rectangle<int>(x, y, 1, 1);
    var renderTextureQuad = this.bitmapData.renderTextureQuad.clip(rectangle);
    if (renderTextureQuad.textureWidth == 0) return 0;
    if (renderTextureQuad.textureHeight == 0) return 0;

    var isLittleEndianSystem = env.isLittleEndianSystem;
    var imageData = renderTextureQuad.getImageData();
    var pixels = imageData.width * imageData.height;
    var data = imageData.data;

    for (int i = 0; i <= data.length - 4; i += 4) {
      r += isLittleEndianSystem ? data[i + 0] : data[i + 3];
      g += isLittleEndianSystem ? data[i + 1] : data[i + 2];
      b += isLittleEndianSystem ? data[i + 2] : data[i + 1];
      a += isLittleEndianSystem ? data[i + 3] : data[i + 0];
    }

    r = r ~/ pixels;
    g = g ~/ pixels;
    b = b ~/ pixels;
    a = a ~/ pixels;

    return (a << 24) + (r << 16) + (g << 8) + b;
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * See [BitmapData.setPixel32]
   */
  void setPixel32(int x, int y, int color) {
    _renderContext.setTransform(_drawMatrix);
    _renderContext.rawContext.fillStyle = color2rgba(color);
    _renderContext.rawContext.clearRect(x, y, 1, 1);
    _renderContext.rawContext.fillRect(x, y, 1, 1);
  }

}
