#library("dartflash");

#import("dart:math");
#import("dart:json");
#import("dart:html", prefix: "html");

//------------------------------------------------------

#source("src/animation/DelayedCall.dart");
#source("src/animation/Animatable.dart");
#source("src/animation/Juggler.dart");
#source("src/animation/Transitions.dart");
#source("src/animation/Tween.dart");

#source("src/geom/Point.dart");
#source("src/geom/Rectangle.dart");
#source("src/geom/Circle.dart");
#source("src/geom/Matrix.dart");
#source("src/geom/ColorTransform.dart");

#source("src/engine/RenderLoop.dart");
#source("src/engine/RenderState.dart");
#source("src/engine/StageRenderMode.dart");

#source("src/events/Event.dart");
#source("src/events/EventPhase.dart");
#source("src/events/EventDispatcher.dart");
#source("src/events/EventDispatcherCatalog.dart");
#source("src/events/EventListener.dart");
#source("src/events/EnterFrameEvent.dart");
#source("src/events/MouseEvent.dart");
#source("src/events/KeyboardEvent.dart");
#source("src/events/TextEvent.dart");

#source("src/filters/BitmapFilter.dart");
#source("src/filters/BitmapFilterQuality.dart");
#source("src/filters/BlurFilter.dart");
#source("src/filters/ColorMatrixFilter.dart");
//#source("src/filters/DropShadowFilter.dart");

#source("src/display/DisplayObject.dart");
#source("src/display/InteractiveObject.dart");
#source("src/display/DisplayObjectContainer.dart");
#source("src/display/Stage.dart");
#source("src/display/Sprite.dart");
#source("src/display/Bitmap.dart");
#source("src/display/BitmapData.dart");
#source("src/display/BitmapDrawable.dart");
#source("src/display/MovieClip.dart");
#source("src/display/Shape.dart");
#source("src/display/PixelSnapping.dart");
#source("src/display/SimpleButton.dart");
#source("src/display/Graphics.dart");
#source("src/display/GraphicsGradient.dart");
#source("src/display/GraphicsPattern.dart");
#source("src/display/GraphicsCommand.dart");
#source("src/display/CapsStyle.dart");
#source("src/display/JointStyle.dart");
#source("src/display/Mask.dart");

#source("src/displayEx/GlassPlate.dart");
#source("src/displayEx/ParticleSystem.dart");
#source("src/displayEx/Warp.dart");

#source("src/media/Sound.dart");
#source("src/media/SoundChannel.dart");
#source("src/media/SoundTransform.dart");
#source("src/media/SoundMixer.dart");
#source("src/media/implementation/AudioElementSound.dart");
#source("src/media/implementation/AudioElementSoundChannel.dart");
#source("src/media/implementation/WebAudioApiSound.dart");
#source("src/media/implementation/WebAudioApiSoundChannel.dart");

#source("src/text/GridFitType.dart");
#source("src/text/TextField.dart");
#source("src/text/TextFieldAutoSize.dart");
#source("src/text/TextFieldType.dart");
#source("src/text/TextFormat.dart");
#source("src/text/TextFormatAlign.dart");
#source("src/text/TextLineMetrics.dart");

#source("src/ui/KeyLocation.dart");
#source("src/ui/Mouse.dart");
#source("src/ui/MouseCursor.dart");
#source("src/ui/Color.dart");
 
#source("src/util/Resource.dart");
#source("src/util/TextureAtlas.dart");
#source("src/util/TextureAtlasFormat.dart");
#source("src/util/TextureAtlasFrame.dart");
#source("src/util/Tools.dart");


