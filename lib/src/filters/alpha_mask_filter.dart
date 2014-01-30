part of stagexl;

class AlphaMaskFilter extends BitmapFilter {

  final BitmapData _alphaBitmapData;
  final Matrix _matrix;

  AlphaMaskFilter(BitmapData alphaBitmapData, [Matrix matrix]) :
    _alphaBitmapData = alphaBitmapData,
    _matrix = (matrix != null) ? matrix : new Matrix.fromIdentity();

  Matrix get matrix => _matrix;

  BitmapFilter clone() => new AlphaMaskFilter(_alphaBitmapData, _matrix.clone());
  Rectangle get overlap => new Rectangle.zero();

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    Matrix matrix = renderTextureQuad.drawMatrix;
    CanvasElement canvas = renderTextureQuad.renderTexture.canvas;
    RenderContextCanvas renderContext = new RenderContextCanvas(canvas, Color.Transparent);
    CanvasRenderingContext2D context = renderContext.rawContext;

    context.save();
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.rect(0, 0, width, height);
    context.clip();
    context.globalCompositeOperation = CompositeOperation.DESTINATION_IN;
    matrix.prepend(this.matrix);
    renderContext.renderQuad(_alphaBitmapData.renderTextureQuad, matrix);
    context.restore();
  }

}
