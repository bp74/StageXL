part of stagexl.display;

class _BitmapContainerProgram extends RenderProgram {

  // Note to the interested reader: The code of this class looks very bloated :)
  // We don't write the code in a more generic way because we want the compiler
  // to optimize the code for us. For example if every BitmapContainer in the
  // application will ignore the skew property the compiler will remove the
  // code dealing with the skew property completely. In the end we will get
  // very fast and also small code.

  final BitmapContainerProperty bitmapBitmapData;
  final BitmapContainerProperty bitmapPosition;
  final BitmapContainerProperty bitmapPivot;
  final BitmapContainerProperty bitmapScale;
  final BitmapContainerProperty bitmapSkew;
  final BitmapContainerProperty bitmapRotation;
  final BitmapContainerProperty bitmapAlpha;
  final BitmapContainerProperty bitmapVisible;

  int _strideDynamic = 0;
  int _strideStatic = 0;

  int _offsetBitmapData = 0;
  int _offsetPosition = 0;
  int _offsetRotation = 0;
  int _offsetPivot = 0;
  int _offsetScale = 0;
  int _offsetAlpha = 0;
  int _offsetSkew = 0;

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

    _initVertexDynamic();
    _initVertexStatic();
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
    _setVertexAttribPointersDynamic();
  }

  @override
  void flush() {
  }

  //-----------------------------------------------------------------------------------------------

  void renderBitmapContainer(RenderState renderState, BitmapContainer container) {

    RenderContextWebGL renderContext = renderState.renderContext;
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
    // TODO: Bind the right texture.

    var batchSize = 50;
    var bitmaps = container._children;

    for (int i = 0; i < bitmaps.length; i += batchSize) {

      batchSize = minInt(bitmaps.length - i, batchSize);
      _updateVertexBufferDynamic(bitmaps, i, batchSize);

      BitmapData bitmapData = bitmaps[i].bitmapData;
      RenderTexture renderTexture = bitmapData.renderTexture;
      renderContext.activateRenderTexture(renderTexture);

      var vertexUpdateLength = _strideDynamic * batchSize * 4;
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, vertexUpdateLength);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawElements(gl.TRIANGLES, batchSize * 6, gl.UNSIGNED_SHORT, 0);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _initVertexDynamic() {

    if (bitmapBitmapData == BitmapContainerProperty.Dynamic) {
      _offsetBitmapData = _strideDynamic;
      _strideDynamic += 4;
    }
    if (bitmapPosition == BitmapContainerProperty.Dynamic) {
      _offsetPosition = _strideDynamic;
      _strideDynamic += 2;
    }
    if (bitmapPivot == BitmapContainerProperty.Dynamic) {
      _offsetPivot = _strideDynamic;
      _strideDynamic += 2;
    }
    if (bitmapScale == BitmapContainerProperty.Dynamic) {
      _offsetScale = _strideDynamic;
      _strideDynamic += 2;
    }
    if (bitmapSkew == BitmapContainerProperty.Dynamic) {
      _offsetSkew = _strideDynamic;
      _strideDynamic += 2;
    }
    if (bitmapRotation == BitmapContainerProperty.Dynamic) {
      _offsetRotation = _strideDynamic;
      _strideDynamic += 1;
    }
    if (bitmapAlpha == BitmapContainerProperty.Dynamic) {
      _offsetAlpha = _strideDynamic;
      _strideDynamic += 1;
    }
  }

  void _initVertexStatic() {

    if (bitmapBitmapData == BitmapContainerProperty.Static) {
      _offsetBitmapData = _strideStatic;
      _strideStatic += 4;
    }
    if (bitmapPosition == BitmapContainerProperty.Static) {
      _offsetPosition = _strideStatic;
      _strideStatic += 2;
    }
    if (bitmapPivot == BitmapContainerProperty.Static) {
      _offsetPivot = _strideStatic;
      _strideStatic += 2;
    }
    if (bitmapScale == BitmapContainerProperty.Static) {
      _offsetScale = _strideStatic;
      _strideStatic += 2;
    }
    if (bitmapSkew == BitmapContainerProperty.Static) {
      _offsetSkew = _strideStatic;
      _strideStatic += 2;
    }
    if (bitmapRotation == BitmapContainerProperty.Static) {
      _offsetRotation = _strideStatic;
      _strideStatic += 1;
    }
    if (bitmapAlpha == BitmapContainerProperty.Static) {
      _offsetAlpha = _strideStatic;
      _strideStatic += 1;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _setVertexAttribPointersDynamic() {

    if (bitmapBitmapData == BitmapContainerProperty.Dynamic) {
      renderingContext.vertexAttribPointer(_locationBitmapData,
          4, gl.FLOAT, false, _strideDynamic * 4, _offsetBitmapData * 4);
    }
    if (bitmapPosition == BitmapContainerProperty.Dynamic) {
      renderingContext.vertexAttribPointer(_locationPosition,
          2, gl.FLOAT, false, _strideDynamic * 4, _offsetPosition * 4);
    }
    if (bitmapPivot == BitmapContainerProperty.Dynamic) {
      renderingContext.vertexAttribPointer(_locationPivot,
          2, gl.FLOAT, false, _strideDynamic * 4, _offsetPivot * 4);
    }
    if (bitmapScale == BitmapContainerProperty.Dynamic) {
      renderingContext.vertexAttribPointer(_locationScale,
          2, gl.FLOAT, false, _strideDynamic * 4, _offsetScale * 4);
    }
    if (bitmapSkew == BitmapContainerProperty.Dynamic) {
      renderingContext.vertexAttribPointer(_locationSkew,
          2, gl.FLOAT, false, _strideDynamic * 4, _offsetSkew * 4);
    }
    if (bitmapRotation == BitmapContainerProperty.Dynamic) {
      renderingContext.vertexAttribPointer(_locationRotation,
          1, gl.FLOAT, false, _strideDynamic * 4, _offsetRotation * 4);
    }
    if (bitmapAlpha == BitmapContainerProperty.Dynamic) {
      renderingContext.vertexAttribPointer(_locationAlpha,
          1, gl.FLOAT, false, _strideDynamic * 4, _offsetAlpha * 4);
    }
  }

  void _setVertexAttribPointersStatic() {

    if (bitmapBitmapData == BitmapContainerProperty.Static) {
      renderingContext.vertexAttribPointer(_locationBitmapData,
          4, gl.FLOAT, false, _strideStatic * 4, _offsetBitmapData * 4);
    }
    if (bitmapPosition == BitmapContainerProperty.Static) {
      renderingContext.vertexAttribPointer(_locationPosition,
          2, gl.FLOAT, false, _strideStatic * 4, _offsetPosition * 4);
    }
    if (bitmapPivot == BitmapContainerProperty.Static) {
      renderingContext.vertexAttribPointer(_locationPivot,
          2, gl.FLOAT, false, _strideStatic * 4, _offsetPivot * 4);
    }
    if (bitmapScale == BitmapContainerProperty.Static) {
      renderingContext.vertexAttribPointer(_locationScale,
          2, gl.FLOAT, false, _strideStatic * 4, _offsetScale * 4);
    }
    if (bitmapSkew == BitmapContainerProperty.Static) {
      renderingContext.vertexAttribPointer(_locationSkew,
          2, gl.FLOAT, false, _strideStatic * 4, _offsetSkew * 4);
    }
    if (bitmapRotation == BitmapContainerProperty.Static) {
      renderingContext.vertexAttribPointer(_locationRotation,
          1, gl.FLOAT, false, _strideStatic * 4, _offsetRotation * 4);
    }
    if (bitmapAlpha == BitmapContainerProperty.Static) {
      renderingContext.vertexAttribPointer(_locationAlpha,
          1, gl.FLOAT, false, _strideStatic * 4, _offsetAlpha * 4);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _updateVertexBufferDynamic(List<Bitmap> bitmaps, int start, int length) {

    var vxList  = _vertexList;
    var vertex0 = _strideDynamic * 0;
    var vertex1 = _strideDynamic * 1;
    var vertex2 = _strideDynamic * 2;
    var vertex3 = _strideDynamic * 3;
    var vertex4 = _strideDynamic * 4;

    for(int i = 0; i < length; i++) {

      var bitmap = bitmaps[start + i];
      var offset = i * vertex4;

      if (bitmapBitmapData == BitmapContainerProperty.Dynamic) {
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

      if (bitmapPosition == BitmapContainerProperty.Dynamic) {
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

      if (bitmapPivot == BitmapContainerProperty.Dynamic) {
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

      if (bitmapScale == BitmapContainerProperty.Dynamic) {
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

      if (bitmapSkew == BitmapContainerProperty.Dynamic) {
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

      if (bitmapRotation == BitmapContainerProperty.Dynamic) {
        var rotation = bitmap.rotation.toDouble();
        vxList[offset + vertex0 + 0] = rotation;
        vxList[offset + vertex1 + 0] = rotation;
        vxList[offset + vertex2 + 0] = rotation;
        vxList[offset + vertex3 + 0] = rotation;
        offset += 1;
      }

      if (bitmapAlpha == BitmapContainerProperty.Dynamic) {
        var alpha = bitmap.alpha.toDouble();
        vxList[offset + vertex0 + 0] = alpha;
        vxList[offset + vertex1 + 0] = alpha;
        vxList[offset + vertex2 + 0] = alpha;
        vxList[offset + vertex3 + 0] = alpha;
        offset += 1;
      }

    }
  }

}
