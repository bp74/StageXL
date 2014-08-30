part of stagexl.filters;

abstract class _BitmapFilterProgram extends RenderProgram {

  String get vertexShaderSource => """
      attribute vec2 aVertexPosition;
      attribute vec2 aVertexTextCoord;
      attribute float aVertexAlpha;
      uniform mat4 uProjectionMatrix;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        vTextCoord = aVertexTextCoord;
        vAlpha = aVertexAlpha;
        gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
      }
      """;

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uSampler;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        vec4 color = texture2D(uSampler, vTextCoord);
        gl_FragColor = color * vAlpha;
      }
      """;

  gl.RenderingContext _renderingContext;
  gl.Program _program;
  gl.Buffer _vertexBuffer;

  gl.UniformLocation _uProjectionMatrixLocation;

  StreamSubscription _contextRestoredSubscription;

  final Float32List _vertexList = new Float32List(4 * 5);
  final Map<String, gl.UniformLocation> _uniformLocations = new Map<String, gl.UniformLocation>();
  final Map<String, int> _attribLocations = new Map<String, int>();

  //-----------------------------------------------------------------------------------------------

  void set projectionMatrix(Matrix3D matrix) {
    gl.UniformLocation uProjectionMatrixLocation = _uniformLocations["uProjectionMatrix"];
    _renderingContext.uniformMatrix4fv(uProjectionMatrixLocation, false, matrix.data);
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (_program == null) {

      if (_renderingContext == null) {
        _renderingContext = renderContext.rawContext;
        _contextRestoredSubscription = renderContext.onContextRestored.listen(_onContextRestored);
      }

      _program = createProgram(_renderingContext, vertexShaderSource, fragmentShaderSource);

      int activeAttributes = _renderingContext.getProgramParameter(_program, gl.ACTIVE_ATTRIBUTES);

      for(int index = 0; index < activeAttributes; index++) {
        var activeInfo = _renderingContext.getActiveAttrib(_program, index);
        var location = _renderingContext.getAttribLocation(_program, activeInfo.name);
        _attribLocations[activeInfo.name] = location;
      }

      int activeUniforms = _renderingContext.getProgramParameter(_program, gl.ACTIVE_UNIFORMS);

      for(int index = 0; index < activeUniforms; index++) {
        var activeInfo = _renderingContext.getActiveUniform(_program, index);
        var location = _renderingContext.getUniformLocation(_program, activeInfo.name);
        _uniformLocations[activeInfo.name] = location;
      }

      _renderingContext.enableVertexAttribArray(_attribLocations["aVertexPosition"]);
      _renderingContext.enableVertexAttribArray(_attribLocations["aVertexTextCoord"]);
      _renderingContext.enableVertexAttribArray(_attribLocations["aVertexAlpha"]);

      _vertexBuffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_attribLocations["aVertexPosition"], 2, gl.FLOAT, false, 20, 0);
    _renderingContext.vertexAttribPointer(_attribLocations["aVertexTextCoord"], 2, gl.FLOAT, false, 20, 8);
    _renderingContext.vertexAttribPointer(_attribLocations["aVertexAlpha"], 1, gl.FLOAT, false, 20, 16);
  }

  //-----------------------------------------------------------------------------------------------

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

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

    _vertexList[00] = ox;
    _vertexList[01] = oy;
    _vertexList[02] = uvList[0];
    _vertexList[03] = uvList[1];
    _vertexList[04] = alpha;
    _vertexList[05] = ox + ax;
    _vertexList[06] = oy + bx;
    _vertexList[07] = uvList[2];
    _vertexList[08] = uvList[3];
    _vertexList[09] = alpha;
    _vertexList[10] = ox + ax + cy;
    _vertexList[11] = oy + bx + dy;
    _vertexList[12] = uvList[4];
    _vertexList[13] = uvList[5];
    _vertexList[14] = alpha;
    _vertexList[15] = ox + cy;
    _vertexList[16] = oy + dy;
    _vertexList[17] = uvList[6];
    _vertexList[18] = uvList[7];
    _vertexList[19] = alpha;

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, _vertexList);
    _renderingContext.drawArrays(gl.TRIANGLE_FAN, 0, 4);
  }

  void flush() {
  }

  _onContextRestored(RenderContextEvent e) {
    _program = null;
  }
}

