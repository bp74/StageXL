part of stagexl;

class RenderProgramQuad extends RenderProgram {

  var _vertexShaderSource = """
      attribute vec2 aVertexPosition;
      attribute vec2 aVertexTextCoord;
      attribute float aVertexAlpha;
      varying vec2 vTextCoord;
      varying float vAlpha;

      void main() {
        vTextCoord = aVertexTextCoord;
        vAlpha = aVertexAlpha;
        gl_Position = vec4(aVertexPosition, 0.0, 1.0); 
      }
      """;

  var _fragmentShaderSource = """
      precision mediump float;
      uniform sampler2D uSampler;
      varying vec2 vTextCoord;
      varying float vAlpha;

      void main() {
        vec4 color = texture2D(uSampler, vTextCoord);
        gl_FragColor = color * vAlpha;
        // gl_FragColor = vec4(color.rgb, color.a * vAlpha);
        // gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0); 
      }
      """;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)
  //---------------------------------------------------------------------------

  static const int _maxQuadCount = 256;

  gl.RenderingContext _renderingContext;
  gl.Program _program;
  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;

  StreamSubscription _contextRestoredSubscription;
  Int16List _indexList = new Int16List(_maxQuadCount * 6);
  Float32List _vertexList = new Float32List(_maxQuadCount * 4 * 5);

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexAlphaLocation = 0;
  int _quadCount = 0;

  RenderProgramQuad() {
    for(int i = 0, j = 0; i <= _indexList.length - 6; i += 6, j +=4 ) {
      _indexList[i + 0] = j + 0;
      _indexList[i + 1] = j + 1;
      _indexList[i + 2] = j + 2;
      _indexList[i + 3] = j + 0;
      _indexList[i + 4] = j + 2;
      _indexList[i + 5] = j + 3;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (_program == null) {

      if (_renderingContext == null) {
        _renderingContext = renderContext.rawContext;
        _contextRestoredSubscription = renderContext.onContextRestored.listen(_onContextRestored);
      }

      _program = createProgram(_renderingContext, _vertexShaderSource, _fragmentShaderSource);

      _aVertexPositionLocation = _renderingContext.getAttribLocation(_program, "aVertexPosition");
      _aVertexTextCoordLocation = _renderingContext.getAttribLocation(_program, "aVertexTextCoord");
      _aVertexAlphaLocation = _renderingContext.getAttribLocation(_program, "aVertexAlpha");

      _renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      _renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
      _renderingContext.enableVertexAttribArray(_aVertexAlphaLocation);

      _indexBuffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      _renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);

      _vertexBuffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 20, 0);
    _renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 20, 8);
    _renderingContext.vertexAttribPointer(_aVertexAlphaLocation, 1, gl.FLOAT, false, 20, 16);
  }

  //-----------------------------------------------------------------------------------------------

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha) {

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

    // x' = tx + a * x + c * y
    // y' = ty + b * x + d * y

    num a = matrix.a;
    num b = matrix.b;
    num c = matrix.c;
    num d = matrix.d;

    num ox = matrix.tx + offsetX * a + offsetY * c;
    num oy = matrix.ty + offsetX * b + offsetY * d;
    num ax = a * width;
    num bx = b * width;
    num cy = c * height;
    num dy = d * height;

    int index = _quadCount * 20;
    if (index > _vertexList.length - 20) return; // dart2js_hint

    // vertex 1
    _vertexList[index + 00] = ox;
    _vertexList[index + 01] = oy;
    _vertexList[index + 02] = uvList[0];
    _vertexList[index + 03] = uvList[1];
    _vertexList[index + 04] = alpha;

    // vertex 2
    _vertexList[index + 05] = ox + ax;
    _vertexList[index + 06] = oy + bx;
    _vertexList[index + 07] = uvList[2];
    _vertexList[index + 08] = uvList[3];
    _vertexList[index + 09] = alpha;

    // vertex 3
    _vertexList[index + 10] = ox + ax + cy;
    _vertexList[index + 11] = oy + bx + dy;
    _vertexList[index + 12] = uvList[4];
    _vertexList[index + 13] = uvList[5];
    _vertexList[index + 14] = alpha;

    // vertex 4
    _vertexList[index + 15] = ox + cy;
    _vertexList[index + 16] = oy + dy;
    _vertexList[index + 17] = uvList[6];
    _vertexList[index + 18] = uvList[7];
    _vertexList[index + 19] = alpha;

    _quadCount += 1;

    if (_quadCount == _maxQuadCount) flush();
  }

  //-----------------------------------------------------------------------------------------------

  void flush() {

    Float32List vertexUpdate = _vertexList;

    if (_quadCount == 0) {
      return;
    } else if (_quadCount < _maxQuadCount) {
      vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 5);
    }

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    _renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
    _quadCount = 0;
  }

  //-----------------------------------------------------------------------------------------------

  _onContextRestored(Event e) {
    _program = null;
  }
}