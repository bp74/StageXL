part of stagexl.display_ex;

class _BitmapContainerProgram extends RenderProgram {

  String get vertexShaderSource => """
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

  String get fragmentShaderSource => """
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
  gl.Buffer _vertexBuffer = null;
  gl.Buffer _indexBuffer = null;
  gl.UniformLocation _uProjectionMatrixLocation = null;
  gl.UniformLocation _uGlobalMatrix = null;
  gl.UniformLocation _uGlobalAlpha = null;

  int _aPositionLocation = 0;
  int _aOffsetLocation = 0;
  int _aScaleLocation = 0;
  int _aSkewLocation = 0;
  int _aTextCoordLocation = 0;
  int _aAlphaLocation = 0;
  int _quadCount = 0;

  final Int16List _indexList = new Int16List(_maxQuadCount * 6);
  final Float32List _vertexList = new Float32List(_maxQuadCount * 4 * 11);

  //-----------------------------------------------------------------------------------------------

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

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (_contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _contextIdentifier = renderContext.contextIdentifier;
      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();
      _aPositionLocation = attributeLocations["aPosition"];
      _aOffsetLocation = attributeLocations["aOffset"];
      _aScaleLocation = attributeLocations["aScale"];
      _aSkewLocation = attributeLocations["aSkew"];
      _aTextCoordLocation = attributeLocations["aTextCoord"];
      _aAlphaLocation = attributeLocations["aAlpha"];
      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uGlobalMatrix = uniformLocations["uGlobalMatrix"];
      _uGlobalAlpha = uniformLocations["uGlobalAlpha"];

      renderingContext.enableVertexAttribArray(_aPositionLocation);
      renderingContext.enableVertexAttribArray(_aOffsetLocation);
      renderingContext.enableVertexAttribArray(_aScaleLocation);
      renderingContext.enableVertexAttribArray(_aSkewLocation);
      renderingContext.enableVertexAttribArray(_aTextCoordLocation);
      renderingContext.enableVertexAttribArray(_aAlphaLocation);
      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(_aPositionLocation, 2, gl.FLOAT, false, 44, 0);
    renderingContext.vertexAttribPointer(_aOffsetLocation, 2, gl.FLOAT, false, 44, 8);
    renderingContext.vertexAttribPointer(_aScaleLocation, 2, gl.FLOAT, false, 44, 16);
    renderingContext.vertexAttribPointer(_aSkewLocation, 2, gl.FLOAT, false, 44, 24);
    renderingContext.vertexAttribPointer(_aTextCoordLocation, 2, gl.FLOAT, false, 44, 32);
    renderingContext.vertexAttribPointer(_aAlphaLocation, 1, gl.FLOAT, false, 44, 40);
  }

  @override
  void flush() {

    if (_quadCount == 0) return;
    var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 11);

    renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, vertexUpdate);
    renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);

    _quadCount = 0;
  }

  //-----------------------------------------------------------------------------------------------

  void reset(Matrix globalMatrix, num globalAlpha) {

    var uGlobalMatrix = new Float32List.fromList([
        globalMatrix.a, globalMatrix.c, globalMatrix.tx,
        globalMatrix.b, globalMatrix.d, globalMatrix.ty,
        0.0, 0.0, 0.0]);

    renderingContext.uniformMatrix3fv(_uGlobalMatrix, false, uGlobalMatrix);
    renderingContext.uniform1f(_uGlobalAlpha, globalAlpha);

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
}
