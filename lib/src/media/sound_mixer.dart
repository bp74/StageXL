part of stagexl.media;

class SoundMixer {

  static String _engine;

  static WebAudioApiMixer _webAudioApiMixer;
  static AudioElementMixer _audioElementMixer;

  static SoundTransform _soundTransform = new SoundTransform();

  //-------------------------------------------------------------------------------------------------

  static String get engine {
    if (_engine == null) _initEngine();
    return _engine;
  }

  static SoundTransform get soundTransform {
    return _soundTransform;
  }

  static set soundTransform(SoundTransform value) {

    var initEngine = SoundMixer.engine;
    var soundTransform = (value != null) ? value : new SoundTransform();

    _soundTransform = soundTransform;

    if (_webAudioApiMixer != null) {
      _webAudioApiMixer.applySoundTransform(soundTransform);
    }

    if (_audioElementMixer != null) {
      _audioElementMixer.applySoundTransform(soundTransform);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static void _initEngine() {

    _engine = "AudioElement";
    _audioElementMixer = new AudioElementMixer();

    if (AudioContext.supported) {
      _engine = "WebAudioApi";
      _webAudioApiMixer = new WebAudioApiMixer();
    }

    var ua = window.navigator.userAgent;

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
