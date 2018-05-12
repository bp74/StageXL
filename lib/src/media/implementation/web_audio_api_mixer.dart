part of stagexl.media;

class WebAudioApiMixer {
  static final AudioContext audioContext = new AudioContext();

  AudioNode _inputNode;
  GainNode _volumeNode;

  WebAudioApiMixer([AudioNode inputNode]) {
    _inputNode = inputNode ?? audioContext.destination;
    _volumeNode = audioContext.createGain();
    _volumeNode.connectNode(_inputNode);
  }

  void applySoundTransform(SoundTransform soundTransform) {
    var time = audioContext.currentTime;
    var value = pow(soundTransform.volume, 2);
    _volumeNode.gain.setValueAtTime(value, time);
  }

  AudioNode get inputNode => _volumeNode;
}
