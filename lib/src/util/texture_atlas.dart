part of stagexl;

class TextureAtlas {

  final List<TextureAtlasFrame> _frames = new List<TextureAtlasFrame>();
  RenderTexture _renderTexture;

  //-------------------------------------------------------------------------------------------------

  static Future<TextureAtlas> load(String url, String textureAtlasFormat, [
      BitmapDataLoadOptions bitmapDataLoadOptions]) {

    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();

    switch (textureAtlasFormat) {

      case TextureAtlasFormat.JSON:
      case TextureAtlasFormat.JSONARRAY:

        HttpRequest.getString(url).then((textureAtlasJson) {

          var data = JSON.decode(textureAtlasJson);
          var frames = data["frames"];
          var meta = data["meta"];
          var imageUrl = _replaceFilename(url, meta["image"]);

          if (frames is List) {
            for (var frame in frames) {
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

          if (bitmapDataLoadOptions == null) {
            bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
          }

          var autoHiDpi = bitmapDataLoadOptions.autoHiDpi;
          var webpAvailable = bitmapDataLoadOptions.webp;
          var loader = RenderTexture.load(imageUrl, autoHiDpi, webpAvailable);

          loader.then((RenderTexture renderTexture) {
            textureAtlas._renderTexture = renderTexture;
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

  RenderTexture get renderTexture => _renderTexture;

  List<TextureAtlasFrame> get frames => _frames.toList(growable: false);
  List<String> get frameNames => _frames.map((f) => f.name).toList(growable: false);

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name) {

    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name == name) return frame.getBitmapData();
    }

    throw new ArgumentError("TextureAtlasFrame not found: '$name'");
  }

  //-------------------------------------------------------------------------------------------------

  List<BitmapData> getBitmapDatas(String namePrefix) {

    var bitmapDataList = new List<BitmapData>();

    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name.startsWith(namePrefix)) {
        bitmapDataList.add(frame.getBitmapData());
      }
    }

    return bitmapDataList;
  }

}
