part of stagexl.display_ex;

/// A display object to play sprite sheet animations.
///
/// Sprite sheet animations are a set of images to simulate a
/// moving/animated body.

class FlipBook extends InteractiveObject implements Animatable {

  List<BitmapData> _bitmapDatas;
  List<double> _frameDurations;

  int _currentFrame;
  double _frameTime;

  bool _play;
  bool _loop;
  Event _progressEvent;
  Event _completeEvent;

  //---------------------------------------------------------------------------

  FlipBook(List<BitmapData> bitmapDatas, [
      int frameRate = 30, bool loop = true]) {

    _bitmapDatas = bitmapDatas;
    _frameDurations = new List.filled(_bitmapDatas.length, 1.0 / frameRate);

    _currentFrame = 0;
    _frameTime = null;
    _play = false;
    _loop = loop;
    _progressEvent = new Event(Event.PROGRESS);
    _completeEvent = new Event(Event.COMPLETE);
  }

  //---------------------------------------------------------------------------

  static const EventStreamProvider<Event> progressEvent =
      const EventStreamProvider<Event>(Event.PROGRESS);

  static const EventStreamProvider<Event> completeEvent =
      const EventStreamProvider<Event>(Event.COMPLETE);

  EventStream<Event> get onProgress => FlipBook.progressEvent.forTarget(this);
  EventStream<Event> get onComplete => FlipBook.completeEvent.forTarget(this);

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  int get currentFrame => _currentFrame;
  int get totalFrames => _bitmapDatas.length;

  bool get loop => _loop;
  set loop(bool value) { _loop = value; }

  bool get playing => _play;

  List<num> get frameDurations => _frameDurations;

  set frameDurations(List<num> value) {
    for (var i = 0; i < _frameDurations.length; i++) {
      _frameDurations[i] = (i < value.length) ? value[i] : value.last;
    }
  }

  //---------------------------------------------------------------------------

  void gotoAndPlay(int frame) {
    _currentFrame = min(max(frame, 0), totalFrames - 1);
    this.play();
  }

  void gotoAndStop(int frame) {
    _currentFrame = min(max(frame, 0), totalFrames - 1);
    this.stop();
  }

  void play() {
    if (_play == false) {
      _play = true;
      _frameTime = null;
    }
  }

  void stop() {
    if (_play == true) {
      _play = false;
      _frameTime = null;
      this.dispatchEvent(_completeEvent);
    }
  }

  //---------------------------------------------------------------------------

  /// Play the animation with the [juggler].
  ///
  /// If the optional [gotoFrame] argument is specified, the animation will
  /// start at the given frame number, otherwise the animation will start at
  /// the current frame.
  ///
  /// If the optional [stopFrame] argument is specified, the animation will
  /// stop at the given frame number, otherwise the animation will continue
  /// to run depending on the [loop] configuration.
  ///
  /// The returned future is completed on the first occurrence of:
  ///
  ///  * the animation does not loop and the last frame was reached.
  ///  * the optionally specified argument [stopFrame] was reached.
  ///  * the [stop] method was called.

  Future playWith(Juggler juggler, {int gotoFrame, int stopFrame}) {

    _play = true;
    _frameTime = null;
    _currentFrame = gotoFrame ?? currentFrame;

    var completed = this.onComplete.first;
    var currentTime = juggler.elapsedTime;
    var subscription = juggler.onElapsedTimeChange.listen((elapsedTime) {
      advanceTime(elapsedTime - currentTime);
      currentTime = elapsedTime;
      if (currentFrame == stopFrame) this.stop();
    });

    completed.then((_) => subscription.cancel());
    return completed;
  }

  //---------------------------------------------------------------------------

  void nextFrame() {

    var lastFrame = totalFrames - 1;
    var nextFrame = currentFrame + 1;
    if (nextFrame > lastFrame) nextFrame = loop ? 0 : lastFrame;

    _play = false;
    _frameTime = null;
    _currentFrame = nextFrame;
  }

  void prevFrame() {

    var lastFrame = totalFrames - 1;
    var prevFrame = currentFrame - 1;
    if (prevFrame < 0) prevFrame = loop ? lastFrame : 0;

    _play = false;
    _frameTime = null;
    _currentFrame = prevFrame;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  bool advanceTime(num time) {

    if (_play == false) return true;

    if (_frameTime == null) {

      _frameTime = 0.0;
      this.dispatchEvent(_progressEvent);

    } else {

      _frameTime += time;

      while (_play) {

        var frameDuration = _frameDurations[_currentFrame];
        if (frameDuration > _frameTime) break;

        var lastFrame = this.totalFrames - 1;
        var prevFrame = _currentFrame;
        var nextFrame = _currentFrame + 1;
        if (nextFrame > lastFrame) nextFrame = loop ? 0 : lastFrame;

        _currentFrame = nextFrame;
        _frameTime -= frameDuration;

        // dispatch progress event on every new frame
        if (nextFrame != prevFrame) {
          this.dispatchEvent(_progressEvent);
          if (_currentFrame != nextFrame) return true;
        }

        // dispatch complete event only on last frame
        if (!loop && nextFrame == lastFrame && nextFrame != prevFrame) {
          this.dispatchEvent(_completeEvent);
          if (_currentFrame != nextFrame) return true;
        }
      }
    }

    return true;
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    var bitmapData = _bitmapDatas[_currentFrame];
    return new Rectangle<num>(0.0, 0.0, bitmapData.width, bitmapData.height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    var bitmapData = _bitmapDatas[_currentFrame];
    if (localX < 0.0 || localX >= bitmapData.width) return null;
    if (localY < 0.0 || localY >= bitmapData.height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {
    var bitmapData = _bitmapDatas[_currentFrame];
    bitmapData.render(renderState);
  }

  @override
  void renderFiltered(RenderState renderState) {
    var bitmapData = _bitmapDatas[_currentFrame];
    var renderTextureQuad = bitmapData.renderTextureQuad;
    renderState.renderTextureQuadFiltered(renderTextureQuad, this.filters);
  }
}
