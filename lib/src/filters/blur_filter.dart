library stagexl.filters.blur;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show ImageData;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/filter_helpers.dart';
import '../internal/tools.dart';

class BlurFilter extends BitmapFilter {

  int _blurX;
  int _blurY;
  int _quality;

  final List<int> _renderPassSources = new List<int>();
  final List<int> _renderPassTargets = new List<int>();

  //---------------------------------------------------------------------------
  // Credits to Alois Zingl, Vienna, Austria.
  // Extended Binomial Filter for Fast Gaussian Blur
  // http://members.chello.at/easyfilter/gauss.html
  // http://members.chello.at/easyfilter/gauss.pdf
  //---------------------------------------------------------------------------

  BlurFilter([int blurX = 4, int blurY = 4, int quality = 1]) {
    this.blurX = blurX;
    this.blurY = blurY;
    this.quality = quality;
  }

  BitmapFilter clone() {
    return new BlurFilter(blurX, blurY);
  }

  Rectangle<int> get overlap {
    return new Rectangle<int>(-blurX, -blurY, 2 * blurX, 2 * blurY);
  }

  List<int> get renderPassSources => _renderPassSources;
  List<int> get renderPassTargets => _renderPassTargets;

  //---------------------------------------------------------------------------

  /// The horizontal blur radius in the range from 0 to 64.

  int get blurX => _blurX;

  set blurX(int value) {
    RangeError.checkValueInInterval(value, 0, 64);
    _blurX = value;
  }

  /// The vertical blur radius in the range from 0 to 64.

  int get blurY => _blurY;

  set blurY(int value) {
    RangeError.checkValueInInterval(value, 0, 64);
    _blurY = value;
  }

  /// The quality of the blur effect in the range from 1 to 5.
  /// A small value is sufficent for small blur radii, a high blur
  /// radius may require a heigher quality setting.

  int get quality => _quality;

  set quality(int value) {

    RangeError.checkValueInInterval(value, 1, 5);

    _quality = value;
    _renderPassSources.clear();
    _renderPassTargets.clear();

    for(int i = 0; i < value; i++) {
      _renderPassSources.add(i * 2 + 0);
      _renderPassSources.add(i * 2 + 1);
      _renderPassTargets.add(i * 2 + 1);
      _renderPassTargets.add(i * 2 + 2);
    }
  }

  //---------------------------------------------------------------------------

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

  //---------------------------------------------------------------------------

  void renderFilter(RenderState renderState,
                    RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    num scale = pow(0.5, pass >> 1);

    BlurFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$BlurFilterProgram", () => new BlurFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);

    if (pass % 2 == 0) {
      renderProgram.configure(scale * blurX / renderTexture.width, 0.0);
      renderProgram.renderQuad(renderState, renderTextureQuad);
    } else {
      renderProgram.configure(0.0, scale * blurY / renderTexture.height);
      renderProgram.renderQuad(renderState, renderTextureQuad);
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class BlurFilterProgram extends BitmapFilterProgram {

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    uniform vec2 uRadius;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute float aVertexAlpha;

    varying vec2 vBlurCoords[7];
    varying float vAlpha;

    void main() {
      vBlurCoords[0] = aVertexTextCoord - uRadius * 1.2;
      vBlurCoords[1] = aVertexTextCoord - uRadius * 0.8;
      vBlurCoords[2] = aVertexTextCoord - uRadius * 0.4;
      vBlurCoords[3] = aVertexTextCoord;
      vBlurCoords[4] = aVertexTextCoord + uRadius * 0.4;
      vBlurCoords[5] = aVertexTextCoord + uRadius * 0.8;
      vBlurCoords[6] = aVertexTextCoord + uRadius * 1.2;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;

    varying vec2 vBlurCoords[7];
    varying float vAlpha;

    void main() {
      vec4 sum = vec4(0.0);
      sum += texture2D(uSampler, vBlurCoords[0]) * 0.00443;
      sum += texture2D(uSampler, vBlurCoords[1]) * 0.05399;
      sum += texture2D(uSampler, vBlurCoords[2]) * 0.24197;
      sum += texture2D(uSampler, vBlurCoords[3]) * 0.39894;
      sum += texture2D(uSampler, vBlurCoords[4]) * 0.24197;
      sum += texture2D(uSampler, vBlurCoords[5]) * 0.05399;
      sum += texture2D(uSampler, vBlurCoords[6]) * 0.00443;
      gl_FragColor = sum * vAlpha;
    }
    """;

   void configure(num radiusX, num radiusY) {
     var uPixelLocation = uniformLocations["uRadius"];
     renderingContext.uniform2f(uPixelLocation, radiusX, radiusY);
   }
}
