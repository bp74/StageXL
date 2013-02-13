part of dartflash;

class AudioElementSound extends Sound
{
  AudioElement _audio;
  List<AudioElement> _audioPool;
  List<AudioElementSoundChannel> _soundChannels;

  AudioElementSound()
  {
    _soundChannels = new List<AudioElementSoundChannel>();

    _audio = new AudioElement();
    _audio.onEnded.listen(_onAudioEnded);

    _audioPool = new List<AudioElement>();
    _audioPool.add(_audio);

    html.document.body.children.add(_audio);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url)
  {
    var sound = new AudioElementSound();
    var audio = sound._audio;
    var loadCompleter = new Completer<Sound>();

    StreamSubscription onCanPlayThroughSubscription;
    StreamSubscription onErrorSubscription;

    onCanPlayThrough(event) {
      onCanPlayThroughSubscription.cancel();
      onErrorSubscription.cancel();
      loadCompleter.complete(sound);
    };

    onError(event) {
      onCanPlayThroughSubscription.cancel();
      onErrorSubscription.cancel();
      loadCompleter.completeError(new StateError("Failed to load audio."));
    };

    onCanPlayThroughSubscription = audio.onCanPlayThrough.listen(onCanPlayThrough);
    onErrorSubscription = audio.onError.listen(onError);
    
    audio.src = Sound.adaptAudioUrl(url);
    audio.load();

    return loadCompleter.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get length
  {
    return _audio.duration;
  }

  SoundChannel play([bool loop = false, SoundTransform soundTransform])
  {
    if (soundTransform == null)
      soundTransform = new SoundTransform();

    return new AudioElementSoundChannel(this, loop, soundTransform);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  AudioElement _getAudioElement(AudioElementSoundChannel soundChannel)
  {
    AudioElement audio;

    if (_audioPool.length == 0) {
      audio = _audio.clone(true);
      audio.onEnded.listen(_onAudioEnded);
    } else {
      audio = _audioPool.removeAt(0);
    }

    _soundChannels.add(soundChannel);

    return audio;
  }

  void _releaseAudioElement(AudioElementSoundChannel soundChannel)
  {
    AudioElement audio = soundChannel._audio;
    int index = _soundChannels.indexOf(soundChannel);

    _soundChannels.removeAt(index);
    _audioPool.add(audio);

    if (_audio.currentTime > 0 && _audio.ended == false)
      _audio.currentTime = 0;
  }

  void _onAudioEnded(event)
  {
    AudioElement audio = event.target;
    AudioElementSoundChannel soundChannel = null;

    for(int i = 0; i < _soundChannels.length && soundChannel == null; i++)
      if (_soundChannels[i]._audio == audio)
        soundChannel = _soundChannels[i];

    if (soundChannel != null)
      soundChannel.stop();
  }
}
