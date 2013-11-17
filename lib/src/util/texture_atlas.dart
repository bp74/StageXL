part of stagexl;

class TextureAtlas {

  final List<TextureAtlasFrame> _frames = new List<TextureAtlasFrame>();
  BitmapData _bitmapData;

  //-------------------------------------------------------------------------------------------------

  static Future<TextureAtlas> load(String url, String textureAtlasFormat) {

    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();

    switch(textureAtlasFormat) {

      case TextureAtlasFormat.JSON:
      case TextureAtlasFormat.JSONARRAY:

        HttpRequest.getString(url).then((textureAtlasJson) {

          var data = JSON.decode(textureAtlasJson);
          var frames = data["frames"];
          var meta = data["meta"];
          var imageUrl = _replaceFilename(url, meta["image"]);

          if (frames is List) {
            for(var frame in frames) {
              var frameMap = frame as Map;
              var fileName = frameMap["filename"] as String;
              var frameName = _getFilenameWithoutExtension(fileName);
              var taf = new TextureAtlasFrame.fromJson(textureAtlas, frameName, frameMap);
              textureAtlas._frames.add(taf);
            }
          }

          if (frames is Map) {
            for(String fileName in frames.keys) {
              var frameMap = frames[fileName] as Map;
              var frameName = _getFilenameWithoutExtension(fileName);
              var taf = new TextureAtlasFrame.fromJson(textureAtlas, frameName, frameMap);
              textureAtlas._frames.add(taf);
            }
          }

          BitmapData.load(imageUrl).then((BitmapData bitmapData) {
            textureAtlas._bitmapData = bitmapData;
            completer.complete(textureAtlas);
          }).catchError((error) {
            completer.completeError(new StateError("Failed to load image."));
          });

        }).catchError((error) {
          completer.completeError(new StateError("Failed to load json file."));
        });

        break;
    }

    return completer.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name) {

    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name == name) {
        return new BitmapData.fromTextureAtlasFrame(frame);
      }
    }

    throw new ArgumentError("TextureAtlasFrame not found: '$name'");
  }

  //-------------------------------------------------------------------------------------------------

  List<BitmapData> getBitmapDatas(String namePrefix) {

    var bitmapDataList = new List<BitmapData>();

    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name.startsWith(namePrefix)) {
        bitmapDataList.add(new BitmapData.fromTextureAtlasFrame(frame));
      }
    }

    return bitmapDataList;
  }

  //-------------------------------------------------------------------------------------------------

  List<String> get frameNames {

    return _frames.map((f) => f.name).toList(growable: false);
  }

}
