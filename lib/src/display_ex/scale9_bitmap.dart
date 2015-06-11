part of stagexl.display_ex;

/// The Scale9Bitmap display object divides it's BitmapData into a 3x3 grid
/// defined by the [grid] rectangle. The corners of the grid are rendered
/// in it's orignal form. The fields between the corners are scaled to get
/// the size defined by the [width] and [height] properties.

class Scale9Bitmap extends Bitmap {

  BitmapData _bitmapData;
  Rectangle<num> _grid;
  num _width = 0.0;
  num _height = 0.0;

  final List<RenderTextureQuad> _slices = new List<RenderTextureQuad>(9);

  Scale9Bitmap(BitmapData bitmapData, Rectangle<num> grid) : super(bitmapData) {
    _bitmapData = bitmapData;
    _grid = grid;
    _width = ensureNum(bitmapData.width);
    _height = ensureNum(bitmapData.height);
    _updateRenderTextureQuads();
  }

  //---------------------------------------------------------------------------

  /// Gets and sets the width of this Scale9Bitmap. In contrast to other
  /// display objects, this does not affect the scaleX factor.

  num get width => _width;

  void set width(num value) {
    _width = ensureNum(value);
  }

  /// Gets and sets the height of this Scale9Bitmap. In contrast to other
  /// display objects, this does not affect the scaleY factor.

  num get height => _height;

  void set height(num value) {
    _height = ensureNum(value);
  }

  /// Gets and sets the grid rectangle within the BitmapData to be scaled.

  Rectangle<num> get grid => _grid;

  void set grid(Rectangle<num> value) {
    _grid = value;
    _updateRenderTextureQuads();
  }

  /// Gets and sets the BitmapData of this Scale9Bitmap.

  BitmapData get bitmapData => _bitmapData;

  void set bitmapData(BitmapData value) {
    _bitmapData = value;
    _updateRenderTextureQuads();
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, _width, _height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    if (localX < 0.0 || localX >= _width) return null;
    if (localY < 0.0 || localY >= _height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {

    var globalMatrix = renderState.globalMatrix;
    var renderContext = renderState.renderContext;
    var tempMatrix = globalMatrix.clone();

    var w0 = _slices[0].targetWidth;
    var h0 = _slices[0].targetHeight;
    var w1 = _slices[4].targetWidth;
    var h1 = _slices[4].targetHeight;
    var w2 = _slices[8].targetWidth;
    var h2 = _slices[8].targetHeight;

    for (int j = 0; j < 3; j++) {
      var sh = j == 0 ? h0 : j == 2 ? h2 : h1;
      var th = j == 0 ? h0 : j == 2 ? h2 : height - h0 - h2;
      var ty = j == 0 ? 0 : j == 1 ? h0 : height - h2;
      for (int i = 0; i < 3; i++) {
        var sw = i == 0 ? w0 : i == 2 ? w2 : w1;
        var tw = i == 0 ? w0 : i == 2 ? w2 : width - w0 - w2;
        var tx = i == 0 ? 0 : i == 1 ? w0 : width - w2;
        globalMatrix.setTo(tw / sw, 0, 0, th / sh, tx, ty);
        globalMatrix.concat(tempMatrix);
        renderContext.renderQuad(renderState, _slices[i + j * 3]);
      }
    }

    globalMatrix.copyFrom(tempMatrix);
  }

  //---------------------------------------------------------------------------

  _updateRenderTextureQuads() {

    var rtq = bitmapData.renderTextureQuad;

    var x0 = 0;
    var x1 = (rtq.pixelRatio * grid.left).round();
    var x2 = (rtq.pixelRatio * grid.right).round();
    var x3 = (rtq.sourceRectangle.width);

    var y0 = 0;
    var y1 = (rtq.pixelRatio * grid.top).round();
    var y2 = (rtq.pixelRatio * grid.bottom).round();
    var y3 = (rtq.sourceRectangle.height);

    for (int j = 0; j < 3; j++) {
      var y = (j == 0 ? y0 : j == 1 ? y1 : y2);
      var h = (j == 0 ? y1 : j == 1 ? y2 : y3) - y;
      for (int i = 0; i < 3; i++) {
        var x = (i == 0 ? x0 : i == 1 ? x1 : x2);
        var w = (i == 0 ? x1 : i == 1 ? x2 : x3) - x;
        var source = new Rectangle<int>(x, y, w, h);
        var offset = new Rectangle<int>(0, 0, w, h);
        var slice = new RenderTextureQuad.slice(rtq, source, offset);
        _slices[i + j * 3] = slice;
      }
    }
  }

}


