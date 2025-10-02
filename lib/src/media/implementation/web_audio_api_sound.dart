part of '../../media.dart';

class WebAudioApiSound extends Sound {
  final web.AudioBuffer _audioBuffer;

  WebAudioApiSound._(this._audioBuffer);

  //---------------------------------------------------------------------------

  static Future<Sound> load(String url,
      [SoundLoadOptions? soundLoadOptions]) async {
    final options = soundLoadOptions ?? Sound.defaultLoadOptions;
    final audioUrls = options.getOptimalAudioUrls(url);
    final audioContext = WebAudioApiMixer.audioContext;
    final aggregateError = AggregateError('Error loading sound.');

    for (var audioUrl in audioUrls) {
      try {
        final response = await http.get(Uri.parse(audioUrl));
        if (response.statusCode == 200) {
          // Convert Dart ByteBuffer to JSArrayBuffer
          final jsArrayBuffer = response.bodyBytes.buffer.toJS;
          final jsPromise = audioContext.decodeAudioData(jsArrayBuffer);
          final audioBuffer = await jsPromise.toDart;
          return WebAudioApiSound._(audioBuffer);
        } else {
          throw Exception('HTTP error: ${response.statusCode}');
        }
      } catch (e) {
        final loadError = LoadError('Failed to load $audioUrl', e);
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

  static Future<Sound> loadDataUrl(String dataUrl,
      [SoundLoadOptions? soundLoadOptions]) async {
    final options = soundLoadOptions ?? Sound.defaultLoadOptions;
    final audioContext = WebAudioApiMixer.audioContext;
    final start = dataUrl.indexOf(',') + 1;
    final bytes = base64.decoder.convert(dataUrl, start);

    try {
      // Convert Dart ByteBuffer to JSArrayBuffer
      final jsArrayBuffer = bytes.buffer.toJS;
      final jsPromise = audioContext.decodeAudioData(jsArrayBuffer);
      final audioBuffer = await jsPromise.toDart;
      return WebAudioApiSound._(audioBuffer);
    } catch (e) {
      if (options.ignoreErrors) {
        return MockSound.loadDataUrl(dataUrl, options);
      } else {
        throw LoadError('Failed to load sound.', e);
      }
    }
  }

  //---------------------------------------------------------------------------

  @override
  SoundEngine get engine => SoundEngine.WebAudioApi;

  @override
  num get length => _audioBuffer.duration;

  @override
  SoundChannel play([bool loop = false, SoundTransform? soundTransform]) =>
      WebAudioApiSoundChannel(this, 0, length, loop, soundTransform);

  @override
  SoundChannel playSegment(num startTime, num duration,
          [bool loop = false, SoundTransform? soundTransform]) =>
      WebAudioApiSoundChannel(this, startTime, duration, loop, soundTransform);
}
