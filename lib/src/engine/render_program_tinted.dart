part of stagexl.engine;

class RenderProgramTinted extends RenderProgram {
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)

  @override
  String get vertexShaderSource => '''

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
    ''';

  @override
  String get fragmentShaderSource => '''

    precision mediump float;
    uniform sampler2D uSampler;
    varying vec2 vTextCoord;
    varying vec4 vColor;

    void main() {
      gl_FragColor = texture2D(uSampler, vTextCoord) * vColor;
    }
    ''';

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {
    super.activate(renderContext);

    renderingContext.uniform1i(uniforms['uSampler'], 0);

    renderBufferVertex.bindAttribute(attributes['aVertexPosition'], 2, 32, 0);
    renderBufferVertex.bindAttribute(attributes['aVertexTextCoord'], 2, 32, 8);
    renderBufferVertex.bindAttribute(attributes['aVertexColor'], 4, 32, 16);
  }

  //---------------------------------------------------------------------------

  void renderTextureQuad(RenderState renderState,
      RenderTextureQuad renderTextureQuad, double r, double g, num b, num a) {
    if (renderTextureQuad.hasCustomVertices) {
      final ixList = renderTextureQuad.ixList;
      final vxList = renderTextureQuad.vxList;
      renderTextureMesh(renderState, ixList, vxList, r, g, b, a);
      return;
    }

    final alpha = renderState.globalAlpha;
    final matrix = renderState.globalMatrix;
    final vxList = renderTextureQuad.vxListQuad;
    const ixListCount = 6;
    const vxListCount = 4;

    // check buffer sizes and flush if necessary

    final ixData = renderBufferIndex.data;
    final ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    final vxData = renderBufferVertex.data;
    final vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 8 >= vxData.length) flush();

    final ixIndex = renderBufferIndex.position;
    final vxIndex = renderBufferVertex.position;
    final vxCount = renderBufferVertex.count;

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

    final ma1 = vxList[0] * matrix.a + matrix.tx;
    final ma2 = vxList[8] * matrix.a + matrix.tx;
    final mb1 = vxList[0] * matrix.b + matrix.ty;
    final mb2 = vxList[8] * matrix.b + matrix.ty;
    final mc1 = vxList[1] * matrix.c;
    final mc2 = vxList[9] * matrix.c;
    final md1 = vxList[1] * matrix.d;
    final md2 = vxList[9] * matrix.d;

    final colorA = a * alpha;
    final colorR = r * colorA;
    final colorG = g * colorA;
    final colorB = b * colorA;

    vxData[vxIndex + 00] = ma1 + mc1;
    vxData[vxIndex + 01] = mb1 + md1;
    vxData[vxIndex + 02] = vxList[2];
    vxData[vxIndex + 03] = vxList[3];
    vxData[vxIndex + 04] = colorR;
    vxData[vxIndex + 05] = colorG;
    vxData[vxIndex + 06] = colorB;
    vxData[vxIndex + 07] = colorA;

    vxData[vxIndex + 08] = ma2 + mc1;
    vxData[vxIndex + 09] = mb2 + md1;
    vxData[vxIndex + 10] = vxList[6];
    vxData[vxIndex + 11] = vxList[7];
    vxData[vxIndex + 12] = colorR;
    vxData[vxIndex + 13] = colorG;
    vxData[vxIndex + 14] = colorB;
    vxData[vxIndex + 15] = colorA;

    vxData[vxIndex + 16] = ma2 + mc2;
    vxData[vxIndex + 17] = mb2 + md2;
    vxData[vxIndex + 18] = vxList[10];
    vxData[vxIndex + 19] = vxList[11];
    vxData[vxIndex + 20] = colorR;
    vxData[vxIndex + 21] = colorG;
    vxData[vxIndex + 22] = colorB;
    vxData[vxIndex + 23] = colorA;

    vxData[vxIndex + 24] = ma1 + mc2;
    vxData[vxIndex + 25] = mb1 + md2;
    vxData[vxIndex + 26] = vxList[14];
    vxData[vxIndex + 27] = vxList[15];
    vxData[vxIndex + 28] = colorR;
    vxData[vxIndex + 29] = colorG;
    vxData[vxIndex + 30] = colorB;
    vxData[vxIndex + 31] = colorA;

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }

  //---------------------------------------------------------------------------

  void renderTextureMesh(RenderState renderState, Int16List ixList,
      Float32List vxList, num r, num g, num b, num a) {
    final matrix = renderState.globalMatrix;
    final alpha = renderState.globalAlpha;
    final ixListCount = ixList.length;
    final vxListCount = vxList.length >> 2;

    // check buffer sizes and flush if necessary

    final ixData = renderBufferIndex.data;
    final ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    final vxData = renderBufferVertex.data;
    final vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 8 >= vxData.length) flush();

    final ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    final vxCount = renderBufferVertex.count;

    // copy index list

    for (var i = 0; i < ixListCount; i++) {
      ixData[ixIndex + i] = vxCount + ixList[i];
    }

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    // copy vertex list

    final ma = matrix.a;
    final mb = matrix.b;
    final mc = matrix.c;
    final md = matrix.d;
    final mx = matrix.tx;
    final my = matrix.ty;

    final colorA = a * alpha;
    final colorR = r * colorA;
    final colorG = g * colorA;
    final colorB = b * colorA;

    for (var i = 0, o = 0; i < vxListCount; i++, o += 4) {
      final x = vxList[o + 0];
      final y = vxList[o + 1];
      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = vxList[o + 2];
      vxData[vxIndex + 3] = vxList[o + 3];
      vxData[vxIndex + 4] = colorR;
      vxData[vxIndex + 5] = colorG;
      vxData[vxIndex + 6] = colorB;
      vxData[vxIndex + 7] = colorA;
      vxIndex += 8;
    }

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }
}
