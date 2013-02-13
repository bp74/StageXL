part of dartflash;

class WebAudioApiSound extends Sound
{
  AudioBuffer _buffer;

  WebAudioApiSound()
  {
    if (SoundMixer._audioContext == null)
      throw new UnsupportedError("This browser does not support Web Audio API.");
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url)
  {
    var sound = new WebAudioApiSound();
    var soundUrl = Sound.adaptAudioUrl(url);
    var loadCompleter = new Completer<Sound>();
    
    HttpRequest.request(soundUrl, responseType: 'arraybuffer').then((request) {
      
      var audioData = request.response;
      var audioContext = SoundMixer._audioContext;
      
      audioContext.decodeAudioData(audioData, (AudioBuffer buffer) {
        sound._buffer = buffer;
        loadCompleter.complete(sound);
      }, (error) {
        loadCompleter.completeError(new StateError("Failed to decode audio."));
      });
      
    }).catchError((error) {
      
      loadCompleter.completeError(new StateError("Failed to load audio."));
      
    });
  
    return loadCompleter.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get length
  {
    return _buffer.duration;
  }

  SoundChannel play([bool loop = false, SoundTransform soundTransform])
  {
    if (soundTransform == null)
      soundTransform = new SoundTransform();

    return new WebAudioApiSoundChannel(this, loop, soundTransform);
  }

}
