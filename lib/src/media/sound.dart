part of stagexl.media;

abstract class Sound {

  Sound() {
    var initEngine = SoundMixer.engine;
  }

  /// Get a list of the audio types supported by the browser.

  static List<String> get supportedTypes {
    return AudioLoader.supportedTypes.toList(growable: false);
  }

  /// The default loading options for the [Sound.load] method.

  static SoundLoadOptions defaultLoadOptions = new SoundLoadOptions(
      mp3:true, mp4:true, ogg:true, ac3: true, wav:true);

  /// Loads a sound from an url.
  ///
  /// The file extension in the url will be replaced according to the browser's
  /// capability to playback certain kinds of audio types. For example if the
  /// url ends with the 'mp3' extension and the browser does not support mp3
  /// playback, the file extension will be replaced with 'ogg' or 'ac3'. You
  /// can customize this feature by changing the [soundLoadOptions].

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions = null]) {
    switch(SoundMixer.engine) {
      case "WebAudioApi" : return WebAudioApiSound.load(url, soundLoadOptions);
      case "AudioElement": return AudioElementSound.load(url, soundLoadOptions);
      default            : return MockSound.load(url, soundLoadOptions);
    }
  }

  /// Loads a sound encoded in the data URI scheme.
  ///
  /// Please be aware that browsers do support different kinds of audio types.
  /// You can get a list of supported types here: [Sound.supportedTypes]
  ///
  ///     var future = Sound.loadDataUri("data:audio/mpeg;base64,<data>");
  ///     future.then((Sound sound)  => sound.play());

  static Future<Sound> loadDataUri(String dataUri) {
    switch(SoundMixer.engine) {
      case "WebAudioApi" : return WebAudioApiSound.loadDataUri(dataUri);
      case "AudioElement": return AudioElementSound.loadDataUri(dataUri);
      default            : return new Future<Sound>.value(new MockSound._());
    }
  }

  //-------------------------------------------------------------------------------------------------

  num get length;

  SoundChannel play([bool loop = false, SoundTransform soundTransform]);

  SoundChannel playSegment(num startTime, num duration, [
                           bool loop = false, SoundTransform soundTransform]);
}
