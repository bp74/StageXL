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
  Future<RenderTextureQuad> getRenderTextureQuad(String filename);
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
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) async {
    final loaderUrl = _loadInfo.loaderUrl;
    final webpAvailable = _loadOptions.webp;
    final imageUrl = replaceFilename(loaderUrl, filename);
    final RenderTexture renderTexture;

    if (env.isImageBitmapSupported) {
      final loader = ImageBitmapLoader(imageUrl, webpAvailable);
      final imageBitmap = await loader.done;
      renderTexture = RenderTexture.fromImageBitmap(imageBitmap);
    } else {
      final corsEnabled = _loadOptions.corsEnabled;
      final loader = ImageLoader(imageUrl, webpAvailable, corsEnabled);
      final imageElement = await loader.done;
      renderTexture = RenderTexture.fromImageElement(imageElement);
    }

    final pixelRatio = _loadInfo.pixelRatio;
    return renderTexture.quad.withPixelRatio(pixelRatio);
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
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) async {
    final name = namePrefix + getFilenameWithoutExtension(filename);
    final bitmapData = textureAtlas.getBitmapData(name);
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
  double getPixelRatio() => bitmapData.renderTextureQuad.pixelRatio.toDouble();

  @override
  Future<String> getSource() => Future.value(source);

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) =>
      Future.value(bitmapData.renderTextureQuad);
}
