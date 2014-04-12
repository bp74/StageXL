part of stagexl;

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

      if (segments is Map) {
        for (String segment in segments.keys) {
          var segmentList = segments[segment] as List;
          var startTime = _ensureNum(segmentList[0]);
          var duration = _ensureNum(segmentList[1]);
          var loop = segmentList.length >= 3 ? _ensureBool(segmentList[2]) : false;
          var sss = new SoundSpriteSegment(soundSprite, segment, startTime, duration, loop);
          soundSprite._segments.add(sss);
        }
      }

      var soundUrls = urls.map((u) => _replaceFilename(url, u)).toList();
      var soundUrl = soundUrls[0];

      soundLoadOptions = (soundLoadOptions == null)
          ? Sound.defaultLoadOptions.clone()
          : soundLoadOptions.clone();

      soundLoadOptions.alternativeUrls = soundUrls.skip(1).toList();

      Sound.load(soundUrl, soundLoadOptions).then((Sound sound) {
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

  //-------------------------------------------------------------------------------------------------

}
