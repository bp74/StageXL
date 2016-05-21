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

  final List<SoundSpriteSegment> _segments = new List<SoundSpriteSegment>();
  Sound _sound;

  //-------------------------------------------------------------------------------------------------

  static Future<SoundSprite> load(String url, [SoundLoadOptions soundLoadOptions = null]) {

    Completer<SoundSprite> completer = new Completer<SoundSprite>();
    SoundSprite soundSprite = new SoundSprite();

    HttpRequest.getString(url).then((soundSpriteJson) {

      var data = JSON.decode(soundSpriteJson);
      var urls = data['urls'];
      var segments = data["sprite"];
      var soundUrls = new List<String>();

      if (segments is Map<String, List>) {
        for (String segment in segments.keys) {
          var segmentList = segments[segment];
          var startTime = ensureNum(segmentList[0]);
          var duration = ensureNum(segmentList[1]);
          var loop = ensureBool(segmentList.length > 2 && segmentList[2]);
          var sss = new SoundSpriteSegment(soundSprite, segment, startTime, duration, loop);
          soundSprite._segments.add(sss);
        }
      }

      if (urls is List<String>) {
        soundUrls.addAll(urls.map((u) => replaceFilename(url, u)));
      }

      soundLoadOptions = (soundLoadOptions == null)
          ? Sound.defaultLoadOptions.clone()
          : soundLoadOptions.clone();

      soundLoadOptions.alternativeUrls = soundUrls.skip(1).toList();

      Sound.load(soundUrls[0], soundLoadOptions).then((Sound sound) {
        soundSprite._sound = sound;
        completer.complete(soundSprite);
      }).catchError((error) {
        completer.completeError(new StateError("Failed to load sound."));
      });

    }).catchError((error) {
      completer.completeError(new StateError("Failed to load json file."));
    });

    return completer.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Sound get sound => _sound;

  List<SoundSpriteSegment> get segments => _segments.toList(growable: false);
  List<String> get segmentNames => _segments.map((s) => s.name).toList(growable: false);

  //-------------------------------------------------------------------------------------------------

  SoundSpriteSegment getSegment(String name) {

    for (int i = 0; i < _segments.length; i++) {
      var s = _segments[i];
      if (s.name == name) return s;
    }

    throw new ArgumentError("SoundSpriteSegment not found: '$name'");
  }

  SoundChannel play(String name, [bool loop, SoundTransform soundTransform]) {
    return this.getSegment(name).play(loop, soundTransform);
  }

}
