class SoundMixer 
{
  static SoundTransform _soundTransform;
  
  static SoundTransform get soundTransform() => _soundTransform;
  
  static void set soundTransform(SoundTransform value) 
  {
    // ToDo
  }
  
  //-------------------------------------------------------------------------------------------------
  
  static html.AudioContext _audioContextPrivate;

  static html.AudioContext get _audioContext()
  {
    if (_audioContextPrivate == null)
    {
      try 
      { 
        _audioContextPrivate = new html.AudioContext(); 
      }
      catch(final error) 
      { 
         // AudioContext is not available, fallback to HtmlAudio
      }
    }
    
    return _audioContextPrivate;
  }
  
  //-------------------------------------------------------------------------------------------------
  
  static String _engine;
  
  static String get engine()
  {
    if (_engine == null)
      _engine = (_audioContext != null) ? "WebAudioApi" : "AudioElement";
    
    return _engine;
  }
  
}
