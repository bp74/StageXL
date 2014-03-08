part of stagexl;

class GlowFilter extends BitmapFilter {

  int color;
  int blurX;
  int blurY;
  bool knockout;
  bool hideObject;

  GlowFilter(this.color, this.blurX, this.blurY, {
             this.knockout: false, this.hideObject: false}) {

    if (blurX < 0 || blurY < 0) {
      throw new ArgumentError("Error #9004: The minimum blur size is 0.");
    }
    if (blurX > 64 || blurY > 64) {
      throw new ArgumentError("Error #9004: The maximum blur size is 64.");
    }
  }

  BitmapFilter clone() => new GlowFilter(
      color, blurX, blurY,
      knockout: knockout, hideObject: hideObject);

  Rectangle<int> get overlap => new Rectangle<int>(-blurX, -blurY, 2 * blurX, 2 * blurY);

  List<int> get renderPassSources => [0, 1, 0];
  List<int> get renderPassTargets => [1, 2, 2];

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData sourceImageData =
        this.hideObject == false || this.knockout ? renderTextureQuad.getImageData() : null;

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    int width = _ensureInt(imageData.width);
    int height = _ensureInt(imageData.height);

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int alphaChannel = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.ALPHA);
    int stride = width * 4;

    for (int x = 0; x < width; x++) {
      _blur2(data, x * 4 + alphaChannel, height, stride, blurY);
    }

    for (int y = 0; y < height; y++) {
      _blur2(data, y * stride + alphaChannel, width, 4, blurX);
    }

    if (this.knockout) {
      _setColorKnockout(data, this.color, sourceImageData.data);
    } else if (this.hideObject) {
      _setColor(data, this.color);
    } else {
      _setColorBlend(data, this.color, sourceImageData.data);
    }

    renderTextureQuad.putImageData(imageData);
  }

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    _GlowProgram glowProgram = _GlowProgram.instance;

    renderContext.activateRenderProgram(glowProgram);
    renderContext.activateRenderTexture(renderTexture);

    if (pass == 0) {
      glowProgram.configure(color, 0.250 * blurX / renderTexture.width, 0.0);
      glowProgram.renderQuad(renderState, renderTextureQuad);
    } else if (pass == 1) {
      glowProgram.configure(color, 0.0, 0.250 * blurY / renderTexture.height);
      glowProgram.renderQuad(renderState, renderTextureQuad);
    } else if (pass == 2) {
      // TODO: render the knockout effect!
      if (this.knockout || this.hideObject) return;
      renderState.renderQuad(renderTextureQuad);
    }
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _GlowProgram extends _BitmapFilterProgram {

  static final _GlowProgram instance = new _GlowProgram();

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uSampler;
      uniform vec2 uPixel;
      uniform vec4 uColor;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        float alpha = 0.0;
        alpha += texture2D(uSampler, vTextCoord - uPixel * 4.0).a * 0.045;
        alpha += texture2D(uSampler, vTextCoord - uPixel * 3.0).a * 0.090;
        alpha += texture2D(uSampler, vTextCoord - uPixel * 2.0).a * 0.125;
        alpha += texture2D(uSampler, vTextCoord - uPixel      ).a * 0.155;
        alpha += texture2D(uSampler, vTextCoord               ).a * 0.170;
        alpha += texture2D(uSampler, vTextCoord + uPixel      ).a * 0.155;
        alpha += texture2D(uSampler, vTextCoord + uPixel * 2.0).a * 0.125;
        alpha += texture2D(uSampler, vTextCoord + uPixel * 3.0).a * 0.090;
        alpha += texture2D(uSampler, vTextCoord + uPixel * 4.0).a * 0.045;
        alpha *= vAlpha;
        gl_FragColor = vec4(uColor.rgb * alpha, alpha);
      }
      """;

   void configure(int color, num pixelX, num pixelY) {
     num r = _colorGetR(color) / 255.0;
     num g = _colorGetG(color) / 255.0;
     num b = _colorGetB(color) / 255.0;
     num a = _colorGetA(color) / 255.0;
     _renderingContext.uniform2f(_uniformLocations["uPixel"], pixelX, pixelY);
     _renderingContext.uniform4f(_uniformLocations["uColor"], r, g, b, a);
   }
}

