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

  gl.Buffer _vertexBuffer = null;
  gl.Buffer _indexBuffer = null;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexColorLocation = 0;
  int _vertexCount = 0;
  int _indexCount = 0;

  final Int16List _indexList = new Int16List(2048);
  final Float32List _vertexList = new Float32List(8192);

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (_contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();
      _aVertexPositionLocation = attributeLocations["aVertexPosition"];
      _aVertexTextCoordLocation = attributeLocations["aVertexTextCoord"];
      _aVertexColorLocation = attributeLocations["aVertexColor"];
      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uSamplerLocation = uniformLocations["uSampler"];

      renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
      renderingContext.enableVertexAttribArray(_aVertexColorLocation);
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

    if (_vertexCount == 0 || _indexCount == 0) return;
    var indexUpdate = new Int16List.view(_indexList.buffer, 0, _indexCount);
    var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _vertexCount * 8);

    renderingContext.bufferSubDataTyped(gl.ELEMENT_ARRAY_BUFFER, 0, indexUpdate);
    renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
    renderingContext.drawElements(gl.TRIANGLES, _indexCount, gl.UNSIGNED_SHORT, 0);

    _indexCount = 0;
    _vertexCount = 0;
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
    if (vertexCount << 1 > xyList.length) throw new ArgumentError("xyList");
    if (vertexCount << 1 > uvList.length) throw new ArgumentError("uvList");

    bool indexFlush  = (_indexCount + indexCount) >= _indexList.length;
    bool vertexFlush = (_vertexCount + vertexCount) * 8 >= _vertexList.length;

    if (indexFlush || vertexFlush) this.flush();

    // This code contains several dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    int indexOffset = _indexCount;
    int vertexOffset = _vertexCount * 8;
    int indexListLength = _indexList.length;
    int vertextListLength = _vertexList.length;
    int xyListLength = xyList.length;
    int uvListLength = uvList.length;

    for(int i = 0; i < indexCount; i++) {
      if (indexOffset > indexListLength - 1) break;
      _indexList[indexOffset] = _vertexCount + indexList[i];
      indexOffset += 1;
    }

    for(int i = 0, o1 = 0, o2 = 0; i < vertexCount; i++, o1 += 2, o2 += 2) {

      if (vertexOffset > vertextListLength - 8) break;
      if (o1 > xyListLength - 2) break;
      if (o2 > uvListLength - 2) break;

      num x = xyList[o1 + 0];
      num y = xyList[o1 + 1];
      num u = uvList[o2 + 0];
      num v = uvList[o2 + 1];

      _vertexList[vertexOffset + 0] = mx + ma * x + mc * y;
      _vertexList[vertexOffset + 1] = my + mb * x + md * y;
      _vertexList[vertexOffset + 2] = u;
      _vertexList[vertexOffset + 3] = v;
      _vertexList[vertexOffset + 4] = r;
      _vertexList[vertexOffset + 5] = g;
      _vertexList[vertexOffset + 6] = b;
      _vertexList[vertexOffset + 7] = a * alpha;
      vertexOffset += 8;
    }

    _indexCount += indexCount;
    _vertexCount += vertexCount;
  }

}
