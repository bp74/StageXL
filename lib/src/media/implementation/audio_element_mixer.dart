part of stagexl.all;

class AudioElementMixer {

  num _volume = 1.0;

  static final StreamController<num> _volumeChangedEvent =
      new StreamController<num>.broadcast();

  Stream<num> get onVolumeChanged => _volumeChangedEvent.stream;

  num get volume => _volume;

  void applySoundTransform(SoundTransform value) {
    _volume = value.volume;
    _volumeChangedEvent.add(_volume);
  }
}
