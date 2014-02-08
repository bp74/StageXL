part of stagexl;

class ColorMatrixFilter extends BitmapFilter {

  final List<num> _matrix = new List.filled(20, 0.0);

  ColorMatrixFilter(List<num> matrix) {
    if (matrix.length != 20) {
      throw new ArgumentError("The supplied matrix needs to be a 4 x 5 matrix.");
    }
    for(int i = 0; i < matrix.length; i++) {
      _matrix[i] = _ensureNum(matrix[i]).toDouble();
    }
  }

  ColorMatrixFilter.grayscale() : this([
    0.212671, 0.715160, 0.072169, 0, 0,
    0.212671, 0.715160, 0.072169, 0, 0,
    0.212671, 0.715160, 0.072169, 0, 0,
    0, 0, 0, 1, 0]);

  ColorMatrixFilter.invert() : this([
    -1,  0,  0, 0, 255,
     0, -1,  0, 0, 255,
     0,  0, -1, 0, 255,
     0,  0,  0, 1, 0]);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapFilter clone() => new ColorMatrixFilter(_matrix);
  Rectangle get overlap => new Rectangle(0, 0, 0, 0);

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {

    //redResult   = (a[0]  * srcR) + (a[1]  * srcG) + (a[2]  * srcB) + (a[3]  * srcA) + a[4]
    //greenResult = (a[5]  * srcR) + (a[6]  * srcG) + (a[7]  * srcB) + (a[8]  * srcA) + a[9]
    //blueResult  = (a[10] * srcR) + (a[11] * srcG) + (a[12] * srcB) + (a[13] * srcA) + a[14]
    //alphaResult = (a[15] * srcR) + (a[16] * srcG) + (a[17] * srcB) + (a[18] * srcA) + a[19]

    bool isLittleEndianSystem = _isLittleEndianSystem;

    int d0c0 = ((isLittleEndianSystem ? _matrix[00] : _matrix[18]) * 65536).round();
    int d0c1 = ((isLittleEndianSystem ? _matrix[01] : _matrix[17]) * 65536).round();
    int d0c2 = ((isLittleEndianSystem ? _matrix[02] : _matrix[16]) * 65536).round();
    int d0c3 = ((isLittleEndianSystem ? _matrix[03] : _matrix[15]) * 65536).round();
    int d0cc = ((isLittleEndianSystem ? _matrix[04] : _matrix[19]) * 65536).round();

    int d1c0 = ((isLittleEndianSystem ? _matrix[05] : _matrix[13]) * 65536).round();
    int d1c1 = ((isLittleEndianSystem ? _matrix[06] : _matrix[12]) * 65536).round();
    int d1c2 = ((isLittleEndianSystem ? _matrix[07] : _matrix[11]) * 65536).round();
    int d1c3 = ((isLittleEndianSystem ? _matrix[08] : _matrix[10]) * 65536).round();
    int d1cc = ((isLittleEndianSystem ? _matrix[09] : _matrix[14]) * 65536).round();

    int d2c0 = ((isLittleEndianSystem ? _matrix[10] : _matrix[08]) * 65536).round();
    int d2c1 = ((isLittleEndianSystem ? _matrix[11] : _matrix[07]) * 65536).round();
    int d2c2 = ((isLittleEndianSystem ? _matrix[12] : _matrix[06]) * 65536).round();
    int d2c3 = ((isLittleEndianSystem ? _matrix[13] : _matrix[05]) * 65536).round();
    int d2cc = ((isLittleEndianSystem ? _matrix[14] : _matrix[09]) * 65536).round();

    int d3c0 = ((isLittleEndianSystem ? _matrix[15] : _matrix[03]) * 65536).round();
    int d3c1 = ((isLittleEndianSystem ? _matrix[16] : _matrix[02]) * 65536).round();
    int d3c2 = ((isLittleEndianSystem ? _matrix[17] : _matrix[01]) * 65536).round();
    int d3c3 = ((isLittleEndianSystem ? _matrix[18] : _matrix[00]) * 65536).round();
    int d3cc = ((isLittleEndianSystem ? _matrix[19] : _matrix[04]) * 65536).round();

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;

    for(int index = 0 ; index <= data.length - 4; index += 4) {
      int c0 = data[index + 0];
      int c1 = data[index + 1];
      int c2 = data[index + 2];
      int c3 = data[index + 3];
      data[index + 0] = ((d0c0 * c0 + d0c1 * c1 + d0c2 * c2 + d0c3 * c3 + d0cc) | 0) >> 16;
      data[index + 1] = ((d1c0 * c0 + d1c1 * c1 + d1c2 * c2 + d1c3 * c3 + d1cc) | 0) >> 16;
      data[index + 2] = ((d2c0 * c0 + d2c1 * c1 + d2c2 * c2 + d2c3 * c3 + d2cc) | 0) >> 16;
      data[index + 3] = ((d3c0 * c0 + d3c1 * c1 + d3c2 * c2 + d3c3 * c3 + d3cc) | 0) >> 16;
    }

    renderTextureQuad.putImageData(imageData);
  }

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad) {
    RenderContextWebGL renderContext = renderState.renderContext;
    renderContext._updateState(_colorMatrixRenderProgram, renderTextureQuad.renderTexture);
    _colorMatrixRenderProgram.renderFilter(renderState, renderTextureQuad, this);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

var _colorMatrixRenderProgram = new _ColorMatrixRenderProgram();

class _ColorMatrixRenderProgram extends _BitmapFilterRenderProgram {

  var _fragmentShaderSource = """
      precision mediump float;
      uniform sampler2D uSampler;
      uniform mat4 uColorMatrix;
      uniform vec4 uColorOffset;
      varying vec2 vTextCoord;
      void main() {
        gl_FragColor = uColorOffset + texture2D(uSampler, vTextCoord) * uColorMatrix;
      }
      """;

  Float32List _colorMatrixList = new Float32List(16);
  Float32List _colorOffsetList = new Float32List(4);

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState,
                    RenderTextureQuad renderTextureQuad,
                    ColorMatrixFilter colorMatrixFilter) {

    List<num> colorMatrix = colorMatrixFilter._matrix;

    _colorMatrixList[00] = colorMatrix[00];
    _colorMatrixList[01] = colorMatrix[01];
    _colorMatrixList[02] = colorMatrix[02];
    _colorMatrixList[03] = colorMatrix[03];
    _colorMatrixList[04] = colorMatrix[05];
    _colorMatrixList[05] = colorMatrix[06];
    _colorMatrixList[06] = colorMatrix[07];
    _colorMatrixList[07] = colorMatrix[08];
    _colorMatrixList[08] = colorMatrix[10];
    _colorMatrixList[09] = colorMatrix[11];
    _colorMatrixList[10] = colorMatrix[12];
    _colorMatrixList[11] = colorMatrix[13];
    _colorMatrixList[12] = colorMatrix[15];
    _colorMatrixList[13] = colorMatrix[16];
    _colorMatrixList[14] = colorMatrix[17];
    _colorMatrixList[15] = colorMatrix[18];

    _colorOffsetList[00] = colorMatrix[04] / 255.0;
    _colorOffsetList[01] = colorMatrix[09] / 255.0;
    _colorOffsetList[02] = colorMatrix[14] / 255.0;
    _colorOffsetList[03] = colorMatrix[19] / 255.0;

    var uColorMatrixLocation = _uniformLocations["uColorMatrix"];
    var uColorOffsetLocation = _uniformLocations["uColorOffset"];

    _renderingContext.uniformMatrix4fv(uColorMatrixLocation, false, _colorMatrixList);
    _renderingContext.uniform4fv(uColorOffsetLocation, _colorOffsetList);

    super.renderQuad(renderState, renderTextureQuad);
  }
}
