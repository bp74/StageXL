part of stagexl;

class WebAudioApiSoundChannel extends SoundChannel {

  SoundTransform _soundTransform;
  bool _loop;
  List<num> _segment;

  AudioBufferSourceNode _sourceNode;
  WebAudioApiSound _webAudioApiSound;
  WebAudioApiMixer _webAudioApiMixer;

  WebAudioApiSoundChannel(WebAudioApiSound webAudioApiSound, bool loop, SoundTransform soundTransform, List<num> segment) {

    _webAudioApiSound = webAudioApiSound;
    _soundTransform = (soundTransform != null) ? soundTransform : new SoundTransform();
    _loop = loop;
    _segment = segment;

    _webAudioApiMixer = new WebAudioApiMixer(SoundMixer._webAudioApiMixer.inputNode);
    _webAudioApiMixer.applySoundTransform(_soundTransform);

    _sourceNode = WebAudioApiMixer.audioContext.createBufferSource();
    _sourceNode.buffer = _webAudioApiSound._buffer;
    _sourceNode.loop = _loop;
    _sourceNode.connectNode(_webAudioApiMixer.inputNode);
    _sourceNode.start(0, _segment[0], _segment[1]);
  }

  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  void set soundTransform(SoundTransform value) {

    _soundTransform = (soundTransform != null) ? soundTransform : new SoundTransform();
    _webAudioApiMixer.applySoundTransform(value);
  }

  void stop() {

    _sourceNode.stop(0);
  }
}
