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

  static Future<Sound> loadAudio(String url)
  {
    var sound = new WebAudioApiSound();
    var loadCompleter = new Completer<Sound>();
    var request = new HttpRequest();
    
    StreamSubscription onLoadSubscription = null;
    StreamSubscription onErrorSubscription = null; 

    void onRequestLoad(event) { 
      
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      
      void audioBufferLoaded(AudioBuffer buffer) {
        sound._buffer = buffer;
        loadCompleter.complete(sound);
      }

      void audioBufferError(error) {
        loadCompleter.completeError(new StateError("Failed to decode audio."));
      }
            
      var audioContext = SoundMixer._audioContext;
      audioContext.decodeAudioData(request.response, audioBufferLoaded, audioBufferError);
    };
    
    void onRequestError (event) {
      
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      
      loadCompleter.completeError(new StateError("Failed to load audio."));
    };

    onLoadSubscription = request.onLoad.listen(onRequestLoad);
    onErrorSubscription = request.onError.listen(onRequestError);
    
    request.open('GET', Sound.adaptAudioUrl(url), true);
    request.responseType = 'arraybuffer';
    request.send();
  
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
