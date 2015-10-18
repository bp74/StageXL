part of stagexl.engine;

class RenderProgramQuad extends RenderProgram {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)

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

    renderingContext.uniform1i(uniforms["uSampler"], 0);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 20, 0);
    renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 20, 8);
    renderBufferVertex.bindAttribute(attributes["aVertexAlpha"], 1, 20, 16);
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

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var vxList = renderTextureQuad.vxListQuad;
    var indexCount = 6;
    var vertexCount = 4;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData == null) return;
    if (ixData.length < ixPosition + indexCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData == null) return;
    if (vxData.length < vxPosition + vertexCount * 5) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxCount = renderBufferVertex.count;

    if (ixIndex > ixData.length - 6) return;
    ixData[ixIndex + 0] = vxCount + 0;
    ixData[ixIndex + 1] = vxCount + 1;
    ixData[ixIndex + 2] = vxCount + 2;
    ixData[ixIndex + 3] = vxCount + 0;
    ixData[ixIndex + 4] = vxCount + 2;
    ixData[ixIndex + 5] = vxCount + 3;

    renderBufferIndex.position += indexCount;
    renderBufferIndex.count += indexCount;

    // copy vertex list

    var ma = matrix.a;
    var mb = matrix.b;
    var mc = matrix.c;
    var md = matrix.d;
    var mx = matrix.tx;
    var my = matrix.ty;

    var vxIndex = renderBufferVertex.position;
    if (vxIndex > vxData.length - 20) return;

    vxData[vxIndex + 00] = mx + vxList[0] * ma + vxList[1] * mc;
    vxData[vxIndex + 01] = my + vxList[0] * mb + vxList[1] * md;
    vxData[vxIndex + 02] = vxList[2];
    vxData[vxIndex + 03] = vxList[3];
    vxData[vxIndex + 04] = alpha;
    vxData[vxIndex + 05] = mx + vxList[4] * ma + vxList[5] * mc;
    vxData[vxIndex + 06] = my + vxList[4] * mb + vxList[5] * md;
    vxData[vxIndex + 07] = vxList[6];
    vxData[vxIndex + 08] = vxList[7];
    vxData[vxIndex + 09] = alpha;
    vxData[vxIndex + 10] = mx + vxList[8] * ma + vxList[9] * mc;
    vxData[vxIndex + 11] = my + vxList[8] * mb + vxList[9] * md;
    vxData[vxIndex + 12] = vxList[10];
    vxData[vxIndex + 13] = vxList[11];
    vxData[vxIndex + 14] = alpha;
    vxData[vxIndex + 15] = mx + vxList[12] * ma + vxList[13] * mc;
    vxData[vxIndex + 16] = my + vxList[12] * mb + vxList[13] * md;
    vxData[vxIndex + 17] = vxList[14];
    vxData[vxIndex + 18] = vxList[15];
    vxData[vxIndex + 19] = alpha;

    renderBufferVertex.position += vertexCount * 5;
    renderBufferVertex.count += vertexCount;
  }

  //---------------------------------------------------------------------------

  void _renderQuadWithCustomVertices(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad) {

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var ixList = renderTextureQuad.ixList;
    var vxList = renderTextureQuad.vxList;
    var indexCount = ixList.length;
    var vertexCount = vxList.length >> 2;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData == null) return;
    if (ixData.length < ixPosition + indexCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData == null) return;
    if (vxData.length < vxPosition + vertexCount * 5) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxCount = renderBufferVertex.count;

    for(var i = 0; i < indexCount; i++) {
      if (ixIndex > ixData.length - 1) break;
      ixData[ixIndex] = vxCount + ixList[i];
      ixIndex += 1;
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

    var vxIndex = renderBufferVertex.position;

    for(var i = 0, o = 0; i < vertexCount; i++, o += 4) {

      if (o > vxList.length - 4) break;
      num x = vxList[o + 0];
      num y = vxList[o + 1];
      num u = vxList[o + 2];
      num v = vxList[o + 3];

      if (vxIndex > vxData.length - 5) break;
      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = u;
      vxData[vxIndex + 3] = v;
      vxData[vxIndex + 4] = alpha;
      vxIndex += 5;
    }

    renderBufferVertex.position += vertexCount * 5;
    renderBufferVertex.count += vertexCount;
  }

}
