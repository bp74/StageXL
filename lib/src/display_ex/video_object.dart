part of stagexl.display_ex;

/// The VideoObject class is a display object to show and control videos.
///
/// To show the video just add the VideoObject to the display list. Use
/// the [play] abd [pause] method to control the video.
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

  static const EventStreamProvider<Event> endedEvent = const EventStreamProvider<Event>("videoEnded");
  static const EventStreamProvider<Event> pauseEvent = const EventStreamProvider<Event>("videoPause");
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>("videoError");
  static const EventStreamProvider<Event> playEvent  = const EventStreamProvider<Event>("videoPlay");

  EventStream<Event> get onEnded => VideoObject.endedEvent.forTarget(this);
  EventStream<Event> get onPause => VideoObject.pauseEvent.forTarget(this);
  EventStream<Event> get onError => VideoObject.errorEvent.forTarget(this);
  EventStream<Event> get onPlay  => VideoObject.playEvent.forTarget(this);

  Video _video;
  RenderTexture _renderTexture;
  RenderTextureQuad _renderTextureQuad;

  VideoObject(Video video, [bool autoplay = false]) {

    _video = video;
    _renderTexture = new RenderTexture.fromVideoElement(video.videoElement);
    _renderTextureQuad = _renderTexture.quad;

    var videoElement = video.videoElement;
    videoElement.onEnded.listen((e) => this.dispatchEvent(new Event("videoEnded")));
    videoElement.onPause.listen((e) => this.dispatchEvent(new Event("videoPause")));
    videoElement.onError.listen((e) => this.dispatchEvent(new Event("videoError")));
    videoElement.onPlay.listen((e) => this.dispatchEvent(new Event("videoPlay")));

    if (autoplay) play();
  }

  //----------------------------------------------------------------------------

  Video get video => _video;
  RenderTexture get renderTexture => _renderTexture;
  RenderTextureQuad get renderTextureQuad => _renderTextureQuad;

  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    var width = _renderTextureQuad.targetWidth;
    var height = _renderTextureQuad.targetHeight;
    return new Rectangle<num>(0.0, 0.0, width, height);
  }

  @override
  void render(RenderState renderState) {
    renderState.renderQuad(_renderTextureQuad);
  }

  @override
  void renderFiltered(RenderState renderState) {
    renderState.renderQuadFiltered(_renderTextureQuad, this.filters);
  }

  //----------------------------------------------------------------------------

  void play() {
    video.play();
  }

  void pause() {
    video.pause();
  }

  bool get muted => video.muted;
  void set muted(muted) {
    video.muted = muted;
  }

  bool get loop => video.loop;
  void set loop(loop) {
    video.loop = loop;
  }

  num get volume => video.volume;
  void set volume(volume) {
    video.volume = volume;
  }

  bool get isPlaying => video.isPlaying;
}
