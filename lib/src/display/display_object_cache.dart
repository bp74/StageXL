part of stagexl.display;

class _DisplayObjectCache {

  final DisplayObject displayObject;

  num pixelRatio = 1.0;
  bool debugBorder = true;

  Rectangle bounds = new Rectangle<int>(0, 0, 256, 256);
  RenderTexture renderTexture = null;
  RenderTextureQuad renderTextureQuad = null;

  _DisplayObjectCache(this.displayObject);

  //---------------------------------------------------------------------------

  void dispose() {
    if (renderTexture != null) renderTexture.dispose();
    renderTexture = null;
    renderTextureQuad = null;
  }

  //---------------------------------------------------------------------------

  void update() {

    var l = (pixelRatio * bounds.left).floor();
    var t = (pixelRatio * bounds.top).floor();
    var r = (pixelRatio * bounds.right).ceil();
    var b = (pixelRatio * bounds.bottom).ceil();
    var w = r - l;
    var h = b - t;

    // adjust size of texture and quad

    var pr = pixelRatio;
    var sr = new Rectangle<int>(0, 0, w, h);
    var or = new Rectangle<int>(0 - l, 0 - t, w, h);

    if (renderTexture == null) {
      renderTexture = new RenderTexture(w, h, Color.Transparent);
      renderTextureQuad = new RenderTextureQuad(renderTexture, sr, or, 0, pr);
    } else {
      renderTexture.resize(w, h);
      renderTextureQuad = new RenderTextureQuad(renderTexture, sr, or, 0, pr);
    }

    // render display object to texture

    var canvas = renderTexture.canvas;
    var matrix = renderTextureQuad.drawMatrix;
    var renderContext = new RenderContextCanvas(canvas);
    var renderState = new RenderState(renderContext, matrix);

    renderContext.clear(Color.Transparent);
    this.displayObject.render(renderState);

    // apply filters

    var filters = this.displayObject.filters;

    if (filters != null && filters.length > 0) {
      var bitmapData = new BitmapData.fromRenderTextureQuad(renderTextureQuad);
      filters.forEach((filter) => filter.apply(bitmapData));
    }

    // draw optional debug border

    if (debugBorder) {
      var context = canvas.context2D;
      context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
      context.lineWidth = 1;
      context.lineJoin = "miter";
      context.lineCap = "butt";
      context.strokeStyle = "#FF00FF";
      context.strokeRect(0.5, 0.5, canvas.width - 1, canvas.height - 1);
    }

    renderTexture.update();
  }

}
