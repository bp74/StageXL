part of stagexl.filters;

class ChromaKeyFilter extends BitmapFilter {

  int _alphaColor;
  int _tolerance;

  ChromaKeyFilter({int alphaColor: 0xFF00FF00, int tolerance: 10}) {

    if (tolerance < 0) {
      throw new ArgumentError("The minimum tolerance is 0.");
    }

    _alphaColor = alphaColor;
    _tolerance = tolerance;
  }

  int get alphaColor => _alphaColor;
  int get tolerance => _tolerance;

  void set alphaColor (int alphaColor) {
    _alphaColor = alphaColor;
  }
  void set tolerance (int tolerance) {
    if (tolerance < 0) {
      throw new ArgumentError("The minimum tolerance is 0.");
    }
    _tolerance = tolerance;
  }

  BitmapFilter clone() => new ChromaKeyFilter(alphaColor: _alphaColor, tolerance: _tolerance);

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    // not web gl program here
    renderTextureQuad.putImageData(imageData);
  }

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    _ChromaKeyProgram chromaKeyProgram = _ChromaKeyProgram.instance;

    renderContext.activateRenderProgram(chromaKeyProgram);
    renderContext.activateRenderTexture(renderTexture);
    chromaKeyProgram.configure(alphaColor, tolerance);
    chromaKeyProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _ChromaKeyProgram extends _BitmapFilterProgram {

  static final _ChromaKeyProgram instance = new _ChromaKeyProgram();

  String get fragmentShaderSource =>  """
      precision mediump float;
      uniform sampler2D uSampler;
      varying vec2 vTextCoord;
      uniform vec4 uAlphaColor;
      uniform float uTolerance;
      void main() {
        vec4 pixelColor = texture2D(uSampler, vTextCoord);
        // calcul diference betwen requested alphaColor
        // and actual pixelColor
        float redDelta = pixelColor.r - uAlphaColor.r;
        float greenDelta = pixelColor.g - uAlphaColor.g;
        float blueDelta = pixelColor.b - uAlphaColor.b;
        // if the diference is smaller than the tolerance
        // we can trasform this pixel to a transparent one
        bool redClose = redDelta > (uTolerance * -1.0) && redDelta < uTolerance;
        bool greenClose = greenDelta > (uTolerance * -1.0) && greenDelta < uTolerance;
        bool blueClose = blueDelta > (uTolerance * -1.0) && blueDelta < uTolerance;
        if (redClose && greenClose && blueClose) {
          // color match the transparentColor setting
          // reduce color to 0 aka transparent
          gl_FragColor = pixelColor * 0.0;
        } else {
          gl_FragColor = pixelColor;
        }
      }
      """;

  void configure(int color, int tolerance) {
    num r = colorGetR(color) / 255.0;
    num g = colorGetG(color) / 255.0;
    num b = colorGetB(color) / 255.0;
    num a = colorGetA(color) / 255.0;

    num webGlTolerance = tolerance / 255.0;
    _renderingContext.uniform4f(_uniformLocations["uAlphaColor"], r, g, b, a);
    _renderingContext.uniform1f(_uniformLocations["uTolerance"], webGlTolerance);
  }
}