class WebAudioApiSoundChannel extends SoundChannel
{
  WebAudioApiSound _webAudioApiSound;
  html.AudioGainNode _gainNode;
  html.AudioBufferSourceNode _sourceNode;

  bool _loop;
  SoundTransform _soundTransform;

  WebAudioApiSoundChannel(WebAudioApiSound webAudioApiSound, bool loop, SoundTransform soundTransform)
  {
    _webAudioApiSound = webAudioApiSound;
    _loop = loop;
    _soundTransform = soundTransform;

    var context = SoundMixer._audioContext;

    _gainNode = context.createGainNode();
    _gainNode.connect(context.destination, 0, 0);
    _gainNode.gain.value =  (_soundTransform != null) ? pow(_soundTransform.volume , 2) : 1;

    _sourceNode = context.createBufferSource();
    _sourceNode.buffer = _webAudioApiSound._buffer;
    _sourceNode.loop = loop;
    _sourceNode.connect(_gainNode, 0, 0);
    _sourceNode.noteOn(0);
  }

  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  void set soundTransform(SoundTransform value)
  {
    _soundTransform = value;
    _gainNode.gain.value =  (_soundTransform != null) ? pow(_soundTransform.volume , 2) : 1;
  }

  //-------------------------------------------------------------------------------------------------

  void stop()
  {
    _sourceNode.noteOff(0);
  }
}
