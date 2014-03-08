part of stagexl;

class BlurFilter extends BitmapFilter {

  int blurX;
  int blurY;

  //-------------------------------------------------------------------------------------------------
  // Credits to Alois Zingl, Vienna, Austria.
  // Extended Binomial Filter for Fast Gaussian Blur
  // http://members.chello.at/easyfilter/gauss.html
  // http://members.chello.at/easyfilter/gauss.pdf
  //-------------------------------------------------------------------------------------------------

  BlurFilter([this.blurX = 4, this.blurY = 4]) {

    if (blurX < 0 || blurY < 0) {
      throw new ArgumentError("Error #9004: The minimum blur size is 0.");
    }
    if (blurX > 64 || blurY > 64) {
      throw new ArgumentError("Error #9004: The maximum blur size is 64.");
    }
  }

  BitmapFilter clone() => new BlurFilter(blurX, blurY);
  Rectangle<int> get overlap => new Rectangle<int>(-blurX, -blurY, 2 * blurX, 2 * blurY);
  List<int> get renderPassSources => [0, 1];
  List<int> get renderPassTargets => [1, 2];

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    int width = _ensureInt(imageData.width);
    int height = _ensureInt(imageData.height);

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int stride = width * 4;

    _premultiplyAlpha(data);

    for (int x = 0; x < width; x++) {
      _blur2(data, x * 4 + 0, height, stride, blurY);
      _blur2(data, x * 4 + 1, height, stride, blurY);
      _blur2(data, x * 4 + 2, height, stride, blurY);
      _blur2(data, x * 4 + 3, height, stride, blurY);
    }

    for (int y = 0; y < height; y++) {
      _blur2(data, y * stride + 0, width, 4, blurX);
      _blur2(data, y * stride + 1, width, 4, blurX);
      _blur2(data, y * stride + 2, width, 4, blurX);
      _blur2(data, y * stride + 3, width, 4, blurX);
    }

    _unpremultiplyAlpha(data);

    renderTextureQuad.putImageData(imageData);
  }

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    _BlurProgram blurProgram = _BlurProgram.instance;

    renderContext.activateRenderProgram(blurProgram);
    renderContext.activateRenderTexture(renderTexture);

    if (pass == 0) {
      blurProgram.configure(0.250 * blurX / renderTexture.width, 0.0);
      blurProgram.renderQuad(renderState, renderTextureQuad);
    } else {
      blurProgram.configure(0.0, 0.250 * blurY / renderTexture.height);
      blurProgram.renderQuad(renderState, renderTextureQuad);
    }
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _BlurProgram extends _BitmapFilterProgram {

  static final _BlurProgram instance = new _BlurProgram();

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uSampler;
      uniform vec2 uPixel;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        vec4 color = vec4(0);
        color += texture2D(uSampler, vTextCoord - uPixel * 4.0) * 0.045;
        color += texture2D(uSampler, vTextCoord - uPixel * 3.0) * 0.090;
        color += texture2D(uSampler, vTextCoord - uPixel * 2.0) * 0.125;
        color += texture2D(uSampler, vTextCoord - uPixel      ) * 0.155;
        color += texture2D(uSampler, vTextCoord               ) * 0.170;
        color += texture2D(uSampler, vTextCoord + uPixel      ) * 0.155;
        color += texture2D(uSampler, vTextCoord + uPixel * 2.0) * 0.125;
        color += texture2D(uSampler, vTextCoord + uPixel * 3.0) * 0.090;
        color += texture2D(uSampler, vTextCoord + uPixel * 4.0) * 0.045;
        gl_FragColor = color * vAlpha;
      }
      """;

   void configure(num pixelX, num pixelY) {
     _renderingContext.uniform2f(_uniformLocations["uPixel"], pixelX, pixelY);
   }
}
