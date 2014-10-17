# changelog

This file contains highlights of what changes on each version of the StageXL
package. This file is normally updated whenever we push a new version to pub.

#### Pub version 0.10.1
  * Added Sprite3D for 3D transformations of display objects.
  * Added RenderTexture.filtering option for pixel art games.
  * Added InteractiveObject.mouseCursor property.
  * Fixed MouseCursor definitions and added new ones.
  * Fixed nested masks with WebGL renderer.
  * Fixed Stage.autoHiDpi heuristics.
  * Bugfixes and performance improvements.

#### Pub version 0.10.0
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
  
This version contains a few minor breaking changes. If you experience 
a problem please report the issue either in the 
[StageXL GitHub issue tracker](https://github.com/bp74/StageXL/issues) 
or in the [StageXL Forum](http://www.stagexl.org/forum.html).

#### Pub version 0.9.4+2
  * Fixed an issue with TouchEvents in Dartium.

#### Pub version 0.9.4+1
  * Fixed an issue with WebGL masks in combination with WebGL filters.

#### Pub version 0.9.4
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

#### Pub version 0.9.3+2
  * stageWidth and stageHeight are integers again.

#### Pub version 0.9.3+1
  * Changed Stage.stageWidth and stageHeight to num.
  * Added workaround for web fonts issue in IE.  
  
#### Pub version 0.9.3
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

#### Pub version 0.9.2
  * Added support for Sound Sprits (thanks Alex).
  * Added Stage.backgroundColor property (thanks Xavier).
  * Added ColorMatrixFilter.adjustColoration method (thanks Emmanuel).
  * Added ResourceManager.contains methods.  
  * Refactored Point and Rectangle classes (thanks Kevin).
  * Fixed MouseEvent/TouchEvent ctrl/alt/shift getters.
  * Fixed Juggler.clear method.

#### Pub version 0.9.1
  * Added WebGL filters.
  * Added TextField stroke and gradients.
  * Enable CORS when loading BitmapDatas.
  * BREAKING CHANGE: Removed Bitmap.clipRectangle.

#### Pub version 0.9.0+2
  * Fixed fallback for WebGL on iOS.

#### Pub version 0.9.0+1
  * Added dartdoc comments for Graphics class (thanks Arron).
  * Enabled audio on IE Mobile 10 (thanks Xavier).
  * Fixed Mask.shape for Canvas2D renderer (thanks Alain).
  * Fixed DisplayObject.compositeOperation.

#### Pub version 0.9.0
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

#### Pub version 0.8.9
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
  
#### Pub version 0.8.8
  * Added new mouse event for roll over and out.
  * Removed examples in favor of StageXL_Samples.
  * Updated ReadMe and GettingStarted documents.
  * Set version of dependencies according to Dart 1.0 release.
  
#### Pub version 0.8.7
  * Refactored event system and how we add capturing event listeners.
  * Optimized filters (up to twice as fast now).
  * Improved performance of Graphics renderer. 
  * Some minor changes to align with the latest Dart changes.

#### Pub version 0.8.6
  * Added TextField.cacheAsBitmap (default = true) for better text scaling.
  * Fixed TextField.autoSize.  
  * Fixed TextFormat.leading, TextFormat.indent and TextFormat.underline.
  * Fixed mouse and touch events for DisplayObjects with masks.
  * Optimized BitmapData.copyPixel and added BitmapData.drawPixels.
  * Fixed BitmapData.colorTransform.
  * Fixed Firefox render problems on Linux.
  * Added Stage.sourceWidth and Stage.sourceHeight getters.

#### Pub version 0.8.5
  * Added FlipBook.frameDurations property for flexible animation speeds.
  * Added SoundMixer.soundTransform implementation. 
  * KeyboardEvent stopPropagation prevents html event defaults.
  * Fixed Point.polar method. 
  * Include the latest Dart API changes.

#### Pub version 0.8.4
  * Fixed TextFieldAutoSize feature.
  * Fixed TextFormat margins.
  * TextField.backgroundColor now matches Flash's default.
  * Moved Flump runtime to separate package.
  * Moved Particle Emitter runtime to separate package.

#### Pub version 0.8.3
  * Added support for text files in ResourceManager.
  * Include the latest Dart API changes.
  * Honor TextFormat.leftMargin in TextField.

#### Pub version 0.8.2
  * ResourceManger got an onProgress event to monitor loading progress.
  * Improved detection of HiDpi displays and mobile devices.
  * Mask got border properties to draw outlines of the mask.
  * Stage does no longer set focus to canvas automatically.
  * Fixed recursive event handler invocation.
  * Smaller JavaScript code size.
  * Minor optimization in Juggler.

#### Pub version 0.8.1
  * Fixed MovieClip frame 0 execution.

#### Pub version 0.8.0
  * New MovieClip class for the Toolkit for Dart.
  * Stage automatically set the "tabindex" attribute of canvas.
  * Smaller JavaScript code size.

#### Pub version 0.7.6
  * Added ParticleEmitter for particle effects.
  * TextField supports TextFieldType.Input.
  * Stage supports resizing (full window, full screen).
  * Stage.contentRectangle property to get the visible content area.
  * Stage.onRender and Stage.onExitFrame events.
  * BitmapData supports HiDpi pixels.
  * Added AlphaMaskFilter class.
  * Smaller JavaScript code size.

#### Pub version 0.7.5
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

#### Pub version 0.7.4
  * New name for the library -> StageXL.
  * Added StageScaleMode and StageAlign.

#### Pub version 0.7.3
  * DisplayObject.applyCache/refreshCache/removeCache.
  * Renamed current MovieClip class to FlipBook.
  * DisplayObject.skewX and skewY support.
  * DisplayObjectContainer.removeChildren().
  * Juggler.containsTween().
  * Stop mouse wheel event propagation on canvas.

#### Pub version 0.7.2
  * Some fixes to align with the latest changes in Dart.

#### Pub version 0.7.1
  * ResourceManager optimization and fixes.

#### Pub version 0.7.0
  * Reworked event system to align with the Dart event system.

----------

*See git version tags for older changes.*
