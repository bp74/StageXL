part of stagexl.display;

class _BitmapContainerProgram extends RenderProgram {

  final BitmapProperty bitmapBitmapData;
  final BitmapProperty bitmapPosition;
  final BitmapProperty bitmapPivot;
  final BitmapProperty bitmapScale;
  final BitmapProperty bitmapSkew;
  final BitmapProperty bitmapRotation;
  final BitmapProperty bitmapAlpha;
  final BitmapProperty bitmapVisible;

  int _strideDynamic = 0;
  int _strideStatic = 0;

  int _locationBitmapData = 0;
  int _locationPosition = 0;
  int _locationRotation = 0;
  int _locationPivot = 0;
  int _locationScale = 0;
  int _locationAlpha = 0;
  int _locationSkew = 0;

  _BitmapContainerProgram(
      this.bitmapBitmapData, this.bitmapPosition,
      this.bitmapPivot, this.bitmapScale, this.bitmapSkew,
      this.bitmapRotation, this.bitmapAlpha, this.bitmapVisible) {

    _strideDynamic = _calculateStride(BitmapProperty.Dynamic);
    _strideStatic = _calculateStride(BitmapProperty.Static);
  }

  //-----------------------------------------------------------------------------------------------

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    uniform mat3 uGlobalMatrix;
    uniform float uGlobalAlpha;

    attribute vec4 aBitmapData;
    attribute vec2 aPosition;
    attribute vec2 aPivot;
    attribute vec2 aScale;
    attribute vec2 aSkew;
    attribute float aRotation;
    attribute float aAlpha;

    varying vec2 vCoord;
    varying float vAlpha;

