part of stagexl;

class SoundSprite {

  final List<SoundSpriteSegment> _segments = new List<SoundSpriteSegment>();
  Sound _sound;

  //-------------------------------------------------------------------------------------------------

  static Future<SoundSprite> load(String url) {

    Completer<SoundSprite> completer = new Completer<SoundSprite>();
    SoundSprite soundSprite = new SoundSprite();

    HttpRequest.getString(url).then((soundSpriteJson) {
          var data = JSON.decode(soundSpriteJson);
          var urls = data['urls'];
          for(var i=0; i<urls.length; i++) {
            var u = urls[i];
            urls[i] = _replaceFilename(url, u);
          }
          
          var segments = data["sprite"];

          if (segments is Map) {
            for(String segment in segments.keys) {
              var segmentList = segments[segment] as List;
              if(segmentList.length<3) segmentList[2] = false;
              var sss = new SoundSpriteSegment.fromJson(soundSprite, segment, segmentList[0], segmentList[1], segmentList[2]);
              soundSprite._segments.add(sss);
            }
          }

          var loader = Sound.load(urls);
          
          loader.then((Sound sound) {
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

    for(int i = 0; i < _segments.length; i++) {
      var s = _segments[i];
      if (s.name == name) return s;
    }

    throw new ArgumentError("SoundSpriteSegment not found: '$name'");
  }
  
  SoundChannel play(String name) {

    for(int i = 0; i < _segments.length; i++) {
      var s = _segments[i];
      if (s.name == name) return _sound.play(s.loop, null, [s.start, s.duration]);
    }

    throw new ArgumentError("SoundSpriteSegment not found: '$name'");
  }

  //-------------------------------------------------------------------------------------------------

}
