part of stagexl.media;

class VideoLoadOptions {

  /// The application provides *mp4* files as an option to load video files.
  bool mp4;

  /// The application provides *webm* files as an option to load video files.
  bool webm;

  /// The application provides *ogg* files as an option to load video files.
  bool ogg;

  /// A list of alternative urls for video files in the case where the
  /// primary url does not work or the file type is not supported by the
  /// browser. If this value is null, the alternative urls are calcualted
  /// automatically based on the mp3, mp4, ogg, ac3 and wav properties.
  List<String> alternativeUrls;

  /// Do not stream the video but download the video file as a whole.
  /// A DataUrl string will be used for the VideoElement source.
  bool loadData;

  /// Use CORS to download the video. This is often necessary when you have
  /// to download video from a third party server.
  bool corsEnabled;

  //---------------------------------------------------------------------------

  VideoLoadOptions({
      this.mp4: false,
      this.webm: false,
      this.ogg: false,
      this.alternativeUrls: null,
      this.loadData: false,
      this.corsEnabled: false
    });

  VideoLoadOptions clone() => new VideoLoadOptions(
      mp4: this.mp4, webm: this.webm, ogg: this.ogg,
      alternativeUrls: this.alternativeUrls,
      loadData: loadData);

  //---------------------------------------------------------------------------

  /// Determine which video files is the most likely to play smoothly,
  /// based on the supported types and formats available.

  List<String> getOptimalVideoUrls(String primaryUrl) {

    var availableTypes = VideoLoader.supportedTypes.toList();
    if (!this.webm) availableTypes.remove("webm");
    if (!this.mp4) availableTypes.remove("mp4");
    if (!this.ogg) availableTypes.remove("ogg");

    var urls = new List<String>();
    var regex = new RegExp(r"([A-Za-z0-9]+)$", multiLine:false, caseSensitive:true);
    var primaryMatch = regex.firstMatch(primaryUrl);
    if (primaryMatch == null) return urls;
    if (availableTypes.remove(primaryMatch.group(1))) urls.add(primaryUrl);

    if (this.alternativeUrls != null) {
      for(var alternativeUrl in this.alternativeUrls) {
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
