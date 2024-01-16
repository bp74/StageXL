part of '../resources.dart';

class _TextureAtlasFormatStarlingXml extends TextureAtlasFormat {
  const _TextureAtlasFormatStarlingXml();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {
    final source = await loader.getSource();
    final pixelRatio = loader.getPixelRatio();
    final textureAtlas = TextureAtlas(pixelRatio);

    final xmlRoot = XmlDocument.parse(source).rootElement;
    final imagePath = _getString(xmlRoot, 'imagePath', '');
    final renderTextureQuad = await loader.getRenderTextureQuad(imagePath);

    for (var subTextureXml in xmlRoot.findAllElements('SubTexture')) {
      final name = _getString(subTextureXml, 'name', '');
      final rotation = _getBool(subTextureXml, 'rotated', false) ? 1 : 0;

      final frameX = _getInt(subTextureXml, 'x', 0);
      final frameY = _getInt(subTextureXml, 'y', 0);
      final frameWidth = _getInt(subTextureXml, 'width', 0);
      final frameHeight = _getInt(subTextureXml, 'height', 0);

      final offsetX = 0 - _getInt(subTextureXml, 'frameX', 0);
      final offsetY = 0 - _getInt(subTextureXml, 'frameY', 0);
      final originalWidth = _getInt(subTextureXml, 'frameWidth', frameWidth);
      final originalHeight = _getInt(subTextureXml, 'frameHeight', frameHeight);

      final textureAtlasFrame = TextureAtlasFrame(
          textureAtlas,
          renderTextureQuad,
          name,
          rotation,
          offsetX,
          offsetY,
          originalWidth,
          originalHeight,
          frameX,
          frameY,
          frameWidth,
          frameHeight,
          null,
          null);

      textureAtlas.frames.add(textureAtlasFrame);
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  String? _getAttributeValue(XmlElement xml, String name) {
    for (var attribute in xml.attributes) {
      if (attribute.name.local == name) return attribute.value;
    }
    return null;
  }

  String _getString(XmlElement xml, String name, String defaultValue) {
    final value = _getAttributeValue(xml, name);
    return value is String ? value : defaultValue;
  }

  int _getInt(XmlElement xml, String name, int defaultValue) {
    final value = _getAttributeValue(xml, name);
    return value is String ? int.parse(value) : defaultValue;
  }

  bool _getBool(XmlElement xml, String name, bool defaultValue) {
    final value = _getAttributeValue(xml, name);
    if (value == null) return defaultValue;
    if (value == '1' || value == 'true') return true;
    if (value == '0' || value == 'false') return false;
    throw FormatException("Error converting '$name' to bool.");
  }
}
