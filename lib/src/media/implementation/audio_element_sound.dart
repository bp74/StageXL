part of stagexl.media;

class AudioElementSound extends Sound {

  final AudioElement _audioElement;
  final Map<AudioElement, AudioElementSoundChannel> _soundChannels;

  AudioElementSound._(AudioElement audioElement) :
    _audioElement = audioElement,
    _soundChannels = new Map<AudioElement, AudioElementSoundChannel>() {

    _audioElement.onEnded.listen(_onAudioEnded);
    _soundChannels[audioElement] = null;
  }

  //---------------------------------------------------------------------------

  static Future<Sound> load(
      String url, [SoundLoadOptions soundLoadOptions]) async {

    try {
      var options = soundLoadOptions ?? Sound.defaultLoadOptions;
      var audioUrls = options.getOptimalAudioUrls(url);
      var corsEnabled = options.corsEnabled;
      var loadData = false; // options.loadData;
      var audioLoader = new AudioLoader(audioUrls, loadData, corsEnabled);
      var audioElement = await audioLoader.done;
      return new AudioElementSound._(audioElement);
    } catch (e) {
      var options = soundLoadOptions ?? Sound.defaultLoadOptions;
      if (options.ignoreErrors) {
        return MockSound.load(url, options);
      } else {
        rethrow;
      }
    }
  }

  static Future<Sound> loadDataUrl(
      String dataUrl, [SoundLoadOptions soundLoadOptions]) async {

    try {
      var audioUrls = <String>[dataUrl];
      var audioLoader = new AudioLoader(audioUrls, false, false);
      var audioElement = await audioLoader.done;
      return new AudioElementSound._(audioElement);
    } catch (e) {
      var options = soundLoadOptions ?? Sound.defaultLoadOptions;
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
  SoundChannel play([bool loop = false, SoundTransform soundTransform]) {
    var startTime = 0.0;
    var duration = _audioElement.duration;
    if (duration.isInfinite) duration = 3600.0;
    return new AudioElementSoundChannel(
        this, startTime, duration, loop, soundTransform);
  }

  @override
  SoundChannel playSegment(num startTime, num duration, [
    bool loop = false, SoundTransform soundTransform]) {
    return new AudioElementSoundChannel(
        this, startTime, duration, loop, soundTransform);
  }

  //---------------------------------------------------------------------------

  Future<AudioElement> _requestAudioElement(
      AudioElementSoundChannel soundChannel) async {

    for(var audioElement in _soundChannels.keys) {
      if (_soundChannels[audioElement] == null) {
        _soundChannels[audioElement] = soundChannel;
        return audioElement;
      }
    }

    var audioElement = _audioElement.clone(true) as AudioElement;
    var audioCanPlay = audioElement.onCanPlay.first;
    if (audioElement.readyState == 0) await audioCanPlay;
    audioElement.onEnded.listen(_onAudioEnded);

    _soundChannels[audioElement] = soundChannel;
    return audioElement;
  }

  void _releaseAudioElement(AudioElement audioElement) {
    _soundChannels[audioElement] = null;
  }

  void _onAudioEnded(html.Event event) {
    var audioElement = event.target;
    var soundChannel = _soundChannels[audioElement];
    if (soundChannel != null) soundChannel._onAudioEnded();
  }

}
