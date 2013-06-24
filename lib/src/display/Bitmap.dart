part of stagexl;

class Bitmap extends DisplayObject {

  BitmapData _bitmapData;
  String _pixelSnapping;
  Rectangle _clipRectangle;

  Bitmap([BitmapData bitmapData = null, String pixelSnapping = "auto"]) {
    this.bitmapData = bitmapData;
    this.pixelSnapping = pixelSnapping;
    _clipRectangle = null;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData get bitmapData => _bitmapData;
  String get pixelSnapping => _pixelSnapping;
  Rectangle get clipRectangle => _clipRectangle;

  set bitmapData(BitmapData value) {
    if (value == null) _bitmapData = null;
    if (value is BitmapData) _bitmapData = value;
  }

  set pixelSnapping(String value) {
    if (value is String) _pixelSnapping = value;
  }

  set clipRectangle(Rectangle value) {
    if (value == null) _clipRectangle = null;
    if (value is Rectangle) _clipRectangle = value;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {

    var bitmapData = _bitmapData;
    var width = 0, height = 0;

    if (bitmapData != null) {
      width = bitmapData.width;
      height = bitmapData.height;
    }

    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {

    var bitmapData = _bitmapData;
    if (bitmapData == null) return null;
    if (localX < 0.0 || localY < 0) return null;
    if (localX >= bitmapData.width || localY >= bitmapData.height) return null;

    return this;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var bitmapData = _bitmapData;
    if (bitmapData == null) return;

    if (_clipRectangle == null) {
      bitmapData.render(renderState);
    } else {
      bitmapData.renderClipped(renderState, _clipRectangle);
    }
  }

}