    void main() {

      mat4 transform = mat4(uGlobalMatrix) * uProjectionMatrix;
      vec2 skew = aSkew + aRotation;
      vec2 offset = aBitmapData.xy - aPivot; 
      vec2 offsetScaled = offset * aScale;
      vec2 offsetSkewed = vec2(
           offsetScaled.x * cos(skew.y) - offsetScaled.y * sin(skew.x), 
           offsetScaled.x * sin(skew.y) + offsetScaled.y * cos(skew.x));

      gl_Position = vec4(aPosition + offsetSkewed, 0.0, 1.0) * transform;
      vCoord  = aBitmapData.pq;  
      vAlpha = aAlpha * uGlobalAlpha;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;

    varying vec2 vCoord;
    varying float vAlpha;

    void main() {
      gl_FragColor = texture2D(uSampler, vCoord) * vAlpha;
    }
    """;

  //---------------------------------------------------------------------------
  // aBitmapData : Float32(x), Float32(y), Float32(u), Float32(v),
  // aPosition   : Float32(x), Float32(y)
  // aPivot      : Float32(x), Float32(y)
  // aScale      : Float32(x), Float32(y)
  // aSkew       : Float32(x), Float32(y)
  // aRotation   : Float32(alpha)
  // aAlpha      : Float32(alpha)

  //---------------------------------------------------------------------------

  Int16List _indexList = null;
  Float32List _vertexList = null;

  gl.Buffer _indexBuffer = null;
  gl.Buffer _vertexBuffer = null;

  gl.UniformLocation _uProjectionMatrixLocation = null;
  gl.UniformLocation _uGlobalMatrix = null;
  gl.UniformLocation _uGlobalAlpha = null;
  gl.UniformLocation _uSampler = null;

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D projectionMatrix) {
    var uPprojectionMatrix = projectionMatrix.data;
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, uPprojectionMatrix);
  }

  //-----------------------------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _indexList = renderContext.staticIndexList;
      _vertexList = renderContext.dynamicVertexList;
      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();

      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uGlobalMatrix = uniformLocations["uGlobalMatrix"];
      _uGlobalAlpha = uniformLocations["uGlobalAlpha"];
      _uSampler = uniformLocations["uSampler"];

      _locationBitmapData = attributeLocations["aBitmapData"];
      _locationPosition = attributeLocations["aPosition"];
      _locationPivot = attributeLocations["aPivot"];
      _locationScale = attributeLocations["aScale"];
      _locationSkew = attributeLocations["aSkew"];
      _locationRotation = attributeLocations["aRotation"];
      _locationAlpha = attributeLocations["aAlpha"];

      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.uniform1i(_uSampler, 0);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _setVertexAttribPointers(BitmapProperty.Dynamic);
  }

  @override
  void flush() {
    // This RenderProgram has a built in draw call batching,
    // therefore we don't need to flush anything to the GPU.
  }

  //-----------------------------------------------------------------------------------------------

  void renderBitmapContainer(RenderState renderState, BitmapContainer container) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture activeRenderTexture = renderContext.activeRenderTexture;

    Matrix globalMatrix = renderState.globalMatrix;
    num globalAlpha = renderState.globalAlpha;
    Float32List uGlobalMatrix = new Float32List(9);

    uGlobalMatrix[0] = globalMatrix.a;
    uGlobalMatrix[1] = globalMatrix.c;
    uGlobalMatrix[2] = globalMatrix.tx;
    uGlobalMatrix[3] = globalMatrix.b;
    uGlobalMatrix[4] = globalMatrix.d;
    uGlobalMatrix[5] = globalMatrix.ty;

    renderingContext.uniformMatrix3fv(_uGlobalMatrix, false, uGlobalMatrix);
    renderingContext.uniform1f(_uGlobalAlpha, globalAlpha);

    // TODO: Use the right size for the batch.
    // TODO: Use the static buffers.

    List<Bitmap> bitmaps = container._children;

    int quadLimit = 200;
    int quadIndex = 0;
    int bitmapIndex = 0;

    while (bitmapIndex < bitmaps.length) {

      var bitmap = bitmaps[bitmapIndex];
      var bitmapData = bitmap.bitmapData;
      var renderTexture = bitmapData.renderTexture;

      var validTexture = identical(activeRenderTexture, renderTexture);
      if (validTexture) {
        _updateVertex(bitmap, _vertexList, quadIndex, _strideDynamic);
        bitmapIndex += 1;
        quadIndex += 1;
      }

      var flush = validTexture ? bitmapIndex == bitmaps.length : quadIndex > 0;
      if (flush || quadIndex == quadLimit) {
        var vertexUpdateLength = _strideDynamic * quadIndex * 4;
        var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, vertexUpdateLength);
        renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
        renderingContext.drawElements(gl.TRIANGLES, quadIndex * 6, gl.UNSIGNED_SHORT, 0);
        quadIndex = 0;
      }

      if (validTexture == false) {
        activeRenderTexture = renderTexture;
        renderContext.activateRenderTexture(renderTexture);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  int _calculateStride(BitmapProperty bitmapProperty) {
    int stride = 0;
    if (bitmapBitmapData == bitmapProperty) stride += 4;
    if (bitmapPosition == bitmapProperty) stride += 2;
    if (bitmapPivot == bitmapProperty) stride += 2;
    if (bitmapScale == bitmapProperty) stride += 2;
    if (bitmapSkew == bitmapProperty) stride += 2;
    if (bitmapRotation == bitmapProperty) stride += 1;
    if (bitmapAlpha == bitmapProperty) stride += 1;
    return stride;
  }

  //-----------------------------------------------------------------------------------------------

  void _setVertexAttribPointers(BitmapProperty bitmapProperty) {

    int offset = 0;
    int stride = 0;
    int type = gl.FLOAT;

    if (bitmapProperty == BitmapProperty.Dynamic) stride = _strideDynamic * 4;
    if (bitmapProperty == BitmapProperty.Static) stride = _strideStatic * 4;
    if (bitmapProperty == BitmapProperty.Ignore) return;

    if (bitmapBitmapData == bitmapProperty) {
      renderingContext.vertexAttribPointer(_locationBitmapData, 4, type, false, stride, offset);
      offset += 16;
    }
    if (bitmapPosition == bitmapProperty) {
      renderingContext.vertexAttribPointer(_locationPosition, 2, type, false, stride, offset);
      offset += 8;
    }
    if (bitmapPivot == bitmapProperty) {
      renderingContext.vertexAttribPointer(_locationPivot, 2, type, false, stride, offset);
      offset += 8;
    }
    if (bitmapScale == bitmapProperty) {
      renderingContext.vertexAttribPointer(_locationScale, 2, type, false, stride, offset);
      offset += 8;
    }
    if (bitmapSkew == bitmapProperty) {
      renderingContext.vertexAttribPointer(_locationSkew, 2, type, false, stride, offset);
      offset += 8;
    }
    if (bitmapRotation == bitmapProperty) {
      renderingContext.vertexAttribPointer(_locationRotation, 1, type, false, stride, offset);
      offset += 4;
    }
    if (bitmapAlpha == bitmapProperty) {
      renderingContext.vertexAttribPointer(_locationAlpha, 1, type, false, stride, offset);
      offset += 4;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _updateVertex(Bitmap bitmap, Float32List vxList, int quadIndex, int stride) {

    var vertex0 = stride * 0;
    var vertex1 = stride * 1;
    var vertex2 = stride * 2;
    var vertex3 = stride * 3;
    var offset  = stride * 4 * quadIndex;

    if (bitmapBitmapData == BitmapProperty.Dynamic) {
      var renderTextureQuad = bitmap.bitmapData.renderTextureQuad;
      var quadX = renderTextureQuad.offsetX.toDouble();
      var quadY = renderTextureQuad.offsetY.toDouble();
      var quadWidth = renderTextureQuad.textureWidth.toDouble();
      var quadHeight = renderTextureQuad.textureHeight.toDouble();
      var quadUVs = renderTextureQuad.uvList;
      vxList[offset + vertex0 + 0] = quadX;
      vxList[offset + vertex0 + 1] = quadY;
      vxList[offset + vertex0 + 2] = quadUVs[0];
      vxList[offset + vertex0 + 3] = quadUVs[1];
      vxList[offset + vertex1 + 0] = quadX + quadWidth;
      vxList[offset + vertex1 + 1] = quadY;
      vxList[offset + vertex1 + 2] = quadUVs[2];
      vxList[offset + vertex1 + 3] = quadUVs[3];
      vxList[offset + vertex2 + 0] = quadX + quadWidth;
      vxList[offset + vertex2 + 1] = quadY + quadHeight;
      vxList[offset + vertex2 + 2] = quadUVs[4];
      vxList[offset + vertex2 + 3] = quadUVs[5];
      vxList[offset + vertex3 + 0] = quadX;
      vxList[offset + vertex3 + 1] = quadY + quadHeight;
      vxList[offset + vertex3 + 2] = quadUVs[6];
      vxList[offset + vertex3 + 3] = quadUVs[7];
      offset += 4;
    }

    if (bitmapPosition == BitmapProperty.Dynamic) {
      var x = bitmap.x.toDouble();
      var y = bitmap.y.toDouble();
      vxList[offset + vertex0 + 0] = x;
      vxList[offset + vertex0 + 1] = y;
      vxList[offset + vertex1 + 0] = x;
      vxList[offset + vertex1 + 1] = y;
      vxList[offset + vertex2 + 0] = x;
      vxList[offset + vertex2 + 1] = y;
      vxList[offset + vertex3 + 0] = x;
      vxList[offset + vertex3 + 1] = y;
      offset += 2;
    }

    if (bitmapPivot == BitmapProperty.Dynamic) {
      var pivotX = bitmap.pivotX.toDouble();
      var pivotY = bitmap.pivotY.toDouble();
      vxList[offset + vertex0 + 0] = pivotX;
      vxList[offset + vertex0 + 1] = pivotY;
      vxList[offset + vertex1 + 0] = pivotX;
      vxList[offset + vertex1 + 1] = pivotY;
      vxList[offset + vertex2 + 0] = pivotX;
      vxList[offset + vertex2 + 1] = pivotY;
      vxList[offset + vertex3 + 0] = pivotX;
      vxList[offset + vertex3 + 1] = pivotY;
      offset += 2;
    }

    if (bitmapScale == BitmapProperty.Dynamic) {
      var scaleX = bitmap.scaleX.toDouble();
      var scaleY = bitmap.scaleY.toDouble();
      vxList[offset + vertex0 + 0] = scaleX;
      vxList[offset + vertex0 + 1] = scaleY;
      vxList[offset + vertex1 + 0] = scaleX;
      vxList[offset + vertex1 + 1] = scaleY;
      vxList[offset + vertex2 + 0] = scaleX;
      vxList[offset + vertex2 + 1] = scaleY;
      vxList[offset + vertex3 + 0] = scaleX;
      vxList[offset + vertex3 + 1] = scaleY;
      offset += 2;
    }

    if (bitmapSkew == BitmapProperty.Dynamic) {
      var skewX = bitmap.skewX.toDouble();
      var skewY = bitmap.skewY.toDouble();
      vxList[offset + vertex0 + 0] = skewX;
      vxList[offset + vertex0 + 1] = skewY;
      vxList[offset + vertex1 + 0] = skewX;
      vxList[offset + vertex1 + 1] = skewY;
      vxList[offset + vertex2 + 0] = skewX;
      vxList[offset + vertex2 + 1] = skewY;
      vxList[offset + vertex3 + 0] = skewX;
      vxList[offset + vertex3 + 1] = skewY;
      offset += 2;
    }

    if (bitmapRotation == BitmapProperty.Dynamic) {
      var rotation = bitmap.rotation.toDouble();
      vxList[offset + vertex0 + 0] = rotation;
      vxList[offset + vertex1 + 0] = rotation;
      vxList[offset + vertex2 + 0] = rotation;
      vxList[offset + vertex3 + 0] = rotation;
      offset += 1;
    }

    if (bitmapAlpha == BitmapProperty.Dynamic) {
      var alpha = bitmap.alpha.toDouble();
      vxList[offset + vertex0 + 0] = alpha;
      vxList[offset + vertex1 + 0] = alpha;
      vxList[offset + vertex2 + 0] = alpha;
      vxList[offset + vertex3 + 0] = alpha;
      offset += 1;
    }
  }

}
