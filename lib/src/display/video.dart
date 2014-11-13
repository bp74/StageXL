part of stagexl.display;

class Video extends DisplayObject {

  RenderTexture _renderTexture;
  RenderTextureQuad _renderTextureQuad;

  VideoElement _video;
  VideoData _videoData;

  bool _isReady = false;
  num _nextFrameTime = 0;
  num _frameRateDelay;
  bool _loop;

  Video(VideoData videoData, {
      bool autoplay: false, bool loop: false,
      int frameRate: 30, num pixelRatio: 1.0}) {
    // we use the VideoData to get
    // a unique and standalone videoElement
    // dedicated to this Video
    _videoData = videoData;
    _video = _videoData.cloneVideoElement();

    _video.autoplay = autoplay;
    _loop = loop;

    _renderTexture = new RenderTexture.fromVideo(_video, pixelRatio);
    _renderTextureQuad = _renderTexture.quad;

    _frameRateDelay = 1 / frameRate;

    _video.onEnded.listen(_onVideoEnded);
    _video.onPlay.listen(_resetFrameTime);
  }

  //---------------------------------------------------------------------------

  void _onVideoEnded(e) {
    _video.pause();
    _video.currentTime = 0;
    // we autoloop manualy to avoid a bug in some browser :
    // http://stackoverflow.com/questions/17930964/
    //
    // for some browser the video should even be served with
    // a 206 result (partial content) and not a simple 200
    // http://stackoverflow.com/a/9549404/1537501
    if(_loop) {
      _video.play();
    }
  }

  void _resetFrameTime(e) {
    // ensure to draw the a frame in the canvas asap after play.
    _nextFrameTime = 0;
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, _videoData.width, _videoData.height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    // We override the hitTestInput method for optimal performance.
    if (localX < 0.0 || localX >= _videoData.width) return null;
    if (localY < 0.0 || localY >= _videoData.height) return null;
    return this;
  }

  //---------------------------------------------------------------------------

  RenderTexture get renderTexture => _renderTextureQuad.renderTexture;
  RenderTextureQuad get renderTextureQuad => _renderTextureQuad;

  //-------------------------------------------------------------------------------------------------
  // DisplayObject render method arrive here
  // this method refresh the current video
  // frame in the intermediary canvas in order
  // to change the bitmap shown into the StageXL
  // canvas
  @override
  void render(RenderState renderState) {

    var videoTime = _video.currentTime;
    if ((_nextFrameTime <= videoTime && !_video.paused) || !_isReady) {
      _isReady = _video.readyState > 3;

      _nextFrameTime = videoTime + _frameRateDelay;

      _renderTexture.updateVideoCanvas(_video);
      _renderTextureQuad = _renderTexture.quad;
    }

    renderState.renderQuad(_renderTextureQuad);
  }
  //-------------------------------------------------------------------------------------------------
  // video controls methods :
  // more or less direct forward to the
  // VideoElement html api methods

  void play() {
    if (_video.paused) {
      _video.play();
    }
  }

  void pause() {
    if (!_video.paused) {
      _video.pause();
    }
  }

  bool get muted => _video.muted;
  void set muted(bool muted) {
    _video.muted = muted;
  }

  bool get loop => _loop;
  void set loop(bool loop) {
    _loop = loop;
  }

  num get volume => _video.volume;
  void set volume(num volume) {
    _video.volume = volume;
  }
}
