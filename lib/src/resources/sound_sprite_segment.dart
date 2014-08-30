part of stagexl.resources;

class SoundSpriteSegment {

  final SoundSprite _soundSprite;
  final String _name;

  final num _start;
  final num _duration;
  final bool _loop;

  SoundSpriteSegment(SoundSprite soundSprite, String name, num start, num duration, bool loop) :
    _soundSprite = soundSprite,
    _name = name,
    _start = start,
    _duration = duration,
    _loop = loop;

  //-------------------------------------------------------------------------------------------------

  SoundSprite get soundSprite => _soundSprite;
  String get name => _name;
  bool get loop => _loop;

  num get start => start;
  num get duration => duration;

  //-------------------------------------------------------------------------------------------------

  SoundChannel play([bool loop, SoundTransform soundTransform]) {
    if (loop == null) loop = _loop;
    if (soundTransform == null) soundTransform = new SoundTransform();
    return _soundSprite.sound.playSegment(_start, _duration, loop, soundTransform);
  }

}