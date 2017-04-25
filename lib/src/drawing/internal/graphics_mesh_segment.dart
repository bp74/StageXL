part of stagexl.drawing;

abstract class _GraphicsMeshSegment {

  Float32List _vertexBuffer;
  Int16List _indexBuffer;

  int _vertexCount = 0;
  int _indexCount = 0;

  double _minX = 0.0 + double.MAX_FINITE;
  double _minY = 0.0 + double.MAX_FINITE;
  double _maxX = 0.0 - double.MAX_FINITE;
  double _maxY = 0.0 - double.MAX_FINITE;

  final Matrix _tmpMatrix = new Matrix.fromIdentity();

  //---------------------------------------------------------------------------

  _GraphicsMeshSegment(int vertexBufferSize, int indexBufferSize) :
        _vertexBuffer = new Float32List(vertexBufferSize),
        _indexBuffer = new Int16List(indexBufferSize);

  _GraphicsMeshSegment.clone(_GraphicsMeshSegment mesh) :
        _vertexBuffer = new Float32List(mesh.vertexCount * 2),
        _indexBuffer = new Int16List(mesh.indexCount) {

    _vertexCount = mesh.vertexCount;
    _indexCount = mesh.indexCount;
    _minX = mesh.minX;
    _minY = mesh.minY;
    _maxX = mesh.maxX;
    _maxY = mesh.maxY;

    _vertexBuffer.setRange(0, _vertexCount * 2, mesh._vertexBuffer);
    _indexBuffer.setRange(0, _indexCount, mesh._indexBuffer);
  }

  //---------------------------------------------------------------------------

  int get vertexCount => _vertexCount;
  int get indexCount => _indexCount;

  double get lastVertexX => _vertexBuffer[_vertexCount * 2 - 2];
  double get lastVertexY => _vertexBuffer[_vertexCount * 2 - 1];
  double get firstVertexX => _vertexBuffer[0];
  double get firstVertexY => _vertexBuffer[1];

  double get minX => _minX;
  double get minY => _minY;
  double get maxX => _maxX;
  double get maxY => _maxY;

  Rectangle<num> get bounds {
    return new Rectangle<double>(minX, minY, maxX - minX, maxY - minY);
  }

  //---------------------------------------------------------------------------

  bool checkBounds(num x, num y) {
    return x >= _minX && x <= _maxX && y >= _minY && y <= _maxY;
  }

  //---------------------------------------------------------------------------

  int addVertex(double x, double y) {

    var offset = _vertexCount * 2;
    var length = _vertexBuffer.length;
    var buffer = _vertexBuffer;

    if (offset + 2 > length) {
      var extend = length;
      if (extend < 16) extend = 16;
      if (extend > 256) extend = 256;
      _vertexBuffer = new Float32List(length + extend);
      _vertexBuffer.setAll(0, buffer);
    }

    _minX = _minX > x ? x : _minX;
    _minY = _minY > y ? y : _minY;
    _maxX = _maxX < x ? x : _maxX;
    _maxY = _maxY < y ? y : _maxY;

    _vertexBuffer[offset + 0] = x;
    _vertexBuffer[offset + 1] = y;
    return _vertexCount++;
  }

  //---------------------------------------------------------------------------

  void addIndices(int index1, int index2, int index3) {

    var offset = _indexCount;
    var length = _indexBuffer.length;
    var buffer = _indexBuffer;

    if (offset + 3 > length) {
      var extend = length;
      if (extend < 32) extend = 32;
      if (extend > 256) extend = 256;
      _indexBuffer = new Int16List(length + extend);
      _indexBuffer.setAll(0, buffer);
    }

    _indexBuffer[offset + 0] = index1;
    _indexBuffer[offset + 1] = index2;
    _indexBuffer[offset + 2] = index3;
    _indexCount += 3;
  }

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {
    var ixList = new Int16List.view(_indexBuffer.buffer, 0, _indexCount);
    var vxList = new Float32List.view(_vertexBuffer.buffer, 0, _vertexCount * 2);
    renderState.renderTriangleMesh(ixList, vxList, color);
  }

  //---------------------------------------------------------------------------

  void fillGradient(RenderState renderState, GraphicsGradient gradient) {

    var ixList = new Int16List.view(_indexBuffer.buffer, 0, _indexCount);
    var vxList = new Float32List.view(_vertexBuffer.buffer, 0, _vertexCount * 2);
    var renderContext = renderState.renderContext as RenderContextWebGL;
    var renderTexture = gradient.getRenderTexture();

    _GraphicsGradientProgram renderProgram;

    if (gradient.type == GraphicsGradientType.Linear) {
      renderProgram = renderContext.getRenderProgram(
          r"$LinearGraphicsGradientProgram", () => new _LinearGraphicsGradientProgram());
    }

    if (gradient.type == GraphicsGradientType.Radial) {
      renderProgram = renderContext.getRenderProgram(
          r"$RadialGraphicsGradientProgram", () => new _RadialGraphicsGradientProgram());
    }

    if (renderProgram.activeGradient != gradient) {
      renderProgram.activeGradient = gradient;
      renderProgram.flush();
    }

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateBlendMode(renderState.globalBlendMode);
    renderContext.activateRenderTexture(renderTexture);
    renderProgram.configure(renderState, gradient);
    renderProgram.renderGradient(renderState, ixList, vxList);
  }

  //---------------------------------------------------------------------------

  void fillPattern(RenderState renderState, GraphicsPattern pattern) {

    var matrix = _tmpMatrix;
    var texture = pattern.patternTexture;
    var invWidth = 1.0 / texture.width;
    var invHeight = 1.0 / texture.height;

    texture.wrappingX = pattern.type.wrappingX;
    texture.wrappingY = pattern.type.wrappingY;

    if (pattern.matrix != null) {
      matrix.copyFromAndInvert(pattern.matrix);
      matrix.scale(invWidth, invHeight);
    } else {
      matrix.setTo(invWidth, 0.0, 0.0, invHeight, 0.0, 0.0);
    }

    var ixList = new Int16List.view(_indexBuffer.buffer, 0, _indexCount);
    var vxList = new Float32List.view(_vertexBuffer.buffer, 0, _vertexCount * 2);
    renderState.renderTextureMapping(texture, matrix, ixList, vxList);
  }

}
