class WebAudioApiSoundChannel extends SoundChannel
{
  WebAudioApiSound _webAudioApiSound;
  html.AudioGainNode _gainNode;
  html.AudioBufferSourceNode _sourceNode;
  
  num _position;  
  bool _loop;
  SoundTransform _soundTransform;
  
  WebAudioApiSoundChannel(WebAudioApiSound webAudioApiSound, bool loop, SoundTransform soundTransform)
  {
    _webAudioApiSound = webAudioApiSound;
    _loop = loop;
    
    html.AudioContext context = _webAudioApiSound._audioContext;

    _gainNode = context.createGainNode();
    _gainNode.connect(context.destination, 0, 0);
    
    this.soundTransform = soundTransform;
    
    _sourceNode = context.createBufferSource();
    _sourceNode.buffer = _webAudioApiSound._buffer;
    _sourceNode.loop = loop;
    _sourceNode.connect(_gainNode, 0, 0);
    _sourceNode.noteOn(0);
  }
  
  //-------------------------------------------------------------------------------------------------
  
  SoundTransform get soundTransform() => _soundTransform;
  
  void set soundTransform(SoundTransform value)
  {
    _soundTransform = value;
    _gainNode.gain.value =  (_soundTransform != null) ? Math.pow(_soundTransform.volume , 2) : 1;
  }
 
  //-------------------------------------------------------------------------------------------------
   
  void stop()
  {
    _sourceNode.noteOff(0);
  }
}
