part of stagexl.engine;

class RenderProgramSimple extends RenderProgram {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)

  @override
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

  @override
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

  void renderTextureQuad(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad) {

    if (renderTextureQuad.hasCustomVertices) {
      var ixList = renderTextureQuad.ixList;
      var vxList = renderTextureQuad.vxList;
      this.renderTextureMesh(renderState, ixList, vxList);
      return;
    }

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var vxList = renderTextureQuad.vxListQuad;
    var ixListCount = 6;
    var vxListCount = 4;

    // check buffer sizes and flush if necessary

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 5 >= vxData.length) flush();

    var ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    var vxCount = renderBufferVertex.count;

    // copy index list

    ixData[ixIndex + 0] = vxCount + 0;
    ixData[ixIndex + 1] = vxCount + 1;
    ixData[ixIndex + 2] = vxCount + 2;
    ixData[ixIndex + 3] = vxCount + 0;
    ixData[ixIndex + 4] = vxCount + 2;
    ixData[ixIndex + 5] = vxCount + 3;

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    // copy vertex list

    var ma1 = vxList[0] * matrix.a + matrix.tx;
    var ma2 = vxList[8] * matrix.a + matrix.tx;
    var mb1 = vxList[0] * matrix.b + matrix.ty;
    var mb2 = vxList[8] * matrix.b + matrix.ty;
    var mc1 = vxList[1] * matrix.c;
    var mc2 = vxList[9] * matrix.c;
    var md1 = vxList[1] * matrix.d;
    var md2 = vxList[9] * matrix.d;

    vxData[vxIndex + 00] = ma1 + mc1;
    vxData[vxIndex + 01] = mb1 + md1;
    vxData[vxIndex + 02] = vxList[2];
    vxData[vxIndex + 03] = vxList[3];
    vxData[vxIndex + 04] = alpha;

    vxData[vxIndex + 05] = ma2 + mc1;
    vxData[vxIndex + 06] = mb2 + md1;
    vxData[vxIndex + 07] = vxList[6];
    vxData[vxIndex + 08] = vxList[7];
    vxData[vxIndex + 09] = alpha;

    vxData[vxIndex + 10] = ma2 + mc2;
    vxData[vxIndex + 11] = mb2 + md2;
    vxData[vxIndex + 12] = vxList[10];
    vxData[vxIndex + 13] = vxList[11];
    vxData[vxIndex + 14] = alpha;

    vxData[vxIndex + 15] = ma1 + mc2;
    vxData[vxIndex + 16] = mb1 + md2;
    vxData[vxIndex + 17] = vxList[14];
    vxData[vxIndex + 18] = vxList[15];
    vxData[vxIndex + 19] = alpha;

    renderBufferVertex.position += vxListCount * 5;
    renderBufferVertex.count += vxListCount;
  }

  //---------------------------------------------------------------------------

  void renderTextureMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList) {

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var ixListCount = ixList.length;
    var vxListCount = vxList.length >> 2;

    // check buffer sizes and flush if necessary

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 5 >= vxData.length) flush();

    var ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    var vxCount = renderBufferVertex.count;

    // copy index list

    for (var i = 0; i < ixListCount; i++) {
      ixData[ixIndex + i] = vxCount + ixList[i];
    }

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    // copy vertex list

    var ma = matrix.a;
    var mb = matrix.b;
    var mc = matrix.c;
    var md = matrix.d;
    var mx = matrix.tx;
    var my = matrix.ty;

    for (var i = 0, o = 0; i < vxListCount; i++, o += 4) {
      num x = vxList[o + 0];
      num y = vxList[o + 1];
      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = vxList[o + 2];
      vxData[vxIndex + 3] = vxList[o + 3];
      vxData[vxIndex + 4] = alpha;
      vxIndex += 5;
    }

    renderBufferVertex.position += vxListCount * 5;
    renderBufferVertex.count += vxListCount;
  }

  //---------------------------------------------------------------------------

  void renderTextureMapping(
      RenderState renderState, Matrix mappingMatrix,
      Int16List ixList, Float32List vxList) {

    var alpha = renderState.globalAlpha;
    var globalMatrix = renderState.globalMatrix;
    var ixListCount = ixList.length;
    var vxListCount = vxList.length >> 1;

    // check buffer sizes and flush if necessary

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 5 >= vxData.length) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    var vxCount = renderBufferVertex.count;

    for (var i = 0; i < ixListCount; i++) {
      ixData[ixIndex + i] = vxCount + ixList[i];
    }

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    // copy vertex list

    var ma = globalMatrix.a;
    var mb = globalMatrix.b;
    var mc = globalMatrix.c;
    var md = globalMatrix.d;
    var mx = globalMatrix.tx;
    var my = globalMatrix.ty;

    var ta = mappingMatrix.a;
    var tb = mappingMatrix.b;
    var tc = mappingMatrix.c;
    var td = mappingMatrix.d;
    var tx = mappingMatrix.tx;
    var ty = mappingMatrix.ty;

    for (var i = 0, o = 0; i < vxListCount; i++, o += 2) {
      num x = vxList[o + 0];
      num y = vxList[o + 1];
      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = tx + ta * x + tc * y;
      vxData[vxIndex + 3] = ty + tb * x + td * y;
      vxData[vxIndex + 4] = alpha;
      vxIndex += 5;
    }

    renderBufferVertex.position += vxListCount * 5;
    renderBufferVertex.count += vxListCount;
  }

}
