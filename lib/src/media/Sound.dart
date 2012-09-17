abstract class Sound 
{
  static Future<Sound> loadAudio(String url)
  {
    Sound sound;
    
    switch(SoundMixer.engine)
    {
      case "WebAudioApi":
        sound = new WebAudioApiSound();
        break;
      case "AudioElement":
        sound = new AudioElementSound();
        break;
      default:
        sound = new MockSound();
        break;
    }
    
    return sound.load(url);
  }

  //-------------------------------------------------------------------------------------------------

  abstract num get length();

  abstract Future<Sound> load(String url);
  
  abstract SoundChannel play([bool loop = false, SoundTransform soundTransform = null]);
  
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
    
    RegExp regex = const RegExp(@"\.(ogg|mp3|wav)$", multiLine:false, ignoreCase:true); 
    Match match = regex.firstMatch(url);
    
    if (match == null)
      throw "Unsupported file extension";
    
    String fileType = match.group(1).toLowerCase();
    
    if (_supportedTypes.indexOf(fileType) == -1 && _supportedTypes.length > 0)
      url = "${url.substring(0, url.length - 3)}${_supportedTypes[0]}";

    return url;
  }
  
}
