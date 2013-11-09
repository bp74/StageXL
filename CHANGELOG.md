# changelog

This file contains highlights of what changes on each version of the StageXL
package. This file is normally updated whenever we push a new version to pub.

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