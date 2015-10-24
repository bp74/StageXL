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
      vec4 color = texture2D(uSampler, vTextCoord);
      gl_FragColor = vec4(color.rgb * vColor.rgb * vColor.a, color.a * vColor.a);
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

  void renderTextureMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList,
      num r, num g, num b, num a) {

    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var ixListCount = ixList.length;
    var vxListCount = vxList.length >> 2;

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
      vxData[vxIndex + 4] = r;
      vxData[vxIndex + 5] = g;
      vxData[vxIndex + 6] = b;
      vxData[vxIndex + 7] = a * alpha;
      vxIndex += 8;
    }

    renderBufferVertex.position += vxListCount * 8;
    renderBufferVertex.count += vxListCount;
  }

}
