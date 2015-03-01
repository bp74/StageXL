library stagexl.filters.normal_map;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:web_gl' as gl;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../ui/color.dart';
import '../internal/tools.dart';

class NormalMapFilter extends BitmapFilter {

  final BitmapData bitmapData;

  int ambientColor = Color.White;
  int lightColor = Color.White;

  num lightX = 0.0;
  num lightY = 0.0;
  num lightZ = 50.0;
  num lightRadius = 100;

  NormalMapFilter(this.bitmapData);

  BitmapFilter clone() => new NormalMapFilter(bitmapData);

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {
    // TODO: implement NormalMapFilter for BitmapDatas.
  }

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    NormalMapFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$NormalMapFilterProgram", () => new NormalMapFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTextureAt(renderTexture, 0);
    renderContext.activateRenderTextureAt(bitmapData.renderTexture, 1);
    renderProgram.renderNormalMapQuad(renderState, renderTextureQuad, this);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class NormalMapFilterProgram extends RenderProgram {

  // attenuation calculation
  // http://gamedev.stackexchange.com/questions/56897/glsl-light-attenuation-color-and-intensity-formula
  // https://www.desmos.com/calculator/nmnaud1hrw
  // https://www.desmos.com/calculator/kp89d5khyb

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTexCoord;
    attribute vec2 aVertexMapCoord;
    attribute vec4 aVertexAmbientColor;
    attribute vec4 aVertexLightColor;
    attribute vec4 aVertexLightCoord;
    attribute float aVertexAlpha;

    varying vec2 vTexCoord;
    varying vec2 vMapCoord;
    varying vec4 vAmbientColor;
    varying vec4 vLightColor;
    varying vec4 vLightCoord;
    varying float vAlpha;

    void main() {
      vTexCoord = aVertexTexCoord;
      vMapCoord = aVertexMapCoord;
      vAmbientColor = aVertexAmbientColor;
      vLightColor = aVertexLightColor;
      vLightCoord = aVertexLightCoord;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

      precision mediump float;
      uniform sampler2D uTexSampler;
      uniform sampler2D uMapSampler;

      varying vec2 vTexCoord;
      varying vec2 vMapCoord;
      varying vec4 vAmbientColor;
      varying vec4 vLightColor;
      varying vec4 vLightCoord;
      varying float vAlpha;

      void main() {

        // Texture color and map color/vector/normal 
        vec4 texColor = texture2D(uTexSampler, vTexCoord.xy);
        vec4 mapColor = texture2D(uMapSampler, vMapCoord.xy);
        vec3 mapVector = vec3(mapColor.r, 1.0 - mapColor.g, mapColor.b);
        vec3 mapNormal = normalize(mapVector * 2.0 - 1.0);

        // Position of light relative to texture coordinates
        vec3 lightDelta = vec3(vLightCoord.xy - vTexCoord.xy, vLightCoord.z);
        vec3 lightNormal = normalize(lightDelta);
        
        // Calculate diffuse and ambient color
        float diffuse = max(dot(mapNormal, lightNormal), 0.0);
        vec3 diffuseColor = vLightColor.rgb * vLightColor.a * diffuse;
        vec3 ambientColor = vAmbientColor.rgb * vAmbientColor.a;
      
        // Calculate attenuation
        float distance = length(lightDelta.xy);
        float radius = vLightCoord.w;
        float temp = clamp(1.0 - (distance * distance) / (radius * radius), 0.0, 1.0); 
        float attenuation = temp * temp;

        // Get the final color
        vec3 color = texColor.rgb * (ambientColor + diffuseColor * attenuation);
        gl_FragColor = vec4(color.rgb, texColor.a) * vAlpha;
      }
      """;

  //---------------------------------------------------------------------------
  // aVertexPosition:      Float32(x), Float32(y)
  // aVertexTexCoord:      Float32(u), Float32(v)
  // aVertexMapCoord:      Float32(v), Float32(v)
  // aVertexAmbientColor:  Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexLightColor:    Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexLightCoord:    Float32(x), Float32(y), Float32(z), Float32(r)
  // aVertexAlpha:         Float32(a)
  //---------------------------------------------------------------------------

  Int16List _indexList;
  Float32List _vertexList;

  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;
  gl.UniformLocation _uProjectionMatrixLocation;
  gl.UniformLocation _uTexSamplerLocation;
  gl.UniformLocation _uMapSamplerLocation;

  int _aVertexPositionLocation = 0;
  int _aVertexTexCoordLocation = 0;
  int _aVertexMapCoordLocation = 0;
  int _aVertexAmbientColor = 0;
  int _aVertexLightColor = 0;
  int _aVertexLightCoord = 0;
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

      _uProjectionMatrixLocation = uniformLocations["uProjectionMatrix"];
      _uTexSamplerLocation = uniformLocations["uTexSampler"];
      _uMapSamplerLocation = uniformLocations["uMapSampler"];

      _aVertexPositionLocation = attributeLocations["aVertexPosition"];
      _aVertexTexCoordLocation = attributeLocations["aVertexTexCoord"];
      _aVertexMapCoordLocation = attributeLocations["aVertexMapCoord"];
      _aVertexAmbientColor     = attributeLocations["aVertexAmbientColor"];
      _aVertexLightColor       = attributeLocations["aVertexLightColor"];
      _aVertexLightCoord       = attributeLocations["aVertexLightCoord"];
      _aVertexAlphaLocation    = attributeLocations["aVertexAlpha"];

      renderingContext.enableVertexAttribArray(_aVertexPositionLocation);
      renderingContext.enableVertexAttribArray(_aVertexTexCoordLocation);
      renderingContext.enableVertexAttribArray(_aVertexMapCoordLocation);
      renderingContext.enableVertexAttribArray(_aVertexAmbientColor);
      renderingContext.enableVertexAttribArray(_aVertexLightColor);
      renderingContext.enableVertexAttribArray(_aVertexLightCoord);
      renderingContext.enableVertexAttribArray(_aVertexAlphaLocation);

      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.uniform1i(_uTexSamplerLocation, 0);
    renderingContext.uniform1i(_uMapSamplerLocation, 1);

    renderingContext.vertexAttribPointer(_aVertexPositionLocation, 2, gl.FLOAT, false, 76,  0);
    renderingContext.vertexAttribPointer(_aVertexTexCoordLocation, 2, gl.FLOAT, false, 76,  8);
    renderingContext.vertexAttribPointer(_aVertexMapCoordLocation, 2, gl.FLOAT, false, 76, 16);
    renderingContext.vertexAttribPointer(_aVertexAmbientColor,     4, gl.FLOAT, false, 76, 24);
    renderingContext.vertexAttribPointer(_aVertexLightColor,       4, gl.FLOAT, false, 76, 40);
    renderingContext.vertexAttribPointer(_aVertexLightCoord,       4, gl.FLOAT, false, 76, 56);
    renderingContext.vertexAttribPointer(_aVertexAlphaLocation,    1, gl.FLOAT, false, 76, 72);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 19);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderNormalMapQuad(RenderState renderState,
                           RenderTextureQuad renderTextureQuad,
                           NormalMapFilter normalMapFilter) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

    Matrix texMatrix = renderTextureQuad.samplerMatrix;
    Matrix mapMatrix = normalMapFilter.bitmapData.renderTextureQuad.samplerMatrix;
    Matrix tmpMatrix = new Matrix.fromIdentity();

    tmpMatrix.copyFromAndInvert(texMatrix);
    tmpMatrix.concat(mapMatrix);

    // vertex positions

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

    // Ambient color,  light color, light position

    num ambientColor = normalMapFilter.ambientColor;
    num ambientR = colorGetA(ambientColor) / 255.0;
    num ambientG = colorGetR(ambientColor) / 255.0;
    num ambientB = colorGetG(ambientColor) / 255.0;
    num ambientA = colorGetB(ambientColor) / 255.0;

    num lightColor = normalMapFilter.lightColor;
    num lightR = colorGetA(lightColor) / 255.0;
    num lightG = colorGetR(lightColor) / 255.0;
    num lightB = colorGetG(lightColor) / 255.0;
    num lightA = colorGetB(lightColor) / 255.0;

    num lx = normalMapFilter.lightX;
    num ly = normalMapFilter.lightY;
    num lightX = texMatrix.tx + lx * texMatrix.a + ly * texMatrix.c;
    num lightY = texMatrix.ty + lx * texMatrix.b + ly * texMatrix.d;
    num lightZ =  math.sqrt(texMatrix.det) * normalMapFilter.lightZ;
    num lightRadius = math.sqrt(texMatrix.det) * normalMapFilter.lightRadius;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixList = _indexList;
    if (ixList == null) return;
    if (ixList.length < _quadCount * 6 + 6) flush();

    var vxList = _vertexList;
    if (vxList == null) return;
    if (vxList.length < _quadCount * 76 + 76) flush();

    var index = _quadCount * 76;
    if (index > vxList.length - 76) return;

    vxList[index + 00] = ox;
    vxList[index + 01] = oy;
    vxList[index + 19] = ox + ax;
    vxList[index + 20] = oy + bx;
    vxList[index + 38] = ox + ax + cy;
    vxList[index + 39] = oy + bx + dy;
    vxList[index + 57] = ox + cy;
    vxList[index + 58] = oy + dy;

    for(int i = 0; i < 4; i++, index += 19) {

      if (index > vxList.length - 19) return;

      num texU = uvList[i + i + 0];
      num texV = uvList[i + i + 1];
      num mapU = tmpMatrix.tx + texU * tmpMatrix.a + texV * tmpMatrix.c;
      num mapV = tmpMatrix.ty + texU * tmpMatrix.b + texV * tmpMatrix.d;

      vxList[index + 02] = texU;
      vxList[index + 03] = texV;
      vxList[index + 04] = mapU;
      vxList[index + 05] = mapV;
      vxList[index + 06] = ambientR;
      vxList[index + 07] = ambientG;
      vxList[index + 08] = ambientB;
      vxList[index + 09] = ambientA;
      vxList[index + 10] = lightR;
      vxList[index + 11] = lightG;
      vxList[index + 12] = lightB;
      vxList[index + 13] = lightA;
      vxList[index + 14] = lightX;
      vxList[index + 15] = lightY;
      vxList[index + 16] = lightZ;
      vxList[index + 17] = lightRadius;
      vxList[index + 18] = alpha;
    }

    _quadCount += 1;
  }
}

