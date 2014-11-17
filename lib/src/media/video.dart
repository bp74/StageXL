part of stagexl.media;

/// The Video will be rendered to a RenderTexture, therefore it will work
/// the same way as any other static BitmapData content. Please look at the
/// sample below to see how it works:
///
///     var resourceManager = new ResourceManager();
///     resourceManager.addVideo("vid1", "video.webm");
///     resourceManager.load().then((_) {
///       var video = resourceManager.getVideo("vid1");
///       var bitmapData = new BitmapData.fromVideoElement(video.videoElement);
///       var bitmap = new Bitmap(bitmapData);
///       stage.addChild(bitmap);
///       video.play();
///     });
///
///  You can also use the more convenient VideoObject class. Please note that
///  the VideoObject will create a clone of the video and therefore the
///  playback is independent from other VideoObject instances.
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
/// If the video codec of the file is not supported by the browser, the
/// runtime will automatically fallback to a different codec. Therefore
/// please provide the same video with different codecs. The supported
/// codecs are webm, mp4 and ogg.

class Video {

  VideoElement videoElement;
  bool loop = false;

  final _endedEvent = new StreamController.broadcast();
  final _pauseEvent = new StreamController.broadcast();
  final _errorEvent = new StreamController.broadcast();
  final _playEvent = new StreamController.broadcast();

  Video._(this.videoElement) {
    videoElement.onEnded.listen(_onEnded);
    videoElement.onPause.listen(_onPause);
    videoElement.onError.listen(_onError);
    videoElement.onPlay.listen(_onPlay);
  }

  Stream get onEnded => _endedEvent.stream;
  Stream get onPause => _pauseEvent.stream;
  Stream get onError => _errorEvent.stream;
  Stream get onPlay => _playEvent.stream;

  //---------------------------------------------------------------------------

  /// The default video load options are used if no custom video load options
  /// are provided for the [load] method. This default video load options
  /// enable all supported video file formats: mp4, webm and ogg.

  static VideoLoadOptions defaultLoadOptions =
      new VideoLoadOptions(mp4:true, webm:true, ogg:true);

  /// Use this method to load a video from a given [url]. If you don't
  /// provide [videoLoadOptions] the [defaultLoadOptions] will be used.

  static Future<Video> load(String url, [
      VideoLoadOptions videoLoadOptions = null]) {

    if (videoLoadOptions == null) videoLoadOptions = Video.defaultLoadOptions;

    var videoUrls = _getOptimalVideoUrls(url, videoLoadOptions);
    var completer = new Completer<Video>();

    if (videoUrls.length == 0) {

      completer.completeError(new StateError("No url provided."));

    } else {

      var videoLoader = new VideoLoader(videoUrls, videoLoadOptions.loadData);
      videoLoader.done.then((VideoElement videoElement) {
        videoElement.width = videoElement.videoWidth;
        videoElement.height = videoElement.videoHeight;
        completer.complete(new Video._(videoElement));
      }).catchError((error) {
        completer.completeError(new StateError("Failed to load video."));
      });
    }

    return completer.future;
  }

  /// Clone this video instance and the underlying HTML VideoElement to play
  /// the new video independantly from this video.

  Video clone() {
    var videoElement = this.videoElement.clone(true);
    videoElement.width = this.videoElement.width;
    videoElement.height = this.videoElement.height;
    videoElement.load();
    return new Video._(videoElement);
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

  void _onEnded(Event event) {

    _endedEvent.add(null);

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

  void _onPause(Event event) {
    _pauseEvent.add(null);
  }

  void _onError(Event event) {
    _errorEvent.add(null);
  }

  void _onPlay(Event event) {
    _playEvent.add(null);
  }

  //---------------------------------------------------------------------------

  // list the video formats suported by the browser
  // H.264 | Webm | Ogg

  static final List<String> _supportedTypes = _getSupportedTypes();

  static List<String> _getSupportedTypes() {

    var supportedTypes = new List<String>();
    var video = new VideoElement();
    var valid = ["maybe", "probably"];

    if (valid.indexOf(video.canPlayType("video/webm", "")) != -1) supportedTypes.add("webm");
    if (valid.indexOf(video.canPlayType("video/mp4", "")) != -1) supportedTypes.add("mp4");
    if (valid.indexOf(video.canPlayType("video/ogg", "")) != -1) supportedTypes.add("ogg");

    print("StageXL video types : ${supportedTypes}");

    return supportedTypes;
  }

  // Determine which video files is the most likely
  // to play smoothly, based on the suported types
  // and formats available

  static List<String> _getOptimalVideoUrls(String primaryUrl, VideoLoadOptions videoLoadOptions) {

    var availableTypes = _supportedTypes.toList();
    if (!videoLoadOptions.webm) availableTypes.remove("webm");
    if (!videoLoadOptions.mp4) availableTypes.remove("mp4");
    if (!videoLoadOptions.ogg) availableTypes.remove("ogg");

    var urls = new List<String>();
    var regex = new RegExp(r"([A-Za-z0-9]+)$", multiLine:false, caseSensitive:true);
    var primaryMatch = regex.firstMatch(primaryUrl);
    if (primaryMatch == null) return urls;
    if (availableTypes.remove(primaryMatch.group(1))) urls.add(primaryUrl);

    if (videoLoadOptions.alternativeUrls != null) {
      for(var alternativeUrl in videoLoadOptions.alternativeUrls) {
        var alternativeMatch = regex.firstMatch(alternativeUrl);
        if (alternativeMatch == null) continue;
        if (availableTypes.contains(alternativeMatch.group(1))) urls.add(alternativeUrl);
      }
    } else {
      for(var availableType in availableTypes) {
        urls.add(primaryUrl.replaceAll(regex, availableType));
      }
    }

    return urls;
  }

}
