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

  RenderBufferIndex _renderBufferIndex = null;
  _BitmapContainerBuffer _dynamicBuffer = null;

  int _staticStride = 0;
  int _dynamicStride = 0;

  //---------------------------------------------------------------------------

  _BitmapContainerProgram(
      this.bitmapBitmapData, this.bitmapPosition,
      this.bitmapPivot, this.bitmapScale, this.bitmapSkew,
      this.bitmapRotation, this.bitmapAlpha, this.bitmapVisible) {

    _staticStride = _calculateStride(BitmapProperty.Static);
    _dynamicStride = _calculateStride(BitmapProperty.Dynamic);

    _dynamicBuffer = new _BitmapContainerBuffer(this,
        BitmapProperty.Dynamic, 1024, _dynamicStride);
  }

  //---------------------------------------------------------------------------
  // aBitmapData : Float32(x), Float32(y), Float32(u), Float32(v),
  // aPosition   : Float32(x), Float32(y)
  // aPivot      : Float32(x), Float32(y)
  // aScale      : Float32(x), Float32(y)
  // aSkew       : Float32(x), Float32(y)
  // aRotation   : Float32(r)
  // aAlpha      : Float32(a)
  //---------------------------------------------------------------------------

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

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);
    super.renderingContext.uniform1i(uniforms["uSampler"], 0);

    _renderBufferIndex = renderContext.renderBufferIndexQuads;
    _renderBufferIndex.activate(renderContext);

    _dynamicBuffer.activate(renderContext);
    _dynamicBuffer.bindAttributes();
  }

  @override
  void flush() {
    // This RenderProgram has a built in draw call batching,
    // therefore we don't need to flush anything to the GPU.
  }

  //---------------------------------------------------------------------------

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

    renderingContext.uniformMatrix3fv(uniforms["uGlobalMatrix"], false, uGlobalMatrix);
    renderingContext.uniform1f(uniforms["uGlobalAlpha"], globalAlpha);

    // Manage static BitmapContainerBuffers

    List<Bitmap> bitmaps = container._children;
    List<_BitmapContainerBuffer> staticBuffers = container._staticBuffers;
    int staticBufferMinimum = (bitmaps.length + 1023) ~/ 1024;

    while(staticBuffers.length < staticBufferMinimum) {
      var st = BitmapProperty.Static;
      var buffer = new _BitmapContainerBuffer(this, st, 1024, _staticStride);
      staticBuffers.add(buffer);
    }

    while(staticBuffers.length > staticBufferMinimum) {
      var buffer = staticBuffers.removeLast();
      buffer.dispose();
    }

    if (staticBufferMinimum == 0) {
      return;
    }

    // Render all Bitmaps

    _BitmapContainerBuffer dynamicBuffer = _dynamicBuffer;
    _BitmapContainerBuffer staticBuffer = staticBuffers.first;
    staticBuffer.activate(renderContext);
    staticBuffer.bindAttributes();

    int quadLimit = 1024;
    int quadStart = 0;
    int quadIndex = 0;
    int bitmapIndex = 0;
    int triangles = gl.TRIANGLES;
    int uShort = gl.UNSIGNED_SHORT;
    var context = renderingContext;

    while (bitmapIndex < bitmaps.length) {

      var bitmap = bitmaps[bitmapIndex];
      var bitmapData = bitmap.bitmapData;
      var renderTexture = bitmapData.renderTexture;
      var textureCheck = identical(activeRenderTexture, renderTexture);
      var textureFlush = false;

      if (textureCheck) {
        dynamicBuffer.setVertexData(bitmap, quadIndex);
        staticBuffer.setVertexData(bitmap, quadIndex);
        bitmapIndex += 1;
        quadIndex += 1;
        textureFlush = bitmapIndex == bitmaps.length || quadIndex == quadLimit;
      } else {
        textureFlush = quadIndex > quadStart;
      }

      if (textureFlush) {
        var offset = quadStart;
        var length = quadIndex - quadStart;
        dynamicBuffer.activate(renderContext);
        dynamicBuffer.updateVertexData(offset, length);
        staticBuffer.activate(renderContext);
        staticBuffer.updateVertexData(offset, length);
        context.drawElements(triangles, length * 6, uShort, offset * 6);
        quadStart = quadIndex;
        if (quadStart == quadLimit && bitmapIndex < bitmaps.length) {
          quadStart = quadIndex = 0;
          staticBuffer = staticBuffers[bitmapIndex ~/ 1024];
          staticBuffer.activate(renderContext);
          staticBuffer.bindAttributes();
        }
      }

      if (textureCheck == false) {
        activeRenderTexture = renderTexture;
        renderContext.activateRenderTexture(renderTexture);
      }
    }
  }

  //---------------------------------------------------------------------------

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

}
