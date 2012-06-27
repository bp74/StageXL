class MovieClip extends InteractiveObject implements IAnimatable
{
  List<BitmapData> _bitmapDatas;

  int _frameRate;
  int _currentFrame;
  double _frameTime;

  bool _play;
  bool _loop;

  Rectangle clipRectangle;

  MovieClip(List<BitmapData> bitmapDatas, [int frameRate = 30, bool loop = true])
  {
    _bitmapDatas = bitmapDatas;
    _frameRate = frameRate;
    _currentFrame = 0;
    _frameTime = 0.0;
    _play = false;
    _loop = loop;

    clipRectangle = null;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get currentFrame() => _currentFrame;
  int get totalFrames() => _bitmapDatas.length;

  bool get loop() => _loop;
  void set loop(bool value) { _loop = value; }

  bool get playing() => _play;

  //-------------------------------------------------------------------------------------------------

  void gotoAndPlay(int frame)
  {
    _currentFrame = Math.min(Math.max(frame, 0), totalFrames - 1);
    _play = true;
    _frameTime = null;
  }

  void gotoAndStop(int frame)
  {
    _currentFrame = Math.min(Math.max(frame, 0), totalFrames - 1);
    _play = false;
    _frameTime = null;
  }

  void play()
  {
    _play = true;
    _frameTime = null;
  }

  void stop()
  {
    _play = false;
    _frameTime = null;
  }

  //-------------------------------------------------------------------------------------------------

  void nextFrame()
  {
    _currentFrame = _loop ? (_currentFrame + 1) % totalFrames : Math.max(_currentFrame + 1, totalFrames - 1);
    _play = false;
    _frameTime = null;
  }

  void prevFrame()
  {
    _currentFrame = _loop ? (_currentFrame - 1) % totalFrames : Math.min(_currentFrame - 1, 0);
    _play = false;
    _frameTime = null;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time)
  {
    if (_play == false || _frameTime == null)
    {
      _frameTime = 0.0;
    }
    else
    {
      _frameTime += time;

      num frameDuration = 1.0 / _frameRate;

      while (_play && _frameTime >= frameDuration)
      {
        _currentFrame = _loop ? (_currentFrame + 1) % totalFrames : Math.max(_currentFrame + 1, totalFrames - 1);
        _frameTime -= frameDuration;

        // ToDo: we should add an event to notify frame progress
      }
    }

    return true;
  }


  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle = null])
  {
    BitmapData bitmapData = _bitmapDatas[_currentFrame];
    int width = bitmapData.width;
    int height = bitmapData.height;

    // tranformedX = X * matrix.a + Y * matrix.c + matrix.tx;
    // tranformedY = X * matrix.b + Y * matrix.d + matrix.ty;

    double x1 = matrix.tx;
    double y1 = matrix.ty;
    double x2 = width * matrix.a + matrix.tx;
    double y2 = width * matrix.b + matrix.ty;
    double x3 = width * matrix.a + height * matrix.c + matrix.tx;
    double y3 = width * matrix.b + height * matrix.d + matrix.ty;
    double x4 = height * matrix.c + matrix.tx;
    double y4 = height * matrix.d + matrix.ty;

    double left = x1;
    if (left > x2) left = x2;
    if (left > x3) left = x3;
    if (left > x4) left = x4;

    double top = y1;
    if (top > y2 ) top = y2;
    if (top > y3 ) top = y3;
    if (top > y4 ) top = y4;

    double right = x1;
    if (right < x2) right = x2;
    if (right < x3) right = x3;
    if (right < x4) right = x4;

    double bottom = y1;
    if (bottom < y2 ) bottom = y2;
    if (bottom < y3 ) bottom = y3;
    if (bottom < y4 ) bottom = y4;

    //---------------------------------------------

    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();

    returnRectangle.x = left;
    returnRectangle.y = top;
    returnRectangle.width = right - left;
    returnRectangle.height = bottom - top;

    return returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY)
  {
    BitmapData bitmapData = _bitmapDatas[_currentFrame];

    if (localX >= 0 && localY >= 0 && localX < bitmapData.width && localY < bitmapData.height)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    BitmapData bitmapData = _bitmapDatas[_currentFrame];

    if (clipRectangle == null)
      bitmapData.render(renderState);
    else
      bitmapData.renderClipped(renderState, clipRectangle);
  }

}
