part of stagexl;

class Gauge extends DisplayObject {

  static const String DIRECTION_UP = 'DIRECTION_UP';
  static const String DIRECTION_RIGHT = 'DIRECTION_RIGHT';
  static const String DIRECTION_DOWN = 'DIRECTION_DOWN';
  static const String DIRECTION_LEFT = 'DIRECTION_LEFT';

  String _direction;
  num _ratio;
  BitmapData _bitmapData;
  RenderTextureQuad _renderTextureQuad;

  Gauge(BitmapData bitmapData, [String direction = DIRECTION_LEFT]) {

    if (direction != DIRECTION_UP && direction != DIRECTION_DOWN &&
        direction != DIRECTION_LEFT && direction != DIRECTION_RIGHT) {
      throw new ArgumentError('Invalid Gauge direction!');
    }

    _direction = direction;
    _bitmapData = bitmapData;
    _ratio = 1.0;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get ratio => _ratio;

  set ratio(num value) {
    if (value < 0.0) value = 0.0;
    if (value > 1.0) value = 1.0;
    _ratio = value;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData get bitmapData => _bitmapData;

  set bitmapData(BitmapData value) {
    _bitmapData = value;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {

    int width = (_bitmapData != null) ? _bitmapData.width : 0;
    int height = (_bitmapData != null) ? _bitmapData.height : 0;

    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {

    return bitmapData != null &&
      localX >= 0.0 && localY >= 0.0 &&
      localX < _bitmapData.width && localY < _bitmapData.height ? this : null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    if (_bitmapData != null) {

      var width = _bitmapData.width;
      var height = _bitmapData.height;
      var left = 0, top = 0;
      var right = width, bottom = height;

      if (_direction == DIRECTION_LEFT) left = ((1.0 - _ratio) * width).round();
      if (_direction == DIRECTION_UP) top = ((1.0 - _ratio) * height).round();
      if (_direction == DIRECTION_RIGHT) right = (_ratio * width).round();
      if (_direction == DIRECTION_DOWN) bottom = (_ratio * height).round();

      var rectangle = new Rectangle(left, top, right - left, bottom - top);
      var quad = _bitmapData.renderTextureQuad.clip(rectangle);
      renderState.renderQuad(quad);
    }
  }

}
