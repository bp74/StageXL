part of stagexl;

class AudioElementMixer {

  num _volume = 1.0;

  static StreamController<num> _volumeChangedEvent = new StreamController<num>();
  Stream<num> onVolumeChanged = _volumeChangedEvent.stream.asBroadcastStream();

  num get volume => _volume;

  applySoundTransform(SoundTransform value) {
    _volume = value.volume;
    _volumeChangedEvent.add(_volume);
  }

}