part of stagexl.engine;

class RenderProgramTriangle extends RenderProgram {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexAlpha:      Float32(r), Float32(g), Float32(b), Float32(a)

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
      gl_FragColor = vColor;
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 24, 0);
    renderBufferVertex.bindAttribute(attributes["aVertexColor"], 4, 24, 8);
  }

  //---------------------------------------------------------------------------

  void renderTriangle(
      RenderState renderState,
      num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var indexCount = 3;
    var vertexCount = 3;

    // check buffer sizes and flush if necessary

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixPosition + indexCount >= ixData.length) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxPosition + vertexCount * 6 >= vxData.length) flush();

    var ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    var vxCount = renderBufferVertex.count;

    // fill index buffer

    ixData[ixIndex + 0] = vxCount + 0;
    ixData[ixIndex + 1] = vxCount + 1;
    ixData[ixIndex + 2] = vxCount + 2;

    renderBufferIndex.position += indexCount;
    renderBufferIndex.count += indexCount;

    // fill vertex buffer

    var ma = matrix.a;
    var mb = matrix.b;
    var mc = matrix.c;
    var md = matrix.d;
    var mx = matrix.tx;
    var my = matrix.ty;

    var colorScale = 1 / 255.0;
    var colorA = colorScale * colorGetA(color) * alpha;
    var colorR = colorScale * colorGetR(color) * colorA;
    var colorG = colorScale * colorGetG(color) * colorA;
    var colorB = colorScale * colorGetB(color) * colorA;

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

  void renderTriangleMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList, int color) {

    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var ixListCount = ixList.length;
    var vxListCount = vxList.length >> 1;

    // check buffer sizes and flush if necessary

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 6 >= vxData.length) flush();

    var ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    var vxOffset = renderBufferVertex.count;

    // copy index list

    for (var i = 0; i < ixListCount; i++) {
      ixData[ixIndex + i] = vxOffset + ixList[i];
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

    var colorScale = 1 / 255.0;
    var colorA = colorScale * colorGetA(color) * alpha;
    var colorR = colorScale * colorGetR(color) * colorA;
    var colorG = colorScale * colorGetG(color) * colorA;
    var colorB = colorScale * colorGetB(color) * colorA;

    for (var i = 0, o = 0 ; i < vxListCount; i++, o += 2) {
      num x = vxList[o + 0];
      num y = vxList[o + 1];
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
