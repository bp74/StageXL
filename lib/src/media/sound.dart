part of stagexl.media;

abstract class Sound {

  Sound() {
    SoundMixer.engine = Sound.defaultLoadOptions.soundEngine;
    SoundMixer._initEngine();
  }

  /// Get a list of the audio types supported by the browser.

  static List<String> get supportedTypes {
    return AudioLoader.supportedTypes.toList(growable: false);
  }

  /// The default loading options for the [Sound.load] method.

  static SoundLoadOptions defaultLoadOptions = new SoundLoadOptions();

  /// Loads a sound from a file url.
  ///
  /// The file extension in the url will be replaced according to the browser's
  /// capability to playback certain kinds of audio types. For example if the
  /// url ends with the 'mp3' extension and the browser does not support mp3
  /// playback, the file extension will be replaced with 'ogg' or 'ac3'. You
  /// can customize this behavior by changing the [soundLoadOptions].
  ///
  ///     var future = Sound.load("assets/audio/hello.mp3");
  ///     future.then((Sound sound) => sound.play());

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions]) {
    switch(SoundMixer.engine) {
      case SoundEngines.WebAudioApi :
        return WebAudioApiSound.load(url, soundLoadOptions);
      case SoundEngines.AudioElement:
        return AudioElementSound.load(url, soundLoadOptions);
      default :
        return MockSound.load(url, soundLoadOptions);
    }
  }

  /// Loads a sound from a data url.
  ///
  /// Please be aware that browsers do support different kinds of audio types.
  /// You can get a list of supported types here: [Sound.supportedTypes]
  ///
  ///     var future = Sound.loadDataUrl("data:audio/mpeg;base64,<data>");
  ///     future.then((Sound sound) => sound.play());

  static Future<Sound> loadDataUrl(String dataUrl, [SoundLoadOptions soundLoadOptions]) {

    switch(SoundMixer.engine) {
      case SoundEngines.WebAudioApi:
        return WebAudioApiSound.loadDataUrl(dataUrl, soundLoadOptions);
      case SoundEngines.AudioElement:
        return AudioElementSound.loadDataUrl(dataUrl, soundLoadOptions);
      default :
        return MockSound.loadDataUrl(dataUrl, soundLoadOptions);
    }
  }

  //-------------------------------------------------------------------------------------------------

  num get length;

  SoundChannel play([
    bool loop = false, SoundTransform soundTransform]);

  SoundChannel playSegment(num startTime, num duration, [
    bool loop = false, SoundTransform soundTransform]);

}
