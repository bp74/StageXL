part of stagexl.display_ex;

/// The Scale9Bitmap display object divides it's BitmapData into a 3x3 grid
/// defined by the [grid] rectangle. The corners of the grid are rendered
/// in it's orignal form. The fields between the corners are scaled to get
/// the size defined by the [width] and [height] properties.

class Scale9Bitmap extends Bitmap {

  BitmapData _bitmapData;
  Rectangle<int> _grid;
  int _width;
  int _height;
  List<RenderTextureQuad> _renderTextureQuads;

  Scale9Bitmap(BitmapData bitmapData, Rectangle<int> grid) : super(bitmapData) {
    _bitmapData = bitmapData;
    _grid = grid;
    _width = ensureInt(bitmapData.width);
    _height = ensureInt(bitmapData.height);
    _updateRenderTextureQuads();
  }

  //-------------------------------------------------------------------------------------------------

  /// Gets and sets the width of this Scale9Bitmap. In contrast to other
  /// display objects, this does not affect the scaleX factor.

  int get width => _width;

  void set width(int value) {
    _width = ensureInt(value);
  }

  /// Gets and sets the height of this Scale9Bitmap. In contrast to other
  /// display objects, this does not affect the scaleY factor.

  int get height => _height;

  void set height(int value) {
    _height = ensureInt(value);
  }

  /// Gets and sets the grid rectangle within the BitmapData to be scaled.

  Rectangle<int> get grid => _grid;

  void set grid(Rectangle<int> value) {
    _grid = value;
    _updateRenderTextureQuads();
  }

  /// Gets and sets the BitmapData of this Scale9Bitmap.

  BitmapData get bitmapData => _bitmapData;

  void set bitmapData(BitmapData value) {
    _bitmapData = value;
    _updateRenderTextureQuads();
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {
    return getBoundsTransformedHelper(matrix, _width, _height, returnRectangle);
  }

  DisplayObject hitTestInput(num localX, num localY) =>
    localX >= 0.0 && localY >= 0.0 &&
    localX < _width && localY < _height ? this : null;

  void render(RenderState renderState) {

    var x1 = _grid.left;
    var x2 = _grid.right;
    var x3 = ensureInt(bitmapData.width);
    var y1 = _grid.top;
    var y2 = _grid.bottom;
    var y3 = ensureInt(bitmapData.height);
    var width = _width;
    var height = _height;

    var globalMatrix = renderState.globalMatrix;
    var renderContext = renderState.renderContext;
    var tempMatrix = globalMatrix.clone();

    for(int x = 0; x < 3; x++) {
      var a = (x == 1) ? (width - x1 - x3 + x2) / (x2 - x1) : 1.0;
      var tx = (x == 1) ? x1 : ((x == 2) ? width - x3 + x2 : 0);
      for(int y = 0; y < 3; y++) {
        var d = (y == 1) ? (height - y1 - y3 + y2) / (y2 - y1) : 1.0;
        var ty = (y == 1) ? y1 : ((y == 2) ? height - y3 + y2 : 0);
        globalMatrix.setTo(a, 0, 0, d, tx, ty);
        globalMatrix.concat(tempMatrix);
        renderContext.renderQuad(renderState, _renderTextureQuads[x + y * 3]);
      }
    }

    globalMatrix.copyFrom(tempMatrix);
  }

  //-------------------------------------------------------------------------------------------------

  _updateRenderTextureQuads() {

    var x0 = 0;
    var x1 = _grid.left;
    var x2 = _grid.right;
    var x3 = bitmapData.width;
    var y0 = 0;
    var y1 = _grid.top;
    var y2 = _grid.bottom;
    var y3 = bitmapData.height;

    var renderTextureQuad = this.bitmapData.renderTextureQuad;

    _renderTextureQuads = [
      renderTextureQuad.cut(new Rectangle<int>(x0, y0, x1 - x0, y1 - y0)),
      renderTextureQuad.cut(new Rectangle<int>(x1, y0, x2 - x1, y1 - y0)),
      renderTextureQuad.cut(new Rectangle<int>(x2, y0, x3 - x2, y1 - y0)),
      renderTextureQuad.cut(new Rectangle<int>(x0, y1, x1 - x0, y2 - y1)),
      renderTextureQuad.cut(new Rectangle<int>(x1, y1, x2 - x1, y2 - y1)),
      renderTextureQuad.cut(new Rectangle<int>(x2, y1, x3 - x2, y2 - y1)),
      renderTextureQuad.cut(new Rectangle<int>(x0, y2, x1 - x0, y3 - y2)),
      renderTextureQuad.cut(new Rectangle<int>(x1, y2, x2 - x1, y3 - y2)),
      renderTextureQuad.cut(new Rectangle<int>(x2, y2, x3 - x2, y3 - y2))
    ];
  }
}
