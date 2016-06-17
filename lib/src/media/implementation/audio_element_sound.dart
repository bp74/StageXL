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

  static Future<Sound> load(String url, [
      SoundLoadOptions soundLoadOptions]) async {

    var options = soundLoadOptions ?? Sound.defaultLoadOptions;
    var audioUrls = options.getOptimalAudioUrls(url);
    var corsEnabled = options.corsEnabled;
    var loadData = false;

    try {
      var audioLoader = new AudioLoader(audioUrls, loadData, corsEnabled);
      var audioElement = await audioLoader.done;
      return new AudioElementSound._(audioElement);
    } catch (e) {
      if (options.ignoreErrors) {
        return MockSound.load(url, options);
      } else {
        throw new StateError("Failed to load audio.");
      }
    }
  }

  static Future<Sound> loadDataUrl(
      String dataUrl, [SoundLoadOptions soundLoadOptions]) async {

    var options = soundLoadOptions ?? Sound.defaultLoadOptions;
    var audioUrls = <String>[dataUrl];
    var loadData = false;
    var corsEnabled = false;

    try {
      var audioLoader = new AudioLoader(audioUrls, loadData, corsEnabled);
      var audioElement = await audioLoader.done;
      return new AudioElementSound._(audioElement);
    } catch (e) {
      if (options.ignoreErrors) {
        return MockSound.loadDataUrl(dataUrl, options);
      } else {
        throw new StateError("Failed to load audio.");
      }
    }
  }

  //---------------------------------------------------------------------------

  SoundEngine get engine => SoundEngine.AudioElement;

  num get length => _audioElement.duration;

  SoundChannel play([bool loop = false, SoundTransform soundTransform]) {
    var startTime = 0.0;
    var duration = _audioElement.duration;
    if (duration.isInfinite) duration = 3600.0;
    return new AudioElementSoundChannel(
        this, startTime, duration, loop, soundTransform);
  }

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
