part of dartflash;

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

        var request = new html.HttpRequest();

        request.open('GET', url, true);

        request.on.load.add((event)
        {
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

          var data = JSON.parse(request.responseText);
          var frames = data["frames"];
          var meta = data["meta"];

          if (frames is List)
            for(var frame in frames)
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

  html.ImageElement get imageElement => _imageElement;

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

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static String _getFilenameWithoutExtension(String filename)
  {
    RegExp regex = const RegExp(r"(.+?)(\.[^.]*$|$)", multiLine:false, ignoreCase:true);
    Match match = regex.firstMatch(filename);
    return match.group(1);
  }

  static String _replaceFilename(String url, String filename)
  {
    RegExp regex = const RegExp(r"^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))", multiLine:false, ignoreCase:true);
    Match match = regex.firstMatch(url);
    String path = match.group(1);
    return (path == null) ? filename : "$path$filename";
  }


}
