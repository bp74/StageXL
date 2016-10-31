library stagexl.filters.color_matrix;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show ImageData;
import 'dart:typed_data';

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/environment.dart' as env;
import '../internal/tools.dart';

class ColorMatrixFilter extends BitmapFilter {

  Float32List _colorMatrixList = new Float32List(16);
  Float32List _colorOffsetList = new Float32List(4);

  static const num _lumaR = 0.213;
  static const num _lumaG = 0.715;
  static const num _lumaB = 0.072;

  ColorMatrixFilter(List<num> colorMatrix, List<num> colorOffset) {

    if (colorMatrix.length != 16) throw new ArgumentError("colorMatrix");
    if (colorOffset.length != 4) throw new ArgumentError("colorOffset");

    for(int i = 0; i < colorMatrix.length; i++) {
      _colorMatrixList[i] = colorMatrix[i].toDouble();
    }

    for(int i = 0; i < colorOffset.length; i++) {
      _colorOffsetList[i] = colorOffset[i].toDouble();
    }
  }

  ColorMatrixFilter.grayscale() : this(
      [0.213, 0.715, 0.072, 0, 0.213, 0.715, 0.072, 0, 0.213, 0.715, 0.072, 0, 0, 0, 0, 1],
      [0, 0, 0, 0]);

  ColorMatrixFilter.invert() : this(
      [-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1],
      [255, 255, 255, 0]);

  ColorMatrixFilter.identity() : this(
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [0, 0, 0, 0]);

