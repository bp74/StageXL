# Change Log

This file contains highlights of the changes we have made in each version.
For questions regarding new features or breaking changes, please follow the
announcements on the StageXL forum or use one of the support links below:

  * StageXL Forum <https://groups.google.com/forum/#!forum/stagexl>
  * StageXL GitHub <https://github.com/bp74/StageXL/issues>
  * StageXL StackOverflow: <http://stackoverflow.com/questions/ask?tags=stagexl>

### 2.0.3
 * Fix a bug where the `meta["format"]` key was assumed to be non-null in json texture atlas filesj.
### 2.0.2
 * Exposing max texture size on WebGl canvas.
 * Exposing getParameters call on WebGL canvas.

### 2.0.1
  * Bug fix for common ancestor call for object to be null.

### 2.0.0
  * Upgrade to null safety
  * Update Dart SDK restraint to >= 2.12.0
  
#### 1.4.6
  * Upgraded to latest package versions
  * Allow overriding blend mode function

#### 1.4.5
  * Upgraded to latest package versions

#### 1.4.4
  * Support the latest release of `package:xml`

#### 1.4.3
  * Fix compilation error due to changes in latest Dart SDK.
    See [dart-lang/sdk#40485](https://github.com/dart-lang/sdk/issues/40485).

#### 1.4.2
  * fixed linter warnings
  * Require Dart 2.7

#### 1.4.1
  * Require Dart 2.4

#### 1.4.0
  * Require Dart 2.
  * Support Dart 2 stable.

#### 1.3.1+4
  * Fixed issues with Dart 2.

#### 1.3.1+3
  * Fixed issues with Dart 2.

#### 1.3.1+2
  * Fixed issues with Dart 2.

#### 1.3.1+1
  * Fixed issue with rectangle masks and TextField updates.
  
#### 1.3.1
  * Replaced deprecated value AudioParam in WebAudio API.
  * Allow colors with alpha value for TextField backgrounds.
  * Fixed issue with rectangular masks within filters.
  * Fixed issue with masks relative to parent.

#### 1.3.0
  * Added SoundChannel.position setter.
  * Added support for non integer HiDpi pixel ratios.
  * Added BitmapDataLoadOptions.pixelRatios list.
  * Added TextureAtlas.pixelRatio getter.
  * Removed BitmapDataLoadOptions.maxPixelRatio.
  * Removed SoundChannel.onComplete workaround for WebAudio API.
  * Fixed infinite scaleX/scaleY on DisplayObjects.
  * Fixed scissor masks on RenderBufferFrames.

#### 1.2.0
  * Added ViewportContainer display object.
  * Added Stage.console to show render statistics.
  * Added support for GraphicsGradient with WebGL renderer.
  * Added support for GraphicsPattern with WebGL renderer.
  * Added StageRenderMode.AUTO_INVALID for lower CPU/GPU load.
  * Optimized stage-aligned rectangular masks.
  * Improved DisplayObject width and height setters.

  Special thanks to John Talley for his work on the WebGL graphics
  code to support gradient and pattern fills and strokes.

#### 1.1.0
  * Added Graphics.arcElliptical method.
  * Added support for SVG encoded graphics paths.
  * Optimized EaselJS encoded graphics paths.
  * Updated to Dart 1.21 and use generic functions.
  * Fixed bug in Sprite.bounds with Sprite.graphics.

#### 1.0.0
  * Stable release

#### 0.13.12
  * Added FxaaFilter.
  * More strong mode fixes.
  * Improved error handling for image, sound and video loader.
  
#### 0.13.11
  * Added ResourceManager.remove(BitmapData/Sound/...) methods.
  * Added ResourceManager.dispose method to unload all resources.
  * Added RenderContext.renderStatistics to measure WebGL operations.
  * Improved graphics stroke rendering in WebGL mode.
  * Improved renderTextureMesh in Canvas2D mode.
  * Improved BlurFilter in Canvas2D mode.
  * Fixed bug in ColorMatrixFilter.
  * Fixed bug in BitmapContainer.
  * Updated SDK dependency to Dart 1.19 

#### 0.13.10
  * Fixed joints of strokes in graphics.
  * Added graphics.undoCommand method.

#### 0.13.9
  * Added SoundEngine enum.
  * Added SoundMixer.engine setter to overrule the detected engine.
  * Added SoundLoadOptions.engine to load with a specific engine.
  * Added Sound.engine to get the underlying engine.
  
#### 0.13.8
  * Added support for opus audio codec.
  * Added support for SoundLoadOptions in Sound.loadDataUrl.
  * Fixes and optimizations in graphics methods.
  * Removed support for legacy CocoonJS workarounds.
  * Enabled analysis options for strong mode.
  * Updated SDK dependency to Dart 1.17 

#### 0.13.7
  * Replaced deprecated WebGL methods
  * Updated SDK dependency to Dart 1.16
  
#### 0.13.6
  * Added support for Starling JSON texture atlas format.
  * Allow all number types in DisplayObject.applyCache.
  * Fixed ColorMatrixClass for some use cases.
  * Fixed Mesh.setVertexUV method.
  * Simplified TintFilter
  
#### 0.13.5
  * Fixed TextField cache update on scale changes. 
  * Fixed int/num type ambiguity in BitmapData. 

#### 0.13.4
  * Fixed an issue with filters caused by resizing of FrameBuffers. 
  * Fixed AlphaMaskFilter with better fragment shader code (again).
  
#### 0.13.3
  * Moved the 'Toolkit for Dart' to a dedicated StageXL extension package.
  * Fixed Graphics.fillGradient and Graphics.fillPattern return types.

#### 0.13.2
  * Added BitmapContainer for extensive Bitmap rendering.
  * Fixed AlphaMaskFilter with better fragment shader code.

#### 0.13.1
  * Added better support for vector graphics in WebGL.
  * Added DisplayObject.alignPivot method.
  * Fixed Sprite.bounds with graphics.
  * Fixed Sprite.getObjectsUnderPoint with graphics.
  
#### 0.13.0
  * Added support for polygon sprite meshes.
  * Added support for polygon texture packing.
  * Added support for custom graphics masks in WebGL.
  * Added initial support for vector graphics in WebGL.
  * Added support for Starling texture atlas format.
  * Added Juggler hasAnimatables getter.
  * Fixed flickering on stage initialization.
  * Simplified render program implementations.
  
#### 0.12.0+1
  * Enabled HiDPI filters. 
  * Fixed stage with transparent background color.
  * Fixed rendering issue with sequential filters. 
  * Fixed color of primitive WebGL triangles.
  
#### 0.12.0
  * Added StageXL global default configuration options.
  * Added Juggler async/await and reactive features.
  * Added SoundChannel play() and pause() methods.
  * Added SoundChannel position, paused, stopped properties.
  * Added SoundMixer.unlockMobileAudio() convenience method.
  * Added BitmapDataLoadOptions.maxPixelRatio (replaces old autoHiDpi). 
  * Added TextureAtlas loader abstraction for custom loaders.
  * Added pixel ratio support for DisplayObject and TextField cache.
  * Added Sprite3D implementation of Sprite interface.
  * Added TextFormat.weight additionally to bold property. 
  * Improved pixel ratio support for HiDPI BitmapDatas.   
  * Fixed RenderTexture update/resize/filtering on iOS8.
  * Fixed TintFilter showing the wrong ARGB values.
  * Fixed cache and mask support for Sprite3D.
  * Breaking Change: changed Stage constructor and properties.
  * Breaking Change: changed BitmapData constructor and properties.
  * Breaking Change: changed RenderTextureQuad constructor and properties.
  * Breaking Change: renamed Transition to Translation (Juggler).
  * Breaking Change: renamed TransitionFunction to Transition (Juggler).
  * Breaking Change: renamed Juggler.tween to Juggler.addTween. 
  * Breaking Change: removed Multitouch class in favor of Stage options.
  
This version contains quite a few breaking changes and we are sorry for it. 
We do this in an effort to to get closer to a 1.0 release.
  
#### 0.11.0+1
  * Added hashCode getter in Point, Rectangle, Circle, Vector.
  
#### 0.11.0
  * Added DisplayObjectContainer.children for better child access.
  * Added DisplayObjectContainer.replaceChildAt. 
  * Added Sound.loadDataUrl and Sound.supportedTypes.
  * Added Point and Rectangle operators.
  * Added TintFilter for color effects.
  * Added NormalMapFilter for light effects.
  * Added quality setting for blur, glow and drop shadow filter.
  * Optimized filters for Bitmap, TextField, FlipBook and VideoObject.
  * Optimized overall performance for filters and display objects.  
  * Optimized onAddedToStage and onRemovedFromStage event dispatching.
  * Optimized memory consumption for BitmapData loading.
  * Fixed SimpleButton setters for the state display objects. 
  * Make TextureAtlasFormat.JSONARRAY the default.
  * Internal simplifications and optimizations.  
  * Requires Dart SDK 1.9 or higher.    

#### 0.10.3
  * Added InputEvent as base class for MouseEvent and TouchEvent.
  * Added InputEvent.current for current propagating InputEvent.
  * Added Sprite drag support for multi touch.
  * Added Mesh display object for BitmapData free form deformation.
  * Added batch drawing support for meshes.
  * Added stagexl.drawing mini-lib for future WebGL support.
  * Remove Sprite.buttonMode since it has no use.
  * Bugfixes.

#### 0.10.2
  * Added lots of API documentations (thanks to @marcojakob)
  * Added Video and VideoObject classes (thanks fot @sebgeelen)
  * Added BitmapData.fromVideoElement constructor.
  * Added Tween.animate3D for 3D tween animations.  
  * Added DisplayObject.getObjectsUnderPoint method.
  * Improved DisplayObject bounds calculations.
  * Improved support for custom WebGL filters/shaders.
  * Improved Sprite3D calculations.
  * Improved global2local and local2global calculations.

#### 0.10.1
  * Added Sprite3D for 3D transformations of display objects.
  * Added RenderTexture.filtering option for pixel art games.
  * Added InteractiveObject.mouseCursor property.
  * Fixed MouseCursor definitions and added new ones.
  * Fixed nested masks with WebGL renderer.
  * Fixed Stage.autoHiDpi heuristics.
  * Bugfixes and performance improvements.

#### 0.10.0
  * Added DisplayObject.blendMode property.
  * Added BitmapDataUpdateBatch class for better BitmapData update performance.
  * Added LibGDX texture atlases loader (for Spine runtime).
  * Added texture mesh renderer (for Spine runtime).
  * Added FlattenFilter to flatten hierarchical containers.
  * Added Mask.relativeToParent property.
  * Added Mask.transformationMatrix property.
  * Deprecated DisplayObject.shadow property.
  * Deprecated DisplayObject.compositeOperation property.
  * Deprecated Mask.targetSpace property.
  * Bugfixes and performance improvements.
  * Internal refactoring to use mini-libs.

#### 0.9.4+2
  * Fixed an issue with TouchEvents in Dartium.

#### 0.9.4+1
  * Fixed an issue with WebGL masks in combination with WebGL filters.

#### 0.9.4
  * Added TouchEvents TOUCH\_ROLL\_OUT, TOUCH\_ROLL\_OVER, TOUCH\_TAP.
  * Added touch support for SimpleButton.
  * Fixed TextField.displayAsPassword
  * Improved compatibility for CocoonJS on Android.
  * Changed default value of BitmapDataLoaderOptions.corsEnabled to false.
  * Removed support for Canvas.backingStorePixelRatio.
  
This will be the last version of StageXL with support for IE9. The Dart team 
announced that Dart 1.5 will be the last version with support for IE9.
Therefore the next version of StageXL will take advantage of features (like
typed arrays) which are not supported by IE9. This will presumably improve
the render performance on all other browsers.

#### 0.9.3+2
  * stageWidth and stageHeight are integers again.

#### 0.9.3+1
  * Changed Stage.stageWidth and stageHeight to num.
  * Added workaround for web fonts issue in IE.  
  
#### 0.9.3
  * Added Scale9Bitmap DisplayObject.
  * Added Mouse.registerCursor for custom cursor styles.
  * Added BitmapData.toDataUrl method.  
  * Added Stage.sourceWidht and Stage.sourceHeight setters.
  * Added Stage.onMouseLeave event.
  * Added BitmapData.sliceIntoFrames margin and spacing parameters.
  * Make CORS for BitmapData loader optional (see BitmapDataLoadOptions).
  * Enabled Stage as mouse and touch event target.
  * Enabled Stage.filters setter (thanks Xavier).
  * Fixed GC issues with WebGL resources.
  * Fixed IE9 render and sound issues.

#### 0.9.2
  * Added support for Sound Sprits (thanks Alex).
  * Added Stage.backgroundColor property (thanks Xavier).
  * Added ColorMatrixFilter.adjustColoration method (thanks Emmanuel).
  * Added ResourceManager.contains methods.  
  * Refactored Point and Rectangle classes (thanks Kevin).
  * Fixed MouseEvent/TouchEvent ctrl/alt/shift getters.
  * Fixed Juggler.clear method.

#### 0.9.1
  * Added WebGL filters.
  * Added TextField stroke and gradients.
  * Enable CORS when loading BitmapDatas.
  * BREAKING CHANGE: Removed Bitmap.clipRectangle.

#### 0.9.0+2
  * Fixed fallback for WebGL on iOS.

#### 0.9.0+1
  * Added dartdoc comments for Graphics class (thanks Arron).
  * Enabled audio on IE Mobile 10 (thanks Xavier).
  * Fixed Mask.shape for Canvas2D renderer (thanks Alain).
  * Fixed DisplayObject.compositeOperation.

#### 0.9.0
  * Added WebGL renderer (opt-in with Stage constructor).
  * Added fallback to Canvas renderer.
  * Added texture atlas optimizations.
  * BREAKING CHANGE: Simplified Stage constructor
  * BREAKING CHANGE: Simplified BitmapFilter.apply method
  
  This version contains major changes in the internal render code.
  The WebGL renderer is highly optimized to draw textures (BitmapDatas) but
  does not support vector graphics yet. If you want to draw Graphics display
  objects please use the applyCache method which renders the vector graphics 
  to a texture or do not opt-in for the WebGL renderer.

#### 0.8.9
  * Added HtmlObject class to use HTML elements as DisplayObjects (kind of).
  * Added DisplayObject.userData property to custom user-defined data. 
  * Added BitmapData.sliceIntoFrames (better SpriteSheet support).
  * Added RenderLoop.start and RenderLoop.stop to control rendering.
  * Added AnimationGroup and AnimactionChain to Juggler framework.
  * Added EventDispatcher.removeEventListener
  * Added EventDispatcher.addEventListener optional "priority" parameter.
  * Added EventStream.listen optional "priority" parameter.
  * Fixed Color bug on iOS7.
  * Fixed GraphicsPattern from BitmapData.
  * Improved performance of BitmapFilters (~ 2x).
  * Improved performance and smaller code for Tweens.
  
#### 0.8.8
  * Added new mouse event for roll over and out.
  * Removed examples in favor of StageXL_Samples.
  * Updated ReadMe and GettingStarted documents.
  * Set version of dependencies according to Dart 1.0 release.
  
#### 0.8.7
  * Refactored event system and how we add capturing event listeners.
  * Optimized filters (up to twice as fast now).
  * Improved performance of Graphics renderer. 
  * Some minor changes to align with the latest Dart changes.

#### 0.8.6
  * Added TextField.cacheAsBitmap (default = true) for better text scaling.
  * Fixed TextField.autoSize.  
  * Fixed TextFormat.leading, TextFormat.indent and TextFormat.underline.
  * Fixed mouse and touch events for DisplayObjects with masks.
  * Optimized BitmapData.copyPixel and added BitmapData.drawPixels.
  * Fixed BitmapData.colorTransform.
  * Fixed Firefox render problems on Linux.
  * Added Stage.sourceWidth and Stage.sourceHeight getters.

#### 0.8.5
  * Added FlipBook.frameDurations property for flexible animation speeds.
  * Added SoundMixer.soundTransform implementation. 
  * KeyboardEvent stopPropagation prevents html event defaults.
  * Fixed Point.polar method. 
  * Include the latest Dart API changes.

#### 0.8.4
  * Fixed TextFieldAutoSize feature.
  * Fixed TextFormat margins.
  * TextField.backgroundColor now matches Flash's default.
  * Moved Flump runtime to separate package.
  * Moved Particle Emitter runtime to separate package.

#### 0.8.3
  * Added support for text files in ResourceManager.
  * Include the latest Dart API changes.
  * Honor TextFormat.leftMargin in TextField.

#### 0.8.2
  * ResourceManger got an onProgress event to monitor loading progress.
  * Improved detection of HiDpi displays and mobile devices.
  * Mask got border properties to draw outlines of the mask.
  * Stage does no longer set focus to canvas automatically.
  * Fixed recursive event handler invocation.
  * Smaller JavaScript code size.
  * Minor optimization in Juggler.

#### 0.8.1
  * Fixed MovieClip frame 0 execution.

#### 0.8.0
  * New MovieClip class for the Toolkit for Dart.
  * Stage automatically set the "tabindex" attribute of canvas.
  * Smaller JavaScript code size.

#### 0.7.6
  * Added ParticleEmitter for particle effects.
  * TextField supports TextFieldType.Input.
  * Stage supports resizing (full window, full screen).
  * Stage.contentRectangle property to get the visible content area.
  * Stage.onRender and Stage.onExitFrame events.
  * BitmapData supports HiDpi pixels.
  * Added AlphaMaskFilter class.
  * Smaller JavaScript code size.

#### 0.7.5
  * DisplayObject.compositeOperation property.
  * DisplayObject.filters property.
  * Customize Sound loading with SoundLoadOptions.
  * Customize BitmapData loading with BitmapDataLoadOptions.
  * Opt in for WebP when loading images.
  * Added Mask.fromShape constructor.
  * Added Shadow class.
  * Stage has own Juggler which is advanced by the RenderLoop.
  * Sprite.startDrag/stopDrag/dropTarget support.
  * Sprite.hitArea property.
  * Sprite.graphics property.
  * Pixel perfect hitTest for Shape.
  * TextField fixes for Firefox.
  * Smaller JavaScript code size.

#### 0.7.4
  * New name for the library -> StageXL.
  * Added StageScaleMode and StageAlign.

#### 0.7.3
  * DisplayObject.applyCache/refreshCache/removeCache.
  * Renamed current MovieClip class to FlipBook.
  * DisplayObject.skewX and skewY support.
  * DisplayObjectContainer.removeChildren().
  * Juggler.containsTween().
  * Stop mouse wheel event propagation on canvas.

#### 0.7.2
  * Some fixes to align with the latest changes in Dart.

#### 0.7.1
  * ResourceManager optimization and fixes.

#### 0.7.0
  * Reworked event system to align with the Dart event system.

----------

*See git version tags for older changes.*
