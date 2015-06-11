part of stagexl.display;

/// The options used by the [Stage] constructor to setup the stage.

class StageOptions {

  /// The [RenderEngine] used to render the [Stage].
  ///
  /// Setting the render engine to WebGL will automatically fallback
  /// to Canvas2D if WebGL is not supported.

  RenderEngine renderEngine = RenderEngine.WebGL;

  /// The [InputEventMode] used for input events on the [Stage].
  ///
  /// You can opt-in for touch events if you set the `TouchOnly` or
  /// `TouchAndMouse` value. The second one is recommended because
  /// you won't get any input events if you choose `TouchOnly` when
  /// there is no touch screen available.

  InputEventMode inputEventMode = InputEventMode.MouseOnly;

  /// The [StageRenderMode] used to render the [Stage].

  StageRenderMode stageRenderMode = StageRenderMode.AUTO;

  /// The [StageScaleMode] used to render the [Stage].
  ///
  /// The scale mode configures the way how the content on the stage
  /// is scaled when the size of the canvas element changes. You
  /// can change the behavior at runtime by changing the [Stage.scaleMode]
  /// property.

  StageScaleMode stageScaleMode = StageScaleMode.SHOW_ALL;

  /// The [StageAlign] used to render the [Stage].
  ///
  /// The align mode configures the way how the content on the stage
  /// is aligned on the canvas element. You can change the behavior at
  /// runtime by changing the [Stage.align] property.

  StageAlign stageAlign = StageAlign.NONE;

  /// The background color for the [Stage].
  ///
  /// You can change the background color at runtime by changing the
  /// [Stage.backgroundColor] property.

  int backgroundColor = Color.White;

  /// Initialize the render engine to support transparency for the [Stage].
  ///
  /// Please note that the Canvas2D render engine will always be transparent
  /// since the underlying API does not provide a way to change this behavior.
  /// The WebGL render engine supports transparency but there is performance
  /// penalty for setting this flag to 'true'.

  bool transparent = false;

  /// Initialize the render engine to support anti-aliasing for the [Stage].
  ///
  /// Please note that the Canvas2D render engine will not be affected by
  /// this setting because the underlying API does not provide this feature.
  /// The WebGL render engine supports anti-aliasing but there is performance
  /// penalty fo setting this flag to 'true'.

  bool antialias = false;

  /// The maximum pixel ratio used to initialize the [Stage].
  ///
  /// This value will limit the pixel ratio for HiDPI screens. The native
  /// pixel ratio of the device may be to high for you application to
  /// achieve good performance. If the native pixel ratio is for instance
  /// 3.0 you may set the [maxPixelRatio] to 2.0 or even 1.0 if the
  /// performance is more important than perfectly sharp edges or pixels.

  num maxPixelRatio = 5.0;

  /// Prevents the browser's default behavior for touch events.
  ///
  /// This value enabled or disables the default behavior for html touch
  /// events that are targeted on the Stage. If the value is `true` the
  /// browser will ignore the event. This does not affect the event
  /// propagation from the Stage to the display objects.

  bool preventDefaultOnTouch = true;

  /// Prevents the browser's default behavior for mouse events.
  ///
  /// This value enabled or disables the default behavior for html mouse
  /// events that are targeted on the Stage. If the value is `true` the
  /// browser will ignore the event. This does not affect the event
  /// propagation from the Stage to the display objects.

  bool preventDefaultOnMouse = true;

  /// Prevents the browser's default behavior for wheel events.
  ///
  /// This value enabled or disables the default behavior for html wheel
  /// events that are targeted on the Stage. If the value is `true` the
  /// browser will ignore the event. This does not affect the event
  /// propagation from the Stage to the display objects.

  bool preventDefaultOnWheel = false;

  /// Prevents the browser's default behavior for keyboard events.
  ///
  /// This value enabled or disables the default behavior for html keyboard
  /// events that are targeted on the Stage. If the value is `true` the
  /// browser will ignore the event. This does not affect the event
  /// propagation from the Stage to the display objects.

  bool preventDefaultOnKeyboard = false;

  //---------------------------------------------------------------------------

  /// Create a deep clone of this [StageOptions].

  StageOptions clone() {
    var options = new StageOptions();
    options.renderEngine = this.renderEngine;
    options.inputEventMode = this.inputEventMode;
    options.stageRenderMode = this.stageRenderMode;
    options.stageScaleMode = this.stageScaleMode;
    options.stageAlign = this.stageAlign;
    options.backgroundColor = this.backgroundColor;
    options.transparent = this.transparent;
    options.antialias = this.antialias;
    options.maxPixelRatio = this.maxPixelRatio;
    options.preventDefaultOnTouch = this.preventDefaultOnTouch;
    options.preventDefaultOnMouse = this.preventDefaultOnMouse;
    options.preventDefaultOnWheel = this.preventDefaultOnWheel;
    options.preventDefaultOnKeyboard = this.preventDefaultOnKeyboard;
    return options;
  }

}
