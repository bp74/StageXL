class Sound 
{
  //abstract Sound();
  
  static Future<Sound> loadAudio(String url)
  {
    Sound sound = null;
    
    if (SoundMixer.engine == "WebAudioApi")
      sound = new WebAudioApiSound();
    else
      sound = new AudioElementSound();
    
    return sound.load(url);
  }

  //-------------------------------------------------------------------------------------------------

  abstract num get length();
  
  //-------------------------------------------------------------------------------------------------

  abstract Future<Sound> load(String url);
  
  SoundChannel play([bool loop = false, SoundTransform soundTransform = null])
  {
    // ToDo: should be abstract, but right now we can't define default values
    // for the optional parameters. This should be fixed by Dart in the future.
  }
  
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
    
    RegExp exp = const RegExp(@"\.(ogg|mp3|wav)$", false, true); 
    Match match = exp.firstMatch(url);
    
    if (match == null)
      throw "Unsupported file extension";
    
    String fileType = match.group(1).toLowerCase();
    
    if (_supportedTypes.indexOf(fileType) == -1 && _supportedTypes.length > 0)
      url = "${url.substring(0, url.length - 3)}${_supportedTypes[0]}";

    return url;
  }
  
}
