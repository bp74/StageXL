part of stagexl.media;

class AudioElementSound extends Sound {

  final AudioElement _audio;
  final List<AudioElement> _audioPool = new List<AudioElement>();
  final List<AudioElementSoundChannel> _soundChannels = new List<AudioElementSoundChannel>();

  AudioElementSound._(AudioElement audio) : _audio = audio {
    _audio.onEnded.listen(_onAudioEnded);
    _audioPool.add(_audio);
  }

  //---------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions = null]) {

    if (soundLoadOptions == null) soundLoadOptions = Sound.defaultLoadOptions;

    var completer = new Completer<Sound>();
    var loadData = false;
    var corsEnabled = soundLoadOptions.corsEnabled;
    var audioUrls = soundLoadOptions.getOptimalAudioUrls(url);
    var audioLoader = new AudioLoader(audioUrls, loadData, corsEnabled);

    audioLoader.done.then((AudioElement audioElement) {
      completer.complete(new AudioElementSound._(audioElement));
    }).catchError((error) {
      if (soundLoadOptions.ignoreErrors) {
        MockSound.load(url, soundLoadOptions).then((s) => completer.complete(s));
      } else {
        completer.completeError(new StateError("Failed to load audio."));
      }
    });

    return completer.future;
  }

  static Future<Sound> loadDataUrl(String dataUrl) {

    var completer = new Completer<Sound>();
    var audioUrls = [dataUrl];
    var loadData = false;
    var corsEnabled = false;
    var audioLoader = new AudioLoader(audioUrls, loadData, corsEnabled);

    audioLoader.done.then((AudioElement audioElement) {
      completer.complete(new AudioElementSound._(audioElement));
    }).catchError((error) {
      completer.completeError(new StateError("Failed to load audio."));
    });

    return completer.future;
  }

  //---------------------------------------------------------------------------

  num get length => _audio.duration;

  SoundChannel play([bool loop = false, SoundTransform soundTransform]) {
    if (soundTransform == null) soundTransform = new SoundTransform();
    return new AudioElementSoundChannel(this, 0, 3600, loop, soundTransform);
  }

  SoundChannel playSegment(num startTime, num duration, [
                           bool loop = false, SoundTransform soundTransform]) {

    if (soundTransform == null) soundTransform = new SoundTransform();
    return new AudioElementSoundChannel(this, startTime, duration, loop, soundTransform);
  }

  //---------------------------------------------------------------------------

  Future<AudioElement> _requestAudioElement(AudioElementSoundChannel soundChannel) {

    _soundChannels.add(soundChannel);

    if (_audioPool.length > 0) {
      return new Future.value(_audioPool.removeAt(0));
    }

    var audio = _audio.clone(true);
    audio.onEnded.listen(_onAudioEnded);

    return audio.readyState == 0
        ? audio.onCanPlay.first.then((_) => audio)
        : new Future.value(audio);
  }

  void _releaseAudioElement(AudioElementSoundChannel soundChannel, AudioElement audio) {
    _soundChannels.remove(soundChannel);
    _audioPool.add(audio);
  }

  void _onAudioEnded(Event event) {
    var soundChannel = _soundChannels.firstWhere(
        (sc) => identical(sc._audio, event.target), orElse: () => null);
    if (soundChannel != null) soundChannel.stop();
  }

}
