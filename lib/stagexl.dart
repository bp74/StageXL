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

/// The default configurations for various StageXL features.
///
/// The system environment in which the application is running:
///
///     StageXL.environment.devicePixelRatio
///     StageXL.environment.isMobileDevice
///     StageXL.environment.isLittleEndianSystem
///     StageXL.environment.isTouchEventSupported
///
/// The default [StageOptions] used by the [Stage] constructor:
///
///     StageXL.stageOptions.renderEngine = RenderEngine.WebGL;
///     StageXL.stageOptions.inputEventMode = InputEventMode.MouseOnly;
///     StageXL.stageOptions.stageRenderMode = StageRenderMode.AUTO;
///     StageXL.stageOptions.stageScaleMode = StageScaleMode.SHOW_ALL;
///     StageXL.stageOptions.stageAlign = StageAlign.NONE;
///     StageXL.stageOptions.backgroundColor = Color.White;
///     StageXL.stageOptions.transparent = false;
///     StageXL.stageOptions.antialias = false;
///     StageXL.stageOptions.maxPixelRatio = 5.0;
///     StageXL.stageOptions.preventDefaultOnTouch = true;
///     StageXL.stageOptions.preventDefaultOnMouse = true;
///     StageXL.stageOptions.preventDefaultOnWheel = false;
///     StageXL.stageOptions.preventDefaultOnKeyboard = false;
///
/// The default [BitmapDataLoadOptions] used by [BitmapData.load]:
///
///     StageXL.bitmapDataLoadOptions.jpg = true;
///     StageXL.bitmapDataLoadOptions.png = true;
///     StageXL.bitmapDataLoadOptions.webp = false;
///     StageXL.bitmapDataLoadOptions.maxPixelRatio = 2;
///     StageXL.bitmapDataLoadOptions.corsEnabled = false;
///
/// The default [SoundLoadOptions] used by [Sound.load]:
///
///     StageXL.soundLoadOptions.mp3 = true;
///     StageXL.soundLoadOptions.mp4 = true;
///     StageXL.soundLoadOptions.ogg = true;
///     StageXL.soundLoadOptions.ac3 = true;
///     StageXL.soundLoadOptions.wav = true;
///     StageXL.soundLoadOptions.alternativeUrls = null;
///     StageXL.soundLoadOptions.ignoreErrors = true;
///     StageXL.soundLoadOptions.corsEnabled = false;
///
/// The default [VideoLoadOptions] used by [Video.load]:
///
///     StageXL.videoLoadOptions.mp4 = true;
///     StageXL.videoLoadOptions.webm = true;
///     StageXL.videoLoadOptions.ogg = true;
///     StageXL.videoLoadOptions.alternativeUrls = null;
///     StageXL.videoLoadOptions.loadData = false;
///     StageXL.videoLoadOptions.corsEnabled = false;

class StageXL {

  /// The system environment in which the application is running.

  static final Environment environment = new Environment._internal();

  /// The default [StageOptions] used by the [Stage] constructor.
  ///
  /// The default options are used if no individual options are passed to
  /// the [Stage] constructor. Please note that this property is
  /// just a forward to [Stage.defaultOptions].

  static StageOptions get stageOptions {
    return Stage.defaultOptions;
  }

  static void set stageOptions(StageOptions options) {
    Stage.defaultOptions = options;
  }

  /// The default [BitmapDataLoadOptions] used by [BitmapData.load].
  ///
  /// The default options are used if no individual options are passed to
  /// the [BitmapData.load] method. Please note that this property is
  /// just a forward to [BitmapData.defaultLoadOptions].

  static BitmapDataLoadOptions get bitmapDataLoadOptions {
    return BitmapData.defaultLoadOptions;
  }

  static void set bitmapDataLoadOptions(BitmapDataLoadOptions options) {
    BitmapData.defaultLoadOptions = options;
  }

  /// The default [SoundLoadOptions] used by [Sound.load].
  ///
  /// The default options are used if no individual options are passed to
  /// the [Sound.load] method. Please note that this property is
  /// just a forward to [Sound.defaultLoadOptions].

  static SoundLoadOptions get soundLoadOptions {
    return Sound.defaultLoadOptions;
  }

  static void set soundLoadOptions(SoundLoadOptions options) {
    Sound.defaultLoadOptions = options;
  }

  /// The default [VideoLoadOptions] used by [Video.load].
  ///
  /// The default options are used if no individual options are passed to
  /// the [Video.load] method. Please note that this property is
  /// just a forward to [Video.defaultLoadOptions].

  static VideoLoadOptions get videoLoadOptions {
    return Video.defaultLoadOptions;
  }

  static void set videoLoadOptions(VideoLoadOptions options) {
    Video.defaultLoadOptions = options;
  }

}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

/// The system environment in which the application is running.

class Environment {

  Environment._internal();

  /// The device pixel ratio is the ratio between physical pixels and
  /// logical pixels.
  ///
  /// For instance, the iPhone 4 and iPhone 4S reports a device pixel ratio
  /// of 2, because the physical linear resolution is double the logical
  /// resolution. The iPhone 6 reports a device pixel ratio of 3. Some
  /// devices may even report a device pixel ratio of 1.325 (Nexus 7 v1).

  final num devicePixelRatio = env.devicePixelRatio;

  /// This flag indicates if the application is running on a mobile device.
  ///
  /// The user agent string of the browser is used to get this information.
  /// Therefore the flag may not be accurate on all devices.

  final bool isMobileDevice = env.isMobileDevice;

  /// This flag indicates if the application is running on a device
  /// with a little endian CPU architecture.
  ///
  /// The method [RenderTextureQuad.getImageData] allows low level texture
  /// access and the RGBA value of each pixel is affected by the endianness
  /// of the CPU architecture. <http://en.wikipedia.org/wiki/Endianness>

  final bool isLittleEndianSystem = env.isLittleEndianSystem;

  /// This flag indicates if the application is running on a device
  /// which support TouchEvents and therefore has a touch screen.

  final bool isTouchEventSupported = env.isTouchEventSupported;
}
