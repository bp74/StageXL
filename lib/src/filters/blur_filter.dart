library stagexl.filters.blur;

import 'dart:math' hide Point, Rectangle;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/filter_helpers.dart';

class BlurFilter extends BitmapFilter {
  late int _blurX;
  late int _blurY;
  late int _quality;

  final List<int> _renderPassSources = <int>[];
  final List<int> _renderPassTargets = <int>[];

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

  @override
  BitmapFilter clone() => BlurFilter(blurX, blurY);

  @override
  Rectangle<int> get overlap =>
      Rectangle<int>(-blurX, -blurY, 2 * blurX, 2 * blurY);

  @override
  List<int> get renderPassSources => _renderPassSources;

  @override
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
  /// A small value is sufficient for small blur radii, a high blur
  /// radius may require a higher quality setting.

  int get quality => _quality;

  set quality(int value) {
    RangeError.checkValueInInterval(value, 1, 5);

    _quality = value;
    _renderPassSources.clear();
    _renderPassTargets.clear();

    for (var i = 0; i < value; i++) {
      _renderPassSources.add(i * 2 + 0);
      _renderPassSources.add(i * 2 + 1);
      _renderPassTargets.add(i * 2 + 1);
      _renderPassTargets.add(i * 2 + 2);
    }
  }

  //---------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num>? rectangle]) {
    final renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    final imageData = renderTextureQuad.getImageData();
    final data = imageData.data;
    final width = imageData.width;
    final height = imageData.height;

    final pixelRatio = renderTextureQuad.pixelRatio;
    final blurX = (this.blurX * pixelRatio).round();
    final blurY = (this.blurY * pixelRatio).round();
    final stride = width * 4;

    premultiplyAlpha(data);

    for (var x = 0; x < width; x++) {
      blur(data, x * 4 + 0, height, stride, blurY);
      blur(data, x * 4 + 1, height, stride, blurY);
      blur(data, x * 4 + 2, height, stride, blurY);
      blur(data, x * 4 + 3, height, stride, blurY);
    }

    for (var y = 0; y < height; y++) {
      blur(data, y * stride + 0, width, 4, blurX);
      blur(data, y * stride + 1, width, 4, blurX);
      blur(data, y * stride + 2, width, 4, blurX);
      blur(data, y * stride + 3, width, 4, blurX);
    }

    unpremultiplyAlpha(data);

    renderTextureQuad.putImageData(imageData);
  }

  //---------------------------------------------------------------------------

  @override
  void renderFilter(
      RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    final renderContext = renderState.renderContext as RenderContextWebGL;
    final renderTexture = renderTextureQuad.renderTexture;
    final passCount = _renderPassSources.length;
    final passScale = pow(0.5, pass >> 1);
    final pixelRatio = sqrt(renderState.globalMatrix.det.abs());
    final pixelRatioScale = pixelRatio * passScale;

    final renderProgram = renderContext.getRenderProgram(
        r'$BlurFilterProgram', BlurFilterProgram.new);

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);

    renderProgram.configure(
        pass == passCount - 1 ? renderState.globalAlpha : 1.0,
        pass.isEven ? pixelRatioScale * blurX / renderTexture.width : 0.0,
        pass.isEven ? 0.0 : pixelRatioScale * blurY / renderTexture.height);

    renderProgram.renderTextureQuad(renderState, renderTextureQuad);
    renderProgram.flush();
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class BlurFilterProgram extends RenderProgramSimple {
  @override
  String get vertexShaderSource => '''

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
    ''';

  @override
  String get fragmentShaderSource => '''

    precision mediump float;

    uniform sampler2D uSampler;
    uniform float uAlpha;

    varying vec2 vBlurCoords[7];

    void main() {
      vec4 sum = vec4(0.0);
      sum += texture2D(uSampler, vBlurCoords[0]) * 0.00443;
      sum += texture2D(uSampler, vBlurCoords[1]) * 0.05399;
      sum += texture2D(uSampler, vBlurCoords[2]) * 0.24197;
      sum += texture2D(uSampler, vBlurCoords[3]) * 0.39894;
      sum += texture2D(uSampler, vBlurCoords[4]) * 0.24197;
      sum += texture2D(uSampler, vBlurCoords[5]) * 0.05399;
      sum += texture2D(uSampler, vBlurCoords[6]) * 0.00443;
      gl_FragColor = sum * uAlpha;
    }
    ''';

  //---------------------------------------------------------------------------

  void configure(num alpha, num radiusX, num radiusY) {
    renderingContext.uniform1f(uniforms['uAlpha'], alpha);
    renderingContext.uniform2f(uniforms['uRadius'], radiusX, radiusY);
  }
}
