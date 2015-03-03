library stagexl.filters.color_matrix;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show ImageData;
import 'dart:typed_data';
import 'dart:web_gl' as gl;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/environment.dart' as env;
import '../internal/tools.dart';

class ColorMatrixFilter extends BitmapFilter {

  Float32List _colorMatrixList = new Float32List(16);
  Float32List _colorOffsetList = new Float32List(4);

  final num _lumaR = 0.213;
  final num _lumaG = 0.715;
  final num _lumaB = 0.072;

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

    _concat([v, 0, 0, 0, 0, v, 0, 0, 0, 0, v, 0, 0, 0, 0, v], [o, o, o, 0]);
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

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    //dstR = (m[ 0] * srcR) + (m[ 1] * srcG) + (m[ 2] * srcB) + (m[ 3] * srcA) + o[0]
    //dstG = (m[ 4] * srcR) + (m[ 5] * srcG) + (m[ 6] * srcB) + (m[ 7] * srcA) + o[1]
    //dstB = (m[ 8] * srcR) + (m[ 9] * srcG) + (m[10] * srcB) + (m[11] * srcA) + o[2]
    //dstA = (m[12] * srcR) + (m[13] * srcG) + (m[14] * srcB) + (m[15] * srcA) + o[3]

    bool isLittleEndianSystem = env.isLittleEndianSystem;

    int d0c0 = (_colorMatrixList[isLittleEndianSystem ? 00 : 15] * 65536).round();
    int d0c1 = (_colorMatrixList[isLittleEndianSystem ? 01 : 14] * 65536).round();
    int d0c2 = (_colorMatrixList[isLittleEndianSystem ? 02 : 13] * 65536).round();
    int d0c3 = (_colorMatrixList[isLittleEndianSystem ? 03 : 12] * 65536).round();
    int d1c0 = (_colorMatrixList[isLittleEndianSystem ? 04 : 11] * 65536).round();
    int d1c1 = (_colorMatrixList[isLittleEndianSystem ? 05 : 10] * 65536).round();
    int d1c2 = (_colorMatrixList[isLittleEndianSystem ? 06 : 09] * 65536).round();
    int d1c3 = (_colorMatrixList[isLittleEndianSystem ? 07 : 08] * 65536).round();
    int d2c0 = (_colorMatrixList[isLittleEndianSystem ? 08 : 07] * 65536).round();
    int d2c1 = (_colorMatrixList[isLittleEndianSystem ? 09 : 06] * 65536).round();
    int d2c2 = (_colorMatrixList[isLittleEndianSystem ? 10 : 05] * 65536).round();
    int d2c3 = (_colorMatrixList[isLittleEndianSystem ? 11 : 04] * 65536).round();
    int d3c0 = (_colorMatrixList[isLittleEndianSystem ? 12 : 03] * 65536).round();
    int d3c1 = (_colorMatrixList[isLittleEndianSystem ? 13 : 02] * 65536).round();
    int d3c2 = (_colorMatrixList[isLittleEndianSystem ? 14 : 01] * 65536).round();
    int d3c3 = (_colorMatrixList[isLittleEndianSystem ? 15 : 00] * 65536).round();

    int d0cc = (_colorOffsetList[isLittleEndianSystem ? 00 : 03] * 65536).round();
    int d1cc = (_colorOffsetList[isLittleEndianSystem ? 01 : 02] * 65536).round();
    int d2cc = (_colorOffsetList[isLittleEndianSystem ? 02 : 01] * 65536).round();
    int d3cc = (_colorOffsetList[isLittleEndianSystem ? 03 : 00] * 65536).round();

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;

    for(int index = 0 ; index <= data.length - 4; index += 4) {
      int c0 = data[index + 0];
      int c1 = data[index + 1];
      int c2 = data[index + 2];
      int c3 = data[index + 3];
      data[index + 0] = ((d0c0 * c0 + d0c1 * c1 + d0c2 * c2 + d0c3 * c3 + d0cc) | 0) >> 16;
      data[index + 1] = ((d1c0 * c0 + d1c1 * c1 + d1c2 * c2 + d1c3 * c3 + d1cc) | 0) >> 16;
      data[index + 2] = ((d2c0 * c0 + d2c1 * c1 + d2c2 * c2 + d2c3 * c3 + d2cc) | 0) >> 16;
      data[index + 3] = ((d3c0 * c0 + d3c1 * c1 + d3c2 * c2 + d3c3 * c3 + d3cc) | 0) >> 16;
    }

