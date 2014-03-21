part of stagexl;

class ColorMatrixFilter extends BitmapFilter {

  Float32List _colorMatrixList = new Float32List(16);
  Float32List _colorOffsetList = new Float32List(4);

  final num _lumaR = 0.213;
  final num _lumaG = 0.715;
  final num _lumaB = 0.072;

  ColorMatrixFilter(List<num> colorMatrix, List<num> colorOffset) {

    if (colorMatrix.length != 16) throw new ArgumentError("colorMatrix");
    if (colorOffset.length != 4) throw new ArgumentError("colorOffset");

    for(int i = 0; i < colorMatrix.length; i++) {
      _colorMatrixList[i] = colorMatrix[i].toDouble();
    }

    for(int i = 0; i < colorOffset.length; i++) {
      _colorOffsetList[i] = colorOffset[i].toDouble();
    }
  }

  ColorMatrixFilter.grayscale() : this(
      [0.213, 0.715, 0.072, 0, 0.213, 0.715, 0.072, 0, 0.213, 0.715, 0.072, 0, 0, 0, 0, 1],
      [0, 0, 0, 0]);

  ColorMatrixFilter.invert() : this(
      [-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1],
      [255, 255, 255, 0]);

  ColorMatrixFilter.identity() : this(
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [0, 0, 0, 0]);

