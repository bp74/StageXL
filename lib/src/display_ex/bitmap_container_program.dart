part of stagexl.display_ex;

class _BitmapContainerProgram extends RenderProgram {

  var _vertexShaderSource = """
      attribute vec2 aPosition;
      attribute vec2 aOffset;
      attribute vec2 aScale;
      attribute vec2 aSkew;
      attribute vec2 aTextCoord;
      attribute float aAlpha;
      uniform mat4 uProjectionMatrix;
      uniform mat3 uGlobalMatrix;
      uniform float uGlobalAlpha;
      varying vec2 vTextCoord;
      varying float vAlpha;

      void main() {
        float skewX = aSkew[0];
        float skewY = aSkew[1];
        vec2 offsetScaled = aOffset * aScale;
        vec2 offsetSkewed = vec2(
             offsetScaled.x * cos(skewY) - offsetScaled.y * sin(skewX), 
             offsetScaled.x * sin(skewY) + offsetScaled.y * cos(skewX));

        vec3 position = vec3(aPosition + offsetSkewed, 1.0);
        gl_Position = vec4(position.xy, 0.0, 1.0) * mat4(uGlobalMatrix) * uProjectionMatrix;
        vTextCoord = aTextCoord;
        vAlpha = aAlpha * uGlobalAlpha;
      }
      """;

  var _fragmentShaderSource = """
      precision mediump float;
      uniform sampler2D uSampler;
      varying vec2 vTextCoord;
      varying float vAlpha;

      void main() {
         gl_FragColor = texture2D(uSampler, vTextCoord) * vAlpha;
      }
      """;

  //---------------------------------------------------------------------------
  // aPosition  : Float32(x), Float32(y)
  // aOffset    : Float32(x), Float32(y)
  // aScale     : Float32(x), Float32(y)
  // aSkew      : Float32(x), Float32(y)
  // aTextCoord : Float32(u), Float32(v)
  // aAlpha     : Float32(alpha)
  //---------------------------------------------------------------------------

  static const int _maxQuadCount = 256;
  static final _BitmapContainerProgram instance = new _BitmapContainerProgram();

  int _contextIdentifier = -1;
  gl.RenderingContext _renderingContext = null;
  gl.Program _program = null;
  gl.Buffer _vertexBuffer = null;
  gl.Buffer _indexBuffer = null;

  gl.UniformLocation _uProjectionMatrixLocation = null;
  gl.UniformLocation _uGlobalMatrix = null;
  gl.UniformLocation _uGlobalAlpha = null;

  Int16List _indexList = new Int16List(_maxQuadCount * 6);
  Float32List _vertexList = new Float32List(_maxQuadCount * 4 * 11);

  int _aPositionLocation = 0;
  int _aOffsetLocation = 0;
  int _aScaleLocation = 0;
  int _aSkewLocation = 0;
  int _aTextCoordLocation = 0;
  int _aAlphaLocation = 0;
  int _quadCount = 0;

  _BitmapContainerProgram() {
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

  void set projectionMatrix(Matrix3D matrix) {
    _renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (_contextIdentifier != renderContext.contextIdentifier) {

      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _program = createProgram(_renderingContext, _vertexShaderSource, _fragmentShaderSource);
      _indexBuffer = _renderingContext.createBuffer();
      _vertexBuffer = _renderingContext.createBuffer();

      _aPositionLocation = _renderingContext.getAttribLocation(_program, "aPosition");
      _aOffsetLocation = _renderingContext.getAttribLocation(_program, "aOffset");
      _aScaleLocation = _renderingContext.getAttribLocation(_program, "aScale");
      _aSkewLocation = _renderingContext.getAttribLocation(_program, "aSkew");
      _aTextCoordLocation = _renderingContext.getAttribLocation(_program, "aTextCoord");
      _aAlphaLocation = _renderingContext.getAttribLocation(_program, "aAlpha");

      _uProjectionMatrixLocation = _renderingContext.getUniformLocation(_program, "uProjectionMatrix");
      _uGlobalMatrix = _renderingContext.getUniformLocation(_program, "uGlobalMatrix");
      _uGlobalAlpha = _renderingContext.getUniformLocation(_program, "uGlobalAlpha");

      _renderingContext.enableVertexAttribArray(_aPositionLocation);
      _renderingContext.enableVertexAttribArray(_aOffsetLocation);
      _renderingContext.enableVertexAttribArray(_aScaleLocation);
      _renderingContext.enableVertexAttribArray(_aSkewLocation);
      _renderingContext.enableVertexAttribArray(_aTextCoordLocation);
      _renderingContext.enableVertexAttribArray(_aAlphaLocation);

      _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      _renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);

      _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_aPositionLocation, 2, gl.FLOAT, false, 44, 0);
    _renderingContext.vertexAttribPointer(_aOffsetLocation, 2, gl.FLOAT, false, 44, 8);
    _renderingContext.vertexAttribPointer(_aScaleLocation, 2, gl.FLOAT, false, 44, 16);
    _renderingContext.vertexAttribPointer(_aSkewLocation, 2, gl.FLOAT, false, 44, 24);
    _renderingContext.vertexAttribPointer(_aTextCoordLocation, 2, gl.FLOAT, false, 44, 32);
    _renderingContext.vertexAttribPointer(_aAlphaLocation, 1, gl.FLOAT, false, 44, 40);
  }

