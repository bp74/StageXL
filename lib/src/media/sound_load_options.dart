part of stagexl.media;

class SoundLoadOptions {

  /// The application provides *mp3* files as an option to load audio files.
  bool mp3;

  /// The application provides *mp4* files as an option to load audio files.
  bool mp4;

  /// The application provides *ogg* files as an option to load audio files.
  bool ogg;

  /// The application provides *ac3* files as an option to load audio files.
  bool ac3;

  /// The application provides *wav* files as an option to load audio files.
  bool wav;

  /// A list of alternative urls for sound samples in the case where the
  /// primary url does not work or the file type is not supported by the
  /// browser. If this value is null, the alternative urls are calcualted
  /// automatically based on the mp3, mp4, ogg, ac3 and wav properties.
  List<String> alternativeUrls;

  /// Ignore loading errors and use a silent audio sample instead.
  bool ignoreErrors;

  /// Use CORS to download the video. This is often necessary when you have
  /// to download video from a third party server.
  bool corsEnabled;

  //---------------------------------------------------------------------------

  SoundLoadOptions({
    this.mp3: false,
    this.mp4: false,
    this.ogg: false,
    this.ac3: false,
    this.wav: false,
    this.alternativeUrls: null,
    this.ignoreErrors: true,
    this.corsEnabled: false
  });

  SoundLoadOptions clone() => new SoundLoadOptions(
      mp3: this.mp3, mp4: this.mp4, ogg: this.ogg, ac3: this.ac3, wav: this.wav,
      alternativeUrls: this.alternativeUrls, ignoreErrors: this.ignoreErrors);


  //-------------------------------------------------------------------------------------------------

  /// Determine which audio files is the most likely to play smoothly,
  /// based on the supported types and formats available.

  List<String> getOptimalAudioUrls(String primaryUrl) {

    var availableTypes = AudioLoader.supportedTypes.toList();
    if (!this.mp3) availableTypes.remove("mp3");
    if (!this.mp4) availableTypes.remove("mp4");
    if (!this.ogg) availableTypes.remove("ogg");
    if (!this.ac3) availableTypes.remove("ac3");
    if (!this.wav) availableTypes.remove("wav");

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