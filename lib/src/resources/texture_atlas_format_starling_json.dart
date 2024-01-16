part of '../resources.dart';

class _TextureAtlasFormatStarlingJson extends TextureAtlasFormat {
  const _TextureAtlasFormatStarlingJson();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {
    final source = await loader.getSource();
    final pixelRatio = loader.getPixelRatio();
    final textureAtlas = TextureAtlas(pixelRatio);

    final json = jsonDecode(source) as Map;
    final imagePath = _getString(json, 'imagePath', '');
    final renderTextureQuad = await loader.getRenderTextureQuad(imagePath);

    for (var subTextureMap in (json['SubTexture'] as List).cast<Map>()) {
      final name = _getString(subTextureMap, 'name', '');
      final rotation = _getBool(subTextureMap, 'rotated', false) ? 1 : 0;

      final frameX = _getInt(subTextureMap, 'x', 0);
      final frameY = _getInt(subTextureMap, 'y', 0);
      final frameWidth = _getInt(subTextureMap, 'width', 0);
      final frameHeight = _getInt(subTextureMap, 'height', 0);

      final offsetX = 0 - _getInt(subTextureMap, 'frameX', 0);
      final offsetY = 0 - _getInt(subTextureMap, 'frameY', 0);
      final originalWidth = _getInt(subTextureMap, 'frameWidth', frameWidth);
      final originalHeight = _getInt(subTextureMap, 'frameHeight', frameHeight);

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

  String _getString(Map map, String name, String defaultValue) {
    final value = map[name];
    return value is String ? value : defaultValue;
  }

  int _getInt(Map map, String name, int defaultValue) {
    final value = map[name];
    return value is int ? value : defaultValue;
  }

  bool _getBool(Map map, String name, bool defaultValue) {
    final value = map[name];
    return value is bool ? value : defaultValue;
  }
}
