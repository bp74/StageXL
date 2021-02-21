part of stagexl.resources;

class TextureAtlas {
  /// A list with the frames in this texture atlas.
  final List<TextureAtlasFrame> frames = <TextureAtlasFrame>[];

  /// The pixelRatio used for the BitmapDatas in the frames
  final double pixelRatio;

  TextureAtlas(this.pixelRatio);

  //---------------------------------------------------------------------------

  static Future<TextureAtlas> load(String url,
          [TextureAtlasFormat textureAtlasFormat = TextureAtlasFormat.JSONARRAY,
          BitmapDataLoadOptions? bitmapDataLoadOptions]) =>
      textureAtlasFormat
          .load(_TextureAtlasLoaderFile(url, bitmapDataLoadOptions));

  static Future<TextureAtlas> fromTextureAtlas(
          TextureAtlas textureAtlas, String namePrefix, String source,
          [TextureAtlasFormat textureAtlasFormat =
              TextureAtlasFormat.JSONARRAY]) =>
      textureAtlasFormat.load(
          _TextureAtlasLoaderTextureAtlas(textureAtlas, namePrefix, source));

  static Future<TextureAtlas> fromBitmapData(
          BitmapData bitmapData, String source,
          [TextureAtlasFormat textureAtlasFormat =
              TextureAtlasFormat.JSONARRAY]) =>
      textureAtlasFormat
          .load(_TextureAtlasLoaderBitmapData(bitmapData, source));

  static Future<TextureAtlas> withLoader(TextureAtlasLoader textureAtlasLoader,
          [TextureAtlasFormat textureAtlasFormat =
              TextureAtlasFormat.JSONARRAY]) =>
      textureAtlasFormat.load(textureAtlasLoader);

  //---------------------------------------------------------------------------

  /// A list with the frame-names in this texture atlas.

  List<String> get frameNames => frames.map((f) => f.name).toList();

  /// Get a list of BitmapDatas of frames whose names starts with [namePrefix].

  List<BitmapData> getBitmapDatas(String namePrefix) => frames
      .where((f) => f.name.startsWith(namePrefix))
      .map((f) => f.bitmapData)
      .toList();

  /// Get the BitmapData of the frame with the given [name].
  ///
  /// The name of a frame is the original file name of the image
  /// without it's file extension.

  BitmapData getBitmapData(String name) {
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      if (frame.name == name) return frame.bitmapData;
    }
    throw ArgumentError("TextureAtlasFrame not found: '$name'");
  }
}
