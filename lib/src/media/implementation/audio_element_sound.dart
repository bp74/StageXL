part of stagexl;

class AudioElementSound extends Sound {

  AudioElement _audio = new AudioElement();
  List<AudioElement> _audioPool = new List<AudioElement>();
  List<AudioElementSoundChannel> _soundChannels = new List<AudioElementSoundChannel>();

  AudioElementSound() {
    _audio.onEnded.listen(_onAudioEnded);
    _audioPool.add(_audio);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions = null]) {

    if (soundLoadOptions == null) soundLoadOptions = Sound.defaultLoadOptions;

    var sound = new AudioElementSound();
    var audio = sound._audio;
    var audioUrls = SoundMixer._getOptimalAudioUrls(url, soundLoadOptions);
    var loadCompleter = new Completer<Sound>();

    if (audioUrls.length == 0) {
      return MockSound.load(url, soundLoadOptions);
    }

    StreamSubscription onCanPlaySubscription;
    StreamSubscription onErrorSubscription;

    onCanPlay(event) {
      onCanPlaySubscription.cancel();
      onErrorSubscription.cancel();
      loadCompleter.complete(sound);
    };

    onError(event) {
      if (audioUrls.length > 0) {
        audio.src = audioUrls.removeAt(0);
        audio.load();
      } else {
        onCanPlaySubscription.cancel();
        onErrorSubscription.cancel();

        if (soundLoadOptions.ignoreErrors) {
          MockSound.load(url, soundLoadOptions).then((s) => loadCompleter.complete(s));
        } else {
          loadCompleter.completeError(new StateError("Failed to load audio."));
        }
      }
    };

    onCanPlaySubscription = audio.onCanPlay.listen(onCanPlay);
    onErrorSubscription = audio.onError.listen(onError);

    audio.src = audioUrls.removeAt(0);
    audio.load();

    return loadCompleter.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

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

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

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

  //-------------------------------------------------------------------------------------------------

  void _onAudioEnded(html.Event event) {
    var soundChannel = _soundChannels.firstWhere((sc) => identical(sc._audio, event.target));
    if (soundChannel != null) soundChannel.stop();
  }

}