  factory ColorMatrixFilter.adjust({
    num hue: 0, num saturation: 0, num brightness: 0, num contrast: 0}) {

    var colorMatrixFilter = new ColorMatrixFilter.identity();
    colorMatrixFilter.adjustHue(hue);
    colorMatrixFilter.adjustSaturation(saturation);
    colorMatrixFilter.adjustBrightness(brightness);
    colorMatrixFilter.adjustContrast(contrast);
    return colorMatrixFilter;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  @override
  BitmapFilter clone() => new ColorMatrixFilter(_colorMatrixList, _colorOffsetList);

  //-----------------------------------------------------------------------------------------------

  void adjustInversion(num value) {

    _concat([-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1], [255, 255, 255, 0]);
  }

  void adjustHue(num value) {

    num v = min(max(value, -1), 1) * PI;
    num cv = cos(v);
    num sv = sin(v);

    _concat([
        _lumaR - cv * _lumaR - sv * _lumaR + cv,
        _lumaG - cv * _lumaG - sv * _lumaG,
        _lumaB - cv * _lumaB - sv * _lumaB + sv, 0,
        _lumaR - cv * _lumaR + sv * 0.143,
        _lumaG - cv * _lumaG + sv * 0.140 + cv,
        _lumaB - cv * _lumaB - sv * 0.283, 0,
        _lumaR - cv * _lumaR + sv * _lumaR - sv,
        _lumaG - cv * _lumaG + sv * _lumaG,
        _lumaB - cv * _lumaB + sv * _lumaB + cv, 0,
        0, 0, 0, 1], [0, 0, 0, 0]);
  }

  void adjustSaturation(num value) {

    num v = min(max(value, -1), 1) + 1;
    num i = 1 - v;
    num r = i * _lumaR;
    num g = i * _lumaG;
    num b = i * _lumaB;

    _concat( [r + v, g, b, 0, r, g + v, b, 0, r, g, b + v, 0, 0, 0, 0, 1], [0, 0, 0, 0]);
  }

  void adjustContrast(num value) {

    num v = min(max(value, -1), 1) + 1;
    num o = 128 * (1 - v);

    _concat([v, 0, 0, 0, 0, v, 0, 0, 0, 0, v, 0, 0, 0, 0, 1], [o, o, o, 0]);
  }

  void adjustBrightness(num value) {

    num v = 255 * min(max(value, -1), 1);

    _concat([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [v, v, v, 0]);
  }

  void adjustColoration(int color, [num strength = 1.0]) {

    num r = colorGetR(color) * strength / 255.0;
    num g = colorGetG(color) * strength / 255.0;
    num b = colorGetB(color) * strength / 255.0;
    num i = 1.0 - strength;

    _concat([
        r * _lumaR + i, r * _lumaG, r * _lumaB, 0.0,
        g * _lumaR, g * _lumaG + i, g * _lumaB, 0.0,
        b * _lumaR, b * _lumaG, b * _lumaB + i, 0.0,
        0.0, 0.0, 0.0, 1.0], [0, 0, 0, 0]);
  }

  //-----------------------------------------------------------------------------------------------

  void _concat(List<num> colorMatrix, List<num> colorOffset) {

    var newColorMatrix = new Float32List(16);
    var newColorOffset = new Float32List(4);

    for (var y = 0, i = 0; y < 4; y++, i += 4) {

      if (i > 12) continue; // dart2js_hint

      for (var x = 0; x < 4; ++x) {
        newColorMatrix[i + x] =
          colorMatrix[i + 0] * _colorMatrixList[x +  0] +
          colorMatrix[i + 1] * _colorMatrixList[x +  4] +
          colorMatrix[i + 2] * _colorMatrixList[x +  8] +
          colorMatrix[i + 3] * _colorMatrixList[x + 12];
      }

      newColorOffset[y] =
          colorOffset[y    ] +
          colorMatrix[i + 0] * _colorOffsetList[0] +
          colorMatrix[i + 1] * _colorOffsetList[1] +
          colorMatrix[i + 2] * _colorOffsetList[2] +
          colorMatrix[i + 3] * _colorOffsetList[3];
    }

    _colorMatrixList = newColorMatrix;
    _colorOffsetList = newColorOffset;
  }

  //-----------------------------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num> rectangle]) {

    //dstR = (m[ 0] * srcR) + (m[ 1] * srcG) + (m[ 2] * srcB) + (m[ 3] * srcA) + o[0]
    //dstG = (m[ 4] * srcR) + (m[ 5] * srcG) + (m[ 6] * srcB) + (m[ 7] * srcA) + o[1]
    //dstB = (m[ 8] * srcR) + (m[ 9] * srcG) + (m[10] * srcB) + (m[11] * srcA) + o[2]
    //dstA = (m[12] * srcR) + (m[13] * srcG) + (m[14] * srcB) + (m[15] * srcA) + o[3]

    bool isLittleEndianSystem = env.isLittleEndianSystem;

    num m00 = _colorMatrixList[isLittleEndianSystem ? 00 : 15];
    num m01 = _colorMatrixList[isLittleEndianSystem ? 01 : 14];
    num m02 = _colorMatrixList[isLittleEndianSystem ? 02 : 13];
    num m03 = _colorMatrixList[isLittleEndianSystem ? 03 : 12];
    num m10 = _colorMatrixList[isLittleEndianSystem ? 04 : 11];
    num m11 = _colorMatrixList[isLittleEndianSystem ? 05 : 10];
    num m12 = _colorMatrixList[isLittleEndianSystem ? 06 : 09];
    num m13 = _colorMatrixList[isLittleEndianSystem ? 07 : 08];
    num m20 = _colorMatrixList[isLittleEndianSystem ? 08 : 07];
    num m21 = _colorMatrixList[isLittleEndianSystem ? 09 : 06];
    num m22 = _colorMatrixList[isLittleEndianSystem ? 10 : 05];
    num m23 = _colorMatrixList[isLittleEndianSystem ? 11 : 04];
    num m30 = _colorMatrixList[isLittleEndianSystem ? 12 : 03];
    num m31 = _colorMatrixList[isLittleEndianSystem ? 13 : 02];
    num m32 = _colorMatrixList[isLittleEndianSystem ? 14 : 01];
    num m33 = _colorMatrixList[isLittleEndianSystem ? 15 : 00];

    num o0 = _colorOffsetList[isLittleEndianSystem ? 00 : 03];
    num o1 = _colorOffsetList[isLittleEndianSystem ? 01 : 02];
    num o2 = _colorOffsetList[isLittleEndianSystem ? 02 : 01];
    num o3 = _colorOffsetList[isLittleEndianSystem ? 03 : 00];

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;

    for(int i = 0 ; i <= data.length - 4; i += 4) {
      int c0 = data[i + 0];
      int c1 = data[i + 1];
      int c2 = data[i + 2];
      int c3 = data[i + 3];
      data[i + 0] = (m00 * c0 + m01 * c1 + m02 * c2 + m03 * c3 + o0).round();
      data[i + 1] = (m10 * c0 + m11 * c1 + m12 * c2 + m13 * c3 + o1).round();
      data[i + 2] = (m20 * c0 + m21 * c1 + m22 * c2 + m23 * c3 + o2).round();
      data[i + 3] = (m30 * c0 + m31 * c1 + m32 * c2 + m33 * c3 + o3).round();
    }

    renderTextureQuad.putImageData(imageData);
  }

  //-----------------------------------------------------------------------------------------------

  @override
  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    ColorMatrixFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$ColorMatrixFilterProgram", () => new ColorMatrixFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);
    renderProgram.renderColorMatrixFilterQuad(renderState, renderTextureQuad, this);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class ColorMatrixFilterProgram extends RenderProgram {

  // aPosition:  Float32(x), Float32(y)
  // aTexCoord:  Float32(u), Float32(v)
  // aMatrixR:   Float32(r), Float32(g), Float32(b), Float32(a)
  // aMatrixG:   Float32(r), Float32(g), Float32(b), Float32(a)
  // aMatrixB:   Float32(r), Float32(g), Float32(b), Float32(a)
  // aMatrixA:   Float32(r), Float32(g), Float32(b), Float32(a)
  // aOffset:    Float32(r), Float32(g), Float32(b), Float32(a)

  @override
  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;

    attribute vec2 aPosition;
    attribute vec2 aTexCoord;
    attribute vec4 aMatrixR, aMatrixG, aMatrixB, aMatrixA; 
    attribute vec4 aOffset;

    varying vec2 vTexCoord;
    varying vec4 vMatrixR, vMatrixG, vMatrixB, vMatrixA;
    varying vec4 vOffset;

    void main() {
      vTexCoord = aTexCoord; 
      vMatrixR = aMatrixR; 
      vMatrixG = aMatrixG;
      vMatrixB = aMatrixB; 
      vMatrixA = aMatrixA; 
      vOffset = aOffset;
      gl_Position = vec4(aPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  @override
  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;

    varying vec2 vTexCoord;
    varying vec4 vMatrixR, vMatrixG, vMatrixB, vMatrixA;
    varying vec4 vOffset;

    void main() {
      vec4 color = texture2D(uSampler, vTexCoord);
      mat4 colorMatrix = mat4(vMatrixR, vMatrixG, vMatrixB, vMatrixA);
      color = vec4(color.rgb / color.a, color.a);
      color = vOffset + color * colorMatrix;
      gl_FragColor = vec4(color.rgb * color.a, color.a);
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderingContext.uniform1i(uniforms["uSampler"], 0);

    renderBufferVertex.bindAttribute(attributes["aPosition"], 2, 96, 0);
    renderBufferVertex.bindAttribute(attributes["aTexCoord"], 2, 96, 8);
    renderBufferVertex.bindAttribute(attributes["aMatrixR"],  4, 96, 16);
    renderBufferVertex.bindAttribute(attributes["aMatrixG"],  4, 96, 32);
    renderBufferVertex.bindAttribute(attributes["aMatrixB"],  4, 96, 48);
    renderBufferVertex.bindAttribute(attributes["aMatrixA"],  4, 96, 64);
    renderBufferVertex.bindAttribute(attributes["aOffset"],   4, 96, 80);
  }

  //---------------------------------------------------------------------------

  void renderColorMatrixFilterQuad(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad,
      ColorMatrixFilter colorMatrixFilter) {

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var ixList = renderTextureQuad.ixList;
    var vxList = renderTextureQuad.vxList;
    var indexCount = ixList.length;
    var vertexCount = vxList.length >> 2;

    var colorMatrixList = colorMatrixFilter._colorMatrixList;
    var colorOffsetList = colorMatrixFilter._colorOffsetList;

    // check buffer sizes and flush if necessary

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixPosition + indexCount >= ixData.length) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxPosition + vertexCount * 24 >= vxData.length) flush();

    var ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    var vxCount = renderBufferVertex.count;

    // copy index list

    for(var i = 0; i < indexCount; i++) {
      ixData[ixIndex + i] = vxCount + ixList[i];
    }

    renderBufferIndex.position += indexCount;
    renderBufferIndex.count += indexCount;

    // copy vertex list

    var ma = matrix.a;
    var mb = matrix.b;
    var mc = matrix.c;
    var md = matrix.d;
    var mx = matrix.tx;
    var my = matrix.ty;

    for(var i = 0, o = 0; i < vertexCount; i++, o += 4) {
      num x = vxList[o + 0];
      num y = vxList[o + 1];
      vxData[vxIndex + 00] = mx + ma * x + mc * y;
      vxData[vxIndex + 01] = my + mb * x + md * y;
      vxData[vxIndex + 02] = vxList[o + 2];
      vxData[vxIndex + 03] = vxList[o + 3];
      vxData[vxIndex + 04] = colorMatrixList[00];
      vxData[vxIndex + 05] = colorMatrixList[01];
      vxData[vxIndex + 06] = colorMatrixList[02];
      vxData[vxIndex + 07] = colorMatrixList[03];
      vxData[vxIndex + 08] = colorMatrixList[04];
      vxData[vxIndex + 09] = colorMatrixList[05];
      vxData[vxIndex + 10] = colorMatrixList[06];
      vxData[vxIndex + 11] = colorMatrixList[07];
      vxData[vxIndex + 12] = colorMatrixList[08];
      vxData[vxIndex + 13] = colorMatrixList[09];
      vxData[vxIndex + 14] = colorMatrixList[10];
      vxData[vxIndex + 15] = colorMatrixList[11];
      vxData[vxIndex + 16] = colorMatrixList[12] * alpha;
      vxData[vxIndex + 17] = colorMatrixList[13] * alpha;
      vxData[vxIndex + 18] = colorMatrixList[14] * alpha;
      vxData[vxIndex + 19] = colorMatrixList[15] * alpha;
      vxData[vxIndex + 20] = colorOffsetList[00] / 255.0;
      vxData[vxIndex + 21] = colorOffsetList[01] / 255.0;
      vxData[vxIndex + 22] = colorOffsetList[02] / 255.0;
      vxData[vxIndex + 23] = colorOffsetList[03] / 255.0 * alpha;
      vxIndex += 24;
    }

    renderBufferVertex.position += vertexCount * 24;
    renderBufferVertex.count += vertexCount;
  }

}
