part of stagexl.engine;

/// A class that provides constant values for visual blend mode effects.
class BlendMode {

  final int srcFactor;
  final int dstFactor;
  final String compositeOperation;

  const BlendMode(this.srcFactor, this.dstFactor, this.compositeOperation);

  /// The display object appears in front of the background. Pixel values of the 
  /// display object override those of the background. Where the display object 
  /// is transparent, the background is visible.
  static const NORMAL   = const BlendMode(gl.ONE, gl.ONE_MINUS_SRC_ALPHA, "source-over");
  
  /// Adds the values of the constituent colors of the display object to the 
  /// colors of its background, applying a ceiling of 0xFF. 
  /// 
  /// This setting is commonly used for animating a lightening dissolve between 
  /// two objects.
  /// 
  /// For example, if the display object has a pixel with an RGB value of 
  /// 0xAAA633, and the background pixel has an RGB value of 0xDD2200, the 
  /// resulting RGB value for the displayed pixel is 0xFFC833 (because 0xAA + 
  /// 0xDD > 0xFF, 0xA6 + 0x22 = 0xC8, and 0x33 + 0x00 = 0x33).
  static const ADD = const BlendMode(gl.ONE, gl.ONE, "lighter");
  
  /// Multiplies the values of the display object constituent colors by the 
  /// colors of the background color, and then normalizes by dividing by 0xFF, 
  /// resulting in darker colors. 
  /// 
  /// This setting is commonly used for shadows and depth effects.
  /// 
  /// For example, if a constituent color (such as red) of one pixel in the 
  /// display object and the corresponding color of the pixel in the background 
  /// both have the value 0x88, the multiplied result is 0x4840. Dividing by 
  /// 0xFF yields a value of 0x48 for that constituent color, which is a darker 
  /// shade than the color of the display object or the color of the background.
  static const MULTIPLY = const BlendMode(gl.DST_COLOR, gl.ONE_MINUS_SRC_ALPHA, "multiply");
  
  /// Multiplies the complement (inverse) of the display object color by the 
  /// complement of the background color, resulting in a bleaching effect. 
  /// 
  /// This setting is commonly used for highlights or to remove black areas of 
  /// the display object.
  static const SCREEN = const BlendMode(gl.ONE, gl.ONE_MINUS_SRC_COLOR, "screen");
  
  /// Erases the background based on the alpha value of the display object. 
  static const ERASE = const BlendMode(gl.ZERO, gl.ONE_MINUS_SRC_ALPHA, "destination-out");
  
  /// The display object appears in behind the background. Pixel values of the 
  /// background object override those of the display object. Where the 
  /// background is transparent, the display object is visible.
  static const BELOW = const BlendMode(gl.ONE_MINUS_DST_ALPHA, gl.ONE, "destination-over");
  
  /// The display object appears above the background. Pixel values of the 
  /// display object are invisible where the backround is transparent.
  static const ABOVE = const BlendMode(gl.DST_ALPHA, gl.ONE_MINUS_SRC_ALPHA, "source-atop");
  
  /// Works only in WebGL and may improve performance for big background images 
  /// withoug alpha. The source pixels are not blended with the destination 
  /// pixels and therefore the GPU does not read the color from the destination
  /// pixels.
  static const NONE = const BlendMode(gl.ONE, gl.ZERO, "source-over");
}
