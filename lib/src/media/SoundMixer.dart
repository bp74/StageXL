class SoundMixer 
{
  static SoundTransform _soundTransform;
  
  static SoundTransform get soundTransform => _soundTransform;
  
  static void set soundTransform(SoundTransform value) 
  {
    // ToDo
  }
  
  //-------------------------------------------------------------------------------------------------
  
  static html.AudioContext _audioContextPrivate;

  static html.AudioContext get _audioContext
  {
    if (_audioContextPrivate == null) {
      try { 
        _audioContextPrivate = new html.AudioContext(); 
      } catch(e) {
        _audioContextPrivate = null; 
      }
    }
    
    return _audioContextPrivate;
  }
  
  //-------------------------------------------------------------------------------------------------
  
  static String _engine;
  
  static String get engine
  {
    if (_engine == null) 
    {
      _engine = (_audioContext != null) ? "WebAudioApi" : "AudioElement";

      var ua = html.document.window.navigator.userAgent;
      
      if (ua.contains("IEMobile/9.0") || ua.contains("iPhone OS 4") || ua.contains("iPhone OS 5")) 
        _engine = "Mock";
    }
    
    return _engine;
  }
  
}
