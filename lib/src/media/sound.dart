part of stagexl;

abstract class Sound {

  Sound() {
    var initEngine = SoundMixer.engine;
  }

  static Future<Sound> load(dynamic url, [SoundLoadOptions soundLoadOptions = null]) {

    switch(SoundMixer.engine) {
      case "WebAudioApi" : return WebAudioApiSound.load(url, soundLoadOptions);
      case "AudioElement": return AudioElementSound.load(url, soundLoadOptions);
      default            : return MockSound.load(url, soundLoadOptions);
    }
  }

  static SoundLoadOptions defaultLoadOptions = new SoundLoadOptions(mp3:true, mp4:true, ogg:true, wav:true);

  //-------------------------------------------------------------------------------------------------

  num get length;
  SoundChannel play([bool loop = false, SoundTransform soundTransform, List<num> segment]);

}
