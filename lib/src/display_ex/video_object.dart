part of stagexl.display_ex;

/// The VideoObject class is a display object to show and control videos.
///
/// To show the video just add the VideoObject to the display list. Use
/// the [play] abd [pause] method to control the video. Please note that
/// the VideoObject will create a clone of the video and therefore the
/// playback is independent from other VideoObject instances.
///
///     var resourceManager = new ResourceManager();
///     resourceManager.addVideo("vid1", "video.webm");
///     resourceManager.load().then((_) {
///       var video = resourceManager.getVideo("vid1");
///       var videoObject = new VideoObject(video);
///       stage.addChild(videoObject);
///       videoObject.play();
///     });
///

class VideoObject extends InteractiveObject {

  Video _video;
  RenderTexture _renderTexture;

  static const EventStreamProvider<Event> endedEvent = const EventStreamProvider<Event>("videoEnded");
  static const EventStreamProvider<Event> pauseEvent = const EventStreamProvider<Event>("videoPause");
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>("videoError");
  static const EventStreamProvider<Event> playEvent  = const EventStreamProvider<Event>("videoPlay");

  EventStream<Event> get onEnded => VideoObject.endedEvent.forTarget(this);
  EventStream<Event> get onPause => VideoObject.pauseEvent.forTarget(this);
  EventStream<Event> get onError => VideoObject.errorEvent.forTarget(this);
  EventStream<Event> get onPlay  => VideoObject.playEvent.forTarget(this);

  VideoObject(Video baseVideo, [bool autoplay = false, num pixelRatio = 1.0]) {

    var video = baseVideo.clone();
    var videoElement = video.videoElement;

    videoElement.onEnded.listen((e) => this.dispatchEvent(new Event("videoEnded")));
    videoElement.onPause.listen((e) => this.dispatchEvent(new Event("videoPause")));
    videoElement.onError.listen((e) => this.dispatchEvent(new Event("videoError")));
    videoElement.onPlay.listen((e) => this.dispatchEvent(new Event("videoPlay")));

    _video = video;
    _renderTexture = new RenderTexture.fromVideoElement(videoElement, pixelRatio);

    if (autoplay) play();
  }

  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, _video.videoElement.width, _video.videoElement.height);
  }

  @override
  render(RenderState renderState) {
    // only render when the videoElement have a frame to give us
    // avoid webGL error and black frame
    if (_video.videoElement.readyState >= 3) {
      renderState.renderQuad(_renderTexture.quad);
    }
  }

  //----------------------------------------------------------------------------

  Video get video => _video;
  RenderTexture get renderTexture => _renderTexture;

  void play() => _video.play();
  void pause() => _video.pause();

  bool get muted => _video.muted;
  void set muted(muted) => _video.muted = muted;

  bool get loop => _video.loop;
  void set loop(loop) => _video.loop = loop;

  num get volume => _video.volume;
  void set volume(volume) => _video.volume = volume;

  bool get isPlaying => _video.isPlaying;
}
