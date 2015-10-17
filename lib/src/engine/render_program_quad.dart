part of stagexl.engine;

class RenderProgramQuad extends RenderProgram {

  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;
  int _indexCount = 0;
  int _vertexCount = 0;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)
  //---------------------------------------------------------------------------

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute float aVertexAlpha;

    varying vec2 vTextCoord;
    varying float vAlpha;

    void main() {
      vTextCoord = aVertexTextCoord;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;

    uniform sampler2D uSampler;

    varying vec2 vTextCoord;
    varying float vAlpha;

    void main() {
      gl_FragColor = texture2D(uSampler, vTextCoord) * vAlpha;
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);
    super.renderingContext.uniform1i(uniforms["uSampler"], 0);

    _renderBufferIndex = renderContext.renderBufferIndexTriangles;
    _renderBufferIndex.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 20, 0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 20, 8);
    _renderBufferVertex.bindAttribute(attributes["aVertexAlpha"], 1, 20, 16);
  }

  @override
  void flush() {
    if (_vertexCount > 0 && _indexCount > 0) {
      _renderBufferIndex.update(0, _indexCount);
      _renderBufferVertex.update(0, _vertexCount * 5);
      _renderingContext.drawElements(gl.TRIANGLES, _indexCount, gl.UNSIGNED_SHORT, 0);
      _indexCount = 0;
      _vertexCount = 0;
    }
  }

  //---------------------------------------------------------------------------

  void renderQuad(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad) {

    if (renderTextureQuad.hasCustomVertices) {
      _renderQuadWithCustomVertices(renderState, renderTextureQuad);
    } else {
      _renderQuadOptimized(renderState, renderTextureQuad);
    }
  }

  //---------------------------------------------------------------------------

  void _renderQuadOptimized(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad) {

    num alpha = renderState.globalAlpha;
    Matrix matrix = renderState.globalMatrix;
    Float32List vxList = renderTextureQuad.vxListQuad;
    int indexCount = 6;
    int vertexCount = 4;

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num mx = matrix.tx;
    num my = matrix.ty;

    num ox = mx + vxList[0] * ma + vxList[1] * mc;
    num oy = my + vxList[0] * mb + vxList[1] * md;
    num ax = vxList[8] * ma - vxList[0] * ma;
    num bx = vxList[8] * mb - vxList[0] * mb;
    num cy = vxList[9] * mc - vxList[1] * mc;
    num dy = vxList[9] * md - vxList[1] * md;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = _renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < (indexCount + _indexCount)) flush();

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < (vertexCount + _vertexCount) * 5) flush();

    // copy index list

    var ixOffset = _indexCount;
    if (ixOffset > ixData.length - 6) return;

    ixData[ixOffset + 0] = _vertexCount + 0;
    ixData[ixOffset + 1] = _vertexCount + 1;
    ixData[ixOffset + 2] = _vertexCount + 2;
    ixData[ixOffset + 3] = _vertexCount + 0;
    ixData[ixOffset + 4] = _vertexCount + 2;
    ixData[ixOffset + 5] = _vertexCount + 3;

    // copy vertex list

    var vxOffset = _vertexCount * 5;
    if (vxOffset > vxData.length - 20) return;

    vxData[vxOffset + 00] = ox;
    vxData[vxOffset + 01] = oy;
    vxData[vxOffset + 02] = vxList[2];
    vxData[vxOffset + 03] = vxList[3];
    vxData[vxOffset + 04] = alpha;
    vxData[vxOffset + 05] = ox + ax;
    vxData[vxOffset + 06] = oy + bx;
    vxData[vxOffset + 07] = vxList[6];
    vxData[vxOffset + 08] = vxList[7];
    vxData[vxOffset + 09] = alpha;
    vxData[vxOffset + 10] = ox + ax + cy;
    vxData[vxOffset + 11] = oy + bx + dy;
    vxData[vxOffset + 12] = vxList[10];
    vxData[vxOffset + 13] = vxList[11];
    vxData[vxOffset + 14] = alpha;
    vxData[vxOffset + 15] = ox + cy;
    vxData[vxOffset + 16] = oy + dy;
    vxData[vxOffset + 17] = vxList[14];
    vxData[vxOffset + 18] = vxList[15];
    vxData[vxOffset + 19] = alpha;

    _indexCount += indexCount;
    _vertexCount += vertexCount;
  }

  //---------------------------------------------------------------------------

  void _renderQuadWithCustomVertices(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad) {

    num alpha = renderState.globalAlpha;
    Matrix matrix = renderState.globalMatrix;
    Int16List ixList = renderTextureQuad.ixList;
    Float32List vxList = renderTextureQuad.vxList;
    int indexCount = ixList.length;
    int vertexCount = vxList.length >> 2;

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num mx = matrix.tx;
    num my = matrix.ty;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = _renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < (indexCount + _indexCount)) flush();

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < (vertexCount + _vertexCount) * 5) flush();

    // copy index list

    var ixOffset = _indexCount;

    for(var i = 0; i < indexCount; i++) {
      if (ixOffset > ixData.length - 1) break;
      ixData[ixOffset] = _vertexCount + ixList[i];
      ixOffset += 1;
    }

    // copy vertex list

    var vxOffset = _vertexCount * 5;

    for(var i = 0, o = 0; i < vertexCount; i++, o += 4) {

      if (o > vxList.length - 4) break;
      num x = vxList[o + 0];
      num y = vxList[o + 1];
      num u = vxList[o + 2];
      num v = vxList[o + 3];

      if (vxOffset > vxData.length - 5) break;
      vxData[vxOffset + 0] = mx + ma * x + mc * y;
      vxData[vxOffset + 1] = my + mb * x + md * y;
      vxData[vxOffset + 2] = u;
      vxData[vxOffset + 3] = v;
      vxData[vxOffset + 4] = alpha;
      vxOffset += 5;
    }

    _indexCount += indexCount;
    _vertexCount += vertexCount;
  }

}
