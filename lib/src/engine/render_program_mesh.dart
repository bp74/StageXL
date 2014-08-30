part of stagexl.engine;

class RenderProgramMesh extends RenderProgram {

  var _vertexShaderSource = """
      attribute vec2 aVertexPosition;
      attribute vec2 aVertexTextCoord;
      attribute vec4 aVertexColor;
      uniform mat4 uProjectionMatrix;
      uniform mat4 uGlobalMatrix;
      varying vec2 vTextCoord;
      varying vec4 vColor; 

      void main() {
        vTextCoord = aVertexTextCoord;
        vColor = aVertexColor;
        gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uGlobalMatrix * uProjectionMatrix;
      }
      """;

  var _fragmentShaderSource = """
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

  int _contextIdentifier = -1;
  gl.RenderingContext _renderingContext = null;
  gl.Program _program = null;
  gl.Buffer _vertexBuffer = null;
  gl.Buffer _indexBuffer = null;

  Int16List _indexList = new Int16List(2048);
  Float32List _vertexList = new Float32List(8192);

  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uGlobalMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexColorLocation = 0;
  int _vertexCount = 0;
  int _indexCount = 0;

  Matrix3D _globalMatrix = new Matrix3D.fromIdentity();

  //-----------------------------------------------------------------------------------------------

  void set projectionMatrix(Matrix3D matrix) {
    _renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  void set globalMatrix(Matrix globalMatrix) {
    _globalMatrix.copyFromMatrix2D(globalMatrix);
    _renderingContext.uniformMatrix4fv(_uGlobalMatrixLocation, false, _globalMatrix.data);
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (_contextIdentifier != renderContext.contextIdentifier) {

      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _program = createProgram(_renderingContext, _vertexShaderSource, _fragmentShaderSource);
      _indexBuffer = _renderingContext.createBuffer();
      _vertexBuffer = _renderingContext.createBuffer();

      _aVertexPositionLocation = _renderingContext.getAttribLocation(_program, "aVertexPosition");
      _aVertexTextCoordLocation = _renderingContext.getAttribLocation(_program, "aVertexTextCoord");
      _aVertexColorLocation = _renderingContext.getAttribLocation(_program, "aVertexColor");

      _uProjectionMatrixLocation = _renderingContext.getUniformLocation(_program, "uProjectionMatrix");
      _uGlobalMatrixLocation = _renderingContext.getUniformLocation(_program, "uGlobalMatrix");
      _uSamplerLocation = _renderingContext.getUniformLocation(_program, "uSampler");

      _renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      _renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
      _renderingContext.enableVertexAttribArray(_aVertexColorLocation);

      _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      _renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.DYNAMIC_DRAW);

      _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 32, 0);
    _renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 32, 8);
    _renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 32, 16);
    _renderingContext.uniform1i(_uSamplerLocation, 0);
  }

  //-----------------------------------------------------------------------------------------------

  void renderMesh(int indexCount, Int16List indexList,
                  int vertexCount, Float32List xyList, Float32List uvList,
                  num r, num g, num b, num a) {

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
    int indexListLenght = _indexList.length;
    int vertextListLength = _vertexList.length;
    int xyListLength = xyList.length;
    int uvListLength = uvList.length;

    for(int i = 0; i < indexCount; i++) {
      if (indexOffset > indexListLenght - 1) break;
      _indexList[indexOffset] = _vertexCount + indexList[i];
      indexOffset += 1;
    }

    for(int i = 0, o1 = 0, o2 = 0; i < vertexCount; i++, o1 += 2, o2 += 2) {
      if (vertexOffset > vertextListLength - 8) break;
      if (o1 > xyListLength - 2) break;
      if (o2 > uvListLength - 2) break;
      _vertexList[vertexOffset + 0] = xyList[o1 + 0];
      _vertexList[vertexOffset + 1] = xyList[o1 + 1];
      _vertexList[vertexOffset + 2] = uvList[o2 + 0];
      _vertexList[vertexOffset + 3] = uvList[o2 + 1];
      _vertexList[vertexOffset + 4] = r;
      _vertexList[vertexOffset + 5] = g;
      _vertexList[vertexOffset + 6] = b;
      _vertexList[vertexOffset + 7] = a;
      vertexOffset += 8;
    }

    _indexCount += indexCount;
    _vertexCount += vertexCount;
  }

  //-----------------------------------------------------------------------------------------------

  void flush() {

    if (_vertexCount == 0 || _indexCount == 0) return;

    var indexUpdate = new Int16List.view(_indexList.buffer, 0, _indexCount);
    var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _vertexCount * 8);

    _renderingContext.bufferSubData(gl.ELEMENT_ARRAY_BUFFER, 0, indexUpdate);
    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    _renderingContext.drawElements(gl.TRIANGLES, _indexCount, gl.UNSIGNED_SHORT, 0);

    _indexCount = 0;
    _vertexCount = 0;
  }

}
