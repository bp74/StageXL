part of stagexl;

class TextureAtlas {

  final List<TextureAtlasFrame> _frames = new List<TextureAtlasFrame>();
  RenderTexture _renderTexture;

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

          RenderTexture.load(imageUrl).then((RenderTexture renderTexture) {
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

  List<String> get frameNames  => _frames.map((f) => f.name).toList(growable: false);

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name) {

    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name == name) return _getBitmapData(frame);
    }

    throw new ArgumentError("TextureAtlasFrame not found: '$name'");
  }

  //-------------------------------------------------------------------------------------------------

  List<BitmapData> getBitmapDatas(String namePrefix) {

    var bitmapDataList = new List<BitmapData>();

    for(int i = 0; i < _frames.length; i++) {
      var frame = _frames[i];
      if (frame.name.startsWith(namePrefix)) {
        bitmapDataList.add(_getBitmapData(frame));
      }
    }

    return bitmapDataList;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData _getBitmapData(TextureAtlasFrame textureAtlasFrame) {

    int x1 = 0, y1 = 0, x3 = 0, y3 = 0;
    int offsetX = textureAtlasFrame.offsetX;
    int offsetY = textureAtlasFrame.offsetY;
    int width = textureAtlasFrame.originalWidth;
    int height = textureAtlasFrame.originalHeight;

    if (textureAtlasFrame.rotated == false) {
      x1 = textureAtlasFrame.frameX;
      y1 = textureAtlasFrame.frameY;
      x3 = textureAtlasFrame.frameX + textureAtlasFrame.frameWidth;
      y3 = textureAtlasFrame.frameY + textureAtlasFrame.frameHeight;
    } else {
      x1 = textureAtlasFrame.frameX + textureAtlasFrame.frameHeight;
      y1 = textureAtlasFrame.frameY;
      x3 = textureAtlasFrame.frameX;
      y3 = textureAtlasFrame.frameY + textureAtlasFrame.frameWidth;
    }

    var renderTextureQuad = new RenderTextureQuad(_renderTexture, x1, y1, x3, y3, 0, 0);
    var bitmapData = new BitmapData.fromRenderTextureQuad(renderTextureQuad);
    var rectangle = new Rectangle(-offsetX, -offsetY, width, height);

    return new BitmapData.fromBitmapData(bitmapData, rectangle);
  }
}
