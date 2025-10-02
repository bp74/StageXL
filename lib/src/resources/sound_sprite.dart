part of '../resources.dart';

/// A SoundSprite combines multiple audio files into a single audio file.
///
/// iOS, Windows Phone and some Android phones have very limited HTML5 audio
/// support. They only support playing single file at a time and loading in
/// new files requires user interaction and has a big latency. To overcome
/// this there is a technique to combine all audio into single file and only
/// play/loop certain parts of that file
///
/// To generate SoundSprites, please check this GitHub repository:
/// https://github.com/realbluesky/soundsprite

class SoundSprite {
  final List<SoundSpriteSegment> _segments = <SoundSpriteSegment>[];
  late final Sound _sound;

  //----------------------------------------------------------------------------

  static Future<SoundSprite> load(String url,
      [SoundLoadOptions? soundLoadOptions]) async {
    final soundSprite = SoundSprite();

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final soundSpriteJson = response.body;
      final data = json.decode(soundSpriteJson) as Map;
      final urls = (data['urls'] as List).cast<String>();
      final segments = data['sprite'];
      final soundUrls = <String>[];

      if (segments is Map) {
        for (var segment in segments.keys as Iterable<String>) {
          final segmentList = segments[segment] as List;
          final startTime = segmentList[0] as num;
          final duration = segmentList[1] as num;
          final loop = segmentList.length > 2 && segmentList[2] as bool;
          final sss =
              SoundSpriteSegment(soundSprite, segment, startTime, duration, loop);
          soundSprite._segments.add(sss);
        }
      }

      soundUrls.addAll(urls.map((u) => replaceFilename(url, u)));
      soundLoadOptions = (soundLoadOptions ?? Sound.defaultLoadOptions).clone();
      soundLoadOptions.alternativeUrls = soundUrls.skip(1).toList();
      soundSprite._sound = await Sound.load(soundUrls[0], soundLoadOptions);
      return soundSprite;
    } else {
      throw StateError('Failed to load sound sprite JSON.');
    }
  }

  //----------------------------------------------------------------------------

  Sound get sound => _sound;

  List<SoundSpriteSegment> get segments => _segments.toList(growable: false);

  List<String> get segmentNames =>
      _segments.map((s) => s.name).toList(growable: false);

  //----------------------------------------------------------------------------

  SoundSpriteSegment getSegment(String name) {
    try {
      return _segments.firstWhere((s) => s.name == name);
      // ignore: avoid_catching_errors
    } on StateError catch (_) {
      throw ArgumentError("SoundSpriteSegment not found: '$name'");
    }
  }

  SoundChannel play(String name,
          [bool? loop, SoundTransform? soundTransform]) =>
      getSegment(name).play(loop, soundTransform);
}
