part of dartflash;

abstract class Sound
{
  static Future<Sound> load(String url) {
    
    var engine = SoundMixer.engine;

    if (engine == "WebAudioApi")
      return WebAudioApiSound.load(url);

    if (engine == "AudioElement")
      return AudioElementSound.load(url);

    return MockSound.load(url);
  }

  @deprecated
  static Future<Sound> loadAudio(String url) {
    return Sound.load(url);
  }
  
  //-------------------------------------------------------------------------------------------------

  num get length;

  SoundChannel play([bool loop = false, SoundTransform soundTransform]);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  static String adaptAudioUrl(String url) {
    
    var regex = new RegExp(r"\.(ogg|mp3|wav)$", multiLine:false, caseSensitive:false);
    var match = regex.firstMatch(url);
    var supportedTypes = SoundMixer._supportedTypes;

    if (match == null)
      throw new ArgumentError("Unsupported file extension.");
    
    if (supportedTypes.length == 0)
      throw new UnsupportedError("This browser supports no known audio codec.");

    var fileType = match.group(1).toLowerCase();

    if (supportedTypes.indexOf(fileType) == -1) {
      var filename = url.substring(0, url.length - fileType.length);
      var extension = supportedTypes[0];
      url = "$filename$extension";
    }
    
    return url;
  }

}
