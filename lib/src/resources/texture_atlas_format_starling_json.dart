part of stagexl.resources;

class _TextureAtlasFormatStarlingJson extends TextureAtlasFormat {

  const _TextureAtlasFormatStarlingJson();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    var source = await loader.getSource();
    var json = JSON.decode(source) as Map;
    var textureAtlas = new TextureAtlas();

    var imagePath = _getString(json, "imagePath", "");
    var renderTextureQuad = await loader.getRenderTextureQuad(imagePath);

    for(Map subTextureMap in json["SubTexture"]) {

      var name = _getString(subTextureMap, "name", "");
      var rotation = _getBool(subTextureMap, "rotated", false) ? 1 : 0;

      var frameX = _getInt(subTextureMap, "x", 0);
      var frameY = _getInt(subTextureMap, "y", 0);
      var frameWidth = _getInt(subTextureMap, "width", 0);
      var frameHeight = _getInt(subTextureMap, "height", 0);

      var offsetX = 0 - _getInt(subTextureMap, "frameX", 0);
      var offsetY = 0 - _getInt(subTextureMap, "frameY", 0);
      var originalWidth = _getInt(subTextureMap, "frameWidth", frameWidth);
      var originalHeight = _getInt(subTextureMap, "frameHeight", frameHeight);

      var textureAtlasFrame = new TextureAtlasFrame(
          textureAtlas, renderTextureQuad, name, rotation,
          offsetX, offsetY, originalWidth, originalHeight,
          frameX, frameY, frameWidth, frameHeight,
          null, null);

      textureAtlas.frames.add(textureAtlasFrame);
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  String _getString(Map map, String name, String defaultValue) {
    var value = map[name];
    return value is String ? value : defaultValue;
  }

  int _getInt(Map map, String name, int defaultValue) {
    var value = map[name];
    return value is int ? value : defaultValue;
  }

  bool _getBool(Map map, String name, bool defaultValue) {
    var value = map[name];
    return value is bool ? value : defaultValue;
  }
}
