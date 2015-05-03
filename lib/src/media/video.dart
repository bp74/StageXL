part of stagexl.media;

/// The Video class is used to load and control videos.
///
/// The video will be rendered to a RenderTexture and therefore can be
/// used like any other static image content. The sample below creates
/// a BitmapData from the video and also a VideoObject display object.
///
///     var resourceManager = new ResourceManager();
///     resourceManager.addVideo("vid1", "video.webm");
///     resourceManager.load().then((_) {
///
///       var video = resourceManager.getVideo("vid1");
///       video.play();
///
///       // create a BitmapData used with a Bitmap
///       var bitmapData = new BitmapData.fromVideoElement(video.videoElement);
///       var bitmap = new Bitmap(bitmapData);
///       stage.addChild(bitmap);
///
///       // create a convenient VideoObject display object
///       var videoObject = new VideoObject(video);
///       stage.addChild(videoObject);
///     });
///
/// Please note that a video can be used with more than one display objects.
/// To control the video independantly from each other the [clone] method
/// creates a clone of this instance.
///
///     video.clone().then((newVideo) => {
///       var videoObject = new VideoObject(newVideo);
///       stage.addChild(videoObject);
///     });
///
/// If the video codec of the file is not supported by the browser, the
/// runtime will automatically fallback to a different codec. Therefore
/// please provide the same video with different codecs. The supported
/// codecs are webm, mp4 and ogg.

class Video {

  final VideoElement videoElement;
  bool loop = false;

  final _endedEvent = new StreamController<Video>.broadcast();
  final _pauseEvent = new StreamController<Video>.broadcast();
  final _errorEvent = new StreamController<Video>.broadcast();
  final _playEvent = new StreamController<Video>.broadcast();

  Video._(this.videoElement) {
    videoElement.onEnded.listen(_onEnded);
    videoElement.onPause.listen(_onPause);
    videoElement.onError.listen(_onError);
    videoElement.onPlay.listen(_onPlay);
  }

  Stream<Video> get onEnded => _endedEvent.stream;
  Stream<Video> get onPause => _pauseEvent.stream;
  Stream<Video> get onError => _errorEvent.stream;
  Stream<Video> get onPlay => _playEvent.stream;

  //---------------------------------------------------------------------------

  /// The default video load options are used if no custom video load options
  /// are provided for the [load] method. This default video load options
  /// enable all supported video file formats: mp4, webm and ogg.

  static VideoLoadOptions defaultLoadOptions = new VideoLoadOptions();

  /// Use this method to load a video from a given [url]. If you don't
  /// provide [videoLoadOptions] the [defaultLoadOptions] will be used.
  ///
  /// Please note that on most mobile devices the load method must be called
  /// from an input event like MouseEvent or TouchEvent. The load method will
  /// never complete if you call it elsewhere in your code. The same is true
  /// for the ResourceManager.addVideo method.

  static Future<Video> load(String url, [VideoLoadOptions videoLoadOptions]) async {

    if (videoLoadOptions == null) {
      videoLoadOptions = Video.defaultLoadOptions;
    }

    var loadData = videoLoadOptions.loadData;
    var corsEnabled = videoLoadOptions.corsEnabled;
    var videoUrls = videoLoadOptions.getOptimalVideoUrls(url);

    try {
      var videoLoader = new VideoLoader(videoUrls, loadData, corsEnabled);
      var videoElement = await videoLoader.done;
      return new Video._(videoElement);
    } catch (e) {
      throw new StateError("Failed to load video.");
    }
  }

  /// Clone this video instance and the underlying HTML VideoElement to play
  /// the new video independantly from this video.

  Future <Video> clone() {

    VideoElement videoElement = this.videoElement.clone(true);
    Completer<Video> completer = new Completer<Video>();
    StreamSubscription onCanPlaySubscription = null;
    StreamSubscription onErrorSubscription = null;

    void onCanPlay(e) {
      var video = new Video._(videoElement);
      video.volume = this.volume;
      video.muted = this.muted;
      onCanPlaySubscription.cancel();
      onErrorSubscription.cancel();
      completer.complete(video);
    }

    void onError(e) {
      onCanPlaySubscription.cancel();
      onErrorSubscription.cancel();
      completer.completeError(e);
    }

    onCanPlaySubscription = videoElement.onCanPlay.listen(onCanPlay);
    onErrorSubscription = videoElement.onError.listen(onError);
    return completer.future;
  }

  /// Play the video.

  void play() {
    if (!isPlaying) {
      videoElement.play();
    }
  }

  /// Pause the video.

  void pause() {
    if (isPlaying) {
      videoElement.pause();
    }
  }

  /// Returns if the video is playing or not.

  bool get isPlaying => !videoElement.paused;

  /// Get or set if the video is muted.

  bool get muted => videoElement.muted;
  void set muted(bool muted) {
    videoElement.muted = muted;
  }

  /// Get or set the volume of the video.

  num get volume => videoElement.volume;
  void set volume(num volume) {
    videoElement.volume = volume;
  }

  /// Get or set the current time (playback position) of the video.

  num get currentTime => videoElement.currentTime;
  void set currentTime(num value) {
    videoElement.currentTime = value;
  }

  //---------------------------------------------------------------------------

  void _onEnded(html.Event event) {

    _endedEvent.add(this);

    // we autoloop manualy to avoid a bug in some browser :
    // http://stackoverflow.com/questions/17930964/
    //
    // for some browser the video should even be served with
    // a 206 result (partial content) and not a simple 200
    // http://stackoverflow.com/a/9549404/1537501

    if(this.loop) {
      videoElement.currentTime = 0.0;
      videoElement.play();
    } else {
      videoElement.currentTime = 0.0;
      videoElement.pause();
    }
  }

  void _onPause(html.Event event) {
    _pauseEvent.add(this);
  }

  void _onError(html.Event event) {
    _errorEvent.add(this);
  }

  void _onPlay(html.Event event) {
    _playEvent.add(this);
  }

}
