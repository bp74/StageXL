library stagexl.filters.glow;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show ImageData;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/filter_helpers.dart';
import '../internal/tools.dart';

class GlowFilter extends BitmapFilter {

  int _color;
  int _blurX;
  int _blurY;
  int _quality;

  bool knockout;
  bool hideObject;

  final List<int> _renderPassSources = new List<int>();
  final List<int> _renderPassTargets = new List<int>();

  GlowFilter([
    int color = 0xFF000000,
    int blurX = 4, int blurY = 4, int quality = 1,
    bool knockout = false, bool hideObject = false]) {

    this.color = color;
    this.blurX = blurX;
    this.blurY = blurY;
    this.quality = quality;
    this.knockout = knockout;
    this.hideObject = hideObject;
  }

  //---------------------------------------------------------------------------

  @override
  BitmapFilter clone() {
    return new GlowFilter(color, blurX, blurY, quality, knockout,  hideObject);
  }

  @override
  Rectangle<int> get overlap {
    return new Rectangle<int>(-blurX, -blurY, 2 * blurX, 2 * blurY);
  }

  @override
  List<int> get renderPassSources => _renderPassSources;

  @override
  List<int> get renderPassTargets => _renderPassTargets;

  //---------------------------------------------------------------------------

  /// The color of the glow.

  int get color => _color;

  set color(int value) {
    _color = value;
  }

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

  /// The quality of the glow in the range from 1 to 5.
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

    _renderPassSources.add(0);
    _renderPassTargets.add(value * 2);
  }

  //---------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData sourceImageData =
        this.hideObject == false || this.knockout ? renderTextureQuad.getImageData() : null;

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    int width = ensureInt(imageData.width);
    int height = ensureInt(imageData.height);

    num pixelRatio = renderTextureQuad.pixelRatio;
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

  //---------------------------------------------------------------------------

  @override
  void renderFilter(RenderState renderState,
                    RenderTextureQuad renderTextureQuad, int pass) {

    var renderContext = renderState.renderContext as RenderContextWebGL;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    int passCount = _renderPassSources.length;
    num passScale = pow(0.5, pass >> 1);
    num pixelRatio = sqrt(renderState.globalMatrix.det.abs());
    num pixelRatioScale = pixelRatio * passScale;

    if (pass == passCount - 1) {

      if (!this.knockout && !this.hideObject) {
        renderContext.renderTextureQuad(renderState, renderTextureQuad);
      }

    } else {

      var renderProgram = renderContext.getRenderProgram(
          r"$GlowFilterProgram", () => new GlowFilterProgram());

      renderContext.activateRenderProgram(renderProgram);
      renderContext.activateRenderTexture(renderTexture);

      renderProgram.configure(
        pass == passCount - 2 ? this.color : this.color | 0xFF000000,
        pass == passCount - 2 ? renderState.globalAlpha : 1.0,
        pass.isEven ? pixelRatioScale * blurX / renderTexture.width : 0.0,
        pass.isEven ? 0.0 : pixelRatioScale * blurY / renderTexture.height);

      renderProgram.renderTextureQuad(renderState, renderTextureQuad);
      renderProgram.flush();
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class GlowFilterProgram extends RenderProgramSimple {

  @override
  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    uniform vec2 uRadius;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;

    varying vec2 vBlurCoords[7];

    void main() {
      vBlurCoords[0] = aVertexTextCoord - uRadius * 1.2;
      vBlurCoords[1] = aVertexTextCoord - uRadius * 0.8;
      vBlurCoords[2] = aVertexTextCoord - uRadius * 0.4;
      vBlurCoords[3] = aVertexTextCoord;
      vBlurCoords[4] = aVertexTextCoord + uRadius * 0.4;
      vBlurCoords[5] = aVertexTextCoord + uRadius * 0.8;
      vBlurCoords[6] = aVertexTextCoord + uRadius * 1.2;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  @override
  String get fragmentShaderSource => """
    
    precision mediump float;

    uniform sampler2D uSampler;
    uniform vec4 uColor;

    varying vec2 vBlurCoords[7];

    void main() {
      float alpha = 0.0;
      alpha += texture2D(uSampler, vBlurCoords[0]).a * 0.00443;
      alpha += texture2D(uSampler, vBlurCoords[1]).a * 0.05399;
      alpha += texture2D(uSampler, vBlurCoords[2]).a * 0.24197;
      alpha += texture2D(uSampler, vBlurCoords[3]).a * 0.39894;
      alpha += texture2D(uSampler, vBlurCoords[4]).a * 0.24197;
      alpha += texture2D(uSampler, vBlurCoords[5]).a * 0.05399;
      alpha += texture2D(uSampler, vBlurCoords[6]).a * 0.00443;
      alpha *= uColor.a;
      gl_FragColor = vec4(uColor.rgb * alpha, alpha);
    }
    """;

  //---------------------------------------------------------------------------

  void configure(int color, num alpha, num radiusX, num radiusY) {

    num r = colorGetR(color) / 255.0;
    num g = colorGetG(color) / 255.0;
    num b = colorGetB(color) / 255.0;
    num a = colorGetA(color) / 255.0 * alpha;

    renderingContext.uniform2f(uniforms["uRadius"], radiusX, radiusY);
    renderingContext.uniform4f(uniforms["uColor"], r, g, b, a);
  }

}

