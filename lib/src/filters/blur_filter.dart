library stagexl.filters.blur;

import 'dart:html' show ImageData;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/filter_helpers.dart';
import '../internal/tools.dart';

class BlurFilter extends BitmapFilter {

  int blurX;
  int blurY;

  //-----------------------------------------------------------------------------------------------
  // Credits to Alois Zingl, Vienna, Austria.
  // Extended Binomial Filter for Fast Gaussian Blur
  // http://members.chello.at/easyfilter/gauss.html
  // http://members.chello.at/easyfilter/gauss.pdf
  //-----------------------------------------------------------------------------------------------

  BlurFilter([this.blurX = 4, this.blurY = 4]) {

    if (blurX < 0 || blurY < 0) {
      throw new ArgumentError("The minimum blur size is 0.");
    }
    if (blurX > 64 || blurY > 64) {
      throw new ArgumentError("The maximum blur size is 64.");
    }
  }

  BitmapFilter clone() => new BlurFilter(blurX, blurY);
  Rectangle<int> get overlap => new Rectangle<int>(-blurX, -blurY, 2 * blurX, 2 * blurY);
  List<int> get renderPassSources => const [0, 1];
  List<int> get renderPassTargets => const [1, 2];

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    int width = ensureInt(imageData.width);
    int height = ensureInt(imageData.height);

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int stride = width * 4;

    premultiplyAlpha(data);

    for (int x = 0; x < width; x++) {
      blur(data, x * 4 + 0, height, stride, blurY);
      blur(data, x * 4 + 1, height, stride, blurY);
      blur(data, x * 4 + 2, height, stride, blurY);
      blur(data, x * 4 + 3, height, stride, blurY);
    }

    for (int y = 0; y < height; y++) {
      blur(data, y * stride + 0, width, 4, blurX);
      blur(data, y * stride + 1, width, 4, blurX);
      blur(data, y * stride + 2, width, 4, blurX);
      blur(data, y * stride + 3, width, 4, blurX);
    }

    unpremultiplyAlpha(data);

    renderTextureQuad.putImageData(imageData);
  }

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    BlurFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$BlurFilterProgram", () => new BlurFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);

    if (pass == 0) {
      renderProgram.configure(blurX / renderTexture.width, 0.0);
      renderProgram.renderQuad(renderState, renderTextureQuad);
    } else {
      renderProgram.configure(0.0, blurY / renderTexture.height);
      renderProgram.renderQuad(renderState, renderTextureQuad);
    }
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class BlurFilterProgram extends BitmapFilterProgram {

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    uniform vec2 uRadius;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute float aVertexAlpha;

    varying vec2 vBlurCoords[15];
    varying float vAlpha;

    void main() {
      vBlurCoords[ 0] = aVertexTextCoord - uRadius * 1.4;
      vBlurCoords[ 1] = aVertexTextCoord - uRadius * 1.2;
      vBlurCoords[ 2] = aVertexTextCoord - uRadius * 1.0;
      vBlurCoords[ 3] = aVertexTextCoord - uRadius * 0.8;
      vBlurCoords[ 4] = aVertexTextCoord - uRadius * 0.6;
      vBlurCoords[ 5] = aVertexTextCoord - uRadius * 0.4;
      vBlurCoords[ 6] = aVertexTextCoord - uRadius * 0.2;
      vBlurCoords[ 7] = aVertexTextCoord;
      vBlurCoords[ 8] = aVertexTextCoord + uRadius * 0.2;
      vBlurCoords[ 9] = aVertexTextCoord + uRadius * 0.4;
      vBlurCoords[10] = aVertexTextCoord + uRadius * 0.6;
      vBlurCoords[11] = aVertexTextCoord + uRadius * 0.8;
      vBlurCoords[12] = aVertexTextCoord + uRadius * 1.0;
      vBlurCoords[13] = aVertexTextCoord + uRadius * 1.2;
      vBlurCoords[14] = aVertexTextCoord + uRadius * 1.4;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;

    varying vec2 vBlurCoords[15];
    varying float vAlpha;

    void main() {
      vec4 sum = vec4(0.0);
      sum += texture2D(uSampler, vBlurCoords[ 0]) * 0.00443;
      sum += texture2D(uSampler, vBlurCoords[ 1]) * 0.00896;
      sum += texture2D(uSampler, vBlurCoords[ 2]) * 0.02160;
      sum += texture2D(uSampler, vBlurCoords[ 3]) * 0.04437;
      sum += texture2D(uSampler, vBlurCoords[ 4]) * 0.07768;
      sum += texture2D(uSampler, vBlurCoords[ 5]) * 0.11588;
      sum += texture2D(uSampler, vBlurCoords[ 6]) * 0.14731;
      sum += texture2D(uSampler, vBlurCoords[ 7]) * 0.15958;
      sum += texture2D(uSampler, vBlurCoords[ 8]) * 0.14731;
      sum += texture2D(uSampler, vBlurCoords[ 9]) * 0.11588;
      sum += texture2D(uSampler, vBlurCoords[10]) * 0.07768;
      sum += texture2D(uSampler, vBlurCoords[11]) * 0.04437;
      sum += texture2D(uSampler, vBlurCoords[12]) * 0.02160;
      sum += texture2D(uSampler, vBlurCoords[13]) * 0.00896;
      sum += texture2D(uSampler, vBlurCoords[14]) * 0.00443;
      gl_FragColor = sum * vAlpha;
    }
    """;

   void configure(num radiusX, num radiusY) {
     var uPixelLocation = uniformLocations["uRadius"];
     renderingContext.uniform2f(uPixelLocation, radiusX, radiusY);
   }
}
