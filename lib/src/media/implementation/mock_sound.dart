part of '../../media.dart';

class MockSound extends Sound {
  MockSound._();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions? soundLoadOptions]) =>
      Future<Sound>.value(MockSound._());

  static Future<Sound> loadDataUrl(String dataUrl,
          [SoundLoadOptions? soundLoadOptions]) =>
      Future<Sound>.value(MockSound._());

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  @override
  SoundEngine get engine => SoundEngine.Mockup;

  @override
  num get length => double.nan;

  @override
  SoundChannel play([bool loop = false, SoundTransform? soundTransform]) =>
      MockSoundChannel(this, loop, soundTransform);

  @override
  SoundChannel playSegment(num startTime, num duration,
          [bool loop = false, SoundTransform? soundTransform]) =>
      MockSoundChannel(this, loop, soundTransform);
}
