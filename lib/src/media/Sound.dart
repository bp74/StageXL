part of stagexl;

abstract class Sound {
  
  static Future<Sound> load(String url) {
    
    switch(SoundMixer.engine) {
      case "WebAudioApi" : return WebAudioApiSound.load(url);
      case "AudioElement": return AudioElementSound.load(url);
      default            : return MockSound.load(url);
    }
  }
 
  //-------------------------------------------------------------------------------------------------

  num get length;
  SoundChannel play([bool loop = false, SoundTransform soundTransform]);

}
