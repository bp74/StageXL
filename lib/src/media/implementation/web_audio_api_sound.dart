part of stagexl.media;

class WebAudioApiSound extends Sound {

  AudioBuffer _audioBuffer;

  WebAudioApiSound._(AudioBuffer audioBuffer) : _audioBuffer = audioBuffer;

  //---------------------------------------------------------------------------

  static Future<Sound> load(String url, [
    SoundLoadOptions soundLoadOptions = null]) {

    if (soundLoadOptions == null) {
      soundLoadOptions = Sound.defaultLoadOptions;
    }

    var completer = new Completer<Sound>();
    var audioUrls = soundLoadOptions.getOptimalAudioUrls(url);
    var audioContext = WebAudioApiMixer.audioContext;

    if (audioUrls.length == 0) {
      return MockSound.load(url, soundLoadOptions);
    }

    void audioRequestFinished(request) {
      audioContext.decodeAudioData(request.response).then((AudioBuffer audioBuffer) {
        completer.complete(new WebAudioApiSound._(audioBuffer));
      }).catchError((error) {
        if (soundLoadOptions.ignoreErrors) {
          MockSound.load(url, soundLoadOptions).then((s) => completer.complete(s));
        } else {
          completer.completeError(new StateError("Failed to decode audio."));
        }
      });
    }

    void  audioRequestNext(error) {
      if (audioUrls.length > 0) {
        HttpRequest.request(audioUrls.removeAt(0), responseType: 'arraybuffer')
        .then(audioRequestFinished)
        .catchError(audioRequestNext);
      } else {
        if (soundLoadOptions.ignoreErrors) {
          MockSound.load(url, soundLoadOptions).then((s) => completer.complete(s));
        } else {
          completer.completeError(new StateError("Failed to load audio."));
        }
      }
    }

    audioRequestNext(null);

    return completer.future;
  }

  //---------------------------------------------------------------------------

  static Future<Sound> loadDataUrl(String dataUrl) {

    var completer = new Completer();
    var audioContext = WebAudioApiMixer.audioContext;
    var byteString = window.atob(dataUrl.split(',')[1]);
    var bytes = new Uint8List(byteString.length);

    for (int i = 0; i < byteString.length; i++) {
      bytes[i] = byteString.codeUnitAt(i);
    }

    audioContext.decodeAudioData(bytes.buffer).then((AudioBuffer audioBuffer) {
      completer.complete(new WebAudioApiSound._(audioBuffer));
    }).catchError((_) {
      completer.completeError(new StateError("Failed to load audio."));
    });

    return completer.future;
  }

  //---------------------------------------------------------------------------

  num get length {
    return _audioBuffer.duration;
  }

  SoundChannel play([bool loop = false, SoundTransform soundTransform = null]) {

    return new WebAudioApiSoundChannel(
        this, 0, this.length, loop, soundTransform);
  }

  SoundChannel playSegment(num startTime, num duration, [
    bool loop = false, SoundTransform soundTransform = null]) {

    return new WebAudioApiSoundChannel(
        this, startTime, duration, loop, soundTransform);
  }

}
