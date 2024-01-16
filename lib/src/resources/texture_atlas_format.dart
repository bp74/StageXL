part of '../resources.dart';

abstract class TextureAtlasFormat {
  static const TextureAtlasFormat JSON = _TextureAtlasFormatJson();
  static const TextureAtlasFormat JSONARRAY = _TextureAtlasFormatJson();
  static const TextureAtlasFormat LIBGDX = _TextureAtlasFormatLibGDX();
  static const TextureAtlasFormat STARLINGXML =
      _TextureAtlasFormatStarlingXml();
  static const TextureAtlasFormat STARLINGJSON =
      _TextureAtlasFormatStarlingJson();

  const TextureAtlasFormat();

  Future<TextureAtlas> load(TextureAtlasLoader textureAtlasLoader);
}
