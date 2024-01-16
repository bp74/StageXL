part of '../../media.dart';

class WebAudioApiMixer {
  static final AudioContext audioContext = AudioContext();

  AudioNode? _inputNode;
  late final GainNode _volumeNode;

  WebAudioApiMixer([AudioNode? inputNode]) {
    _inputNode = inputNode ?? audioContext.destination;
    _volumeNode = audioContext.createGain();
    _volumeNode.connectNode(_inputNode!);
  }

  void applySoundTransform(SoundTransform soundTransform) {
    final time = audioContext.currentTime!;
    final value = pow(soundTransform.volume, 2);
    _volumeNode.gain!.setValueAtTime(value, time);
  }

  AudioNode get inputNode => _volumeNode;
}
