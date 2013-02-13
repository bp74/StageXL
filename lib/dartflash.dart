library dartflash;

import 'dart:async';
import 'dart:math';
import 'dart:json' as json;
import 'dart:html' as html;
import 'package:meta/meta.dart';

import 'dart:html' show
  Element, ImageElement, AudioElement, HttpRequest,
  CanvasElement, CanvasRenderingContext2D, CanvasPattern, CanvasGradient;

import 'dart:web_audio' show
  AudioContext, AudioBuffer, AudioBufferSourceNode, GainNode;

//-----------------------------------------------------------------------------

part 'src/animation/DelayedCall.dart';
part 'src/animation/Animatable.dart';
part 'src/animation/Juggler.dart';
part 'src/animation/TransitionFunction.dart';
part 'src/animation/Tween.dart';
part 'src/animation/Transition.dart';

part 'src/geom/Point.dart';
part 'src/geom/Rectangle.dart';
part 'src/geom/Circle.dart';
part 'src/geom/Matrix.dart';
part 'src/geom/ColorTransform.dart';

part 'src/engine/RenderLoop.dart';
part 'src/engine/RenderState.dart';
part 'src/engine/StageRenderMode.dart';

part 'src/events/Event.dart';
part 'src/events/EventPhase.dart';
part 'src/events/EventDispatcher.dart';
part 'src/events/EventStreamIndex.dart';
part 'src/events/EventStream.dart';
part 'src/events/EventStreamProvider.dart';
part 'src/events/EventStreamSubscription.dart';
part 'src/events/EnterFrameEvent.dart';
part 'src/events/MouseEvent.dart';
part 'src/events/KeyboardEvent.dart';
part 'src/events/TextEvent.dart';
part 'src/events/TouchEvent.dart';

part 'src/filters/BitmapFilter.dart';
part 'src/filters/BlurFilter.dart';
part 'src/filters/ColorMatrixFilter.dart';
part 'src/filters/DropShadowFilter.dart';
part 'src/filters/GlowFilter.dart';

part 'src/display/DisplayObject.dart';
part 'src/display/InteractiveObject.dart';
part 'src/display/DisplayObjectContainer.dart';
part 'src/display/Stage.dart';
part 'src/display/Sprite.dart';
part 'src/display/Bitmap.dart';
part 'src/display/BitmapData.dart';
part 'src/display/BitmapDrawable.dart';
part 'src/display/MovieClip.dart';
part 'src/display/Shape.dart';
part 'src/display/PixelSnapping.dart';
part 'src/display/SimpleButton.dart';
part 'src/display/Graphics.dart';
part 'src/display/GraphicsGradient.dart';
part 'src/display/GraphicsPattern.dart';
part 'src/display/GraphicsCommand.dart';
part 'src/display/CapsStyle.dart';
part 'src/display/JointStyle.dart';
part 'src/display/Mask.dart';

part 'src/displayEx/Gauge.dart';
part 'src/displayEx/TimeGauge.dart';
part 'src/displayEx/GlassPlate.dart';
part 'src/displayEx/ParticleSystem.dart';
part 'src/displayEx/Warp.dart';
part 'src/displayEx/Flump.dart';

part 'src/media/Sound.dart';
part 'src/media/SoundChannel.dart';
part 'src/media/SoundTransform.dart';
part 'src/media/SoundMixer.dart';
part 'src/media/implementation/AudioElementSound.dart';
part 'src/media/implementation/AudioElementSoundChannel.dart';
part 'src/media/implementation/WebAudioApiSound.dart';
part 'src/media/implementation/WebAudioApiSoundChannel.dart';
part 'src/media/implementation/MockSound.dart';
part 'src/media/implementation/MockSoundChannel.dart';

part 'src/text/GridFitType.dart';
part 'src/text/TextField.dart';
part 'src/text/TextFieldAutoSize.dart';
part 'src/text/TextFieldType.dart';
part 'src/text/TextFormat.dart';
part 'src/text/TextFormatAlign.dart';
part 'src/text/TextLineMetrics.dart';

part 'src/ui/KeyLocation.dart';
part 'src/ui/Mouse.dart';
part 'src/ui/MouseCursor.dart';
part 'src/ui/Color.dart';
part 'src/ui/Multitouch.dart';

part 'src/util/ResourceManager.dart';
part 'src/util/TextureAtlas.dart';
part 'src/util/TextureAtlasFormat.dart';
part 'src/util/TextureAtlasFrame.dart';
part 'src/util/Tools.dart';

//-----------------------------------------------------------------------------

bool _isLittleEndianSystem = _checkLittleEndianSystem();


