part of '../../media.dart';

class WebAudioApiMixer {
  static final web.AudioContext audioContext = web.AudioContext();

  web.AudioNode? _inputNode;
  late final web.GainNode _volumeNode;

  WebAudioApiMixer([web.AudioNode? inputNode]) {
    _inputNode = inputNode ?? audioContext.destination;
    _volumeNode = audioContext.createGain();
    _volumeNode.connect(_inputNode!);
  }

  void applySoundTransform(SoundTransform soundTransform) {
    final time = audioContext.currentTime;
    final value = pow(soundTransform.volume, 2);
    _volumeNode.gain.setValueAtTime(value, time);
  }

  web.AudioNode get inputNode => _volumeNode;
}
