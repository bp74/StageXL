part of stagexl.engine;

class RenderProgramSimple extends RenderProgram {

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

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData.length < ixPosition + ixListCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData.length < vxPosition + vxListCount * 5) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxOffset = renderBufferVertex.count;

    if (ixIndex > ixData.length - 6) return;
    ixData[ixIndex + 0] = vxOffset + 0;
    ixData[ixIndex + 1] = vxOffset + 1;
    ixData[ixIndex + 2] = vxOffset + 2;
    ixData[ixIndex + 3] = vxOffset + 0;
    ixData[ixIndex + 4] = vxOffset + 2;
    ixData[ixIndex + 5] = vxOffset + 3;

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

    var vxIndex = renderBufferVertex.position;
    if (vxIndex > vxData.length - 20) return;

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

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData.length < ixPosition + ixListCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData.length < vxPosition + vxListCount * 5) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxCount = renderBufferVertex.count;

    for(var i = 0; i < ixListCount; i++) {
      if (ixIndex > ixData.length - 1) break;
      ixData[ixIndex] = vxCount + ixList[i];
      ixIndex += 1;
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

    var vxIndex = renderBufferVertex.position;

    for(var i = 0, o = 0; i < vxListCount; i++, o += 4) {

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

    renderBufferVertex.position += vxListCount * 5;
    renderBufferVertex.count += vxListCount;
  }

}
