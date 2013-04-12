part of stagexl;

class TextureAtlas {
  
  final ImageElement _imageElement = new ImageElement();
  final List<TextureAtlasFrame> _frames = new List<TextureAtlasFrame>();

  //-------------------------------------------------------------------------------------------------

  static Future<TextureAtlas> load(String url, String textureAtlasFormat) {
    
    Completer<TextureAtlas> completer = new Completer<TextureAtlas>();
    TextureAtlas textureAtlas = new TextureAtlas();

    switch(textureAtlasFormat) {
      
      case TextureAtlasFormat.JSON:
      case TextureAtlasFormat.JSONARRAY:
        
        HttpRequest.getString(url).then((textureAtlasJson) {
        
          var data = json.parse(textureAtlasJson);
          var frames = data["frames"];
          var meta = data["meta"];
          
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

          ImageElement imageElement = textureAtlas._imageElement;
          StreamSubscription onLoadSubscription;
          StreamSubscription onErrorSubscription;
          
          onLoadSubscription = imageElement.onLoad.listen((e) {
            onLoadSubscription.cancel();
            onErrorSubscription.cancel();
            completer.complete(textureAtlas);
          });
          
          onErrorSubscription = imageElement.onError.listen((e) {
            onLoadSubscription.cancel();
            onErrorSubscription.cancel();
            completer.completeError(new StateError("Failed to load image."));
          });
          
          imageElement.src = _replaceFilename(url, meta["image"]);
        
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

  BitmapData getBitmapData(String name) {
    
    for(int i = 0; i < _frames.length; i++)
      if (_frames[i].name == name)
        return new BitmapData.fromTextureAtlasFrame(_frames[i]);

    throw new ArgumentError("TextureAtlasFrame not found: '$name'");
  }

  //-------------------------------------------------------------------------------------------------

  List<BitmapData> getBitmapDatas(String namePrefix) {
    
    var bitmapDataList = new List<BitmapData>();

    for(int i = 0; i < _frames.length; i++)
      if (_frames[i].name.startsWith(namePrefix))
        bitmapDataList.add(new BitmapData.fromTextureAtlasFrame(_frames[i]));

    return bitmapDataList;
  }

  //-------------------------------------------------------------------------------------------------

  List<String> get frameNames {
    
    return _frames.map((f) => f.name).toList(growable: false);
  }

}
