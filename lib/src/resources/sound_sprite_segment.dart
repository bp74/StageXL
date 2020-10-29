part of stagexl.resources;

class SoundSpriteSegment {
  final SoundSprite soundSprite;
  final String name;
  final num startTime;
  final num duration;
  final bool loop;

  SoundSpriteSegment(
      this.soundSprite, this.name, this.startTime, this.duration, this.loop);

  SoundChannel play([bool? loop, SoundTransform? soundTransform]) {
    return soundSprite.sound
        .playSegment(startTime, duration, loop ?? this.loop, soundTransform);
  }
}
