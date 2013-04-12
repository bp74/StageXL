part of stagexl;

class WebAudioApiSound extends Sound {
  
  AudioBuffer _buffer;

  WebAudioApiSound() {
    
    if (SoundMixer._audioContext == null)
      throw new UnsupportedError("This browser does not support Web Audio API.");
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url) {
    
    var sound = new WebAudioApiSound();
    var loadCompleter = new Completer<Sound>();
    var audioUrls = SoundMixer._getOptimalAudioUrls(url);
    var audioContext = SoundMixer._audioContext;
    
    audioRequestFinished(request) {
      audioContext.decodeAudioData(request.response, (AudioBuffer buffer) {
        sound._buffer = buffer;
        loadCompleter.complete(sound);
      }, (error) {
        loadCompleter.completeError(new StateError("Failed to decode audio."));
      });
    }
    
    audioRequestNext(error) {
      if (audioUrls.length > 0) {
        HttpRequest.request(audioUrls.removeAt(0), responseType: 'arraybuffer')
        .then(audioRequestFinished)
        .catchError(audioRequestNext);
      } else {
        loadCompleter.completeError(new StateError("Failed to load audio."));
      }
    }

    audioRequestNext(null);
    
    return loadCompleter.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get length {
    
    return _buffer.duration;
  }

  SoundChannel play([bool loop = false, SoundTransform soundTransform]) {
    
    if (soundTransform == null)
      soundTransform = new SoundTransform();

    return new WebAudioApiSoundChannel(this, loop, soundTransform);
  }

}
