part of '../../media.dart';

class AudioElementMixer {
  num _volume = 1.0;

  final StreamController<num> _volumeChangedEvent =
      StreamController<num>.broadcast();

  Stream<num> get onVolumeChanged => _volumeChangedEvent.stream;

  //---------------------------------------------------------------------------

  num get volume => _volume;

  void applySoundTransform(SoundTransform value) {
    _volume = value.volume;
    _volumeChangedEvent.add(_volume);
  }
}
