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

    return _getBoundsTransformedHelper(matrix, bitmapData.width, bitmapData.height, returnRectangle);
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
