part of '../../media.dart';

class AudioElementSound extends Sound {
  final web.HTMLAudioElement _audioElement;
  final Map<web.HTMLAudioElement, AudioElementSoundChannel?> _soundChannels = {};

  AudioElementSound._(web.HTMLAudioElement audioElement)
      : _audioElement = audioElement {
    _audioElement.onEnded.listen(_onAudioEnded);
    _soundChannels[audioElement] = null;
  }

  //---------------------------------------------------------------------------

  static Future<Sound> load(String url,
      [SoundLoadOptions? soundLoadOptions]) async {
    try {
      final options = soundLoadOptions ?? Sound.defaultLoadOptions;
      final audioUrls = options.getOptimalAudioUrls(url);
      final corsEnabled = options.corsEnabled;
      const loadData = false; // options.loadData;
      final audioLoader = AudioLoader(audioUrls, loadData, corsEnabled);
      final audioElement = await audioLoader.done;
      return AudioElementSound._(audioElement);
    } catch (e) {
      final options = soundLoadOptions ?? Sound.defaultLoadOptions;
      if (options.ignoreErrors) {
        return MockSound.load(url, options);
      } else {
        rethrow;
      }
    }
  }

  static Future<Sound> loadDataUrl(String dataUrl,
      [SoundLoadOptions? soundLoadOptions]) async {
    try {
      final audioUrls = <String>[dataUrl];
      final audioLoader = AudioLoader(audioUrls, false, false);
      final audioElement = await audioLoader.done;
      return AudioElementSound._(audioElement);
    } catch (e) {
      final options = soundLoadOptions ?? Sound.defaultLoadOptions;
      if (options.ignoreErrors) {
        return MockSound.loadDataUrl(dataUrl, options);
      } else {
        rethrow;
      }
    }
  }

  //---------------------------------------------------------------------------

  @override
  SoundEngine get engine => SoundEngine.AudioElement;

  @override
  num get length => _audioElement.duration;

  @override
  SoundChannel play([bool loop = false, SoundTransform? soundTransform]) {
    const startTime = 0.0;
    var duration = _audioElement.duration;
    if (duration.isInfinite) duration = 3600.0;
    return AudioElementSoundChannel(
        this, startTime, duration, loop, soundTransform);
  }

  @override
  SoundChannel playSegment(num startTime, num duration,
          [bool loop = false, SoundTransform? soundTransform]) =>
      AudioElementSoundChannel(this, startTime, duration, loop, soundTransform);

  //---------------------------------------------------------------------------

  Future<web.HTMLAudioElement> _requestAudioElement(
      AudioElementSoundChannel soundChannel) async {
    for (var audioElement in _soundChannels.keys) {
      if (_soundChannels[audioElement] == null) {
        _soundChannels[audioElement] = soundChannel;
        return audioElement;
      }
    }

    final audioElement = _audioElement.cloneNode(true) as web.HTMLAudioElement;
    final audioCanPlay = audioElement.onCanPlay.first;
    if (audioElement.readyState == 0) await audioCanPlay;
    audioElement.onEnded.listen(_onAudioEnded);

    _soundChannels[audioElement] = soundChannel;
    return audioElement;
  }

  void _releaseAudioElement(web.HTMLAudioElement audioElement) {
    _soundChannels[audioElement] = null;
  }

  void _onAudioEnded(web.Event event) {
    final audioElement = event.target;
    if (!audioElement.isA<web.HTMLAudioElement>()) return;

    _soundChannels[audioElement]?._onAudioEnded();
  }
}
