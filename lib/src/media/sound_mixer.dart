part of stagexl.media;

class SoundMixer {

  static String _engine;

  static WebAudioApiMixer _webAudioApiMixer;
  static AudioElementMixer _audioElementMixer;

  static SoundTransform _soundTransform = new SoundTransform();

  //---------------------------------------------------------------------------

  static String get engine {
    _initEngine();
    return _engine;
  }

  //---------------------------------------------------------------------------

  static SoundTransform get soundTransform {
    return _soundTransform;
  }

  static set soundTransform(SoundTransform value) {

    _initEngine();
    _soundTransform =  value != null ? value : new SoundTransform();

    if (_webAudioApiMixer != null) {
      _webAudioApiMixer.applySoundTransform(_soundTransform);
    }

    if (_audioElementMixer != null) {
      _audioElementMixer.applySoundTransform(_soundTransform);
    }
  }

  //---------------------------------------------------------------------------

  /// A helper method to unlock audio on mobile devices.
  ///
  /// Some mobile devices (like iOS) do not allow audio playback by default.
  /// Call this method in the first onTouchBegin event to unlock the website
  /// for audio playback.
  ///
  ///     stage.onTouchBegin.first.then((e) {
  ///       SoundMixer.unlockMobileAudio();
  ///     });

  static void unlockMobileAudio() {
    if (engine == "WebAudioApi") {
      try {
        var context = WebAudioApiMixer.audioContext;
        var source = context.createBufferSource();
        source.buffer = context.createBuffer(1, 1, 22050);
        source.connectNode(context.destination);
        source.start(0);
      } catch(e) {
        // There is nothing we can do :(
      }
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  static void _initEngine() {

    if (_engine != null) {
      return;
    }

    _engine = "AudioElement";
    _audioElementMixer = new AudioElementMixer();

    if (AudioContext.supported) {
      _engine = "WebAudioApi";
      _webAudioApiMixer = new WebAudioApiMixer();
    }

    var ua = html.window.navigator.userAgent;

    if (ua.contains("IEMobile")) {
      if (ua.contains("9.0")) {
        _engine = "Mock";
      }
    }

    if (ua.contains("iPhone") || ua.contains("iPad") || ua.contains("iPod")) {
      if (ua.contains("OS 3") || ua.contains("OS 4") || ua.contains("OS 5")) {
        _engine = "Mock";
      }
    }

    if (AudioLoader.supportedTypes.length == 0) {
      _engine = "Mock";
    }

    print("StageXL audio engine  : $engine");
  }

}