  //-----------------------------------------------------------------------------------------------

  void reset(Matrix globalMatrix, num globalAlpha) {

    var uGlobalMatrix = new Float32List.fromList([
        globalMatrix.a, globalMatrix.c, globalMatrix.tx,
        globalMatrix.b, globalMatrix.d, globalMatrix.ty,
        0.0, 0.0, 0.0]);

    _renderingContext.uniformMatrix3fv(_uGlobalMatrix, false, uGlobalMatrix);
    _renderingContext.uniform1f(_uGlobalAlpha, globalAlpha);
    _quadCount = 0;
  }

  //-----------------------------------------------------------------------------------------------

  void renderBitmap(Bitmap bitmap) {

    BitmapData bitmapData = bitmap.bitmapData;
    RenderTextureQuad renderTextureQuad = bitmapData.renderTextureQuad;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

    double x = bitmap.x.toDouble();
    double y = bitmap.y.toDouble();
    double pivotX = bitmap.pivotX.toDouble() - offsetX;
    double pivotY = bitmap.pivotY.toDouble() - offsetY;
    double scaleX = bitmap.scaleX.toDouble();
    double scaleY = bitmap.scaleY.toDouble();
    double rotation = bitmap.rotation.toDouble();
    double skewX = bitmap.skewX.toDouble() + rotation;
    double skewY = bitmap.skewY.toDouble() + rotation;
    double alpha = bitmap.alpha.toDouble();

    double offsetLeft = 0.0 - pivotX;
    double offsetTop = 0.0 - pivotY;
    double offsetRight = width - pivotX;
    double offsetBottom = height - pivotY;

    int index = _quadCount * 44;
    if (index > _vertexList.length - 44) return; // dart2js_hint

    // vertex 1
    _vertexList[index + 00] = x;
    _vertexList[index + 01] = y;
    _vertexList[index + 02] = offsetLeft;
    _vertexList[index + 03] = offsetTop;
    _vertexList[index + 04] = scaleX;
    _vertexList[index + 05] = scaleY;
    _vertexList[index + 06] = skewX;
    _vertexList[index + 07] = skewY;
    _vertexList[index + 08] = uvList[0];
    _vertexList[index + 09] = uvList[1];
    _vertexList[index + 10] = alpha;

    // vertex 2
    _vertexList[index + 11] = x;
    _vertexList[index + 12] = y;
    _vertexList[index + 13] = offsetRight;
    _vertexList[index + 14] = offsetTop;
    _vertexList[index + 15] = scaleX;
    _vertexList[index + 16] = scaleY;
    _vertexList[index + 17] = skewX;
    _vertexList[index + 18] = skewY;
    _vertexList[index + 19] = uvList[2];
    _vertexList[index + 20] = uvList[3];
    _vertexList[index + 21] = alpha;

    // vertex 3
    _vertexList[index + 22] = x;
    _vertexList[index + 23] = y;
    _vertexList[index + 24] = offsetRight;
    _vertexList[index + 25] = offsetBottom;
    _vertexList[index + 26] = scaleX;
    _vertexList[index + 27] = scaleY;
    _vertexList[index + 28] = skewX;
    _vertexList[index + 29] = skewY;
    _vertexList[index + 30] = uvList[4];
    _vertexList[index + 31] = uvList[5];
    _vertexList[index + 32] = alpha;

    // vertex 4
    _vertexList[index + 33] = x;
    _vertexList[index + 34] = y;
    _vertexList[index + 35] = offsetLeft;
    _vertexList[index + 36] = offsetBottom;
    _vertexList[index + 37] = scaleX;
    _vertexList[index + 38] = scaleY;
    _vertexList[index + 39] = skewX;
    _vertexList[index + 40] = skewY;
    _vertexList[index + 41] = uvList[6];
    _vertexList[index + 42] = uvList[7];
    _vertexList[index + 43] = alpha;

    _quadCount += 1;

    if (_quadCount == _maxQuadCount) flush();
  }

  //-----------------------------------------------------------------------------------------------

  void flush() {

    Float32List vertexUpdate = _vertexList;

    if (_quadCount == 0) {
      return;
    } else if (_quadCount < _maxQuadCount) {
      vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 11);
    }

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    _renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
    _quadCount = 0;
  }

}
