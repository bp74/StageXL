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

  //---------------------------------------------------------------------------

  void renderTriangle(
      RenderState renderState,
      num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var indexCount = 3;
    var vertexCount = 3;

    var colorA = colorGetA(color) / 255.0 * alpha;
    var colorR = colorGetR(color) / 255.0;
    var colorG = colorGetG(color) / 255.0;
    var colorB = colorGetB(color) / 255.0;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData == null) return;
    if (ixData.length < ixPosition + indexCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData == null) return;
    if (vxData.length < vxPosition + vertexCount * 6) flush();

    // fill index buffer

    var ixIndex = renderBufferIndex.position;
    var vxCount = renderBufferVertex.count;

    if (ixIndex > ixData.length - 3) return;
    ixData[ixIndex + 0] = vxCount + 0;
    ixData[ixIndex + 1] = vxCount + 1;
    ixData[ixIndex + 2] = vxCount + 2;

    renderBufferIndex.position += indexCount;
    renderBufferIndex.count += indexCount;

    // fill vertex buffer

    var a = matrix.a;
    var b = matrix.b;
    var c = matrix.c;
    var d = matrix.d;
    var tx = matrix.tx;
    var ty = matrix.ty;

    var vxIndex = renderBufferVertex.position;
    if (vxIndex > vxData.length - 18) return;

    vxData[vxIndex + 00] = x1 * a + y1 * c + tx;
    vxData[vxIndex + 01] = x1 * b + y1 * d + ty;
    vxData[vxIndex + 02] = colorR;
    vxData[vxIndex + 03] = colorG;
    vxData[vxIndex + 04] = colorB;
    vxData[vxIndex + 05] = colorA;
    vxData[vxIndex + 06] = x2 * a + y2 * c + tx;
    vxData[vxIndex + 07] = x2 * b + y2 * d + ty;
    vxData[vxIndex + 08] = colorR;
    vxData[vxIndex + 09] = colorG;
    vxData[vxIndex + 10] = colorB;
    vxData[vxIndex + 11] = colorA;
    vxData[vxIndex + 12] = x3 * a + y3 * c + tx;
    vxData[vxIndex + 13] = x3 * b + y3 * d + ty;
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
      int indexCount, Int16List indexList,
      int vertexCount, Float32List vertexList, int color) {

    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;

    var colorA = colorGetA(color) / 255.0 * alpha;
    var colorR = colorGetR(color) / 255.0;
    var colorG = colorGetG(color) / 255.0;
    var colorB = colorGetB(color) / 255.0;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData == null) return;
    if (ixData.length < ixPosition + indexCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData == null) return;
    if (vxData.length < vxPosition + vertexCount * 6) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxCount = renderBufferVertex.count;

    for(var i = 0; i < indexCount; i++) {
      if (ixIndex > ixData.length - 1) break;
      ixData[ixIndex] = vxCount + indexList[i];
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

    for(var i = 0, o = 0 ; i < vertexCount; i++, o += 2) {

      if (vxIndex > vxData.length - 6) break;
      if (o > vertexList.length - 2) break;

      num x = vertexList[o + 0];
      num y = vertexList[o + 1];

      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = colorR;
      vxData[vxIndex + 3] = colorG;
      vxData[vxIndex + 4] = colorB;
      vxData[vxIndex + 5] = colorA;
      vxIndex += 6;
    }

    renderBufferVertex.position += vertexCount * 6;
    renderBufferVertex.count += vertexCount;
  }

}
