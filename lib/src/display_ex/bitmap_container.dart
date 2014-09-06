part of stagexl.display_ex;

/// WARNING: This class is experimental! The implementation and behaviour may
/// change in the future. Therefore it's recommended to use the [Sprite]
/// class instead.
///
/// The BitmapContainer class is an optimized container for Bitmaps.
///
/// Please note that only the Bitmap properties x, y, pivotX, pivotY,
/// scaleX, scaleY, skewX, skewY, rotate and alpha are supported.
/// The mask and filters property are ignored.
///
/// A specialized WebGL render program takes over all matrix calculations
/// to improve the performance and reduce garbage collection. Another
/// specialized render path improves performance even for the standard
/// Canvas renderer.
///
class BitmapContainer extends DisplayObjectContainer {

  void addChildAt(DisplayObject child, int index) {
    if (child is! Bitmap) {
      throw new ArgumentError("BitmapBatch only supports Bitmap children.");
    } else {
      super.addChildAt(child, index);
    }
  }

  DisplayObject hitTestInput(num localX, num localY) {
    return null;
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
    var renderProgram = _BitmapContainerProgram.instance;

    renderContextWebGL.activateRenderProgram(renderProgram);
    renderProgram.flush();
    renderProgram.reset(globalMatrix, globalAlpha);

    for (int i = 0; i < numChildren; i++) {
      Bitmap bitmap = getChildAt(i);
      BitmapData bitmapData = bitmap.bitmapData;
      if (bitmap.visible && bitmap.off == false && bitmapData != null) {
        renderContextWebGL.activateRenderTexture(bitmapData.renderTexture);
        renderProgram.renderBitmap(bitmap);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _renderCanvas(RenderState renderState) {

    var renderContext = renderState.renderContext;
    var renderContextCanvas = renderContext as RenderContextCanvas;

    renderContextCanvas.setTransform(renderState.globalMatrix);
    renderContextCanvas.setAlpha(renderState.globalAlpha);

    // TODO: implement optimized BitmapBatch render code for canvas.

    for (int i = 0; i < numChildren; i++) {
      Bitmap bitmap = getChildAt(i);
      if (bitmap.visible && bitmap.off == false) {
        renderState.renderObject(bitmap);
      }
    }
  }

}
