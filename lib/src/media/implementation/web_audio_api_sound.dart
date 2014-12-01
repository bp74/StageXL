part of stagexl.media;

class WebAudioApiSound extends Sound {

  AudioBuffer _buffer;

  WebAudioApiSound._() {
    if (SoundMixer.engine != "WebAudioApi") {
      throw new UnsupportedError("This browser does not support Web Audio API.");
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions = null]) {

    if (soundLoadOptions == null) soundLoadOptions = Sound.defaultLoadOptions;

    var sound = new WebAudioApiSound._();
    var loadCompleter = new Completer<Sound>();
    var audioUrls = soundLoadOptions.getOptimalAudioUrls(url);
    var audioContext = WebAudioApiMixer.audioContext;

    if (audioUrls.length == 0) {
      return MockSound.load(url, soundLoadOptions);
    }

    audioRequestFinished(request) {
      audioContext.decodeAudioData(request.response).then((AudioBuffer buffer) {
        sound._buffer = buffer;
        loadCompleter.complete(sound);
      }).catchError((error) {
        if (soundLoadOptions.ignoreErrors) {
          MockSound.load(url, soundLoadOptions).then((s) => loadCompleter.complete(s));
        } else {
          loadCompleter.completeError(new StateError("Failed to decode audio."));
        }
      });
    }

    audioRequestNext(error) {
      if (audioUrls.length > 0) {
        HttpRequest.request(audioUrls.removeAt(0), responseType: 'arraybuffer')
        .then(audioRequestFinished)
        .catchError(audioRequestNext);
      } else {
        if (soundLoadOptions.ignoreErrors) {
          MockSound.load(url, soundLoadOptions).then((s) => loadCompleter.complete(s));
        } else {
          loadCompleter.completeError(new StateError("Failed to load audio."));
        }
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
    if (soundTransform == null) soundTransform = new SoundTransform();
    return new WebAudioApiSoundChannel(this, 0, this.length, loop, soundTransform);
  }

  SoundChannel playSegment(num startTime, num duration, [
                           bool loop = false, SoundTransform soundTransform]) {

    if (soundTransform == null) soundTransform = new SoundTransform();
    return new WebAudioApiSoundChannel(this, startTime, duration, loop, soundTransform);
  }

}
