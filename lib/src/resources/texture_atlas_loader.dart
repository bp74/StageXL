part of stagexl.resources;

/// The base class for a custom texture atlas loader.
///
/// Use the [TextureAtlas.withLoader] function to load a texture atlas
/// from a custom source by implementing a TextureAtlasLoader class.

abstract class TextureAtlasLoader {
  /// Get the pixel ratio of the texture atlas.
  double getPixelRatio();

  /// Get the source of the texture atlas.
  Future<String> getSource();

  /// Get the RenderTextureQuad for the texture atlas.
  Future<RenderTextureQuad> getRenderTextureQuad(String? filename);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasLoaderFile extends TextureAtlasLoader {
  late BitmapDataLoadOptions _loadOptions;
  late BitmapDataLoadInfo _loadInfo;

  _TextureAtlasLoaderFile(String url, BitmapDataLoadOptions? options) {
    _loadOptions = options ?? BitmapData.defaultLoadOptions;
    _loadInfo = BitmapDataLoadInfo(url, _loadOptions.pixelRatios);
  }

  @override
  double getPixelRatio() => _loadInfo.pixelRatio;

  @override
  Future<String> getSource() => HttpRequest.getString(_loadInfo.loaderUrl);

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String? filename) async {
    var loaderUrl = _loadInfo.loaderUrl;
    var pixelRatio = _loadInfo.pixelRatio;
    var webpAvailable = _loadOptions.webp;
    var corsEnabled = _loadOptions.corsEnabled;
    var imageUrl = replaceFilename(loaderUrl, filename);
    var imageLoader = ImageLoader(imageUrl, webpAvailable, corsEnabled);
    var imageElement = await imageLoader.done;
    var renderTexture = RenderTexture.fromImageElement(imageElement);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
    return renderTextureQuad;
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasLoaderTextureAtlas extends TextureAtlasLoader {
  final TextureAtlas textureAtlas;
  final String namePrefix;
  final String source;

  _TextureAtlasLoaderTextureAtlas(
      this.textureAtlas, this.namePrefix, this.source);

  @override
  double getPixelRatio() => textureAtlas.pixelRatio;

  @override
  Future<String> getSource() => Future.value(source);

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String? filename) async {
    var name = namePrefix + getFilenameWithoutExtension(filename!)!;
    var bitmapData = textureAtlas.getBitmapData(name)!;
    return bitmapData.renderTextureQuad;
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasLoaderBitmapData extends TextureAtlasLoader {
  final BitmapData bitmapData;
  final String source;

  _TextureAtlasLoaderBitmapData(this.bitmapData, this.source);

  @override
  double getPixelRatio() => bitmapData.renderTextureQuad.pixelRatio as double;

  @override
  Future<String> getSource() => Future.value(source);

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String? filename) {
    return Future.value(bitmapData.renderTextureQuad);
  }
}
