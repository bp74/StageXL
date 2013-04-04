part of stagexl;

class Gauge extends DisplayObject {
  
  static const String DIRECTION_UP = 'DIRECTION_UP';
  static const String DIRECTION_RIGHT = 'DIRECTION_RIGHT';
  static const String DIRECTION_DOWN = 'DIRECTION_DOWN';
  static const String DIRECTION_LEFT = 'DIRECTION_LEFT';

  String _direction;
  num _ratio;
  BitmapData _bitmapData;
  Rectangle _clipRectangle;

  Gauge(BitmapData bitmapData, [String direction = DIRECTION_LEFT]) {
    
    if (direction != DIRECTION_UP && direction != DIRECTION_DOWN &&
        direction != DIRECTION_LEFT && direction != DIRECTION_RIGHT) {
      throw new ArgumentError('Invalid Gauge direction!');
    }

    _direction = direction;
    _ratio = 1.0;
    _bitmapData = bitmapData;
    _clipRectangle = new Rectangle.zero();

    _updateMask();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get ratio => _ratio;

  set ratio(num value) {
    
    if (value < 0.0) value = 0.0;
    if (value > 1.0) value = 1.0;

    _ratio = value;
    _updateMask();
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData get bitmapData => _bitmapData;

  set bitmapData(BitmapData value) {
    
    _bitmapData = value;
    _updateMask();
  }

  //-------------------------------------------------------------------------------------------------

  _updateMask() {
    
    if (_bitmapData == null) {
      _clipRectangle.left = 0;
      _clipRectangle.top = 0;
      _clipRectangle.right = 0;
      _clipRectangle.bottom = 0;

    } else {

      int bdWidth = _bitmapData.width;
      int bdHeight = _bitmapData.height;

      switch (_direction)
      {
        case DIRECTION_LEFT:
          _clipRectangle.left = ((1.0 - _ratio) * bdWidth).toInt();
          _clipRectangle.top = 0;
          _clipRectangle.right = bdWidth;
          _clipRectangle.bottom = bdHeight;
          break;

        case DIRECTION_UP:
          _clipRectangle.left = 0;
          _clipRectangle.top = ((1.0 - _ratio) * bdHeight).toInt();
          _clipRectangle.right = bdWidth;
          _clipRectangle.bottom = bdHeight;
          break;

        case DIRECTION_RIGHT:
          _clipRectangle.left = 0;
          _clipRectangle.top = 0;
          _clipRectangle.right = (_ratio * bdWidth).toInt();
          _clipRectangle.bottom = bdHeight;
          break;

        case DIRECTION_DOWN:
          _clipRectangle.left = 0;
          _clipRectangle.top = 0;
          _clipRectangle.right = bdWidth;
          _clipRectangle.bottom = (_ratio * bdHeight).toInt();
          break;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {
    
    int width = (_bitmapData != null) ? _bitmapData.width : 0;
    int height = (_bitmapData != null) ? _bitmapData.height : 0;

    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {
    
    if (_bitmapData != null && localX >= 0.0 && localY >= 0.0 && localX < _bitmapData.width && localY < _bitmapData.height)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {
    
    if (_bitmapData != null)
        _bitmapData.renderClipped(renderState, _clipRectangle);
  }

}
