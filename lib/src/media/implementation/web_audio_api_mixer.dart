part of stagexl;

class WebAudioApiMixer {

  static AudioContext audioContext = new AudioContext();

  AudioNode _inputNode;
  GainNode _volumeNode;

  WebAudioApiMixer([AudioNode inputNode]) {
    _inputNode = (inputNode != null) ? inputNode : audioContext.destination;
    _volumeNode = audioContext.createGain();
    _volumeNode.connectNode(_inputNode);
  }

  void applySoundTransform(SoundTransform soundTransform) {
    var volume = soundTransform.volume;
    _volumeNode.gain.value = pow(volume, 2);
  }

  AudioNode get inputNode => _volumeNode;
}