part of stagexl;

class SoundSpriteSegment {

  final SoundSprite _soundSprite;
  final String _name;
  final bool _loop;

  final num _start;
  final num _duration;
  
  SoundSpriteSegment.fromJson(SoundSprite soundSprite, String name, num start, num duration, bool loop) :
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
  
  SoundChannel play() {
    return _soundSprite.sound.play(_loop, null, [_start, _duration]);
  }

}
