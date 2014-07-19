part of stagexl;

/// The BitmapBatch class is an optimized container for Bitmaps.
///
/// Please not that only the DisplayObject properties x, y, pivotX, pivotY,
/// scaleX, scaleY, rotate, skewX and skewY are used to render the Bitmaps.
/// The mask and filters properties are ignored.
///
/// A specialized WebGL render program takes over all matrix calculations
/// to improve the performance and reduce garbage collection. Another
/// specialized render path even improves performance if WebGL is not
/// available and the standard Canvas element render operations are used.
///
class BitmapBatch extends DisplayObjectContainer {

  void addChildAt(DisplayObject child, int index) {
    if (child is! Bitmap) {
      throw new ArgumentError("BitmapBatch only supports Bitmap children.");
    } else {
      super.addChildAt(child, index);
    }
  }

  void render(RenderState renderState) {
    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextWebGL) {
      _renderWebGL(renderState);
    } else if (renderContext is RenderContextCanvas) {
      _renderCanvas(renderState);
    } else {
      super.render(renderState);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    var globalMatrix = renderState.globalMatrix;
    var globalAlpha = renderState.globalAlpha;
    var renderContext = renderState.renderContext;
    var renderContextWebGL = renderContext as RenderContextWebGL;
    var renderProgram = _BitmapBatchProgram.instance;

    renderContextWebGL.activateRenderProgram(renderProgram);
    renderProgram.flush();
    renderProgram.reset(globalMatrix, globalAlpha);

    for (int i = 0; i < _children.length; i++) {
      Bitmap bitmap = _children[i];
      BitmapData bitmapData = bitmap.bitmapData;
      if (bitmap.visible && bitmap.off == false && bitmapData != null) {
        renderContextWebGL.activateRenderTexture(bitmapData.renderTexture);
        renderProgram.renderBitmap(bitmap);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _renderCanvas(RenderState renderState) {

    var globalMatrix = renderState.globalMatrix;
    var globalAlpha = renderState.globalAlpha;
    var renderContext = renderState.renderContext;
    var renderContextCanvas = renderContext as RenderContextCanvas;
    var rawContext = renderContextCanvas.rawContext;
    var matrix = globalMatrix;

    rawContext.globalAlpha = renderState.globalAlpha;
    rawContext.globalCompositeOperation = renderState.globalCompositeOperation;
    rawContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

    // TODO: implement optimized BitmapBatch render code for canvas.

    for (int i = 0; i < _children.length; i++) {
      Bitmap bitmap = _children[i];
      if (bitmap.visible && bitmap.off == false) {
        renderState.renderDisplayObject(bitmap);
      }
    }
  }

}
