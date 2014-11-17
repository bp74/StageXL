part of stagexl.display_ex;

class VideoObject extends InteractiveObject {

  Video _video;
  RenderTexture _renderTexture;

  VideoObject(Video baseVideo, [bool autoplay = false, num pixelRatio = 1.0]) {
    _video = baseVideo.clone();
    _renderTexture = new RenderTexture.fromVideoElement(video.videoElement, pixelRatio);

    if (autoplay)
      play();
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

  void play() => _video.play();
  void pause() => _video.pause();

  bool get muted => _video.muted;
  void set muted(muted) => _video.muted = muted;

  bool get loop => _video.loop;
  void set loop(loop) => _video.loop = loop;

  bool get volume => _video.volume;
  void set volume(volume) => _video.volume = volume;

  bool get isPlaying => _video.isPlaying;

  //----------------------------------------------------------------------------
  //
  ElementStream<Event> get onEnded => _video.onEnded;
  ElementStream<Event> get onPause => _video.onPause;
  ElementStream<Event> get onPlay => _video.onPlay;
  ElementStream<Event> get onError => _video.onError;

}
