part of stagexl.display_ex;

class VideoObject extends InteractiveObject {

  Video video;
  RenderTexture renderTexture;

  VideoObject(Video baseVideo, [bool autoplay = false, num pixelRatio = 1.0]) {
    video = baseVideo.clone();
    renderTexture = new RenderTexture.fromVideoElement(video.videoElement, pixelRatio);

    if (autoplay)
      play();
  }

  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, width, height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    // We override the hitTestInput method for optimal performance.
    if (localX < 0.0 || localX >= width) return null;
    if (localY < 0.0 || localY >= height) return null;
    return this;
  }

  @override
  render(RenderState renderState) {
    // only render when the videoElement have a frame to give us
    // avoid webGL error and black frame
    if (video.videoElement.readyState >= 3) {
      renderState.renderQuad(renderTexture.quad);
    }
  }

  //----------------------------------------------------------------------------

  void play() => video.play();
  void pause() => video.pause();

  bool get muted => video.muted;
  void set muted(muted) => video.muted = muted;

  bool get loop => video.loop;
  void set loop(loop) => video.loop = loop;

  bool get volume => video.volume;
  void set volume(volume) => video.volume = volume;


  int get width => ensureInt(video.videoElement.width);
  int get height => ensureInt(video.videoElement.height);

}
