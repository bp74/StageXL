library stagexl.filters.tint;

import 'dart:typed_data';
import 'dart:web_gl' as gl;

import '../engine.dart';
import '../geom.dart';

class TintProgram extends RenderProgram {

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

  static const int _maxQuadCount = 256;

  gl.Buffer _vertexBuffer = null;
  gl.Buffer _indexBuffer = null;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexColorLocation = 0;
  int _quadCount = 0;

  final Int16List _indexList = new Int16List(_maxQuadCount * 6);
  final Float32List _vertexList = new Float32List(_maxQuadCount * 4 * 8);

  //-----------------------------------------------------------------------------------------------

  TintProgram() {
    for(int i = 0, j = 0; i <= _indexList.length - 6; i += 6, j +=4 ) {
      _indexList[i + 0] = j + 0;
      _indexList[i + 1] = j + 1;
      _indexList[i + 2] = j + 2;
      _indexList[i + 3] = j + 0;
      _indexList[i + 4] = j + 2;
      _indexList[i + 5] = j + 3;
    }
  }

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

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

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad,
                  num factorR, num factorG, num factorB, num factorA) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

    num colorR = factorR.toDouble();
    num colorG = factorG.toDouble();
    num colorB = factorB.toDouble();
    num colorA = factorA.toDouble() * alpha;

    // x' = tx + a * x + c * y
    // y' = ty + b * x + d * y

    num a = matrix.a;
    num b = matrix.b;
    num c = matrix.c;
    num d = matrix.d;

    num ox = matrix.tx + offsetX * a + offsetY * c;
    num oy = matrix.ty + offsetX * b + offsetY * d;
    num ax = a * width;
    num bx = b * width;
    num cy = c * height;
    num dy = d * height;

    int index = _quadCount * 32;
    if (index > _vertexList.length - 32) return; // dart2js_hint

    // vertex 1
    _vertexList[index + 00] = ox;
    _vertexList[index + 01] = oy;
    _vertexList[index + 02] = uvList[0];
    _vertexList[index + 03] = uvList[1];
    _vertexList[index + 04] = colorR;
    _vertexList[index + 05] = colorG;
    _vertexList[index + 06] = colorB;
    _vertexList[index + 07] = colorA;

    // vertex 2
    _vertexList[index + 08] = ox + ax;
    _vertexList[index + 09] = oy + bx;
    _vertexList[index + 10] = uvList[2];
    _vertexList[index + 11] = uvList[3];
    _vertexList[index + 12] = colorR;
    _vertexList[index + 13] = colorG;
    _vertexList[index + 14] = colorB;
    _vertexList[index + 15] = colorA;

    // vertex 3
    _vertexList[index + 16] = ox + ax + cy;
    _vertexList[index + 17] = oy + bx + dy;
    _vertexList[index + 18] = uvList[4];
    _vertexList[index + 19] = uvList[5];
    _vertexList[index + 20] = colorR;
    _vertexList[index + 21] = colorG;
    _vertexList[index + 22] = colorB;
    _vertexList[index + 23] = colorA;

    // vertex 4
    _vertexList[index + 24] = ox + cy;
    _vertexList[index + 25] = oy + dy;
    _vertexList[index + 26] = uvList[6];
    _vertexList[index + 27] = uvList[7];
    _vertexList[index + 28] = colorR;
    _vertexList[index + 29] = colorG;
    _vertexList[index + 30] = colorB;
    _vertexList[index + 31] = colorA;

    _quadCount += 1;

    if (_quadCount == _maxQuadCount) flush();
  }

}