part of stagexl.resources;

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
  Sound? _sound;

  //----------------------------------------------------------------------------

  static Future<SoundSprite> load(String url,
      [SoundLoadOptions? soundLoadOptions]) async {
    var soundSprite = SoundSprite();

    var soundSpriteJson = await HttpRequest.getString(url);
    var data = json.decode(soundSpriteJson);
    var urls = data['urls'] as List<dynamic>;
    var segments = data['sprite'];
    var soundUrls = <String?>[];

    if (segments is Map) {
      for (var segment in segments.keys as Iterable<String>) {
        var segmentList = segments[segment] as List;
        var startTime = segmentList[0] as num;
        var duration = segmentList[1] as num;
        var loop = segmentList.length > 2 && segmentList[2] as bool;
        var sss =
            SoundSpriteSegment(soundSprite, segment, startTime, duration, loop);
        soundSprite._segments.add(sss);
      }
    }

    soundUrls.addAll(urls.map((u) => replaceFilename(url, u)));
    soundLoadOptions = (soundLoadOptions ?? Sound.defaultLoadOptions).clone();
    soundLoadOptions.alternativeUrls = soundUrls.skip(1).toList();
    soundSprite._sound = await Sound.load(soundUrls[0], soundLoadOptions);
    return soundSprite;
  }

  //----------------------------------------------------------------------------

  Sound? get sound => _sound;

  List<SoundSpriteSegment> get segments {
    return _segments.toList(growable: false);
  }

  List<String> get segmentNames {
    return _segments.map((s) => s.name).toList(growable: false);
  }

  //----------------------------------------------------------------------------

  SoundSpriteSegment getSegment(String name) {
    try {
      var segment = _segments.firstWhere((s) => s.name == name);
      return segment;
    } on StateError catch (_) {
      throw ArgumentError("SoundSpriteSegment not found: '$name'");
    }
  }

  SoundChannel play(String name, [bool? loop, SoundTransform? soundTransform]) {
    return getSegment(name).play(loop, soundTransform);
  }
}
