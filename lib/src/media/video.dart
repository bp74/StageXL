part of stagexl.media;

/// The Video will be rendered to a RenderTexture, therefore it will work
/// the same way as any other static BitmapData content. Please look at the
/// sample below to see how it works:
///
///     var resourceManager = new ResourceManager();
///     resourceManager.addVideo("vid1", "video.webm");
///     resourceManager.load().then((_) {
///       var video = resourceManager.getVideo("vid1");
///       var videoObject = new VideoObject(video);
///
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
  bool autoplay = false;

  Video(this.videoElement) {
    videoElement.onEnded.listen(_onEnded);
  }

  static VideoLoadOptions defaultLoadOptions = new VideoLoadOptions(mp4:true, webm:true, ogg:true);
  static VideoLoadOptions defaultDataLoadOptions = new VideoLoadOptions(mp4:true, webm:true, ogg:true, loadData:true);

  static Future<Video> load(String url, [VideoLoadOptions videoLoadOptions = null]) {

    if (videoLoadOptions == null) videoLoadOptions = Video.defaultLoadOptions;

    var videoElement = new VideoElement();
    var video = new Video(videoElement);
    var videoUrls = _getOptimalVideoUrls(url, videoLoadOptions);
    var loadCompleter = new Completer<Video>();

    if (videoUrls.length == 0) {
      loadCompleter.completeError(new StateError("No url provided."));
      return loadCompleter.future;
    }

    // necessary to get videoWidth and videoHeight
    videoElement.style.display = 'none';
    document.body.children.add(videoElement);

    StreamSubscription onCanPlaySubscription;
    StreamSubscription onErrorSubscription;

    void onCanPlay(event) {
      onCanPlaySubscription.cancel();
      onErrorSubscription.cancel();

      videoElement.width = videoElement.videoWidth;
      videoElement.height = videoElement.videoHeight;

      loadCompleter.complete(video);
    };

    void onError(event) {
      if (videoUrls.length > 0) {
        videoElement.src = videoUrls.removeAt(0);
        videoElement.load();
      } else {
        onCanPlaySubscription.cancel();
        onErrorSubscription.cancel();
        loadCompleter.completeError(new StateError("Failed to load video."));
      }
    };

    onCanPlaySubscription = videoElement.onCanPlayThrough.listen(onCanPlay);
    onErrorSubscription = videoElement.onError.listen(onError);

    videoElement.preload = "auto";
    videoElement.src = videoUrls.removeAt(0);
    videoElement.load();

    return loadCompleter.future;
  }


  static Future<Video> loadDataUrl(String url, [VideoLoadOptions videoLoadOptions = null]) {
    if (videoLoadOptions == null) videoLoadOptions = Video.defaultLoadOptions;

    VideoElement videoElement;

    var videoUrls = _getOptimalVideoUrls(url, videoLoadOptions);

    var loadCompleter = new Completer<Video>();

    var onCanPlaySubscription;
    var onErrorSubscription;

    onCanPlay(event) {
      onCanPlaySubscription.cancel();
      onErrorSubscription.cancel();

      var video = new Video(videoElement);
      videoElement.width = videoElement.videoWidth;
      videoElement.height = videoElement.videoHeight;

      loadCompleter.complete(video);
    };

    onData(HttpRequest request) {
      FileReader reader = new FileReader();
      reader.readAsDataUrl(request.response);

      reader.onLoadEnd.first.then((e){
        if(reader.readyState != FileReader.DONE) {
          throw 'Error while reading ${url}';
        }

        videoElement = new VideoElement();

        onCanPlaySubscription = videoElement.onCanPlayThrough.listen(onCanPlay);
        onErrorSubscription = videoElement.onError.listen((_){
          loadCompleter.completeError(new StateError("Failed to create video with data."));
        });

        videoElement.preload = "auto";
        videoElement.src = reader.result;
        videoElement.load();
      });
    };

    onError(event) {
      if (videoUrls.length > 0) {
        HttpRequest.request(videoUrls.removeAt(0), responseType: 'blob')
          .then(onData)
          .catchError(onError);
      } else {
        loadCompleter.completeError(new StateError("Failed to load uri."));
      }
    };
    HttpRequest.request(videoUrls.removeAt(0), responseType: 'blob')
      .then(onData)
      .catchError(onError);

    return loadCompleter.future;
  }


  //-------------------------------------------------------------------------------------------------
  // Clone the VideoElement
  // so it can be played independantly from
  // the previous base Video

  Video clone() {
    var video = videoElement.clone(true);
    video.width = videoElement.videoWidth;
    video.height = videoElement.videoHeight;

    video.load();

    return new Video(video);
  }


  //-------------------------------------------------------------------------------------------------
  // video controls methods :
  // more or less direct forward to the
  // VideoElement html api methods

  bool get isPlaying => !videoElement.paused;

  void play() {
    if (!isPlaying) {
      videoElement.play();
    }
  }

  void pause() {
    if (isPlaying) {
      videoElement.pause();
    }
  }

  bool get muted => videoElement.muted;
  void set muted(bool muted) {
    videoElement.muted = muted;
  }

  num get volume => videoElement.volume;
  void set volume(num volume) {
    videoElement.volume = volume;
  }

  //-----------------------------------------------------------------------------------------------
  // event front VideoElement api

  ElementStream<Event> get onEnded => videoElement.onEnded;
  ElementStream<Event> get onPause => videoElement.onPause;
  ElementStream<Event> get onPlay => videoElement.onPlay;
  ElementStream<Event> get onError => videoElement.onError;

  //-----------------------------------------------------------------------------------------------

  void _onEnded(Event event) {
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

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------
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

  //-----------------------------------------------------------------------------------------------
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
