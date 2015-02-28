library stagexl.filters.glow;

import 'dart:html' show ImageData;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/filter_helpers.dart';
import '../internal/tools.dart';

class GlowFilter extends BitmapFilter {

  int color;
  int blurX;
  int blurY;
  bool knockout;
  bool hideObject;

  GlowFilter(this.color, this.blurX, this.blurY, {
             this.knockout: false, this.hideObject: false}) {

    if (blurX < 0 || blurY < 0) {
      throw new ArgumentError("The minimum blur size is 0.");
    }
    if (blurX > 64 || blurY > 64) {
      throw new ArgumentError("The maximum blur size is 64.");
    }
  }

  BitmapFilter clone() => new GlowFilter(
      color, blurX, blurY,
      knockout: knockout, hideObject: hideObject);

  Rectangle<int> get overlap => new Rectangle<int>(-blurX, -blurY, 2 * blurX, 2 * blurY);

  List<int> get renderPassSources => const [0, 1, 0];
  List<int> get renderPassTargets => const [1, 2, 2];

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData sourceImageData =
        this.hideObject == false || this.knockout ? renderTextureQuad.getImageData() : null;

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    int width = ensureInt(imageData.width);
    int height = ensureInt(imageData.height);

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int alphaChannel = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.ALPHA);
    int stride = width * 4;

    for (int x = 0; x < width; x++) {
      blur(data, x * 4 + alphaChannel, height, stride, blurY);
    }

    for (int y = 0; y < height; y++) {
      blur(data, y * stride + alphaChannel, width, 4, blurX);
    }

    if (this.knockout) {
      setColorKnockout(data, this.color, sourceImageData.data);
    } else if (this.hideObject) {
      setColor(data, this.color);
    } else {
      setColorBlend(data, this.color, sourceImageData.data);
    }

    renderTextureQuad.putImageData(imageData);
  }

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    GlowFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$GlowFilterProgram", () => new GlowFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);

    if (pass == 0) {
      renderProgram.configure(color, 0.250 * blurX / renderTexture.width, 0.0);
      renderProgram.renderQuad(renderState, renderTextureQuad);
    } else if (pass == 1) {
      renderProgram.configure(color, 0.0, 0.250 * blurY / renderTexture.height);
      renderProgram.renderQuad(renderState, renderTextureQuad);
    } else if (pass == 2) {
      // TODO: render the knockout effect!
      if (this.knockout || this.hideObject) return;
      renderState.renderQuad(renderTextureQuad);
    }
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class GlowFilterProgram extends BitmapFilterProgram {

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

     num r = colorGetR(color) / 255.0;
     num g = colorGetG(color) / 255.0;
     num b = colorGetB(color) / 255.0;
     num a = colorGetA(color) / 255.0;

     var uPixelLocation = uniformLocations["uPixel"];
     var uColorLocation = uniformLocations["uColor"];

     renderingContext.uniform2f(uPixelLocation, pixelX, pixelY);
     renderingContext.uniform4f(uColorLocation, r, g, b, a);
   }
}

