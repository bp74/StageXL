class AudioElementSound extends Sound
{
  html.AudioElement _audio;
  List<html.AudioElement> _audioPool;
  Completer<Sound> _loadCompleter;
  List<AudioElementSoundChannel> _soundChannels;
  
  html.EventListener _audioCanPlayThroughHandler;
  html.EventListener _audioErrorHandler;
  html.EventListener _audioEndedHandler;
  
  AudioElementSound()
  {
    _soundChannels = new List<AudioElementSoundChannel>();

    // ToDo: In Dart method closures aren't canonicalized yet.
    // So we use a little workaround meanwhile.
    
    _audioCanPlayThroughHandler = _onAudioCanPlayThrough;
    _audioErrorHandler = _onAudioError;
    _audioEndedHandler = _onAudioEnded;
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  Future<Sound> load(String url)
  {
    _loadCompleter = new Completer<Sound>();

    _audio = new html.AudioElement(Sound.adaptAudioUrl(url));
    _audio.on["canplaythrough"].add(_audioCanPlayThroughHandler);
    _audio.on["error"].add(_audioErrorHandler);
    _audio.on["ended"].add(_audioEndedHandler);
    _audio.load();

    html.document.body.elements.add(_audio);

    _audioPool = new List<html.AudioElement>();
    _audioPool.add(_audio);
    
    return _loadCompleter.future;
  }

  //-------------------------------------------------------------------------------------------------

  num get length()
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
      audio.on["ended"].add(_onAudioEnded);
    }
    else
    {
      audio = _audioPool[0];
      _audioPool.removeRange(0, 1);
    }
    
    _soundChannels.add(soundChannel);

    return audio;
  }
  
  void _releaseAudioElement(AudioElementSoundChannel soundChannel)
  {
    html.AudioElement audio = soundChannel._audio;
    int index = _soundChannels.indexOf(soundChannel);
    
    _soundChannels.removeRange(index, 1);
    _audioPool.add(audio);
    
    if (_audio.currentTime > 0 && _audio.ended == false)
      _audio.currentTime = 0;
  }
  
  //-------------------------------------------------------------------------------------------------
  
  _onAudioEnded(event)
  {
    html.AudioElement audio = event.target;
    AudioElementSoundChannel soundChannel = null;

    for(int i = 0; i < _soundChannels.length && soundChannel == null; i++)
      if (_soundChannels[i]._audio == audio)
        soundChannel = _soundChannels[i];
      
    if (soundChannel != null)
      soundChannel.stop();
  } 
  
  _onAudioCanPlayThrough(event)
  {
    _audio.on["canplaythrough"].remove(_audioCanPlayThroughHandler);
    _audio.on["error"].remove(_audioErrorHandler);
    
    if (_loadCompleter.future.isComplete == false)
      _loadCompleter.complete(this);      
  }
  
  _onAudioError(event)
  {
    _audio.on["canplaythrough"].remove(_audioCanPlayThroughHandler);
    _audio.on["error"].remove(_audioErrorHandler);
    
    if (_loadCompleter.future.isComplete == false)
      _loadCompleter.completeException("Failed to load audio.");        
  }
  
}
