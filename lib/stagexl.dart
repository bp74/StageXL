library stagexl;

//==========================================================
// StageXL Library Hierarchy (bottom-up)
//==========================================================
// display_ex, toolkit
//----------------------------------------------------------
// filters, resources, text
//----------------------------------------------------------
// display
//----------------------------------------------------------
// drawing
//----------------------------------------------------------
// engine, media
//----------------------------------------------------------
// events, animation, ui, geom.*, internal.*
//==========================================================

import 'src/display.dart';
import 'src/media.dart';
import 'src/internal/environment.dart' as env;

export 'src/animation.dart';
export 'src/display.dart';
export 'src/display_ex.dart';
export 'src/drawing.dart';
export 'src/engine.dart';
export 'src/events.dart';
export 'src/filters.dart';
export 'src/geom.dart';
export 'src/media.dart';
export 'src/resources.dart';
export 'src/text.dart';
export 'src/toolkit.dart';
export 'src/ui.dart';

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class StageXL {

  // TODO: Add pixelRatio config for stage, cache, textfield, ...

  /// The device pixel ratio is the ratio between physical pixels and
  /// logical pixels.
  ///
  /// For instance, the iPhone 4 and iPhone 4S reports a device pixel ratio
  /// of 2, because the physical linear resolution is double the logical
  /// resolution. The iPhone 6 reports a device pixel ratio of 3. Some
  /// devices may even report a device pixel ratio of 1.325 (Nexus 7 v1).

  static final num devicePixelRatio = env.devicePixelRatio;

  /// This flag indicates if the application is running on a mobile device.
  ///
  /// The user agent string of the browser is used to get this information.
  /// Therefore the flag may not be accurate on all devices.

  static final bool isMobileDevice = env.isMobileDevice;

  /// This flag indicates if the application is running on a device
  /// with a little endian CPU architecture.
  ///
  /// The method [RenderTextureQuad.getImageData] allows low level texture
  /// access and the RGBA value of each pixel is affected by the endianness
  /// of the CPU architecture. <http://en.wikipedia.org/wiki/Endianness>

  static final bool isLittleEndianSystem = env.isLittleEndianSystem;

  /// The default loader configuration for [BitmapData.load].
  ///
  /// This is just the default configuration, every load operation can use
  /// individual loader configurations. Please note that this property is
  /// forwarded to [BitmapData.defaultLoadOptions].

  static BitmapDataLoadOptions get bitmapDataLoadOptions {
    return BitmapData.defaultLoadOptions;
  }

  static void set bitmapDataLoadOptions(BitmapDataLoadOptions options) {
    BitmapData.defaultLoadOptions = options;
  }

  /// The default loader configuration for [Sound.load].
  ///
  /// This is just the default configuration, every load operation can use
  /// individual loader configurations. Please note that this property is
  /// forwarded to [Sound.defaultLoadOptions].

  static SoundLoadOptions get soundLoadOptions {
    return Sound.defaultLoadOptions;
  }

  static void set soundLoadOptions(SoundLoadOptions options) {
    Sound.defaultLoadOptions = options;
  }

}
