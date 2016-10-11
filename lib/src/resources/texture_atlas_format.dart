part of stagexl.resources;

abstract class TextureAtlasFormat {

  static const TextureAtlasFormat JSON = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat JSONARRAY = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat LIBGDX = const _TextureAtlasFormatLibGDX();
  static const TextureAtlasFormat STARLINGXML = const _TextureAtlasFormatStarlingXml();
  static const TextureAtlasFormat STARLINGJSON = const _TextureAtlasFormatStarlingJson();

  const TextureAtlasFormat();

  Future<TextureAtlas> load(TextureAtlasLoader textureAtlasLoader);
}
