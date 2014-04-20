part of stagexl;

class DropShadowFilter extends BitmapFilter {

  num distance;
  num angle;
  int color;
  int blurX;
  int blurY;
  bool knockout;
  bool hideObject;

  DropShadowFilter(this.distance, this.angle, this.color, this.blurX, this.blurY, {
                   this.knockout: false, this.hideObject: false }) {

    if (blurX < 0 || blurY < 0)
      throw new ArgumentError("Error #9004: The minimum blur size is 0.");

    if (blurX > 64 || blurY > 64)
      throw new ArgumentError("Error #9004: The maximum blur size is 64.");
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapFilter clone() => new DropShadowFilter(
      distance, angle, color, blurX, blurY,
      knockout: knockout, hideObject: hideObject);

  Rectangle<int> get overlap {
    int shiftX = (this.distance * cos(this.angle)).round();
    int shiftY = (this.distance * sin(this.angle)).round();
    var sRect = new Rectangle<int>(-1, -1, 2, 2);
    var dRect = new Rectangle<int>(shiftX - blurX, shiftY - blurY, 2 * blurX, 2 * blurY);
    return sRect.boundingBox(dRect);
  }

  List<int> get renderPassSources => [0, 1, 0];
  List<int> get renderPassTargets => [1, 2, 2];

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
    int shiftX = (this.distance * cos(this.angle)).round();
    int shiftY = (this.distance * sin(this.angle)).round();

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int alphaChannel = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.ALPHA);
    int stride = width * 4;

    _shiftChannel(data, 3, width, height, shiftX, shiftY);

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
    _DropShadowProgram dropShadowProgram = _DropShadowProgram.instance;

    renderContext.activateRenderProgram(dropShadowProgram);
    renderContext.activateRenderTexture(renderTexture);

    if (pass == 0) {
      var shift = (this.distance * cos(this.angle)).round() / renderTexture.width;
      var pixel = 0.250 * blurX / renderTexture.width;
      dropShadowProgram.configure(color, shift, 0.0, pixel, 0.0);
      dropShadowProgram.renderQuad(renderState, renderTextureQuad);
    } else if (pass == 1) {
      var shift = (this.distance * sin(this.angle)).round() / renderTexture.height;
      var pixel = 0.250 * blurY / renderTexture.height;
      dropShadowProgram.configure(color, 0.0, shift, 0.0, pixel);
      dropShadowProgram.renderQuad(renderState, renderTextureQuad);
    } else if (pass == 2) {
      // TODO: render the knockout effect!
      if (this.knockout || this.hideObject) return;
      renderState.renderQuad(renderTextureQuad);
    }
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _DropShadowProgram extends _BitmapFilterProgram {

  static final _DropShadowProgram instance = new _DropShadowProgram();

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uSampler;
      uniform vec2 uShift;
      uniform vec2 uPixel;
      uniform vec4 uColor;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        float alpha = 0.0;
        alpha += texture2D(uSampler, vTextCoord - uShift - uPixel * 4.0).a * 0.045;
        alpha += texture2D(uSampler, vTextCoord - uShift - uPixel * 3.0).a * 0.090;
        alpha += texture2D(uSampler, vTextCoord - uShift - uPixel * 2.0).a * 0.125;
        alpha += texture2D(uSampler, vTextCoord - uShift - uPixel      ).a * 0.155;
        alpha += texture2D(uSampler, vTextCoord - uShift               ).a * 0.170;
        alpha += texture2D(uSampler, vTextCoord - uShift + uPixel      ).a * 0.155;
        alpha += texture2D(uSampler, vTextCoord - uShift + uPixel * 2.0).a * 0.125;
        alpha += texture2D(uSampler, vTextCoord - uShift + uPixel * 3.0).a * 0.090;
        alpha += texture2D(uSampler, vTextCoord - uShift + uPixel * 4.0).a * 0.045;
        alpha *= vAlpha;
        alpha *= uColor.a;
        gl_FragColor = vec4(uColor.rgb * alpha, alpha);
      }
      """;

   void configure(int color, num shiftX, num shiftY, num pixelX, num pixelY) {
     num r = _colorGetR(color) / 255.0;
     num g = _colorGetG(color) / 255.0;
     num b = _colorGetB(color) / 255.0;
     num a = _colorGetA(color) / 255.0;
     _renderingContext.uniform2f(_uniformLocations["uShift"], shiftX, shiftY);
     _renderingContext.uniform2f(_uniformLocations["uPixel"], pixelX, pixelY);
     _renderingContext.uniform4f(_uniformLocations["uColor"], r, g, b, a);
   }
}
