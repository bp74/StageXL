part of stagexl.media;

class WebAudioApiSound extends Sound {

  AudioBuffer _audioBuffer;

  WebAudioApiSound._(AudioBuffer audioBuffer) : _audioBuffer = audioBuffer;

  //---------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions]) async {

    soundLoadOptions ??= Sound.defaultLoadOptions;

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

  static Future<Sound> loadDataUrl(
      String dataUrl, [SoundLoadOptions soundLoadOptions]) async {

    soundLoadOptions ??= Sound.defaultLoadOptions;

    var audioContext = WebAudioApiMixer.audioContext;
    var decoder = new Base64Decoder();
    var start = dataUrl.indexOf(',') + 1;
    var bytes = decoder.convert(dataUrl, start) as Uint8List;

    try {
      var audioData = bytes.buffer;
      var audioBuffer = await audioContext.decodeAudioData(audioData);
      return new WebAudioApiSound._(audioBuffer);
    } catch (e) {
      if (soundLoadOptions.ignoreErrors) {
        return new MockSound._();
      } else {
        throw new StateError("Failed to load audio.");
      }
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
