part of dartflash;

class SoundMixer {
  
  static SoundTransform _soundTransform;
  static SoundTransform get soundTransform => _soundTransform;

  static set soundTransform(SoundTransform value) {
    // ToDo
  }

  //-------------------------------------------------------------------------------------------------
  
  static String engine = _getEngine();
  
  static AudioContext _audioContext = _getAudioContext(); 
  static List<String> _supportedTypes = _getSupportedTypes();
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  static String _getEngine() {    
      
    var engine = (_audioContext != null) ? "WebAudioApi" : "AudioElement";

    var ua = html.window.navigator.userAgent;

    if (ua.contains("IEMobile"))
      if (ua.contains("9.0"))
        engine = "Mock";

    if (ua.contains("iPhone") || ua.contains("iPad") || ua.contains("iPod"))
      if (ua.contains("OS 3") || ua.contains("OS 4") || ua.contains("OS 5"))
        engine = "Mock";
    
    if (_supportedTypes.length == 0)
      engine = "Mock";

    print("dartflash: supported audio engine is: $engine");
    
    return engine;
  }

  //-------------------------------------------------------------------------------------------------
  
  static AudioContext _getAudioContext() {
    
    try {
      return new AudioContext();
    } catch(e) {
      return null;
    }
  }
  
  //-------------------------------------------------------------------------------------------------

  static List<String> _getSupportedTypes() {
    
    var supportedTypes = new List<String>();
    var audio = new AudioElement();
    var valid = ["maybe", "probably"];

    if (valid.indexOf(audio.canPlayType("audio/ogg", "")) != -1) supportedTypes.add("ogg");
    if (valid.indexOf(audio.canPlayType("audio/mpeg", "")) != -1) supportedTypes.add("mp3");
    if (valid.indexOf(audio.canPlayType("audio/wav", "")) != -1) supportedTypes.add("wav");
          
    print("dartflash: supported audio types are: ${supportedTypes}");
    
    return supportedTypes;
  }
  
}
