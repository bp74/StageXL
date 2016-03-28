part of stagexl.engine;

class RenderProgramTinted extends RenderProgram {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute vec4 aVertexColor;

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
      gl_FragColor = texture2D(uSampler, vTextCoord) * vColor;
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderingContext.uniform1i(uniforms["uSampler"], 0);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 32, 0);
    renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 32, 8);
    renderBufferVertex.bindAttribute(attributes["aVertexColor"], 4, 32, 16);
  }

  //---------------------------------------------------------------------------

  void renderTextureQuad(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad,
      num r, num g, num b, num a) {

    if (renderTextureQuad.hasCustomVertices) {
      var ixList = renderTextureQuad.ixList;
      var vxList = renderTextureQuad.vxList;
      this.renderTextureMesh(renderState, ixList, vxList, r, g, b, a);
      return;
    }

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var vxList = renderTextureQuad.vxListQuad;
    var ixListCount = 6;
    var vxListCount = 4;

    var ta = a * alpha;
    var tr = r * ta;
    var tg = g * ta;
    var tb = b * ta;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData.length < ixPosition + ixListCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData.length < vxPosition + vxListCount * 8) flush();

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
    if (vxIndex > vxData.length - 32) return;

    vxData[vxIndex + 00] = ma1 + mc1;
    vxData[vxIndex + 01] = mb1 + md1;
    vxData[vxIndex + 02] = vxList[2];
    vxData[vxIndex + 03] = vxList[3];
    vxData[vxIndex + 04] = tr;
    vxData[vxIndex + 05] = tg;
    vxData[vxIndex + 06] = tb;
    vxData[vxIndex + 07] = ta;

    vxData[vxIndex + 08] = ma2 + mc1;
    vxData[vxIndex + 09] = mb2 + md1;
    vxData[vxIndex + 10] = vxList[6];
    vxData[vxIndex + 11] = vxList[7];
    vxData[vxIndex + 12] = tr;
    vxData[vxIndex + 13] = tg;
    vxData[vxIndex + 14] = tb;
    vxData[vxIndex + 15] = ta;

    vxData[vxIndex + 16] = ma2 + mc2;
    vxData[vxIndex + 17] = mb2 + md2;
    vxData[vxIndex + 18] = vxList[10];
    vxData[vxIndex + 19] = vxList[11];
    vxData[vxIndex + 20] = tr;
    vxData[vxIndex + 21] = tg;
    vxData[vxIndex + 22] = tb;
    vxData[vxIndex + 23] = ta;

    vxData[vxIndex + 24] = ma1 + mc2;
    vxData[vxIndex + 25] = mb1 + md2;
    vxData[vxIndex + 26] = vxList[14];
    vxData[vxIndex + 27] = vxList[15];
    vxData[vxIndex + 28] = tr;
    vxData[vxIndex + 29] = tg;
    vxData[vxIndex + 30] = tb;
    vxData[vxIndex + 31] = ta;

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }

  //---------------------------------------------------------------------------

  void renderTextureMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList,
      num r, num g, num b, num a) {

    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var ixListCount = ixList.length;
    var vxListCount = vxList.length >> 2;

    var ta = a * alpha;
    var tr = r * ta;
    var tg = g * ta;
    var tb = b * ta;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData.length < ixPosition + ixListCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData.length < vxPosition + vxListCount * 8) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxOffset = renderBufferVertex.count;

    for(var i = 0; i < ixListCount; i++) {
      if (ixIndex > ixData.length - 1) break;
      ixData[ixIndex] = vxOffset + ixList[i];
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

      if (vxIndex > vxData.length - 8) break;
      if (o > vxList.length - 4) break;

      num x = vxList[o + 0];
      num y = vxList[o + 1];
      num u = vxList[o + 2];
      num v = vxList[o + 3];

      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = u;
      vxData[vxIndex + 3] = v;
      vxData[vxIndex + 4] = tr;
      vxData[vxIndex + 5] = tg;
      vxData[vxIndex + 6] = tb;
      vxData[vxIndex + 7] = ta;
      vxIndex += 8;
    }

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }

}
