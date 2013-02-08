part of dartflash;

class TextureAtlas
{
  ImageElement _imageElement;
  List<TextureAtlasFrame> _frames;

  TextureAtlas()
  {
    _imageElement = new ImageElement();
    _frames = new List<TextureAtlasFrame>();
  }

  //-------------------------------------------------------------------------------------------------

  static Future<TextureAtlas> load(String url, String textureAtlasFormat)
  {
    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();

    switch(textureAtlasFormat)
    {
      case TextureAtlasFormat.JSON:
      case TextureAtlasFormat.JSONARRAY:

        void parseFrame(String filename, Map frame) {
          var frameName = _getFilenameWithoutExtension(filename);
          var taf = new TextureAtlasFrame(frameName, textureAtlas);
          taf._frameX = frame["frame"]["x"].toInt();
          taf._frameY = frame["frame"]["y"].toInt();
          taf._frameWidth = frame["frame"]["w"].toInt();
          taf._frameHeight = frame["frame"]["h"].toInt();
          taf._offsetX = frame["spriteSourceSize"]["x"].toInt();
          taf._offsetY = frame["spriteSourceSize"]["y"].toInt();
          taf._originalWidth = frame["sourceSize"]["w"].toInt();
          taf._originalHeight = frame["sourceSize"]["h"].toInt();
          taf._rotated = frame["rotated"] as bool;
          textureAtlas._frames.add(taf);
        }
        
        HttpRequest.getString(url).then((textureAtlasJson) {
        
          var data = json.parse(textureAtlasJson);
          var frames = data["frames"];
          var meta = data["meta"];

          if (frames is List)
            for(var frame in frames)
              parseFrame(frame["filename"], frame);

          if (frames is Map)
            for(String filename in frames.keys)
               parseFrame(filename, frames[filename]);

          textureAtlas._imageElement
            ..onLoad.listen((e) => completer.complete(textureAtlas))
            ..onError.listen((e) => completer.completeError(new StateError("Failed to load image.")))
            ..src = _replaceFilename(url, meta["image"]);
        
        }).catchError((error) {
          
          completer.completeError(new StateError("Failed to load json file."));
          
        });
        
        break;
    }

    return completer.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  ImageElement get imageElement => _imageElement;

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name)
  {
    BitmapData bitmapData;

    for(int i = 0; i < _frames.length && bitmapData == null; i++)
      if (_frames[i].name == name)
        bitmapData = new BitmapData.fromTextureAtlasFrame(_frames[i]);

    if (bitmapData == null)
      throw new ArgumentError("TextureAtlasFrame not found: '$name'");

    return bitmapData;
  }

  //-------------------------------------------------------------------------------------------------

  List<BitmapData> getBitmapDatas(String namePrefix)
  {
    List<BitmapData> bitmapDataList = new List<BitmapData>();

    for(int i = 0; i < _frames.length; i++)
      if (_frames[i].name.indexOf(namePrefix) == 0)
        bitmapDataList.add(new BitmapData.fromTextureAtlasFrame(_frames[i]));

    return bitmapDataList;
  }

  //-------------------------------------------------------------------------------------------------

  List<String> get frameNames
  {
    List<String> names = new List<String>();

    for(int i = 0; i < _frames.length; i++)
      names.add(_frames[i].name);

    return names;
  }

}
