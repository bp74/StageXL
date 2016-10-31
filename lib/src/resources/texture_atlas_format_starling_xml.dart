part of stagexl.resources;

class _TextureAtlasFormatStarlingXml  extends TextureAtlasFormat {

  const _TextureAtlasFormatStarlingXml();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    var source = await loader.getSource();
    var xmlRoot = parse(source).rootElement;
    var textureAtlas = new TextureAtlas();

    var imagePath = _getString(xmlRoot, "imagePath", "");
    var renderTextureQuad = await loader.getRenderTextureQuad(imagePath);

    for(var subTextureXml in xmlRoot.findAllElements("SubTexture")) {

      var name = _getString(subTextureXml, "name", "");
      var rotation = _getBool(subTextureXml, "rotated", false) ? 1 : 0;

      var frameX = _getInt(subTextureXml, "x", 0);
      var frameY = _getInt(subTextureXml, "y", 0);
      var frameWidth = _getInt(subTextureXml, "width", 0);
      var frameHeight = _getInt(subTextureXml, "height", 0);

      var offsetX = 0 - _getInt(subTextureXml, "frameX", 0);
      var offsetY = 0 - _getInt(subTextureXml, "frameY", 0);
      var originalWidth = _getInt(subTextureXml, "frameWidth", frameWidth);
      var originalHeight = _getInt(subTextureXml, "frameHeight", frameHeight);

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

  String _getAttributeValue(XmlElement xml, String name) {
    for(var attribute in xml.attributes) {
      if (attribute.name.local == name) return attribute.value;
    }
    return null;
  }

  String _getString(XmlElement xml, String name, String defaultValue) {
    var value = _getAttributeValue(xml, name);
    return value is String ? value : defaultValue;
  }

  int _getInt(XmlElement xml, String name, int defaultValue) {
    var value = _getAttributeValue(xml, name);
    return value is String ? int.parse(value) : defaultValue;
  }

  bool _getBool(XmlElement xml, String name, bool defaultValue) {
    var value = _getAttributeValue(xml, name);
    if (value == null) return defaultValue;
    if (value == "1" || value =="true") return true;
    if (value == "0" || value =="false") return false;
    throw new FormatException("Error converting '$name' to bool.");
  }
}
