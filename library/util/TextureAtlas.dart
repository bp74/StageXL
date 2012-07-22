class TextureAtlas
{
  html.ImageElement _imageElement;
  List<TextureAtlasFrame> _frames;

  TextureAtlas()
  {
    _imageElement = new html.ImageElement();
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

        html.XMLHttpRequest request = new html.XMLHttpRequest();
        request.open('GET', url, true);

        request.on.load.add((event)
        {
          void parseFrame(String filename, Dynamic frame) {
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

          Dynamic data = json.JSON.parse(request.responseText);
          Dynamic frames = data["frames"];
          Dynamic meta = data["meta"];

          if (frames is List)
            for(Dynamic frame in frames)
              parseFrame(frame["filename"], frame);

          if (frames is Map)
            for(String filename in frames.getKeys())
               parseFrame(filename, frames[filename]);

          textureAtlas._imageElement.on.load.add((e) => completer.complete(textureAtlas));
          textureAtlas._imageElement.on.error.add((e) => completer.completeException("Failed to load image."));
          textureAtlas._imageElement.src = _replaceFilename(url, meta["image"]);
        });

        request.on.error.add((event) => completer.completeException("Failed to load json file."));
        request.send();

        break;
    }

    return completer.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  html.ImageElement get imageElement() => _imageElement;

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name)
  {
    BitmapData bitmapData;

    for(int i = 0; i < _frames.length && bitmapData == null; i++)
      if (_frames[i].name == name)
        bitmapData = new BitmapData.fromTextureAtlasFrame(_frames[i]);

    if (bitmapData == null)
      throw "TextureAtlasFrame not found: '$name'";

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
  //-------------------------------------------------------------------------------------------------

  static String _getFilenameWithoutExtension(String filename)
  {
    RegExp exp = const RegExp(@"(.+?)(\.[^.]*$|$)", false, true);
    Match match = exp.firstMatch(filename);
    return match.group(1);
  }

  static String _replaceFilename(String url, String filename)
  {
    RegExp exp = const RegExp(@"^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))", false, true);
    Match match = exp.firstMatch(url);
    String path = match.group(1);
    return (path == null) ? filename : "$path$filename";
  }


}
