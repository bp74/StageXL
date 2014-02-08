part of stagexl;

abstract class BitmapFilter {

  BitmapFilter clone();
  Rectangle get overlap;

  void apply(BitmapData bitmapData, [Rectangle rectangle]);

  //-----------------------------------------------------------------------------------------------

  static var _buffer = new List<int>.filled(1024, 0);

  //-----------------------------------------------------------------------------------------------

  _premultiplyAlpha(List<int> data) {

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 3];
        data[i + 0] = (data[i + 0] * alpha) ~/ 255;
        data[i + 1] = (data[i + 1] * alpha) ~/ 255;
        data[i + 2] = (data[i + 2] * alpha) ~/ 255;
      }
    } else {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 0];
        data[i + 1] = (data[i + 1] * alpha) ~/ 255;
        data[i + 2] = (data[i + 2] * alpha) ~/ 255;
        data[i + 3] = (data[i + 3] * alpha) ~/ 255;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _unpremultiplyAlpha(List<int> data) {

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 3];
        if (alpha > 0) {
          data[i + 0] = (data[i + 0] * 255) ~/ alpha;
          data[i + 1] = (data[i + 1] * 255) ~/ alpha;
          data[i + 2] = (data[i + 2] * 255) ~/ alpha;
        }
      }
    } else {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 0];
        if (alpha > 0) {
          data[i + 1] = (data[i + 1] * 255) ~/ alpha;
          data[i + 2] = (data[i + 2] * 255) ~/ alpha;
          data[i + 3] = (data[i + 3] * 255) ~/ alpha;
        }
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _clearChannel(List<int> data, int offset, int length) {
    int offsetStart = offset;
    int offsetEnd = offset + length * 4 - 4;
    if (offsetStart < 0) throw new RangeError(offsetStart);
    if (offsetEnd >= data.length) throw new RangeError(offsetEnd);
    for(int i = offsetStart; i <= offsetEnd; i += 4) {
      data[i] = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  _shiftChannel(List<int> data, int channel, int width, int height, int shiftX, int shiftY) {

    if (channel < 0) throw new ArgumentError();
    if (channel > 3) throw new ArgumentError();
    if (shiftX == 0 && shiftY == 0) return;

    if (shiftX.abs() >= width || shiftY.abs() >= height) {
      _clearChannel(data, channel, width * height);
      return;
    }

    if (shiftX + width * shiftY < 0) {
      int dst = channel;
      int src = channel - 4 * (shiftX + width * shiftY);
      for(; src < data.length; src += 4, dst += 4) data[dst] = data[src];
    } else {
      int dst = data.length + channel - 4;
      int src = data.length + channel - 4 * (shiftX + width * shiftY);
      for(; src >= 0; src -= 4, dst -= 4) data[dst] = data[src];
    }

    for(int y = 0; y < height; y++) {
      if (y < shiftY || y >= height + shiftY) {
        _clearChannel(data, (y * width) * 4 + channel, width);
      } else if (shiftX > 0) {
        _clearChannel(data, (y * width) * 4 + channel, shiftX);
      } else if (shiftX < 0) {
        _clearChannel(data, (y * width + width + shiftX) * 4 + channel, 0 - shiftX);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _blur2(List<int> data, int offset, int length, int stride, int radius) {

    int weight = radius * radius;
    int weightInv = (1 << 22) ~/ weight;
    int sum = weight ~/ 2;
    int dif = 0;
    int offsetSource = offset;
    int offsetDestination = offset;
    int radius1 = radius * 1;
    int radius2 = radius * 2;

    List<int> buffer = _buffer;

    for (int i = 0; i < length + radius1; i++) {

      if (i >= radius1) {
        data[offsetDestination] = ((sum * weightInv) | 0) >> 22;
        offsetDestination += stride;
        if (i >= radius2) {
          dif -= 2 * buffer[i & 1023] - buffer[(i - radius1) & 1023];
        } else {
          dif -= 2 * buffer[i & 1023];
        }
      }

      if (i < length) {
        int value = data[offsetSource];
        offsetSource += stride;
        buffer[(i + radius1) & 1023] = value;
        sum += dif += value;
      } else {
        buffer[(i + radius1) & 1023] = 0;
        sum += dif;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _setColor(List<int> data, int color, num alpha) {

    int rColor = _colorGetR(color);
    int gColor = _colorGetG(color);
    int bColor = _colorGetB(color);
    int alpha256 = (alpha * 256).toInt();

    if (_isLittleEndianSystem) {
      for(var i = 0; i <= data.length - 4; i += 4) {
        data[i + 0] = rColor;
        data[i + 1] = gColor;
        data[i + 2] = bColor;
        data[i + 3] = (data[i + 3] * alpha256 | 0) >> 8;
      }
    } else {
      for(var i = 0; i <= data.length - 4; i += 4) {
        data[i + 0] = (data[i + 0] * alpha256 | 0) >> 8;
        data[i + 1] = bColor;
        data[i + 2] = gColor;
        data[i + 3] = rColor;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _blend(List<int> dstData, List<int> srcData) {

    if (dstData.length != srcData.length) return;

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 3];
        int dstA = dstData[i + 3];
        int srcAX = srcA * 255;
        int dstAX = dstA * (255 - srcA);
        int outAX = srcAX + dstAX;
        if (outAX > 0) {
          dstData[i + 0] = (srcData[i + 0] * srcAX + dstData[i + 0] * dstAX) ~/ outAX;
          dstData[i + 1] = (srcData[i + 1] * srcAX + dstData[i + 1] * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + dstData[i + 2] * dstAX) ~/ outAX;
          dstData[i + 3] = outAX ~/ 255;
        }
      }
    } else {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 0];
        int dstA = dstData[i + 0];
        int srcAX = srcA * 255;
        int dstAX = dstA * (255 - srcA);
        int outAX = srcAX + dstAX;
        if (outAX > 0) {
          dstData[i + 0] = outAX ~/ 255;
          dstData[i + 1] = (srcData[i + 1] * srcAX + dstData[i + 1] * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + dstData[i + 2] * dstAX) ~/ outAX;
          dstData[i + 3] = (srcData[i + 3] * srcAX + dstData[i + 3] * dstAX) ~/ outAX;
        }
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _knockout(List<int> dstData, List<int> srcData) {

    if (dstData.length != srcData.length) return;

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 3] = dstData[i + 3] * (255 - srcData[i + 3]) ~/ 255;
      }
    } else {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 0] = dstData[i + 0] * (255 - srcData[i + 0]) ~/ 255;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _setColorBlend(List<int> dstData, int color, num alpha, List<int> srcData) {

    // optimized version for:
    //   _setColor(data, this.color, this.alpha);
    //   _blend(data, sourceImageData.data);

    if (dstData.length != srcData.length) return;

    int rColor = _colorGetR(color);
    int gColor = _colorGetG(color);
    int bColor = _colorGetB(color);
    int alpha256 = (alpha * 256).toInt();

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 3];
        int dstA = dstData[i + 3];
        int srcAX = (srcA * 255);
        int dstAX = (dstA * (255 - srcA) * alpha256 | 0) >> 8;
        int outAX = (srcAX + dstAX);
        if (outAX > 0) {
          dstData[i + 0] = (srcData[i + 0] * srcAX + rColor * dstAX) ~/ outAX;
          dstData[i + 1] = (srcData[i + 1] * srcAX + gColor * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + bColor * dstAX) ~/ outAX;
          dstData[i + 3] = outAX ~/ 255;
        } else {
          dstData[i + 3] = 0;
        }
      }
    } else {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 0];
        int dstA = dstData[i + 0];
        int srcAX = (srcA * 255);
        int dstAX = (dstA * (255 - srcA) * alpha256 | 0) >> 8;
        int outAX = (srcAX + dstAX);
        if (outAX > 0) {
          dstData[i + 0] = outAX ~/ 255;
          dstData[i + 1] = (srcData[i + 1] * srcAX + bColor * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + gColor * dstAX) ~/ outAX;
          dstData[i + 3] = (srcData[i + 3] * srcAX + rColor * dstAX) ~/ outAX;
        } else {
          dstData[i + 0] = 0;
        }
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _setColorKnockout(List<int> dstData, int color, num alpha, List<int> srcData) {

    // optimized version for:
    //   _setColor(data, this.color, this.alpha);
    //   _knockout(data, sourceImageData.data);

    if (dstData.length != srcData.length) return;

    int rColor = _colorGetR(color);
    int gColor = _colorGetG(color);
    int bColor = _colorGetB(color);
    int alpha256 = (alpha * 256).toInt();

    if (_isLittleEndianSystem) {
      for(var i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 0] = rColor;
        dstData[i + 1] = gColor;
        dstData[i + 2] = bColor;
        dstData[i + 3] = (alpha256 * dstData[i + 3] * (255 - srcData[i + 3]) | 0) ~/ (255 * 256);
      }
    } else {
      for(var i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 0] = (alpha256 * dstData[i + 0] * (255 - srcData[i + 0]) | 0) ~/ (255 * 256);
        dstData[i + 1] = bColor;
        dstData[i + 2] = gColor;
        dstData[i + 3] = rColor;
      }
    }
  }

}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _BitmapFilterRenderProgram extends RenderProgram {

  var _vertexShaderSource = """
      attribute vec2 aVertexPosition;
      attribute vec2 aVertexTextCoord;
      varying vec2 vTextCoord;
      void main() {
        vTextCoord = aVertexTextCoord;
        gl_Position = vec4(aVertexPosition, 0.0, 1.0);
      }
      """;

  var _fragmentShaderSource = """
      precision mediump float;
      uniform sampler2D uSampler;
      varying vec2 vTextCoord;
      void main() {
        gl_FragColor = texture2D(uSampler, vTextCoord);
      }
      """;

  gl.RenderingContext _renderingContext;
  gl.Program _program;
  gl.Buffer _vertexBuffer;

  StreamSubscription _contextRestoredSubscription;

  final Float32List _vertexList = new Float32List(4 * 4);
  final Map<String, gl.UniformLocation> _uniformLocations = new Map<String, gl.UniformLocation>();
  final Map<String, int> _attribLocations = new Map<String, int>();

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (_program == null) {

      if (_renderingContext == null) {
        _renderingContext = renderContext.rawContext;
        _contextRestoredSubscription = renderContext.onContextRestored.listen(_onContextRestored);
      }

      _program = createProgram(_renderingContext, _vertexShaderSource, _fragmentShaderSource);

      int activeAttributes = _renderingContext.getProgramParameter(_program, gl.ACTIVE_ATTRIBUTES);

      for(int index = 0; index < activeAttributes; index++) {
        var activeInfo = _renderingContext.getActiveAttrib(_program, index);
        var location = _renderingContext.getAttribLocation(_program, activeInfo.name);
        _attribLocations[activeInfo.name] = location;
      }

      int activeUniforms = _renderingContext.getProgramParameter(_program, gl.ACTIVE_UNIFORMS);

      for(int index = 0; index < activeUniforms; index++) {
        var activeInfo = _renderingContext.getActiveUniform(_program, index);
        var location = _renderingContext.getUniformLocation(_program, activeInfo.name);
        _uniformLocations[activeInfo.name] = location;
      }

      _renderingContext.enableVertexAttribArray(_attribLocations["aVertexPosition"]);
      _renderingContext.enableVertexAttribArray(_attribLocations["aVertexTextCoord"]);

      _vertexBuffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      _renderingContext.bufferData(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    _renderingContext.useProgram(_program);
    _renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    _renderingContext.vertexAttribPointer(_attribLocations["aVertexPosition"], 2, gl.FLOAT, false, 16, 0);
    _renderingContext.vertexAttribPointer(_attribLocations["aVertexTextCoord"], 2, gl.FLOAT, false, 16, 8);
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
    _vertexList[04] = ox + ax;
    _vertexList[05] = oy + bx;
    _vertexList[06] = uvList[2];
    _vertexList[07] = uvList[3];
    _vertexList[08] = ox + ax + cy;
    _vertexList[09] = oy + bx + dy;
    _vertexList[10] = uvList[4];
    _vertexList[11] = uvList[5];
    _vertexList[12] = ox + cy;
    _vertexList[13] = oy + dy;
    _vertexList[14] = uvList[6];
    _vertexList[15] = uvList[7];

    _renderingContext.bufferSubData(gl.ARRAY_BUFFER, 0, _vertexList);
    _renderingContext.drawArrays(gl.TRIANGLE_FAN, 0, 4);
  }

  void flush() {
  }

  _onContextRestored(Event e) {
    _program = null;
  }
}

