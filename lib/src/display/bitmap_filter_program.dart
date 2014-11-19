part of stagexl.display;

/// The BitmapFilterProgram is a base class for filter render programs.
///
/// Most filter render programs share the same requirements. This
/// abstract base class can be extended and the filter render program
/// only needs to change the fragment shader source code.

abstract class BitmapFilterProgram extends RenderProgram {

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

  int _contextIdentifier = -1;
  gl.Buffer _vertexBuffer;

  final Float32List _vertexList = new Float32List(4 * 5);

  //-----------------------------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    if (_contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _contextIdentifier = renderContext.contextIdentifier;
      _vertexBuffer = renderingContext.createBuffer();

      renderingContext.enableVertexAttribArray(attributeLocations["aVertexPosition"]);
      renderingContext.enableVertexAttribArray(attributeLocations["aVertexTextCoord"]);
      renderingContext.enableVertexAttribArray(attributeLocations["aVertexAlpha"]);

      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.vertexAttribPointer(attributeLocations["aVertexPosition"], 2, gl.FLOAT, false, 20, 0);
    renderingContext.vertexAttribPointer(attributeLocations["aVertexTextCoord"], 2, gl.FLOAT, false, 20, 8);
    renderingContext.vertexAttribPointer(attributeLocations["aVertexAlpha"], 1, gl.FLOAT, false, 20, 16);
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

    renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, _vertexList);
    renderingContext.drawArrays(gl.TRIANGLE_FAN, 0, 4);
  }

}

