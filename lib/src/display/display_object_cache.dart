part of '../display.dart';

class _DisplayObjectCache {
  final DisplayObject displayObject;

  num pixelRatio = 1.0;
  bool debugBorder = true;

  Rectangle<num> bounds = Rectangle<num>(0, 0, 256, 256);
  RenderTexture? renderTexture;
  RenderTextureQuad? renderTextureQuad;

  _DisplayObjectCache(this.displayObject);

  //---------------------------------------------------------------------------

  void dispose() {
    renderTexture?.dispose();
    renderTexture = null;
    renderTextureQuad = null;
  }

  //---------------------------------------------------------------------------

  void update() {
    final l = (pixelRatio * bounds.left).floor();
    final t = (pixelRatio * bounds.top).floor();
    final r = (pixelRatio * bounds.right).ceil();
    final b = (pixelRatio * bounds.bottom).ceil();
    final w = r - l;
    final h = b - t;

    // adjust size of texture and quad

    final pr = pixelRatio;
    final sr = Rectangle<int>(0, 0, w, h);
    final or = Rectangle<int>(0 - l, 0 - t, w, h);

    if (renderTexture == null) {
      renderTexture = RenderTexture(w, h, Color.Transparent);
      renderTextureQuad = RenderTextureQuad(renderTexture!, sr, or, 0, pr);
    } else {
      renderTexture!.resize(w, h);
      renderTextureQuad = RenderTextureQuad(renderTexture!, sr, or, 0, pr);
    }

    // render display object to texture

    final canvas = renderTexture!.canvas;
    final matrix = renderTextureQuad!.drawMatrix;
    final renderContext = RenderContextCanvas(canvas);
    final renderState = RenderState(renderContext, matrix);

    renderContext.clear(Color.Transparent);
    displayObject.render(renderState);

    // apply filters

    final filters = displayObject.filters;
    if (filters.isNotEmpty) {
      final bitmapData = BitmapData.fromRenderTextureQuad(renderTextureQuad!);
      filters.forEach((filter) => filter.apply(bitmapData));
    }

    // draw optional debug border

    if (debugBorder) {
      final context = canvas.context2D;
      context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
      context.lineWidth = 1;
      context.lineJoin = 'miter';
      context.lineCap = 'butt';
      context.strokeStyle = '#FF00FF';
      context.strokeRect(0.5, 0.5, canvas.width! - 1, canvas.height! - 1);
    }

    renderTexture!.update();
  }
}
