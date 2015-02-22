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

    if (soundLoadOptions == null) {
      soundLoadOptions = Sound.defaultLoadOptions;
    }

    var loadData = false;
    var corsEnabled = soundLoadOptions.corsEnabled;
    var audioUrls = soundLoadOptions.getOptimalAudioUrls(url);

    try {
      var audioLoader = new AudioLoader(audioUrls, loadData, corsEnabled);
      var audioElement = await audioLoader.done;
      return new AudioElementSound._(audioElement);
    } catch (e) {
      if (soundLoadOptions.ignoreErrors) {
        return MockSound.load(url, soundLoadOptions);
      } else {
        throw new StateError("Failed to load audio.");
      }
    }
  }

  static Future<Sound> loadDataUrl(String dataUrl) async {

    var audioUrls = [dataUrl];
    var loadData = false;
    var corsEnabled = false;

    try {
      var audioLoader = new AudioLoader(audioUrls, loadData, corsEnabled);
      var audioElement = await audioLoader.done;
      return new AudioElementSound._(audioElement);
    } catch (e) {
      throw new StateError("Failed to load audio.");
    }
  }

  //---------------------------------------------------------------------------

  num get length => _audioElement.duration;

  SoundChannel play([
    bool loop = false, SoundTransform soundTransform]) {

    return new AudioElementSoundChannel(
        this, 0, 3600, loop, soundTransform);
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

    var audioElement = _audioElement.clone(true);
    var audioCanPlay = audioElement.onCanPlay.first;
    if (audioElement.readyState == 0) await audioCanPlay;
    audioElement.onEnded.listen(_onAudioEnded);

    _soundChannels[audioElement] = soundChannel;
    return audioElement;
  }

  void _releaseAudioElement(AudioElement audioElement) {
    _soundChannels[audioElement] = null;
  }

  void _onAudioEnded(Event event) {
    var audioElement = event.target;
    var soundChannel = _soundChannels[audioElement];
    if (soundChannel != null) soundChannel.stop();
  }

}
