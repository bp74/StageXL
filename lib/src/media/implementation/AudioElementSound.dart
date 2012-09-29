class AudioElementSound extends Sound
{
  html.AudioElement _audio;
  List<html.AudioElement> _audioPool;
  List<AudioElementSoundChannel> _soundChannels;

  AudioElementSound()
  {
    _soundChannels = new List<AudioElementSoundChannel>();

    _audio = new html.AudioElement();
    _audio.on.ended.add(_onAudioEnded);

    _audioPool = new List<html.AudioElement>();
    _audioPool.add(_audio);

    html.document.body.elements.add(_audio);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> loadAudio(String url)
  {
    var sound = new AudioElementSound();
    var loadCompleter = new Completer<Sound>();

    void onAudioCanPlayThrough(event)
    {
      if (loadCompleter.future.isComplete == false)
        loadCompleter.complete(sound);
    }

    void onAudioError(event)
    {
      if (loadCompleter.future.isComplete == false)
        loadCompleter.completeException("Failed to load audio.");
    }

    sound._audio.src = Sound.adaptAudioUrl(url);
    sound._audio.on.canPlayThrough.add(onAudioCanPlayThrough);
    sound._audio.on.error.add(onAudioError);
    sound._audio.load();

    return loadCompleter.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get length
  {
    return _audio.duration;
  }

  SoundChannel play([bool loop = false, SoundTransform soundTransform = null])
  {
    if (soundTransform == null)
      soundTransform = new SoundTransform();

    return new AudioElementSoundChannel(this, loop, soundTransform);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  html.AudioElement _getAudioElement(AudioElementSoundChannel soundChannel)
  {
    html.AudioElement audio;

    if (_audioPool.length == 0)
    {
      audio = _audio.clone(true);
      audio.on.ended.add(_onAudioEnded);
    }
    else
    {
      audio = _audioPool[0];
      _audioPool.removeAt(0);
    }

    _soundChannels.add(soundChannel);

    return audio;
  }

  void _releaseAudioElement(AudioElementSoundChannel soundChannel)
  {
    html.AudioElement audio = soundChannel._audio;
    int index = _soundChannels.indexOf(soundChannel);

    _soundChannels.removeAt(index);
    _audioPool.add(audio);

    if (_audio.currentTime > 0 && _audio.ended == false)
      _audio.currentTime = 0;
  }

  void _onAudioEnded(event)
  {
    html.AudioElement audio = event.target;
    AudioElementSoundChannel soundChannel = null;

    for(int i = 0; i < _soundChannels.length && soundChannel == null; i++)
      if (_soundChannels[i]._audio == audio)
        soundChannel = _soundChannels[i];

    if (soundChannel != null)
      soundChannel.stop();
  }
}
