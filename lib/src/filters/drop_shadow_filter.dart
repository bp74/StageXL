library stagexl.filters.drop_shadow;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show ImageData;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/filter_helpers.dart';
import '../internal/tools.dart';

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
      throw new ArgumentError("The minimum blur size is 0.");

    if (blurX > 64 || blurY > 64)
      throw new ArgumentError("The maximum blur size is 64.");
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

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

  List<int> get renderPassSources => const [0, 1, 0];
  List<int> get renderPassTargets => const [1, 2, 2];

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
    int shiftX = (this.distance * cos(this.angle)).round();
    int shiftY = (this.distance * sin(this.angle)).round();

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int alphaChannel = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.ALPHA);
    int stride = width * 4;

    shiftChannel(data, 3, width, height, shiftX, shiftY);

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

    DropShadowFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$DropShadowFilterProgram", () => new DropShadowFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);

    if (pass == 0) {
      var shift = (this.distance * cos(this.angle)).round() / renderTexture.width;
      var radius = blurX / renderTexture.width;
      renderProgram.configure(color, shift, 0.0, radius, 0.0);
      renderProgram.renderQuad(renderState, renderTextureQuad);
    } else if (pass == 1) {
      var shift = (this.distance * sin(this.angle)).round() / renderTexture.height;
      var radius = blurY / renderTexture.height;
      renderProgram.configure(color, 0.0, shift, 0.0, radius);
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

class DropShadowFilterProgram extends BitmapFilterProgram {

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    uniform vec2 uRadius;
    uniform vec2 uShift;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute float aVertexAlpha;

    varying vec2 vBlurCoords[15];
    varying float vAlpha;

    void main() {
      vec2 textCoord = aVertexTextCoord - uShift;
      vBlurCoords[ 0] = textCoord - uRadius * 1.4;
      vBlurCoords[ 1] = textCoord - uRadius * 1.2;
      vBlurCoords[ 2] = textCoord - uRadius * 1.0;
      vBlurCoords[ 3] = textCoord - uRadius * 0.8;
      vBlurCoords[ 4] = textCoord - uRadius * 0.6;
      vBlurCoords[ 5] = textCoord - uRadius * 0.4;
      vBlurCoords[ 6] = textCoord - uRadius * 0.2;
      vBlurCoords[ 7] = textCoord;
      vBlurCoords[ 8] = textCoord + uRadius * 0.2;
      vBlurCoords[ 9] = textCoord + uRadius * 0.4;
      vBlurCoords[10] = textCoord + uRadius * 0.6;
      vBlurCoords[11] = textCoord + uRadius * 0.8;
      vBlurCoords[12] = textCoord + uRadius * 1.0;
      vBlurCoords[13] = textCoord + uRadius * 1.2;
      vBlurCoords[14] = textCoord + uRadius * 1.4;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """
    precision mediump float;
    uniform sampler2D uSampler;
    uniform vec4 uColor;
      
    varying vec2 vBlurCoords[15];
    varying float vAlpha;

    void main() {
      float alpha = 0.0;
      alpha += texture2D(uSampler, vBlurCoords[ 0]).a * 0.00443;
      alpha += texture2D(uSampler, vBlurCoords[ 1]).a * 0.00896;
      alpha += texture2D(uSampler, vBlurCoords[ 2]).a * 0.02160;
      alpha += texture2D(uSampler, vBlurCoords[ 3]).a * 0.04437;
      alpha += texture2D(uSampler, vBlurCoords[ 4]).a * 0.07768;
      alpha += texture2D(uSampler, vBlurCoords[ 5]).a * 0.11588;
      alpha += texture2D(uSampler, vBlurCoords[ 6]).a * 0.14731;
      alpha += texture2D(uSampler, vBlurCoords[ 7]).a * 0.15958;
      alpha += texture2D(uSampler, vBlurCoords[ 8]).a * 0.14731;
      alpha += texture2D(uSampler, vBlurCoords[ 9]).a * 0.11588;
      alpha += texture2D(uSampler, vBlurCoords[10]).a * 0.07768;
      alpha += texture2D(uSampler, vBlurCoords[11]).a * 0.04437;
      alpha += texture2D(uSampler, vBlurCoords[12]).a * 0.02160;
      alpha += texture2D(uSampler, vBlurCoords[13]).a * 0.00896;
      alpha += texture2D(uSampler, vBlurCoords[14]).a * 0.00443;
      alpha *= vAlpha;
      alpha *= uColor.a;
      gl_FragColor = vec4(uColor.rgb * alpha, alpha);
    }
    """;

  void configure(int color, num shiftX, num shiftY, num radiusX, num radiusY) {

    num r = colorGetR(color) / 255.0;
    num g = colorGetG(color) / 255.0;
    num b = colorGetB(color) / 255.0;
    num a = colorGetA(color) / 255.0;

    var uColorLocation = uniformLocations["uColor"];
    var uShiftLocation = uniformLocations["uShift"];
    var uRadiusLocation = uniformLocations["uRadius"];

    renderingContext.uniform4f(uColorLocation, r, g, b, a);
    renderingContext.uniform2f(uShiftLocation, shiftX, shiftY);
    renderingContext.uniform2f(uRadiusLocation, radiusX, radiusY);
  }
}
