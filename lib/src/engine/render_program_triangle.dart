part of stagexl.engine;

class RenderProgramTriangle extends RenderProgram {

  String get vertexShaderSource => """
    attribute vec2 aVertexPosition;
    attribute vec4 aVertexColor;
    uniform mat4 uProjectionMatrix;
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
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexAlpha:      Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  Float32List _vertexList;

  gl.Buffer _vertexBuffer;
  gl.UniformLocation _uProjectionMatrixLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexColorLocation = 0;
  int _triangleCount = 0;

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _vertexList = renderContext.dynamicVertexList;
      _vertexBuffer = renderingContext.createBuffer();
      _aVertexPositionLocation = attributeLocations["aVertexPosition"];
      _aVertexColorLocation = attributeLocations["aVertexColor"];
      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];

      renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      renderingContext.enableVertexAttribArray(_aVertexColorLocation);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 24, 0);
    renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 24, 8);
  }

  @override
  void flush() {
    if (_triangleCount > 0) {
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _triangleCount * 18);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawArrays(gl.TRIANGLES, 0, _triangleCount * 3);
      _triangleCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderTriangle(RenderState renderState,
                      num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    num colorA = colorGetA(color) / 255.0 * alpha;
    num colorR = colorGetR(color) / 255.0;
    num colorG = colorGetG(color) / 255.0;
    num colorB = colorGetB(color) / 255.0;

    num a = matrix.a;
    num b = matrix.b;
    num c = matrix.c;
    num d = matrix.d;
    num tx = matrix.tx;
    num ty = matrix.ty;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var vxList = _vertexList;
    if (vxList == null) return;
    if (vxList.length <= _triangleCount * 18 + 18) flush();

    var index = _triangleCount * 18;
    if (index > vxList.length - 18) return;

    // vertex 1
    vxList[index + 00] = x1 * a + y1 * c + tx;
    vxList[index + 01] = x1 * b + y1 * d + ty;
    vxList[index + 02] = colorR;
    vxList[index + 03] = colorG;
    vxList[index + 04] = colorB;
    vxList[index + 05] = colorA;

    // vertex 2
    vxList[index + 06] = x2 * a + y2 * c + tx;
    vxList[index + 07] = x2 * b + y2 * d + ty;
    vxList[index + 08] = colorR;
    vxList[index + 09] = colorG;
    vxList[index + 10] = colorB;
    vxList[index + 11] = colorA;

    // vertex 3
    vxList[index + 12] = x3 * a + y3 * c + tx;
    vxList[index + 13] = x3 * b + y3 * d + ty;
    vxList[index + 14] = colorR;
    vxList[index + 15] = colorG;
    vxList[index + 16] = colorB;
    vxList[index + 17] = colorA;

    _triangleCount += 1;
  }

}
