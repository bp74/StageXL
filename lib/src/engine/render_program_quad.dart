part of stagexl.engine;

class RenderProgramQuad extends RenderProgram {

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
      gl_FragColor = texture2D(uSampler, vTextCoord) * vAlpha;
    }
    """;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)
  //---------------------------------------------------------------------------

  Int16List _indexList;
  Float32List _vertexList;

  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTextCoordLocation = 0;
  int _aVertexAlphaLocation = 0;
  int _quadCount = 0;

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrixLocation, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _indexList = renderContext.staticIndexList;
      _vertexList = renderContext.dynamicVertexList;
      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();
      _aVertexPositionLocation = attributeLocations["aVertexPosition"];
      _aVertexTextCoordLocation = attributeLocations["aVertexTextCoord"];
      _aVertexAlphaLocation = attributeLocations["aVertexAlpha"];
      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uSamplerLocation = uniformLocations["uSampler"];

      renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      renderingContext.enableVertexAttribArray(_aVertexTextCoordLocation);
      renderingContext.enableVertexAttribArray(_aVertexAlphaLocation);
      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 20, 0);
    renderingContext.vertexAttribPointer(_aVertexTextCoordLocation, 2, gl.FLOAT, false, 20, 8);
    renderingContext.vertexAttribPointer(_aVertexAlphaLocation, 1, gl.FLOAT, false, 20, 16);
    renderingContext.uniform1i(_uSamplerLocation, 0);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 20);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
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

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num ox = matrix.tx + offsetX * ma + offsetY * mc;
    num oy = matrix.ty + offsetX * mb + offsetY * md;
    num ax = ma * width;
    num bx = mb * width;
    num cy = mc * height;
    num dy = md * height;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixList = _indexList;
    if (ixList == null) return;
    if (ixList.length < _quadCount * 6 + 6) flush();

    var vxList = _vertexList;
    if (vxList == null) return;
    if (vxList.length < _quadCount * 20 + 20) flush();

    var index = _quadCount * 20;
    if (index > vxList.length - 20) return;

    // vertex 1
    vxList[index + 00] = ox;
    vxList[index + 01] = oy;
    vxList[index + 02] = uvList[0];
    vxList[index + 03] = uvList[1];
    vxList[index + 04] = alpha;

    // vertex 2
    vxList[index + 05] = ox + ax;
    vxList[index + 06] = oy + bx;
    vxList[index + 07] = uvList[2];
    vxList[index + 08] = uvList[3];
    vxList[index + 09] = alpha;

    // vertex 3
    vxList[index + 10] = ox + ax + cy;
    vxList[index + 11] = oy + bx + dy;
    vxList[index + 12] = uvList[4];
    vxList[index + 13] = uvList[5];
    vxList[index + 14] = alpha;

    // vertex 4
    vxList[index + 15] = ox + cy;
    vxList[index + 16] = oy + dy;
    vxList[index + 17] = uvList[6];
    vxList[index + 18] = uvList[7];
    vxList[index + 19] = alpha;

    _quadCount += 1;
  }

}