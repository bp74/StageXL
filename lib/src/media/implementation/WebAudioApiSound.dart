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
    var onRequestLoad = null;
    var onRequestError = null;

    onRequestLoad = (event) { 
      
      request.on.load.remove(onRequestLoad);
      request.on.error.remove(onRequestError);
      
      void audioBufferLoaded(AudioBuffer buffer)
      {
        sound._buffer = buffer;
        loadCompleter.complete(sound);
      }

      void audioBufferError(error)
      {
        loadCompleter.completeError(new StateError("Failed to decode audio."));
      }
            
      var audioContext = SoundMixer._audioContext;
      audioContext.decodeAudioData(request.response, audioBufferLoaded, audioBufferError);
    };
    
    onRequestError = (event) {
      
      request.on.load.remove(onRequestLoad);
      request.on.error.remove(onRequestError);
      
      loadCompleter.completeError(new StateError("Failed to load audio."));
    };

    request.open('GET', Sound.adaptAudioUrl(url), true);
    request.responseType = 'arraybuffer';
    request.on.load.add(onRequestLoad);
    request.on.error.add(onRequestError);
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
