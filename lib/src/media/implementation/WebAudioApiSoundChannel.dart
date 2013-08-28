part of stagexl;

class WebAudioApiSoundChannel extends SoundChannel {

  SoundTransform _soundTransform;
  bool _loop;

  AudioBufferSourceNode _sourceNode;
  WebAudioApiSound _webAudioApiSound;
  WebAudioApiMixer _webAudioApiMixer;

  WebAudioApiSoundChannel(WebAudioApiSound webAudioApiSound, bool loop, SoundTransform soundTransform) {

    _webAudioApiSound = webAudioApiSound;
    _soundTransform = (soundTransform != null) ? soundTransform : new SoundTransform();
    _loop = loop;

    _webAudioApiMixer = new WebAudioApiMixer(SoundMixer._webAudioApiMixer.inputNode);
    _webAudioApiMixer.applySoundTransform(_soundTransform);

    _sourceNode = WebAudioApiMixer.audioContext.createBufferSource();
    _sourceNode.buffer = _webAudioApiSound._buffer;
    _sourceNode.loop = loop;
    _sourceNode.connectNode(_webAudioApiMixer.inputNode);
    _sourceNode.start(0);
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
