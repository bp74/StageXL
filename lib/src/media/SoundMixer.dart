part of dartflash;

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

      var ua = html.window.navigator.userAgent;

      if (ua.contains("IEMobile"))
        if (ua.contains("9.0"))
          _engine = "Mock";

      if (ua.contains("iPhone") || ua.contains("iPad") || ua.contains("iPod"))
        if (ua.contains("OS 3") || ua.contains("OS 4") || ua.contains("OS 5"))
          _engine = "Mock";
    }

    return _engine;
  }

}
