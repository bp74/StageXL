part of stagexl.engine;

class RenderProgramMesh extends RenderProgram {

  String get vertexShaderSource => """
    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute vec4 aVertexColor;
    uniform mat4 uProjectionMatrix;
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
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertextColor:     Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  Int16List _indexList;
  Float32List _vertexList;

  gl.Buffer _vertexBuffer = null;
  gl.Buffer _indexBuffer = null;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexColorLocation = 0;
  int _vertexCount = 0;
  int _indexCount = 0;

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _indexList = renderContext.dynamicIndexList;
      _vertexList = renderContext.dynamicVertexList;
      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();

      _aVertexPositionLocation = attributeLocations["aVertexPosition"];
      _aVertexTextCoordLocation = attributeLocations["aVertexTextCoord"];
      _aVertexColorLocation = attributeLocations["aVertexColor"];
      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uSamplerLocation = uniformLocations["uSampler"];

      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.DYNAMIC_DRAW);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 32, 0);
    renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 32, 8);
    renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 32, 16);
    renderingContext.uniform1i(_uSamplerLocation, 0);
  }

  @override
  void flush() {
    if (_vertexCount> 0 || _indexCount > 0) {
      var indexUpdate = new Int16List.view(_indexList.buffer, 0, _indexCount);
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _vertexCount * 8);
      renderingContext.bufferSubDataTyped(gl.ELEMENT_ARRAY_BUFFER, 0, indexUpdate);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawElements(gl.TRIANGLES, _indexCount, gl.UNSIGNED_SHORT, 0);
      _indexCount = 0;
      _vertexCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

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

    var ixList = _indexList;
    if (ixList == null) return;
    if (ixList.length < _indexCount + indexCount) flush();

    var vxList = _vertexList;
    if (vxList == null) return;
    if (vxList.length < _vertexCount * 8 + vertexCount * 8) flush();

    var ixOffset = _indexCount;
    var vxOffset = _vertexCount * 8;
    var xyListLength = xyList.length;
    var uvListLength = uvList.length;

    // copy index list

    for(var i = 0; i < indexCount; i++) {
      if (ixOffset > ixList.length - 1) break;
      ixList[ixOffset] = _vertexCount + indexList[i];
      ixOffset += 1;
    }

    // copy vertex list

    for(var i = 0, o1 = 0, o2 = 0; i < vertexCount; i++, o1 += 2, o2 += 2) {

      if (vxOffset > vxList.length - 8) break;
      if (o1 > xyListLength - 2) break;
      if (o2 > uvListLength - 2) break;

      num x = xyList[o1 + 0];
      num y = xyList[o1 + 1];
      num u = uvList[o2 + 0];
      num v = uvList[o2 + 1];

      vxList[vxOffset + 0] = mx + ma * x + mc * y;
      vxList[vxOffset + 1] = my + mb * x + md * y;
      vxList[vxOffset + 2] = u;
      vxList[vxOffset + 3] = v;
      vxList[vxOffset + 4] = r;
      vxList[vxOffset + 5] = g;
      vxList[vxOffset + 6] = b;
      vxList[vxOffset + 7] = a * alpha;
      vxOffset += 8;
    }

    _indexCount += indexCount;
    _vertexCount += vertexCount;
  }

}
