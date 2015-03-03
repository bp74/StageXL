part of stagexl.media;

class WebAudioApiSound extends Sound {

  AudioBuffer _audioBuffer;

  WebAudioApiSound._(AudioBuffer audioBuffer) : _audioBuffer = audioBuffer;

  //---------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions]) async {

    if (soundLoadOptions == null) {
      soundLoadOptions = Sound.defaultLoadOptions;
    }

    var audioUrls = soundLoadOptions.getOptimalAudioUrls(url);
    var audioContext = WebAudioApiMixer.audioContext;

    for(var audioUrl in audioUrls) {
      try {
        var httpRequest = await HttpRequest.request(audioUrl, responseType: 'arraybuffer');
        var audioData = httpRequest.response;
        var audioBuffer = await audioContext.decodeAudioData(audioData);
        return new WebAudioApiSound._(audioBuffer);
      } catch (e) {
        // ignore error
      }
    }

    if (soundLoadOptions.ignoreErrors) {
      return MockSound.load(url, soundLoadOptions);
    } else {
      throw new StateError("Failed to load audio.");
    }
  }

  //---------------------------------------------------------------------------

  static Future<Sound> loadDataUrl(String dataUrl) async {

    var audioContext = WebAudioApiMixer.audioContext;
    var byteString = window.atob(dataUrl.split(',')[1]);
    var bytes = new Uint8List(byteString.length);

    for (int i = 0; i < byteString.length; i++) {
      bytes[i] = byteString.codeUnitAt(i);
    }

    try {
      var audioData = bytes.buffer;
      var audioBuffer = await audioContext.decodeAudioData(audioData);
      return new WebAudioApiSound._(audioBuffer);
    } catch (e) {
      throw new StateError("Failed to load audio.");
    }
  }

  //---------------------------------------------------------------------------

  num get length => _audioBuffer.duration;

  SoundChannel play([
    bool loop = false, SoundTransform soundTransform]) {

    return new WebAudioApiSoundChannel(
        this, 0, this.length, loop, soundTransform);
  }

  SoundChannel playSegment(num startTime, num duration, [
    bool loop = false, SoundTransform soundTransform]) {

    return new WebAudioApiSoundChannel(
        this, startTime, duration, loop, soundTransform);
  }

}
