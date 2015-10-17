part of stagexl.engine;

class RenderProgramTriangle extends RenderProgram {

  int _indexCount = 0;
  int _vertexCount = 0;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexAlpha:      Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    attribute vec2 aVertexPosition;
    attribute vec4 aVertexColor;
    varying vec4 vColor;

    void main() {
      vColor = aVertexColor;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;
    varying vec4 vColor;

    void main() {
      gl_FragColor = vec4(vColor.rgb * vColor.a, vColor.a);
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 24, 0);
    renderBufferVertex.bindAttribute(attributes["aVertexColor"], 4, 24, 8);
  }

  @override
  void flush() {
    if (_vertexCount > 0 && _indexCount > 0) {
      renderBufferIndex.update(0, _indexCount);
      renderBufferVertex.update(0, _vertexCount * 6);
      renderingContext.drawElements(gl.TRIANGLES, _indexCount, gl.UNSIGNED_SHORT, 0);
      _indexCount = 0;
      _vertexCount = 0;
    }
  }

  //---------------------------------------------------------------------------

  void renderTriangle(
      RenderState renderState,
      num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    num colorA = colorGetA(color) / 255.0 * alpha;
    num colorR = colorGetR(color) / 255.0;
    num colorG = colorGetG(color) / 255.0;
    num colorB = colorGetB(color) / 255.0;

    num a = matrix.a;
    num b = matrix.b;
    num c = matrix.c;
    num d = matrix.d;
    num tx = matrix.tx;
    num ty = matrix.ty;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < _indexCount + 3) flush();

    var vxData = renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _vertexCount * 6 + 3 * 6) flush();

    var ixOffset = _indexCount;
    var vxOffset = _vertexCount * 6;

    // fill index buffer
    ixData[ixOffset + 0] = _vertexCount + 0;
    ixData[ixOffset + 1] = _vertexCount + 1;
    ixData[ixOffset + 2] = _vertexCount + 2;

    // vertex 1
    vxData[vxOffset + 00] = x1 * a + y1 * c + tx;
    vxData[vxOffset + 01] = x1 * b + y1 * d + ty;
    vxData[vxOffset + 02] = colorR;
    vxData[vxOffset + 03] = colorG;
    vxData[vxOffset + 04] = colorB;
    vxData[vxOffset + 05] = colorA;

    // vertex 2
    vxData[vxOffset + 06] = x2 * a + y2 * c + tx;
    vxData[vxOffset + 07] = x2 * b + y2 * d + ty;
    vxData[vxOffset + 08] = colorR;
    vxData[vxOffset + 09] = colorG;
    vxData[vxOffset + 10] = colorB;
    vxData[vxOffset + 11] = colorA;

    // vertex 3
    vxData[vxOffset + 12] = x3 * a + y3 * c + tx;
    vxData[vxOffset + 13] = x3 * b + y3 * d + ty;
    vxData[vxOffset + 14] = colorR;
    vxData[vxOffset + 15] = colorG;
    vxData[vxOffset + 16] = colorB;
    vxData[vxOffset + 17] = colorA;

    _indexCount += 3;
    _vertexCount += 3;
  }

  //---------------------------------------------------------------------------

  void renderTriangleMesh(
      RenderState renderState,
      int indexCount, Int16List indexList,
      int vertexCount, Float32List vertexList, int color) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    num colorA = colorGetA(color) / 255.0 * alpha;
    num colorR = colorGetR(color) / 255.0;
    num colorG = colorGetG(color) / 255.0;
    num colorB = colorGetB(color) / 255.0;

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num mx = matrix.tx;
    num my = matrix.ty;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < _indexCount + indexCount) flush();

    var vxData = renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _vertexCount * 6 + vertexCount * 6) flush();

    var ixOffset = _indexCount;
    var vxOffset = _vertexCount * 6;
    var vertexListLength = vertexList.length;

    // copy index list

    for(var i = 0; i < indexCount; i++) {
      if (ixOffset > ixData.length - 1) break;
      ixData[ixOffset] = _vertexCount + indexList[i];
      ixOffset += 1;
    }

    // copy vertex list

    for(var i = 0, o = 0 ; i < vertexCount; i++, o += 2) {

      if (vxOffset > vxData.length - 6) break;
      if (o > vertexListLength - 2) break;

      num x = vertexList[o + 0];
      num y = vertexList[o + 1];

      vxData[vxOffset + 0] = mx + ma * x + mc * y;
      vxData[vxOffset + 1] = my + mb * x + md * y;
      vxData[vxOffset + 2] = colorR;
      vxData[vxOffset + 3] = colorG;
      vxData[vxOffset + 4] = colorB;
      vxData[vxOffset + 5] = colorA;
      vxOffset += 6;
    }

    _indexCount += indexCount;
    _vertexCount += vertexCount;
  }

}
