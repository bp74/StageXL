library stagexl.filters.tint;

import 'dart:html' show ImageData;
import 'dart:typed_data';
import 'dart:web_gl' as gl;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/environment.dart' as env;
import '../internal/tools.dart';

class TintFilter extends BitmapFilter {

  num factorR;
  num factorG;
  num factorB;
  num factorA;

  TintFilter(this.factorR, this.factorG, this.factorB, this.factorA);

  TintFilter.fromColor(int color) :
    this.factorR = colorGetR(color) / 255.0,
    this.factorG = colorGetG(color) / 255.0,
    this.factorB = colorGetB(color) / 255.0,
    this.factorA = colorGetA(color) / 255.0;

  BitmapFilter clone() => new TintFilter(factorR, factorG, factorB, factorA);

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    bool isLittleEndianSystem = env.isLittleEndianSystem;

    int d0 = ((isLittleEndianSystem ? this.factorR : this.factorA) * 65536).round();
    int d1 = ((isLittleEndianSystem ? this.factorG : this.factorB) * 65536).round();
    int d2 = ((isLittleEndianSystem ? this.factorB : this.factorG) * 65536).round();
    int d3 = ((isLittleEndianSystem ? this.factorA : this.factorR) * 65536).round();

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
      data[index + 0] = ((d0 * c0) | 0) >> 16;
      data[index + 1] = ((d1 * c1) | 0) >> 16;
      data[index + 2] = ((d2 * c2) | 0) >> 16;
      data[index + 3] = ((d3 * c3) | 0) >> 16;
    }

    renderTextureQuad.putImageData(imageData);
  }

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    TintFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$TintFilterProgram", () => new TintFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);
    renderProgram.renderTintFilterQuad(renderState, renderTextureQuad, this);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class TintFilterProgram extends RenderProgram {

  String get vertexShaderSource => """
    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute vec4 aVertexColor;
    uniform mat4 uProjectionMatrix;
    varying vec2 vTextCoord;
    varying vec4 vColor;

    void main() {
      vTextCoord = aVertexTextCoord;
      vColor = aVertexColor;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """
    precision mediump float;
    uniform sampler2D uSampler;
    varying vec2 vTextCoord;
    varying vec4 vColor;

    void main() {
      gl_FragColor = texture2D(uSampler, vTextCoord)* vColor;
    }
    """;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexColor:      Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  Int16List _indexList;
  Float32List _vertexList;

  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexColorLocation = 0;
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
      _aVertexPositionLocation = attributeLocations["aVertexPosition"];
      _aVertexTextCoordLocation = attributeLocations["aVertexTextCoord"];
      _aVertexColorLocation = attributeLocations["aVertexColor"];
      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uSamplerLocation = uniformLocations["uSampler"];

      renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
      renderingContext.enableVertexAttribArray(_aVertexColorLocation);
      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 32, 0);
    renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 32, 8);
    renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 32, 16);
    renderingContext.uniform1i(_uSamplerLocation, 0);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 8);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderTintFilterQuad(
    RenderState renderState, RenderTextureQuad renderTextureQuad, TintFilter tintFilter) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

    num colorR = tintFilter.factorR.toDouble();
    num colorG = tintFilter.factorG.toDouble();
    num colorB = tintFilter.factorB.toDouble();
    num colorA = tintFilter.factorA.toDouble() * alpha;

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num ox = matrix.tx + offsetX * ma + offsetY * mc;
    num oy = matrix.ty + offsetX * mb + offsetY * md;
    num ax = ma * width;
    num bx = mb * width;
    num cy = mc * height;
    num dy = md * height;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixList = _indexList;
    if (ixList == null) return;
    if (ixList.length < _quadCount * 6 + 6) flush();

    var vxList = _vertexList;
    if (vxList == null) return;
    if (vxList.length < _quadCount * 32 + 32) flush();

    var index = _quadCount * 32;
    if (index > vxList.length - 32) return;

    // vertex 1
    vxList[index + 00] = ox;
    vxList[index + 01] = oy;
    vxList[index + 02] = uvList[0];
    vxList[index + 03] = uvList[1];
    vxList[index + 04] = colorR;
    vxList[index + 05] = colorG;
    vxList[index + 06] = colorB;
    vxList[index + 07] = colorA;

    // vertex 2
    vxList[index + 08] = ox + ax;
    vxList[index + 09] = oy + bx;
    vxList[index + 10] = uvList[2];
    vxList[index + 11] = uvList[3];
    vxList[index + 12] = colorR;
    vxList[index + 13] = colorG;
    vxList[index + 14] = colorB;
    vxList[index + 15] = colorA;

    // vertex 3
    vxList[index + 16] = ox + ax + cy;
    vxList[index + 17] = oy + bx + dy;
    vxList[index + 18] = uvList[4];
    vxList[index + 19] = uvList[5];
    vxList[index + 20] = colorR;
    vxList[index + 21] = colorG;
    vxList[index + 22] = colorB;
    vxList[index + 23] = colorA;

    // vertex 4
    vxList[index + 24] = ox + cy;
    vxList[index + 25] = oy + dy;
    vxList[index + 26] = uvList[6];
    vxList[index + 27] = uvList[7];
    vxList[index + 28] = colorR;
    vxList[index + 29] = colorG;
    vxList[index + 30] = colorB;
    vxList[index + 31] = colorA;

    _quadCount += 1;
  }
}
