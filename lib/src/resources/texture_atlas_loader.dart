part of stagexl.resources;

/// The base class for a custom texture atlas loader.
///
/// Use the [TextureAtlas.withLoader] function to load a texture atlas
/// from a custom source by implementing a TextureAtlasLoader class.

abstract class TextureAtlasLoader {

  /// Get the source of the texture atlas.
  Future<String> getSource();

  /// Get the RenderTextureQuad for the texture atlas.
  Future<RenderTextureQuad> getRenderTextureQuad(String filename);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasLoaderFile extends TextureAtlasLoader {

  BitmapDataLoadOptions _loadOptions;
  BitmapDataLoadInfo _loadInfo;

  _TextureAtlasLoaderFile(String url, BitmapDataLoadOptions options) {
    _loadOptions = options ?? BitmapData.defaultLoadOptions;
    _loadInfo = new BitmapDataLoadInfo(url, _loadOptions.pixelRatios);
  }

  @override
  Future<String> getSource() {
    return HttpRequest.getString(_loadInfo.loaderUrl);
  }

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) async {
    var loaderUrl = _loadInfo.loaderUrl;
    var pixelRatio = _loadInfo.pixelRatio;
    var webpAvailable = _loadOptions.webp;
    var corsEnabled = _loadOptions.corsEnabled;
    var imageUrl = replaceFilename(loaderUrl, filename);
    var imageLoader = new ImageLoader(imageUrl, webpAvailable, corsEnabled);
    var imageElement = await imageLoader.done;
    var renderTexture = new RenderTexture.fromImageElement(imageElement);
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

  _TextureAtlasLoaderTextureAtlas(this.textureAtlas, this.namePrefix, this.source);

  @override
  Future<String> getSource() {
    return new Future.value(this.source);
  }

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) async {
    var name = this.namePrefix + getFilenameWithoutExtension(filename);
    var bitmapData = this.textureAtlas.getBitmapData(name);
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
  Future<String> getSource() {
    return new Future.value(this.source);
  }

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) {
    return new Future.value(this.bitmapData.renderTextureQuad);
  }
}
