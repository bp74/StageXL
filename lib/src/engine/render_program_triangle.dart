part of stagexl;

class RenderProgramTriangle extends RenderProgram {

  var _vertexShaderSource = """
      attribute vec2 aVertexPosition;
      attribute vec4 aVertexColor;
      varying vec4 vColor;

      void main() {
        vColor = aVertexColor;
        gl_Position = vec4(aVertexPosition, 0.0, 1.0); 
      }
      """;

  var _fragmentShaderSource = """
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
  gl.Program _program;
  gl.Buffer _vertexBuffer;

  StreamSubscription _contextRestoredSubscription;
  Float32List _vertexList = new Float32List(_maxTriangleCount * 3 * 6);

  int _aVertexPositionLocation = 0;
  int _aVertexColorLocation = 0;
  int _triangleCount = 0;

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (_program == null) {

      if (_renderingContext == null) {
        _renderingContext = renderContext.rawContext;
        _contextRestoredSubscription = renderContext.onContextRestored.listen(_onContextRestored);
      }

      _program = createProgram(_renderingContext, _vertexShaderSource, _fragmentShaderSource);

      _aVertexPositionLocation = _renderingContext.getAttribLocation(_program, "aVertexPosition");
      _aVertexColorLocation = _renderingContext.getAttribLocation(_program, "aVertexColor");

      _renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      _renderingContext.enableVertexAttribArray(_aVertexColorLocation);

      _vertexBuffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 24, 0);
    _renderingContext.vertexAttribPointer(_aVertexColorLocation, 4, gl.FLOAT, false, 24, 8);
  }

  //-----------------------------------------------------------------------------------------------

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color) {

    num colorA = ((color >> 24) & 0xFF) / 255.0;
    num colorR = ((color >> 16) & 0xFF) / 255.0;
    num colorG = ((color >>  8) & 0xFF) / 255.0;
    num colorB = ((color      ) & 0xFF) / 255.0;

    num a = matrix.a;
    num b = matrix.b;
    num c = matrix.c;
    num d = matrix.d;
    num tx = matrix.tx;
    num ty = matrix.ty;

    int index = _triangleCount * 18;
    if (index > _vertexList.length - 18) return; // dart2js_hint

    // vertex 1
    _vertexList[index + 00] = x1 * a + y1 * c + tx;
    _vertexList[index + 01] = x1 * b + y1 * d + ty;
    _vertexList[index + 02] = colorR;
    _vertexList[index + 03] = colorG;
    _vertexList[index + 04] = colorB;
    _vertexList[index + 05] = colorA;

    // vertex 2
    _vertexList[index + 06] = x2 * a + y2 * c + tx;
    _vertexList[index + 07] = x2 * b + y2 * d + ty;
    _vertexList[index + 08] = colorR;
    _vertexList[index + 09] = colorG;
    _vertexList[index + 10] = colorB;
    _vertexList[index + 11] = colorA;

    // vertex 3
    _vertexList[index + 12] = x3 * a + y3 * c + tx;
    _vertexList[index + 13] = x3 * b + y3 * d + ty;
    _vertexList[index + 14] = colorR;
    _vertexList[index + 15] = colorG;
    _vertexList[index + 16] = colorB;
    _vertexList[index + 17] = colorA;

    _triangleCount += 3;

    if (_triangleCount == _maxTriangleCount) flush();
  }

  //-----------------------------------------------------------------------------------------------

  void flush() {

    Float32List vertexUpdate = _vertexList;

    if (_triangleCount == 0) {
      return;
    } else if (_triangleCount < _maxTriangleCount) {
      vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _triangleCount * 3 * 6);
    }

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    _renderingContext.drawArrays(gl.TRIANGLES, 0, _triangleCount * 3);
    _triangleCount = 0;
  }

  //-----------------------------------------------------------------------------------------------

  _onContextRestored(Event e) {
    _program = null;
  }
}