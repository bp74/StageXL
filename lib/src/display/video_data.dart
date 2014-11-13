part of stagexl.display;

class VideoData {

  VideoElement _video;

  int _width = 0;
  int _height = 0;

  //-------------------------------------------------------------------------------------------------
  // Create a new videoData based on an existing VideoElement

  VideoData(VideoElement video) {

    _width = video.width;
    _height = video.height;

    _video = video;
  }

  //-------------------------------------------------------------------------------------------------
  // Create the very first VideoElement in the dom
  // It would later be used to know the width and
  // height of the cloned videoData objects

  static Future<VideoData> load(String url, {
        bool mp4: true, bool ogg: true, bool webm: true}) {

    var video = new VideoElement();
    var videoUrls = _getOptimalVideoUrls(url, mp4, ogg, webm);
    var loadCompleter = new Completer<VideoData>();

    // necessary to get videoWidth and videoHeight
    video.style.display = 'none';
    html.document.body.children.add(video);

    if (videoUrls.length == 0) {
      loadCompleter.completeError(new StateError("No url provided."));
    }

    StreamSubscription onCanPlaySubscription;
    StreamSubscription onErrorSubscription;

    onCanPlay(event) {
      onCanPlaySubscription.cancel();
      onErrorSubscription.cancel();

      video.width = video.videoWidth;
      video.height = video.videoHeight;

      var videoData = new VideoData(video);

      loadCompleter.complete(videoData);
    };

    onError(event) {
      if (videoUrls.length > 0) {
        video.src = videoUrls.removeAt(0);
        video.load();
      } else {
        onCanPlaySubscription.cancel();
        onErrorSubscription.cancel();

        loadCompleter.completeError(new StateError("Failed to load video."));
      }
    };

    onCanPlaySubscription = video.onCanPlayThrough.listen(onCanPlay);
    onErrorSubscription = video.onError.listen(onError);

    video.src = videoUrls.removeAt(0);
    video.load();

    return loadCompleter.future;
  }

  //-------------------------------------------------------------------------------------------------
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

  //-------------------------------------------------------------------------------------------------
  // Determine which video files is the most likely
  // to play smoothly, based on the suported types
  // and formats available

  static List<String> _getOptimalVideoUrls(String primaryUrl, bool mp4, bool ogg, bool webm) {

    var availableTypes = _supportedTypes.toList();
    if (!webm) availableTypes.remove("webm");
    if (!mp4) availableTypes.remove("mp4");
    if (!ogg) availableTypes.remove("ogg");

    var urls = new List<String>();
    var regex = new RegExp(r"([A-Za-z0-9]+)$", multiLine:false, caseSensitive:true);
    var primaryMatch = regex.firstMatch(primaryUrl);
    if (primaryMatch == null) return urls;
    if (availableTypes.remove(primaryMatch.group(1))) urls.add(primaryUrl);

      for(var availableType in availableTypes) {
        urls.add(primaryUrl.replaceAll(regex, availableType));
      }

    return urls;
  }

  //-------------------------------------------------------------------------------------------------
  // Clone the VideoElement (_video) Object
  // so it can be played independantly from
  // the previous base VideoElement

  VideoElement cloneVideoElement() {
    var video = _video.clone(true);
    video..width = _width
      ..height = _height;

    return video;
  }

  //-------------------------------------------------------------------------------------------------
  // Geters

  int get width => _width;
  int get height => _height;

}
