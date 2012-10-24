part of dartflash;

class Gauge extends DisplayObject
{
  static const String DIRECTION_UP = 'DIRECTION_UP';
  static const String DIRECTION_RIGHT = 'DIRECTION_RIGHT';
  static const String DIRECTION_DOWN = 'DIRECTION_DOWN';
  static const String DIRECTION_LEFT = 'DIRECTION_LEFT';

  BitmapData bitmapData;

  String _direction;
  num _ratio;
  Rectangle _clipRectangle;

  Gauge(BitmapData bitmapData, [String direction = DIRECTION_LEFT])
  {
    if (direction != DIRECTION_UP || direction != DIRECTION_DOWN ||
        direction != DIRECTION_RIGHT || direction != DIRECTION_LEFT) {
      throw new ArgumentError('Invalid Gauge direction!');
    }

    this.bitmapData = bitmapData;

    _direction = direction;
    _ratio = 1.0;
    _clipRectangle = new Rectangle.zero();

    _updateMask();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get ratio => _ratio;

  void set ratio(num value)
  {
    if (value < 0.0) value = 0.0;
    if (value > 1.0) value = 1.0;

    _ratio = value;
    _updateMask();
  }

  //-------------------------------------------------------------------------------------------------

  _updateMask()
  {
    if (bitmapData == null)
      return;

    int bdWidth = bitmapData.width;
    int bdHeight = bitmapData.height;

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

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle = null])
  {
    int width = (bitmapData != null) ? bitmapData.width : 0;
    int height = (bitmapData != null) ? bitmapData.height : 0;

    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY)
  {
    if (bitmapData != null && localX >= 0.0 && localY >= 0.0 && localX < bitmapData.width && localY < bitmapData.height)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    if (bitmapData != null)
        bitmapData.renderClipped(renderState, _clipRectangle);
  }


}
