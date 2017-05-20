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

  String _sourceUrl = "";
  bool _webpAvailable = false;
  bool _corsEnabled = false;
  num _pixelRatio = 1.0;

  _TextureAtlasLoaderFile(String url, BitmapDataLoadOptions options) {

    options = options ?? BitmapData.defaultLoadOptions;

    var pixelRatio = 1.0;
    var pixelRatioRegexp = new RegExp(r"@(\d+(.\d+)?)x");
    var pixelRatioMatch = pixelRatioRegexp.firstMatch(url);

    if (pixelRatioMatch != null) {
      var match = pixelRatioMatch;
      var originPixelRatioFractions = (match.group(2) ?? ".").length - 1;
      var originPixelRatio = double.parse(match.group(1));
      var devicePixelRatio = env.devicePixelRatio;
      var loaderPixelRatio = options.pixelRatios.fold<num>(0.0, (num a, num b) {
        var aDelta = pow(a - devicePixelRatio, 2);
        var bDelta = pow(b - devicePixelRatio, 2);
        return aDelta < bDelta && a > 0.0 ? a : b;
      });
      var name = loaderPixelRatio.toStringAsFixed(originPixelRatioFractions);
      url = url.replaceRange(match.start + 1, match.end - 1, name);
      pixelRatio = loaderPixelRatio / originPixelRatio;
    }

    _sourceUrl = url;
    _webpAvailable = options.webp;
    _corsEnabled = options.corsEnabled;
    _pixelRatio = pixelRatio;
  }

  @override
  Future<String> getSource() {
    return HttpRequest.getString(_sourceUrl);
  }

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) async {
    var imageUrl = replaceFilename(_sourceUrl, filename);
    var imageLoader = new ImageLoader(imageUrl, _webpAvailable, _corsEnabled);
    var imageElement = await imageLoader.done;
    var renderTexture = new RenderTexture.fromImageElement(imageElement);
    var renderTextureQuad = renderTexture.quad.withPixelRatio(_pixelRatio);
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
