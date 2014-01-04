part of stagexl;

class RenderProgramPrimitive extends RenderProgram {

  var vertexShaderSource = """
      attribute vec2 aVertexPosition;
      attribute vec4 aVertexColor;
      uniform mat3 uViewMatrix;
      varying vec4 vColor;

      void main() {
        vColor = aVertexColor;
        gl_Position = vec4(uViewMatrix * vec3(aVertexPosition, 1.0), 1.0); 
      }
      """;

  var fragmentShaderSource = """
      precision mediump float;

      varying vec4 vColor;

      void main() {
        gl_FragColor = vColor; 
        //gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0); 
      }
      """;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexAlpha:      Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  static const int _maxTriangleCount = 256;

  gl.RenderingContext _renderingContext;
  gl.Buffer _vertexBuffer;

  Float32List _vertexList = new Float32List(_maxTriangleCount * 3 * 6);

  int _aVertexPositionLocation = 0;
  int _aVertexColorLocation = 0;

  int _triangleCount = 0;

  //-----------------------------------------------------------------------------------------------

  RenderProgramPrimitive(RenderContextWebGL renderContext) {

    _renderContext = renderContext;
    _renderingContext = _renderContext.rawContext;

    var vertexShader = _createShader(vertexShaderSource, gl.VERTEX_SHADER);
    var fragmentShader = _createShader(fragmentShaderSource, gl.FRAGMENT_SHADER);

    _program = _createProgram(vertexShader, fragmentShader);

    //----------------------------------

    _aVertexPositionLocation = _renderingContext.getAttribLocation(_program, "aVertexPosition");
    _aVertexColorLocation = _renderingContext.getAttribLocation(_program, "aVertexColor");

    _renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
    _renderingContext.enableVertexAttribArray(_aVertexColorLocation);

    //----------------------------------

    _vertexBuffer = _renderingContext.createBuffer();
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
  }

  //-----------------------------------------------------------------------------------------------

  void activate() {
    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 24, 0);
    _renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 24, 8);
  }

  //-----------------------------------------------------------------------------------------------

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha) {

  }

  //-----------------------------------------------------------------------------------------------

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color) {

    // TODO: optimize point transformations

    var colorA = ((color >> 24) & 0xFF) / 255.0;
    var colorR = ((color >> 16) & 0xFF) / 255.0;
    var colorG = ((color >>  8) & 0xFF) / 255.0;
    var colorB = ((color      ) & 0xFF) / 255.0;

    var p1 = matrix.transformPoint(new Point(x1, y1));
    var p2 = matrix.transformPoint(new Point(x2, y2));
    var p3 = matrix.transformPoint(new Point(x3, y3));

    var index = _triangleCount * 18;
    if (index > _vertexList.length - 18) return; // dart2js_hint

    // vertex 1
    _vertexList[index + 00] = p1.x;
    _vertexList[index + 01] = p1.y;
    _vertexList[index + 02] = colorR;
    _vertexList[index + 03] = colorG;
    _vertexList[index + 04] = colorB;
    _vertexList[index + 05] = colorA;

    // vertex 2
    _vertexList[index + 06] = p2.x;
    _vertexList[index + 07] = p2.y;
    _vertexList[index + 08] = colorR;
    _vertexList[index + 09] = colorG;
    _vertexList[index + 10] = colorB;
    _vertexList[index + 11] = colorA;

    // vertex 3
    _vertexList[index + 12] = p3.x;
    _vertexList[index + 13] = p3.y;
    _vertexList[index + 14] = colorR;
    _vertexList[index + 15] = colorG;
    _vertexList[index + 16] = colorB;
    _vertexList[index + 17] = colorA;

    _triangleCount += 3;

    if (_triangleCount == _maxTriangleCount) flush();
  }

  //-----------------------------------------------------------------------------------------------

  void flush() {

    var vertexUpdate = _vertexList;

    if (_triangleCount == 0) {
      return;
    } else if (_triangleCount < _maxTriangleCount) {
      vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _triangleCount * 3 * 6);
    }

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    _renderingContext.drawArrays(gl.TRIANGLES, 0, _triangleCount * 3);
    _triangleCount = 0;
  }
}