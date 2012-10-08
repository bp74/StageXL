abstract class Sound
{
  static Future<Sound> loadAudio(String url)
  {
    var engine = SoundMixer.engine;

    if (engine == "WebAudioApi")
      return WebAudioApiSound.loadAudio(url);

    if (engine == "AudioElement")
      return AudioElementSound.loadAudio(url);

    return MockSound.loadAudio(url);
  }

  //-------------------------------------------------------------------------------------------------

  num get length;

  SoundChannel play([bool loop = false, SoundTransform soundTransform = null]);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static List<String> _supportedTypes;

  static String adaptAudioUrl(String url)
  {
    if (_supportedTypes == null)
    {
      _supportedTypes = new List<String>();

      html.AudioElement audio = new html.AudioElement();
      List valid = ["maybe", "probably"];

      if (valid.indexOf(audio.canPlayType("audio/ogg", "")) != -1) _supportedTypes.add("ogg");
      if (valid.indexOf(audio.canPlayType("audio/mp3", "")) != -1) _supportedTypes.add("mp3");
      if (valid.indexOf(audio.canPlayType("audio/wav", "")) != -1) _supportedTypes.add("wav");
    }

    //---------------------------------------

    RegExp regex = const RegExp(r"\.(ogg|mp3|wav)$", multiLine:false, ignoreCase:true);
    Match match = regex.firstMatch(url);

    if (match == null)
      throw new ArgumentError("Unsupported file extension.");

    String fileType = match.group(1).toLowerCase();

    if (_supportedTypes.indexOf(fileType) == -1 && _supportedTypes.length > 0)
      url = "${url.substring(0, url.length - 3)}${_supportedTypes[0]}";

    return url;
  }

}
