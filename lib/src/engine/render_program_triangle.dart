part of '../engine.dart';

class RenderProgramTriangle extends RenderProgram {
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexAlpha:      Float32(r), Float32(g), Float32(b), Float32(a)

  @override
  String get vertexShaderSource => '''

    uniform mat4 uProjectionMatrix;
    attribute vec2 aVertexPosition;
    attribute vec4 aVertexColor;
    varying vec4 vColor;

    void main() {
      vColor = aVertexColor;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    ''';

  @override
  String get fragmentShaderSource => '''

    precision mediump float;
    varying vec4 vColor;

    void main() {
      gl_FragColor = vColor;
    }
    ''';

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {
    super.activate(renderContext);

    renderBufferVertex.bindAttribute(attributes['aVertexPosition'], 2, 24, 0);
    renderBufferVertex.bindAttribute(attributes['aVertexColor'], 4, 24, 8);
  }

  //---------------------------------------------------------------------------

  void renderTriangle(RenderState renderState, num x1, num y1, num x2, num y2,
      num x3, num y3, int color) {
    final matrix = renderState.globalMatrix;
    final alpha = renderState.globalAlpha;
    const indexCount = 3;
    const vertexCount = 3;

    // check buffer sizes and flush if necessary

    final ixData = renderBufferIndex.data;
    final ixPosition = renderBufferIndex.position;
    if (ixPosition + indexCount >= ixData.length) flush();

    final vxData = renderBufferVertex.data;
    final vxPosition = renderBufferVertex.position;
    if (vxPosition + vertexCount * 6 >= vxData.length) flush();

    final ixIndex = renderBufferIndex.position;
    final vxIndex = renderBufferVertex.position;
    final vxCount = renderBufferVertex.count;

    // fill index buffer

    ixData[ixIndex + 0] = vxCount + 0;
    ixData[ixIndex + 1] = vxCount + 1;
    ixData[ixIndex + 2] = vxCount + 2;

    renderBufferIndex.position += indexCount;
    renderBufferIndex.count += indexCount;

    // fill vertex buffer

    final ma = matrix.a;
    final mb = matrix.b;
    final mc = matrix.c;
    final md = matrix.d;
    final mx = matrix.tx;
    final my = matrix.ty;

    const colorScale = 1 / 255.0;
    final colorA = colorScale * colorGetA(color) * alpha;
    final colorR = colorScale * colorGetR(color) * colorA;
    final colorG = colorScale * colorGetG(color) * colorA;
    final colorB = colorScale * colorGetB(color) * colorA;

    vxData[vxIndex + 00] = x1 * ma + y1 * mc + mx;
    vxData[vxIndex + 01] = x1 * mb + y1 * md + my;
    vxData[vxIndex + 02] = colorR;
    vxData[vxIndex + 03] = colorG;
    vxData[vxIndex + 04] = colorB;
    vxData[vxIndex + 05] = colorA;

    vxData[vxIndex + 06] = x2 * ma + y2 * mc + mx;
    vxData[vxIndex + 07] = x2 * mb + y2 * md + my;
    vxData[vxIndex + 08] = colorR;
    vxData[vxIndex + 09] = colorG;
    vxData[vxIndex + 10] = colorB;
    vxData[vxIndex + 11] = colorA;

    vxData[vxIndex + 12] = x3 * ma + y3 * mc + mx;
    vxData[vxIndex + 13] = x3 * mb + y3 * md + my;
    vxData[vxIndex + 14] = colorR;
    vxData[vxIndex + 15] = colorG;
    vxData[vxIndex + 16] = colorB;
    vxData[vxIndex + 17] = colorA;

    renderBufferVertex.position += vertexCount * 6;
    renderBufferVertex.count += vertexCount;
  }

  //---------------------------------------------------------------------------

  void renderTriangleMesh(RenderState renderState, Int16List ixList,
      Float32List vxList, int color) {
    final matrix = renderState.globalMatrix;
    final alpha = renderState.globalAlpha;
    final ixListCount = ixList.length;
    final vxListCount = vxList.length >> 1;

    // check buffer sizes and flush if necessary

    final ixData = renderBufferIndex.data;
    final ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    final vxData = renderBufferVertex.data;
    final vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 6 >= vxData.length) flush();

    final ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    final vxOffset = renderBufferVertex.count;

    // copy index list

    for (var i = 0; i < ixListCount; i++) {
      ixData[ixIndex + i] = vxOffset + ixList[i];
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

    const colorScale = 1 / 255.0;
    final colorA = colorScale * colorGetA(color) * alpha;
    final colorR = colorScale * colorGetR(color) * colorA;
    final colorG = colorScale * colorGetG(color) * colorA;
    final colorB = colorScale * colorGetB(color) * colorA;

    for (var i = 0, o = 0; i < vxListCount; i++, o += 2) {
      final x = vxList[o + 0];
      final y = vxList[o + 1];
      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = colorR;
      vxData[vxIndex + 3] = colorG;
      vxData[vxIndex + 4] = colorB;
      vxData[vxIndex + 5] = colorA;
      vxIndex += 6;
    }

    renderBufferVertex.position += vxListCount * 6;
    renderBufferVertex.count += vxListCount;
  }
}
