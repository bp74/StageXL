part of stagexl.resources;

class TextureAtlas {
  /// A list with the frames in this texture atlas.
  final List<TextureAtlasFrame> frames = <TextureAtlasFrame>[];
  /// The pixelRatio used for the BitmapDatas in the frames
  final double pixelRatio;

  TextureAtlas(this.pixelRatio);

  //---------------------------------------------------------------------------

  static Future<ImageAssetLoader> load(String url,
          [TextureAtlasFormat textureAtlasFormat = TextureAtlasFormat.JSONARRAY,
          BitmapDataLoadOptions? bitmapDataLoadOptions]) {
    var loaderFile = _TextureAtlasLoaderFile(url, bitmapDataLoadOptions);
    textureAtlasFormat.load(loaderFile).then((textureAtlas) {
      loaderFile.imageLoader!.textureAtlas = textureAtlas;
    });
    return loaderFile.loaderCreated;
  }


  static ImageAssetLoader fromTextureAtlas(
          TextureAtlas textureAtlas, String namePrefix, String source,
          [TextureAtlasFormat textureAtlasFormat =
              TextureAtlasFormat.JSONARRAY]) {
    var loaderFile = _TextureAtlasLoaderTextureAtlas(textureAtlas, namePrefix, source);
    textureAtlasFormat.load(loaderFile).then((textureAtlas) {
      loaderFile.imageLoader!.textureAtlas = textureAtlas;
    });
    return loaderFile.imageLoader!;
  }

  static ImageAssetLoader fromBitmapData(
          BitmapData bitmapData, String source,
          [TextureAtlasFormat textureAtlasFormat =
              TextureAtlasFormat.JSONARRAY]){
    var loaderFile = _TextureAtlasLoaderBitmapData(bitmapData, source);
    textureAtlasFormat.load(loaderFile).then((textureAtlas) {
      loaderFile.imageLoader!.textureAtlas = textureAtlas;
    });
    return loaderFile.imageLoader!;
  }

  static ImageAssetLoader withLoader(TextureAtlasLoader textureAtlasLoader,
          [TextureAtlasFormat textureAtlasFormat =
              TextureAtlasFormat.JSONARRAY]) {
    var loaderFile = textureAtlasLoader;
    textureAtlasFormat.load(loaderFile).then((textureAtlas) {
      loaderFile.imageLoader!.textureAtlas = textureAtlas;
    });
    return loaderFile.imageLoader!;
  }

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
