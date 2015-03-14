library stagexl.filters.chroma_key;

import 'dart:html' show ImageData;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/tools.dart';

/// This filter provide a simple ChromaKey solution
///  that can be aplied on bitmap or video
///
/// <int> backgroundColor
/// @represent : the color you want to make transparent
/// @default : 0xFF00FF00 > pure green
///
/// <int> solidThreshold
/// @represent : this minimal diference for a color to be consider solid
/// @default : 140
/// @range : 0 <> 255
///
/// <int> invisibleThreshold
/// @represent : this minimal similarity for a color to be consider completely invisible
/// @default : 15
/// @range : 0 <> 255
///
///
///
/// play with the solidThreshold and invisibleThreshold
/// to have the best possible result for you image
///

class ChromaKeyFilter extends BitmapFilter {

  int _backgroundColor;
  int _solidThreshold;
  int _invisibleThreshold;

  ChromaKeyFilter({
    int backgroundColor: 0xFF00FF00,
    int solidThreshold: 140,
    int invisibleThreshold: 20}) {

    if (invisibleThreshold < 0) {
      throw new ArgumentError("The minimum solidThreshold is 0.");
    }
    if (solidThreshold < invisibleThreshold) {
      throw new ArgumentError("solidThreshold cannot be lower than invisibleThreshold");
    }

    _backgroundColor = backgroundColor;
    _solidThreshold = solidThreshold;
    _invisibleThreshold = invisibleThreshold;
  }

  int get backgroundColor => _backgroundColor;
  int get solidThreshold => _solidThreshold;
  int get invisibleThreshold => _invisibleThreshold;

  void set backgroundColor (int backgroundColor) {
    _backgroundColor = backgroundColor;
  }

  void set solidThreshold (int solidThreshold) {
    if (solidThreshold < _invisibleThreshold) {
      throw new ArgumentError("solidThreshold cannot be lower than _invisibleThreshold");
    }
    _solidThreshold = solidThreshold;
  }

  void set invisibleThreshold (int invisibleThreshold) {
    if (invisibleThreshold < 0) {
      throw new ArgumentError("The minimum solidThreshold is 0.");
    }
    _invisibleThreshold = invisibleThreshold;
  }

  BitmapFilter clone() => new ChromaKeyFilter(
      backgroundColor: _backgroundColor,
      solidThreshold: _solidThreshold,
      invisibleThreshold: _invisibleThreshold);

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    // this filter is only WebGL compliant
    renderTextureQuad.putImageData(imageData);
  }

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    ChromaKeyFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$ChromaKeyFilterProgram", () => new ChromaKeyFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);
    renderProgram.configure(backgroundColor, solidThreshold, invisibleThreshold);
    renderProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class ChromaKeyFilterProgram extends BitmapFilterProgram {

  String get fragmentShaderSource =>  """
      precision mediump float;
      uniform sampler2D uSampler;
      varying vec2 vTextCoord;

      uniform vec4 backgroundColor;
      uniform float solidThreshold;
      uniform float invisibleThreshold;

      uniform float weight;

      void main() {
        // -- get pixel color
        vec4 pixelColor = texture2D(uSampler, vTextCoord);

        // -- calcul diference betwen chroma key color and actual pixelColor
        float redDiff = abs(pixelColor.r - backgroundColor.r);
        float greenDiff = abs(pixelColor.g - backgroundColor.g);
        float blueDiff = abs(pixelColor.b - backgroundColor.b);

        // is pixel close enouph to chroma key to be fully invisible
        bool rCanBeInvisible = redDiff < invisibleThreshold;
        bool gCanBeInvisible = greenDiff < invisibleThreshold;
        bool bCanBeInvisible = blueDiff < invisibleThreshold;

        // is pixel different enouph to chroma key to be fully visible
        bool rCanBeSolid = redDiff > solidThreshold;
        bool gCanBeSolid = greenDiff > solidThreshold;
        bool bCanBeSolid = blueDiff > solidThreshold;

        if (rCanBeSolid || gCanBeSolid || bCanBeSolid) {
          gl_FragColor = pixelColor;

        } else if (rCanBeInvisible && gCanBeInvisible && bCanBeInvisible) {
          gl_FragColor = pixelColor * 0.0;

        } else {
          // semi transparent color
          float alpha = 1.0;

          // try tyo calculate the alpha as cloase as possible
          float rAlpha = clamp((redDiff - invisibleThreshold) / (solidThreshold - invisibleThreshold), 0.0, 1.0);
          float gAlpha = clamp((greenDiff - invisibleThreshold) / (solidThreshold - invisibleThreshold), 0.0, 1.0);
          float bAlpha = clamp((blueDiff - invisibleThreshold) / (solidThreshold - invisibleThreshold), 0.0, 1.0);

          alpha = min(rAlpha, gAlpha);
          alpha = min(bAlpha, alpha);

          // try to ge back the original color
          float red = pixelColor.r - (1.0 - redDiff) * (1.0 - alpha) * backgroundColor.r * weight;
          float green = pixelColor.g - (1.0 - greenDiff) * (1.0 - alpha) * backgroundColor.g * weight;
          float blue = pixelColor.b - (1.0 - blueDiff) * (1.0 - alpha) * backgroundColor.b * weight;

          gl_FragColor = vec4(red, green, blue, alpha);
        }
      }
      """;

  void configure(int backgroundColor, int solidThreshold, int invisibleThreshold) {
    num r = colorGetR(backgroundColor) / 255.0;
    num g = colorGetG(backgroundColor) / 255.0;
    num b = colorGetB(backgroundColor) / 255.0;

    renderingContext.uniform4f(uniforms["backgroundColor"], r, g, b, 1.0);

    renderingContext.uniform1f(uniforms["solidThreshold"], solidThreshold / 255.0);
    renderingContext.uniform1f(uniforms["invisibleThreshold"], invisibleThreshold / 255.0);

    // this affect the color corection on semi transparent pixel, for now not public
    // it is quite experimental
    renderingContext.uniform1f(uniforms["weight"], 0.8);
  }
}
