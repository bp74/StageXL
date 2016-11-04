part of stagexl.media;

class WebAudioApiSound extends Sound {

  AudioBuffer _audioBuffer;

  WebAudioApiSound._(AudioBuffer audioBuffer) : _audioBuffer = audioBuffer;

  //---------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions]) async {

    var options = soundLoadOptions ?? Sound.defaultLoadOptions;
    var audioUrls = options.getOptimalAudioUrls(url);
    var audioContext = WebAudioApiMixer.audioContext;
    var aggregateError = new AggregateError("Error loading sound.");

    for(var audioUrl in audioUrls) {
      try {
        var httpRequest = await HttpRequest.request(audioUrl, responseType: 'arraybuffer');
        var audioData = httpRequest.response as ByteBuffer;
        var audioBuffer = await audioContext.decodeAudioData(audioData);
        return new WebAudioApiSound._(audioBuffer);
      } catch (e) {
        var loadError = new LoadError("Failed to load $audioUrl", e);
        aggregateError.errors.add(loadError);
      }
    }

    if (options.ignoreErrors) {
      return MockSound.load(url, options);
    } else {
      throw aggregateError;
    }
  }

  //---------------------------------------------------------------------------

  static Future<Sound> loadDataUrl(
      String dataUrl, [SoundLoadOptions soundLoadOptions]) async {

    var options = soundLoadOptions ?? Sound.defaultLoadOptions;
    var audioContext = WebAudioApiMixer.audioContext;
    var start = dataUrl.indexOf(',') + 1;
    var bytes = BASE64.decoder.convert(dataUrl, start) as Uint8List;

    try {
      var audioData = bytes.buffer;
      var audioBuffer = await audioContext.decodeAudioData(audioData);
      return new WebAudioApiSound._(audioBuffer);
    } catch (e) {
      if (options.ignoreErrors) {
        return MockSound.loadDataUrl(dataUrl, options);
      } else {
        throw new LoadError("Failed to load sound.", e);
      }
    }
  }

  //---------------------------------------------------------------------------

  @override
  SoundEngine get engine => SoundEngine.WebAudioApi;

  @override
  num get length => _audioBuffer.duration;

  @override
  SoundChannel play([
    bool loop = false, SoundTransform soundTransform]) {

    return new WebAudioApiSoundChannel(
        this, 0, this.length, loop, soundTransform);
  }

  @override
  SoundChannel playSegment(num startTime, num duration, [
    bool loop = false, SoundTransform soundTransform]) {

    return new WebAudioApiSoundChannel(
        this, startTime, duration, loop, soundTransform);
  }

}
