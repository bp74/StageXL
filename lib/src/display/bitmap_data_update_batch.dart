part of '../display.dart';

/// The [BitmapDataUpdateBatch] class provides all the [BitmapData] update
/// methods, but does not automatically update the underlying WebGL texture.
/// This improves the performance for multiple updates to the BitmapData.
/// Once all updates are done, call the [update] method to update the
/// underlying WebGL texture.

class BitmapDataUpdateBatch {
  final BitmapData bitmapData;
  final RenderContextCanvas _renderContext;
  final Matrix _drawMatrix;

  BitmapDataUpdateBatch(this.bitmapData)
      : _renderContext = RenderContextCanvas(bitmapData.renderTexture.canvas),
        _drawMatrix = bitmapData.renderTextureQuad.drawMatrix;

  //---------------------------------------------------------------------------

  /// Update the underlying rendering surface.

  void update() => bitmapData.renderTexture.update();

  //---------------------------------------------------------------------------

  void applyFilter(BitmapFilter filter, [Rectangle<num>? rectangle]) {
    filter.apply(bitmapData, rectangle);
  }

  //---------------------------------------------------------------------------

  void colorTransform(Rectangle<num> rectangle, ColorTransform transform) {
    final isLittleEndianSystem = env.isLittleEndianSystem;

    final redMultiplier = (1024 * transform.redMultiplier).toInt();
    final greenMultiplier = (1024 * transform.greenMultiplier).toInt();
    final blueMultiplier = (1024 * transform.blueMultiplier).toInt();
    final alphaMultiplier = (1024 * transform.alphaMultiplier).toInt();

    final redOffset = transform.redOffset;
    final greenOffset = transform.greenOffset;
    final blueOffset = transform.blueOffset;
    final alphaOffset = transform.alphaOffset;

    final mulitplier0 = isLittleEndianSystem ? redMultiplier : alphaMultiplier;
    final mulitplier1 = isLittleEndianSystem ? greenMultiplier : blueMultiplier;
    final mulitplier2 = isLittleEndianSystem ? blueMultiplier : greenMultiplier;
    final mulitplier3 = isLittleEndianSystem ? alphaMultiplier : redMultiplier;

    final offset0 = isLittleEndianSystem ? redOffset : alphaOffset;
    final offset1 = isLittleEndianSystem ? greenOffset : blueOffset;
    final offset2 = isLittleEndianSystem ? blueOffset : greenOffset;
    final offset3 = isLittleEndianSystem ? alphaOffset : redOffset;

    final renderTextureQuad = bitmapData.renderTextureQuad.cut(rectangle);
    final imageData = renderTextureQuad.getImageData();
    final data = imageData.data;

    for (var i = 0; i <= data.length - 4; i += 4) {
      final c0 = data[i + 0];
      final c1 = data[i + 1];
      final c2 = data[i + 2];
      final c3 = data[i + 3];

      data[i + 0] = offset0 + (((c0 * mulitplier0) | 0) >> 10);
      data[i + 1] = offset1 + (((c1 * mulitplier1) | 0) >> 10);
      data[i + 2] = offset2 + (((c2 * mulitplier2) | 0) >> 10);
      data[i + 3] = offset3 + (((c3 * mulitplier3) | 0) >> 10);
    }

    renderTextureQuad.putImageData(imageData);
  }

  //---------------------------------------------------------------------------

  /// See [BitmapData.clear]

  void clear() {
    _renderContext.setTransform(_drawMatrix);
    _renderContext.rawContext
        .clearRect(0, 0, bitmapData.width, bitmapData.height);
  }

  //---------------------------------------------------------------------------

  void fillRect(Rectangle<num> rectangle, int color) {
    _renderContext.setTransform(_drawMatrix);
    _renderContext.rawContext.fillStyle = color2rgba(color);
    _renderContext.rawContext.fillRect(
        rectangle.left, rectangle.top, rectangle.width, rectangle.height);
  }

  //---------------------------------------------------------------------------

  void draw(BitmapDrawable source, [Matrix? matrix]) {
    final renderState = RenderState(_renderContext, _drawMatrix);
    if (matrix != null) renderState.globalMatrix.prepend(matrix);
    source.render(renderState);
  }

  //---------------------------------------------------------------------------

  /// See [BitmapData.copyPixels]

  void copyPixels(
      BitmapData source, Rectangle<num> sourceRect, Point<num> destPoint) {
    final sourceQuad = source.renderTextureQuad.cut(sourceRect);
    final renderState = RenderState(_renderContext, _drawMatrix);
    renderState.globalMatrix.prependTranslation(destPoint.x, destPoint.y);
    _renderContext.setTransform(renderState.globalMatrix);
    _renderContext.rawContext
        .clearRect(0, 0, sourceRect.width, sourceRect.height);
    _renderContext.renderTextureQuad(renderState, sourceQuad);
  }

  //---------------------------------------------------------------------------

  /// See [BitmapData.drawPixels]

  void drawPixels(
      BitmapData source, Rectangle<num> sourceRect, Point<num> destPoint,
      [BlendMode? blendMode]) {
    final sourceQuad = source.renderTextureQuad.cut(sourceRect);
    final renderState =
        RenderState(_renderContext, _drawMatrix, 1.0, blendMode);
    renderState.globalMatrix.prependTranslation(destPoint.x, destPoint.y);
    renderState.renderTextureQuad(sourceQuad);
  }

  //---------------------------------------------------------------------------

  /// See [BitmapData.getPixel32]

  int getPixel32(num x, num y) {
    var r = 0, g = 0, b = 0, a = 0;

    final rectangle = Rectangle<num>(x, y, 1, 1);
    final renderTextureQuad = bitmapData.renderTextureQuad.clip(rectangle);
    if (renderTextureQuad.sourceRectangle.isEmpty) return Color.Transparent;

    final isLittleEndianSystem = env.isLittleEndianSystem;
    final imageData = renderTextureQuad.getImageData();
    final pixels = imageData.width * imageData.height;
    final data = imageData.data;

    for (var i = 0; i <= data.length - 4; i += 4) {
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

  //---------------------------------------------------------------------------

  /// See [BitmapData.setPixel32]

  void setPixel32(num x, num y, int color) {
    _renderContext.setTransform(_drawMatrix);
    _renderContext.rawContext.fillStyle = color2rgba(color);
    _renderContext.rawContext.clearRect(x, y, 1, 1);
    _renderContext.rawContext.fillRect(x, y, 1, 1);
  }
}