  factory ColorMatrixFilter.adjust({num hue: 0, num saturation: 0, num brightness: 0, num contrast: 0}) {
    var colorMatrixFilter = new ColorMatrixFilter.identity();
    colorMatrixFilter.adjustHue(hue);
    colorMatrixFilter.adjustSaturation(saturation);
    colorMatrixFilter.adjustBrightness(brightness);
    colorMatrixFilter.adjustContrast(contrast);
    return colorMatrixFilter;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapFilter clone() => new ColorMatrixFilter(_colorMatrixList, _colorOffsetList);

  //-------------------------------------------------------------------------------------------------

  void adjustInversion(num value) {

    _concat([-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1], [255, 255, 255, 0]);
  }

  void adjustHue(num value) {

    num v = min(max(value, -1), 1) * PI;
    num cv = cos(v);
    num sv = sin(v);

    _concat([
        _lumaR - cv * _lumaR - sv * _lumaR + cv,
        _lumaG - cv * _lumaG - sv * _lumaG,
        _lumaB - cv * _lumaB - sv * _lumaB + sv, 0,
        _lumaR - cv * _lumaR + sv * 0.143,
        _lumaG - cv * _lumaG + sv * 0.140 + cv,
        _lumaB - cv * _lumaB - sv * 0.283, 0,
        _lumaR - cv * _lumaR + sv * _lumaR - sv,
        _lumaG - cv * _lumaG + sv * _lumaG,
        _lumaB - cv * _lumaB + sv * _lumaB + cv, 0,
        0, 0, 0, 1], [0, 0, 0, 0]);
  }

  void adjustSaturation(num value) {

    num v = min(max(value, -1), 1) + 1;
    num i = 1 - v;
    num r = i * _lumaR;
    num g = i * _lumaG;
    num b = i * _lumaB;

    _concat( [r + v, g, b, 0, r, g + v, b, 0, r, g, b + v, 0, 0, 0, 0, 1], [0, 0, 0, 0]);
  }

  void adjustContrast(num value) {

    num v = min(max(value, -1), 1) + 1;
    num o = 128 * (1 - v);

    _concat([v, 0, 0, 0, 0, v, 0, 0, 0, 0, v, 0, 0, 0, 0, v], [o, o, o, 0]);
  }

  void adjustBrightness(num value) {

    num v = 255 * min(max(value, -1), 1);

    _concat([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [v, v, v, 0]);
  }

  void adjustColoration(int color, [num strength = 1.0]) {

    num r = _colorGetR(color) * strength / 255.0;
    num g = _colorGetG(color) * strength / 255.0;
    num b = _colorGetB(color) * strength / 255.0;
    num i = 1.0 - strength;

    _concat([
        r * _lumaR + i, r * _lumaG, r * _lumaB, 0.0,
        g * _lumaR, g * _lumaG + i, g * _lumaB, 0.0,
        b * _lumaR, b * _lumaG, b * _lumaB + i, 0.0,
        0.0, 0.0, 0.0, 1.0], [0, 0, 0, 0]);
  }

  //-------------------------------------------------------------------------------------------------

  void _concat(List<num> colorMatrix, List<num> colorOffset) {

    var newColorMatrix = new Float32List(16);
    var newColorOffset = new Float32List(4);

    for (var y = 0, i = 0; y < 4; y++, i += 4) {

      if (i > 12) continue; // dart2js_hint

      for (var x = 0; x < 4; ++x) {
        newColorMatrix[i + x] =
          colorMatrix[i + 0] * _colorMatrixList[x +  0] +
          colorMatrix[i + 1] * _colorMatrixList[x +  4] +
          colorMatrix[i + 2] * _colorMatrixList[x +  8] +
          colorMatrix[i + 3] * _colorMatrixList[x + 12];
      }

      newColorOffset[y] =
          colorOffset[y    ] +
          colorMatrix[i + 0] * _colorOffsetList[0] +
          colorMatrix[i + 1] * _colorOffsetList[1] +
          colorMatrix[i + 2] * _colorOffsetList[2] +
          colorMatrix[i + 3] * _colorOffsetList[3];
    }

    _colorMatrixList = newColorMatrix;
    _colorOffsetList = newColorOffset;
  }

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    //dstR = (m[ 0] * srcR) + (m[ 1] * srcG) + (m[ 2] * srcB) + (m[ 3] * srcA) + o[0]
    //dstG = (m[ 4] * srcR) + (m[ 5] * srcG) + (m[ 6] * srcB) + (m[ 7] * srcA) + o[1]
    //dstB = (m[ 8] * srcR) + (m[ 9] * srcG) + (m[10] * srcB) + (m[11] * srcA) + o[2]
    //dstA = (m[12] * srcR) + (m[13] * srcG) + (m[14] * srcB) + (m[15] * srcA) + o[3]

    bool isLittleEndianSystem = BitmapDataChannel.isLittleEndianSystem;

    int d0c0 = (_colorMatrixList[isLittleEndianSystem ? 00 : 15] * 65536).round();
    int d0c1 = (_colorMatrixList[isLittleEndianSystem ? 01 : 14] * 65536).round();
    int d0c2 = (_colorMatrixList[isLittleEndianSystem ? 02 : 13] * 65536).round();
    int d0c3 = (_colorMatrixList[isLittleEndianSystem ? 03 : 12] * 65536).round();
    int d1c0 = (_colorMatrixList[isLittleEndianSystem ? 04 : 11] * 65536).round();
    int d1c1 = (_colorMatrixList[isLittleEndianSystem ? 05 : 10] * 65536).round();
    int d1c2 = (_colorMatrixList[isLittleEndianSystem ? 06 : 09] * 65536).round();
    int d1c3 = (_colorMatrixList[isLittleEndianSystem ? 07 : 08] * 65536).round();
    int d2c0 = (_colorMatrixList[isLittleEndianSystem ? 08 : 07] * 65536).round();
    int d2c1 = (_colorMatrixList[isLittleEndianSystem ? 09 : 06] * 65536).round();
    int d2c2 = (_colorMatrixList[isLittleEndianSystem ? 10 : 05] * 65536).round();
    int d2c3 = (_colorMatrixList[isLittleEndianSystem ? 11 : 04] * 65536).round();
    int d3c0 = (_colorMatrixList[isLittleEndianSystem ? 12 : 03] * 65536).round();
    int d3c1 = (_colorMatrixList[isLittleEndianSystem ? 13 : 02] * 65536).round();
    int d3c2 = (_colorMatrixList[isLittleEndianSystem ? 14 : 01] * 65536).round();
    int d3c3 = (_colorMatrixList[isLittleEndianSystem ? 15 : 00] * 65536).round();

    int d0cc = (_colorOffsetList[isLittleEndianSystem ? 00 : 03] * 65536).round();
    int d1cc = (_colorOffsetList[isLittleEndianSystem ? 01 : 02] * 65536).round();
    int d2cc = (_colorOffsetList[isLittleEndianSystem ? 02 : 01] * 65536).round();
    int d3cc = (_colorOffsetList[isLittleEndianSystem ? 03 : 00] * 65536).round();

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

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    _ColorMatrixProgram colorMatrixProgram = _ColorMatrixProgram.instance;

    renderContext.activateRenderProgram(colorMatrixProgram);
    renderContext.activateRenderTexture(renderTexture);
    colorMatrixProgram.configure(this);
    colorMatrixProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _ColorMatrixProgram extends _BitmapFilterProgram {

  static final _ColorMatrixProgram instance = new _ColorMatrixProgram();

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uSampler;
      uniform mat4 uColorMatrix;
      uniform vec4 uColorOffset;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        vec4 color = texture2D(uSampler, vTextCoord);
        color = vec4(color.rgb / (color.a + 0.001), color.a);
        color = (uColorOffset / 255.0) + color * uColorMatrix;
        color = vec4(color.rgb * color.a, color.a);
        gl_FragColor = color * vAlpha;
      }
      """;

  void configure(ColorMatrixFilter colorMatrixFilter) {
    var colorMatrixList = colorMatrixFilter._colorMatrixList;
    var colorOffsetList = colorMatrixFilter._colorOffsetList;
    var uColorMatrixLocation = _uniformLocations["uColorMatrix"];
    var uColorOffsetLocation = _uniformLocations["uColorOffset"];
    _renderingContext.uniformMatrix4fv(uColorMatrixLocation, false, colorMatrixList);
    _renderingContext.uniform4fv(uColorOffsetLocation, colorOffsetList);
  }
}
