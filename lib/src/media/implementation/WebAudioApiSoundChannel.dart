part of dartflash;

class WebAudioApiSoundChannel extends SoundChannel
{
  WebAudioApiSound _webAudioApiSound;
  bool _loop;
  SoundTransform _soundTransform;
  
  // ToDo: specify type when AudioGainNode was renamed to GainNode.
  var _gainNode;
  var _sourceNode;

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
    _sourceNode.start(0);
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
    _sourceNode.stop(0);
  }
}
