part of stagexl;

abstract class RenderProgram {

  RenderContextWebGL _renderContext;
  gl.Program _program;

  //-----------------------------------------------------------------------------------------------

  gl.Program get program => _program;

  void activate();
  void flush();

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad);

  //-----------------------------------------------------------------------------------------------

  gl.Shader _createShader(String source, int shaderType) {

    var renderingContext = _renderContext.rawContext;
    var shader = renderingContext.createShader(shaderType);

    renderingContext.shaderSource(shader, source);
    renderingContext.compileShader(shader);

    var vertexShaderStatus = renderingContext.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (vertexShaderStatus == false) throw renderingContext.getShaderInfoLog(shader);

    return shader;
  }

  //-----------------------------------------------------------------------------------------------

  gl.Program _createProgram(gl.Shader vertexShader, gl.Shader fragmentShader) {

    var renderingContext = _renderContext.rawContext;
    var program = renderingContext.createProgram();

    renderingContext.attachShader(program, vertexShader);
    renderingContext.attachShader(program, fragmentShader);
    renderingContext.linkProgram(program);

    var programStatus = renderingContext.getProgramParameter(program, gl.LINK_STATUS);
    if (programStatus == false) throw renderingContext.getProgramInfoLog(program);

    return program;
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class DefaultRenderProgram extends RenderProgram {

  var vertexShaderSource = """
      attribute vec2 aVertexPosition;
      attribute vec2 aVertexTextCoord;
      attribute float aVertexAlpha;

      uniform mat3 uViewMatrix;
      
      varying vec2 vTextCoord;
      varying float vAlpha;

      void main() {
        vTextCoord = aVertexTextCoord;
        vAlpha = aVertexAlpha;
        gl_Position = vec4(uViewMatrix * vec3(aVertexPosition, 1.0), 1.0); 
      }
      """;

  var fragmentShaderSource = """
      precision mediump float;

      uniform sampler2D uSampler;
      varying vec2 vTextCoord;
      varying float vAlpha;

      void main() {
        gl_FragColor = texture2D(uSampler, vTextCoord) * vAlpha;
        //gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0); 
      }
      """;

  //-----------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)
  //-----------------------------------------------

  static const int _maxQuadCount = 256;

  gl.RenderingContext _renderingContext;

  Int16List _indexList = new Int16List(_maxQuadCount * 6);
  Float32List _vertexList = new Float32List(_maxQuadCount * 4 * 5);
  Float32List _vertexListSingle = null;

  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexAlphaLocation = 0;

  int _quadCount = 0;

  //-----------------------------------------------------------------------------------------------

  DefaultRenderProgram(RenderContextWebGL renderContext) {

    _renderContext = renderContext;
    _renderingContext = _renderContext.rawContext;

    var vertexShader = _createShader(vertexShaderSource, gl.VERTEX_SHADER);
    var fragmentShader = _createShader(fragmentShaderSource, gl.FRAGMENT_SHADER);

    _program = _createProgram(vertexShader, fragmentShader);

    //----------------------------------

    _aVertexPositionLocation = _renderingContext.getAttribLocation(_program, "aVertexPosition");
    _aVertexTextCoordLocation = _renderingContext.getAttribLocation(_program, "aVertexTextCoord");
    _aVertexAlphaLocation = _renderingContext.getAttribLocation(_program, "aVertexAlpha");

    _renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
    _renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
    _renderingContext.enableVertexAttribArray(_aVertexAlphaLocation);

    //----------------------------------

    _vertexListSingle = new Float32List.view(_vertexList.buffer, 0, 5 * 4);

    for(int i = 0, j = 0; i <= _indexList.length - 6; i += 6, j +=4 ) {
      _indexList[i + 0] = j + 0;
      _indexList[i + 1] = j + 1;
      _indexList[i + 2] = j + 2;
      _indexList[i + 3] = j + 0;
      _indexList[i + 4] = j + 2;
      _indexList[i + 5] = j + 3;
    }

    _indexBuffer = _renderingContext.createBuffer();
    _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    _renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);

    _vertexBuffer = _renderingContext.createBuffer();
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);

    activate();
  }

  //-----------------------------------------------------------------------------------------------

  void activate() {
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 20, 0);
    _renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 20, 8);
    _renderingContext.vertexAttribPointer(_aVertexAlphaLocation, 1, gl.FLOAT, false, 20, 16);
  }

  //-----------------------------------------------------------------------------------------------

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {

    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;

    var width = renderTextureQuad.width;
    var height = renderTextureQuad.height;
    var offsetX = renderTextureQuad.offsetX;
    var offsetY = renderTextureQuad.offsetY;
    var uvList = renderTextureQuad.uvList;

    // x' = tx + a * x + c * y
    // y' = ty + b * x + d * y

    var a = matrix.a;
    var b = matrix.b;
    var c = matrix.c;
    var d = matrix.d;
    var tx = matrix.tx;
    var ty = matrix.ty;

    var ox = tx + offsetX * a + offsetY * c;
    var oy = ty + offsetX * b + offsetY * d;
    var ax = a * width;
    var bx = b * width;
    var cy = c * height;
    var dy = d * height;

    var index = _quadCount * 20;
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

    var vertexUpdate = _vertexList;

    if (_quadCount == 0) {
      return;
    } else  if (_quadCount == 1) {
      vertexUpdate = _vertexListSingle;
    } else if (_quadCount < _maxQuadCount) {
      vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 5);
    }

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    _renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
    _quadCount = 0;
  }

}