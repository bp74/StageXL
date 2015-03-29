part of stagexl.engine;

class RenderProgramMesh extends RenderProgram {

  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;
  int _indexCount = 0;
  int _vertexCount = 0;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

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
    super.renderingContext.uniform1i(uniforms["uSampler"], 0);

    _renderBufferIndex = renderContext.renderBufferIndexTriangles;
    _renderBufferIndex.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 32, 0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 32, 8);
    _renderBufferVertex.bindAttribute(attributes["aVertexColor"], 4, 32, 16);
  }

  @override
  void flush() {
    if (_vertexCount > 0 && _indexCount > 0) {
      _renderBufferIndex.update(0, _indexCount);
      _renderBufferVertex.update(0, _vertexCount * 8);
      _renderingContext.drawElements(gl.TRIANGLES, _indexCount, gl.UNSIGNED_SHORT, 0);
      _indexCount = 0;
      _vertexCount = 0;
    }
  }

  //---------------------------------------------------------------------------

  void renderMesh(
    RenderState renderState,
    int indexCount, Int16List indexList,
    int vertexCount, Float32List xyList, Float32List uvList,
    num r, num g, num b, num a) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num mx = matrix.tx;
    num my = matrix.ty;

    if (indexCount > indexList.length) throw new ArgumentError("indexList");
    if (vertexCount > xyList.length * 2) throw new ArgumentError("xyList");
    if (vertexCount > uvList.length * 2) throw new ArgumentError("uvList");

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = _renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < _indexCount + indexCount) flush();

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _vertexCount * 8 + vertexCount * 8) flush();

    var ixOffset = _indexCount;
    var vxOffset = _vertexCount * 8;
    var xyListLength = xyList.length;
    var uvListLength = uvList.length;

    // copy index list

    for(var i = 0; i < indexCount; i++) {
      if (ixOffset > ixData.length - 1) break;
      ixData[ixOffset] = _vertexCount + indexList[i];
      ixOffset += 1;
    }

    // copy vertex list

    for(var i = 0, o1 = 0, o2 = 0; i < vertexCount; i++, o1 += 2, o2 += 2) {

      if (vxOffset > vxData.length - 8) break;
      if (o1 > xyListLength - 2) break;
      if (o2 > uvListLength - 2) break;

      num x = xyList[o1 + 0];
      num y = xyList[o1 + 1];
      num u = uvList[o2 + 0];
      num v = uvList[o2 + 1];

      vxData[vxOffset + 0] = mx + ma * x + mc * y;
      vxData[vxOffset + 1] = my + mb * x + md * y;
      vxData[vxOffset + 2] = u;
      vxData[vxOffset + 3] = v;
      vxData[vxOffset + 4] = r;
      vxData[vxOffset + 5] = g;
      vxData[vxOffset + 6] = b;
      vxData[vxOffset + 7] = a * alpha;
      vxOffset += 8;
    }

    _indexCount += indexCount;
    _vertexCount += vertexCount;
  }

}
