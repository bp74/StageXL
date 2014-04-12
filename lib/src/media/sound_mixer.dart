part of stagexl;

class SoundMixer {

  static String _engine;

  static WebAudioApiMixer _webAudioApiMixer;
  static AudioElementMixer _audioElementMixer;

  static SoundTransform _soundTransform = new SoundTransform();
  static List<String> _supportedTypes = _getSupportedTypes();

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

    if (_supportedTypes.length == 0) {
      _engine = "Mock";
    }

    print("StageXL audio engine  : $engine");
  }

  //-------------------------------------------------------------------------------------------------

  static List<String> _getSupportedTypes() {

    var supportedTypes = new List<String>();
    var audio = new AudioElement();
    var valid = ["maybe", "probably"];

    if (valid.indexOf(audio.canPlayType("audio/mpeg", "")) != -1) supportedTypes.add("mp3");
    if (valid.indexOf(audio.canPlayType("audio/mp4", "")) != -1) supportedTypes.add("mp4");
    if (valid.indexOf(audio.canPlayType("audio/ogg", "")) != -1) supportedTypes.add("ogg");
    if (valid.indexOf(audio.canPlayType("audio/ac3", "")) != -1) supportedTypes.add("ac3");
    if (valid.indexOf(audio.canPlayType("audio/wav", "")) != -1) supportedTypes.add("wav");

    print("StageXL audio types   : ${supportedTypes}");

    return supportedTypes;
  }

  //-------------------------------------------------------------------------------------------------

  static List<String> _getOptimalAudioUrls(String originalUrl, SoundLoadOptions soundLoadOptions) {

    var availableTypes = _supportedTypes.toList();
    if (!soundLoadOptions.mp3) availableTypes.remove("mp3");
    if (!soundLoadOptions.mp4) availableTypes.remove("mp4");
    if (!soundLoadOptions.ogg) availableTypes.remove("ogg");
    if (!soundLoadOptions.ac3) availableTypes.remove("ac3");
    if (!soundLoadOptions.wav) availableTypes.remove("wav");

    var regex = new RegExp(r"(mp3|mp4|ogg|ac3|wav)$", multiLine:false, caseSensitive:true);
    var match = regex.firstMatch(originalUrl);
    if (match == null) return new List<String>(0);

    var fileType = match.group(1);
    var urls = new List<String>();

    if (availableTypes.remove(fileType)) {
      urls.add(originalUrl);
    }

    for(var availableType in availableTypes) {
      urls.add(originalUrl.replaceAll(regex, availableType));
    }

    return urls;
  }

}
