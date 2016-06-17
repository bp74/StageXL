part of stagexl.media;

/// The SoundLoadOptions class contains different options to configure
/// how audio files are loaded from the server.
///
/// The [Sound.defaultLoadOptions] object is the default for all
/// loading operations if no SoundLoadOptions are provided to the
/// [Sound.load] function.

class SoundLoadOptions {

  /// The application provides *mp3* files as an option to load audio files.

  bool mp3 = true;

  /// The application provides *mp4* files as an option to load audio files.

  bool mp4 = true;

  /// The application provides *ogg* files as an option to load audio files.

  bool ogg = true;
  
  /// The application provides *opus* files as an option to load audio files.

  bool opus = false;

  /// The application provides *ac3* files as an option to load audio files.

  bool ac3 = true;

  /// The application provides *wav* files as an option to load audio files.

  bool wav = true;

  /// A list of alternative urls for sound samples in the case where the
  /// primary url does not work or the file type is not supported by the
  /// browser. If this value is null, the alternative urls are calculated
  /// automatically based on the mp3, mp4, ogg, opus, ac3 and wav properties.

  List<String> alternativeUrls;

  /// Ignore loading errors and use a silent audio sample instead.

  bool ignoreErrors = true;

  /// Use CORS to download the audio file. This is often necessary when you have
  /// to download audio files from a third party server.

  bool corsEnabled = false;

  /// Ignore the [SoundMixer.engine] and use this sound engine instead.

  SoundEngine engine;

  //---------------------------------------------------------------------------

  /// Create a deep clone of this [SoundLoadOptions].

  SoundLoadOptions clone() {
    var options = new SoundLoadOptions();
    var urls = this.alternativeUrls;
    options.mp3 = this.mp3;
    options.mp4 = this.mp4;
    options.ogg = this.ogg;
    options.opus = this.opus;
    options.ac3 = this.ac3;
    options.wav = this.wav;
    options.engine = this.engine;
    options.alternativeUrls = urls == null ? null : urls.toList();
    options.ignoreErrors = this.ignoreErrors;
    options.corsEnabled = this.corsEnabled;
    return options;
  }

  //---------------------------------------------------------------------------

  /// Determine which audio files are the most likely to play smoothly,
  /// based on the supported types and formats available.

  List<String> getOptimalAudioUrls(String primaryUrl) {

    var availableTypes = AudioLoader.supportedTypes.toList();
    if (!this.mp3) availableTypes.remove("mp3");
    if (!this.mp4) availableTypes.remove("mp4");
    if (!this.ogg) availableTypes.remove("ogg");
    if (!this.opus) availableTypes.remove("opus");
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
