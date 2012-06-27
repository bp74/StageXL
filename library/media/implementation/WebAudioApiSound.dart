class WebAudioApiSound extends Sound
{
  html.AudioContext _audioContext;
  html.AudioBuffer _buffer;
  Completer<Sound> _loadCompleter;
  
  Future<Sound> load(String url)
  {
    _audioContext = SoundMixer._audioContext;
    
    if (_audioContext == null)
      throw "This browser does not support Web Audio API.";
    
    //---------------------------------------
    
    _loadCompleter = new Completer<Sound>();

    html.XMLHttpRequest request = new html.XMLHttpRequest();
    request.open('GET', Sound.adaptAudioUrl(url), true);
    request.responseType = 'arraybuffer';
    request.on.load.add(_onRequestLoad);
    request.on.error.add(_onRequestError);
    request.send();
    
    return _loadCompleter.future;
  }
  
  //-------------------------------------------------------------------------------------------------
  
  num get length()
  {
    return _buffer.duration;
  }
  
  SoundChannel play([bool loop = false, SoundTransform soundTransform = null])
  {
    if (soundTransform == null)
      soundTransform = new SoundTransform();
    
    return new WebAudioApiSoundChannel(this, loop, soundTransform);
  }
    
  //-------------------------------------------------------------------------------------------------
  
  _onRequestLoad(html.Event event)
  {
    html.XMLHttpRequest request = event.target;

    _audioContext.decodeAudioData(request.response, _audioBufferLoaded, _audioBufferError);
  }
  
  _onRequestError(html.Event event)
  {
    if (_loadCompleter.future.isComplete == false)
      _loadCompleter.completeException("Failed to load audio.");
  }
  
  bool _audioBufferLoaded(html.AudioBuffer buffer)
  {
    _buffer = buffer;
    
    if (_loadCompleter.future.isComplete == false)
      _loadCompleter.complete(this);
    
    return true;
  }
  
  bool _audioBufferError(error)
  {
    if (_loadCompleter.future.isComplete == false)
      _loadCompleter.completeException("Failed to decode audio.");

    return true;
  }
}