    renderTextureQuad.putImageData(imageData);
  }

  //-----------------------------------------------------------------------------------------------

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

  String get vertexShaderSource => """
    uniform mat4 uProjectionMatrix;
    attribute vec2 aVertexPosition, aVertexTexCoord;
    attribute vec4 aVertexColor0, aVertexColor1, aVertexColor2, aVertexColor3, aVertexColor4; 
    varying vec2 vTexCoord;
    varying vec4 vColor0, vColor1, vColor2, vColor3, vColor4;
    void main() {
      vTexCoord = aVertexTexCoord; 
      vColor0 = aVertexColor0; vColor1 = aVertexColor1;
      vColor2 = aVertexColor2; vColor3 = aVertexColor3; vColor4 = aVertexColor4;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """
    precision mediump float;
    uniform sampler2D uSampler;
    varying vec2 vTexCoord;
    varying vec4 vColor0, vColor1, vColor2, vColor3, vColor4;
    void main() {
      vec4 color = texture2D(uSampler, vTexCoord);
      color = vec4(color.rgb / (color.a + 0.001), color.a);
      color = vColor0 + color * mat4(vColor1, vColor2, vColor3, vColor4);
      gl_FragColor = vec4(color.rgb * color.a, color.a);
    }
    """;

  //---------------------------------------------------------------------------
  // aVertexPosition:  Float32(x), Float32(y)
  // aVertexTexCoord:  Float32(u), Float32(v)
  // aVertexColor0:    Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexColor1:    Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexColor2:    Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexColor3:    Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexColor4:    Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  Int16List _indexList;
  Float32List _vertexList;

  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTexCoordLocation = 0;
  int _aVertexColor0Location = 0;
  int _aVertexColor1Location = 0;
  int _aVertexColor2Location = 0;
  int _aVertexColor3Location = 0;
  int _aVertexColor4Location = 0;
  int _quadCount = 0;

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _indexList = renderContext.staticIndexList;
      _vertexList = renderContext.dynamicVertexList;
      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();

      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uSamplerLocation          = uniformLocations["uSampler"];
      _aVertexPositionLocation   = attributeLocations["aVertexPosition"];
      _aVertexTexCoordLocation   = attributeLocations["aVertexTexCoord"];
      _aVertexColor0Location     = attributeLocations["aVertexColor0"];
      _aVertexColor1Location     = attributeLocations["aVertexColor1"];
      _aVertexColor2Location     = attributeLocations["aVertexColor2"];
      _aVertexColor3Location     = attributeLocations["aVertexColor3"];
      _aVertexColor4Location     = attributeLocations["aVertexColor4"];

      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 96, 0);
    renderingContext.vertexAttribPointer(_aVertexTexCoordLocation, 2, gl.FLOAT, false, 96, 8);
    renderingContext.vertexAttribPointer(_aVertexColor0Location,   4, gl.FLOAT, false, 96, 16);
    renderingContext.vertexAttribPointer(_aVertexColor1Location,   4, gl.FLOAT, false, 96, 32);
    renderingContext.vertexAttribPointer(_aVertexColor2Location,   4, gl.FLOAT, false, 96, 48);
    renderingContext.vertexAttribPointer(_aVertexColor3Location,   4, gl.FLOAT, false, 96, 64);
    renderingContext.vertexAttribPointer(_aVertexColor4Location,   4, gl.FLOAT, false, 96, 80);
    renderingContext.uniform1i(_uSamplerLocation, 0);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 24);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderColorMatrixFilterQuad(RenderState renderState,
                                   RenderTextureQuad renderTextureQuad,
                                   ColorMatrixFilter colorMatrixFilter) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

    Float32List colorMatrixList = colorMatrixFilter._colorMatrixList;
    Float32List colorOffsetList = colorMatrixFilter._colorOffsetList;

    // Check if the index and vertex buffer are valid and if
     // we need to flush the render program to free the buffers.

     var ixList = _indexList;
     if (ixList == null) return;
     if (ixList.length < _quadCount * 6 + 6) flush();

     var vxList = _vertexList;
     if (vxList == null) return;
     if (vxList.length < _quadCount * 96 + 96) flush();

     // Calculate the 4 vertices of the RenderTextureQuad

     for(int vertex = 0, index = _quadCount * 96; vertex < 4; vertex++, index += 24) {

       num x = offsetX + (vertex == 1 || vertex == 2 ? width  : 0);
       num y = offsetY + (vertex == 2 || vertex == 3 ? height : 0);

       if (index > vxList.length - 24) return; // dart2js_hint

       vxList[index + 00] = matrix.tx + x * matrix.a + y * matrix.c;
       vxList[index + 01] = matrix.ty + x * matrix.b + y * matrix.d;
       vxList[index + 02] = uvList[vertex + vertex + 0];
       vxList[index + 03] = uvList[vertex + vertex + 1];
       vxList[index + 04] = colorOffsetList[00] / 255.0;
       vxList[index + 05] = colorOffsetList[01] / 255.0;
       vxList[index + 06] = colorOffsetList[02] / 255.0;
       vxList[index + 07] = colorOffsetList[03] / 255.0 * alpha;
       vxList[index + 08] = colorMatrixList[00];
       vxList[index + 09] = colorMatrixList[01];
       vxList[index + 10] = colorMatrixList[02];
       vxList[index + 11] = colorMatrixList[03];
       vxList[index + 12] = colorMatrixList[04];
       vxList[index + 13] = colorMatrixList[05];
       vxList[index + 14] = colorMatrixList[06];
       vxList[index + 15] = colorMatrixList[07];
       vxList[index + 16] = colorMatrixList[08];
       vxList[index + 17] = colorMatrixList[09];
       vxList[index + 18] = colorMatrixList[10];
       vxList[index + 19] = colorMatrixList[11];
       vxList[index + 20] = colorMatrixList[12] * alpha;
       vxList[index + 21] = colorMatrixList[13] * alpha;
       vxList[index + 22] = colorMatrixList[14] * alpha;
       vxList[index + 23] = colorMatrixList[15] * alpha;
     }

     _quadCount += 1;
  }
}
