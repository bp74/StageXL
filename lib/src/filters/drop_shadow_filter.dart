library stagexl.filters.drop_shadow;

import 'dart:math' hide Point, Rectangle;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/filter_helpers.dart';
import '../internal/tools.dart';

class DropShadowFilter extends BitmapFilter {
  num _distance = 8;
  num _angle = pi / 4;
  int _blurX = 4;
  int _blurY = 4;
  int _quality = 1;
  int _color = 0xFF000000;

  bool knockout = false;
  bool hideObject = false;

  final List<int> _renderPassSources = <int>[];
  final List<int> _renderPassTargets = <int>[];

  DropShadowFilter(
      [num distance = 8,
      num angle = pi / 4,
      int color = 0xFF000000,
      int blurX = 4,
      int blurY = 4,
      int quality = 1,
      bool knockout = false,
      bool hideObject = false]) {
    this.distance = distance;
    this.angle = angle;
    this.color = color;
    this.blurX = blurX;
    this.blurY = blurY;
    this.quality = quality;
    this.knockout = knockout;
    this.hideObject = hideObject;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  BitmapFilter clone() {
    return DropShadowFilter(
        distance, angle, color, blurX, blurY, quality, knockout, hideObject);
  }

  @override
  Rectangle<int> get overlap {
    var shiftX = (distance * cos(angle)).round();
    var shiftY = (distance * sin(angle)).round();
    var sRect = Rectangle<int>(-1, -1, 2, 2);
    var dRect =
        Rectangle<int>(shiftX - blurX, shiftY - blurY, 2 * blurX, 2 * blurY);
    return sRect.boundingBox(dRect);
  }

  @override
  List<int> get renderPassSources => _renderPassSources;

  @override
  List<int> get renderPassTargets => _renderPassTargets;

  //---------------------------------------------------------------------------

  /// The distance from the object to the shadow.

  num get distance => _distance;

  set distance(num value) {
    _distance = value;
  }

  /// The angle where the shadow is casted to.

  num get angle => _angle;

  set angle(num value) {
    _angle = value;
  }

  /// The color of the shadow.

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

  /// The quality of the shadow in the range from 1 to 5.
  /// A small value is sufficent for small blur radii, a high blur
  /// radius may require a heigher quality setting.

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

    _renderPassSources.add(0);
    _renderPassTargets.add(value * 2);
  }

  //---------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num>? rectangle]) {
    var renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    var sourceImageData = hideObject == false || knockout
        ? renderTextureQuad.getImageData()
        : null;

    var imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    var width = imageData.width;
    var height = imageData.height;
    var shiftX = (distance * cos(angle)).round();
    var shiftY = (distance * sin(angle)).round();

    var pixelRatio = renderTextureQuad.pixelRatio;
    var blurX = (this.blurX * pixelRatio).round();
    var blurY = (this.blurY * pixelRatio).round();
    var alphaChannel =
        BitmapDataChannel.getCanvasIndex(BitmapDataChannel.ALPHA);
    var stride = width * 4;

    shiftChannel(data, 3, width, height, shiftX, shiftY);

    for (var x = 0; x < width; x++) {
      blur(data, x * 4 + alphaChannel, height, stride, blurY);
    }

    for (var y = 0; y < height; y++) {
      blur(data, y * stride + alphaChannel, width, 4, blurX);
    }

    if (knockout) {
      setColorKnockout(data, color, sourceImageData!.data);
    } else if (hideObject) {
      setColor(data, color);
    } else {
      setColorBlend(data, color, sourceImageData!.data);
    }

    renderTextureQuad.putImageData(imageData);
  }

  //---------------------------------------------------------------------------

  @override
  void renderFilter(
      RenderState renderState, RenderTextureQuad? renderTextureQuad, int pass) {
    var renderContext = renderState.renderContext as RenderContextWebGL?;
    var renderTexture = renderTextureQuad!.renderTexture;
    var passCount = _renderPassSources.length;
    var passScale = pow(0.5, pass >> 1);
    var pixelRatio = sqrt(renderState.globalMatrix.det.abs());
    var pixelRatioScale = pixelRatio * passScale;
    var pixelRatioDistance = pixelRatio * distance;

    if (pass == passCount - 1) {
      if (!knockout && !hideObject) {
        renderContext!.renderTextureQuad(renderState, renderTextureQuad);
      }
    } else {
      var renderProgram = renderContext!.getRenderProgram(
          r'$DropShadowFilterProgram', () => DropShadowFilterProgram());

      renderContext.activateRenderProgram(renderProgram);
      renderContext.activateRenderTexture(renderTexture);

      renderProgram.configure(
          pass == passCount - 2 ? color : color | 0xFF000000,
          pass == passCount - 2 ? renderState.globalAlpha : 1.0,
          pass == 0
              ? pixelRatioDistance * cos(angle) / renderTexture.width
              : 0.0,
          pass == 0
              ? pixelRatioDistance * sin(angle) / renderTexture.height
              : 0.0,
          pass.isEven ? pixelRatioScale * blurX / renderTexture.width : 0.0,
          pass.isEven ? 0.0 : pixelRatioScale * blurY / renderTexture.height);

      renderProgram.renderTextureQuad(renderState, renderTextureQuad);
      renderProgram.flush();
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class DropShadowFilterProgram extends RenderProgramSimple {
  @override
  String get vertexShaderSource => '''

    uniform mat4 uProjectionMatrix;
    uniform vec2 uRadius;
    uniform vec2 uShift;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;

    varying vec2 vBlurCoords[7];

    void main() {
      vec2 texCoord = aVertexTextCoord - uShift;
      vBlurCoords[0] = texCoord - uRadius * 1.2;
      vBlurCoords[1] = texCoord - uRadius * 0.8;
      vBlurCoords[2] = texCoord - uRadius * 0.4;
      vBlurCoords[3] = texCoord;
      vBlurCoords[4] = texCoord + uRadius * 0.4;
      vBlurCoords[5] = texCoord + uRadius * 0.8;
      vBlurCoords[6] = texCoord + uRadius * 1.2;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    ''';

  @override
  String get fragmentShaderSource => '''

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
    ''';

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void configure(
      int color, num alpha, num shiftX, num shiftY, num radiusX, num radiusY) {
    num r = colorGetR(color) / 255.0;
    num g = colorGetG(color) / 255.0;
    num b = colorGetB(color) / 255.0;
    num a = colorGetA(color) / 255.0 * alpha;

    renderingContext.uniform2f(uniforms['uShift'], shiftX, shiftY);
    renderingContext.uniform2f(uniforms['uRadius'], radiusX, radiusY);
    renderingContext.uniform4f(uniforms['uColor'], r, g, b, a);
  }
}
