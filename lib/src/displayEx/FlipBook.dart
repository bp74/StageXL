part of stagexl;

class FlipBook extends InteractiveObject implements Animatable {

  List<BitmapData> _bitmapDatas;

  int _frameRate;
  int _currentFrame;
  double _frameTime;

  bool _play;
  bool _loop;
  Event _progressEvent;
  Event _completeEvent;

  Rectangle clipRectangle;

  //-------------------------------------------------------------------------------------------------

  FlipBook(List<BitmapData> bitmapDatas, [int frameRate = 30, bool loop = true]) {

    _bitmapDatas = bitmapDatas;
    _frameRate = frameRate;
    _currentFrame = 0;
    _frameTime = null;
    _play = false;
    _loop = loop;
    _progressEvent = new Event(Event.PROGRESS);
    _completeEvent = new Event(Event.COMPLETE);

    clipRectangle = null;
  }

  //-------------------------------------------------------------------------------------------------

  static const EventStreamProvider<Event> progressEvent = const EventStreamProvider<Event>(Event.PROGRESS);
  static const EventStreamProvider<Event> completeEvent = const EventStreamProvider<Event>(Event.COMPLETE);

  Stream<Event> get onProgress => FlipBook.progressEvent.forTarget(this);
  Stream<Event> get onComplete => FlipBook.completeEvent.forTarget(this);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get currentFrame => _currentFrame;
  int get totalFrames => _bitmapDatas.length;

  bool get loop => _loop;
  void set loop(bool value) { _loop = value; }

  bool get playing => _play;

  //-------------------------------------------------------------------------------------------------

  void gotoAndPlay(int frame) {
    _currentFrame = min(max(frame, 0), totalFrames - 1);
    _play = true;
    _frameTime = null;
  }

  void gotoAndStop(int frame) {
    _currentFrame = min(max(frame, 0), totalFrames - 1);
    _play = false;
    _frameTime = null;
  }

  void play() {
    _play = true;
    _frameTime = null;
  }

  void stop() {
    _play = false;
    _frameTime = null;
  }

  //-------------------------------------------------------------------------------------------------

  void nextFrame() {
    _currentFrame = _loop ? (_currentFrame + 1) % totalFrames : max(_currentFrame + 1, totalFrames - 1);
    _play = false;
    _frameTime = null;
  }

  void prevFrame() {
    _currentFrame = _loop ? (_currentFrame - 1) % totalFrames : min(_currentFrame - 1, 0);
    _play = false;
    _frameTime = null;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time) {
    if (_play == false)
      return true;

    if (_frameTime == null) {

      _frameTime = 0.0;
      _dispatchEventInternal(_progressEvent, this, this, EventPhase.AT_TARGET);

    } else {

      _frameTime += time;

      num frameDuration = 1.0 / _frameRate;

      while (_play && _frameTime >= frameDuration)
      {
        var lastFrame = _currentFrame;
        var nextFrame = _loop ? (lastFrame + 1) % totalFrames : min(lastFrame + 1, totalFrames - 1);

        _currentFrame = nextFrame;
        _frameTime -= frameDuration;

        // dispatch progress event on every new frame

        if (lastFrame != nextFrame) {

          _dispatchEventInternal(_progressEvent, this, this, EventPhase.AT_TARGET);
          if (_currentFrame != nextFrame) return true;
        }

        // dispatch complete event only on last frame

        if (lastFrame != nextFrame && nextFrame == totalFrames - 1 && _loop == false) {

          _dispatchEventInternal(_completeEvent, this, this, EventPhase.AT_TARGET);
          if (_currentFrame != nextFrame) return true;
        }
      }
    }

    return true;
  }


  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {

    BitmapData bitmapData = _bitmapDatas[_currentFrame];
    return _getBoundsTransformedHelper(matrix, bitmapData.width, bitmapData.height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {

    BitmapData bitmapData = _bitmapDatas[_currentFrame];

    if (localX >= 0 && localY >= 0 && localX < bitmapData.width && localY < bitmapData.height)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var bitmapData = _bitmapDatas[_currentFrame];
    if (bitmapData is! BitmapData) return; // dart2js_hint

    // ToDo: The dart2js hint above is necessary to get a good translation
    // of "BitmapData.render". The type check is a little bit expensive,
    // so maybe we can find a better solution. It is strange because the
    // type of "renderState" should have more effect on the dart2js
    // compilation anyway!?!

    if (clipRectangle == null)
      bitmapData.render(renderState);
    else
      bitmapData.renderClipped(renderState, clipRectangle);
  }

}
