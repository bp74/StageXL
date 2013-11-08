library stagexl;

import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:convert';
import 'dart:html' as html;

import 'dart:html' show
  Element, ImageElement, AudioElement, HttpRequest,
  CanvasElement, CanvasRenderingContext2D, CanvasImageSource,
  CanvasPattern, CanvasGradient, ImageData;

import 'dart:web_audio' show
  AudioContext, AudioBuffer, AudioBufferSourceNode,
  AudioNode, GainNode, PannerNode, DynamicsCompressorNode,
  ChannelSplitterNode, ChannelMergerNode;

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
part 'src/geom/Vector.dart';

part 'src/engine/RenderLoop.dart';
part 'src/engine/RenderState.dart';

part 'src/events/Event.dart';
part 'src/events/EventPhase.dart';
part 'src/events/EventDispatcher.dart';
part 'src/events/EventStream.dart';
part 'src/events/EventStreamProvider.dart';
part 'src/events/EventStreamSubscription.dart';
part 'src/events/BroadcastEvent.dart';
part 'src/events/MouseEvent.dart';
part 'src/events/KeyboardEvent.dart';
part 'src/events/TextEvent.dart';
part 'src/events/TouchEvent.dart';

part 'src/filters/BitmapFilter.dart';
part 'src/filters/BlurFilter.dart';
part 'src/filters/ColorMatrixFilter.dart';
part 'src/filters/DropShadowFilter.dart';
part 'src/filters/GlowFilter.dart';
part 'src/filters/AlphaMaskFilter.dart';

part 'src/display/DisplayObject.dart';
part 'src/display/InteractiveObject.dart';
part 'src/display/DisplayObjectContainer.dart';
part 'src/display/Stage.dart';
part 'src/display/Sprite.dart';
part 'src/display/Bitmap.dart';
part 'src/display/BitmapData.dart';
part 'src/display/BitmapDataLoadOptions.dart';
part 'src/display/BitmapDrawable.dart';
part 'src/display/MovieClip.dart';
part 'src/display/ButtonHelper.dart';
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
part 'src/display/Shadow.dart';
part 'src/display/CompositeOperation.dart';

part 'src/displayEx/FlipBook.dart';
part 'src/displayEx/Gauge.dart';
part 'src/displayEx/TimeGauge.dart';
part 'src/displayEx/GlassPlate.dart';
part 'src/displayEx/Warp.dart';

part 'src/media/Sound.dart';
part 'src/media/SoundChannel.dart';
part 'src/media/SoundLoadOptions.dart';
part 'src/media/SoundTransform.dart';
part 'src/media/SoundMixer.dart';
part 'src/media/implementation/AudioElementMixer.dart';
part 'src/media/implementation/AudioElementSound.dart';
part 'src/media/implementation/AudioElementSoundChannel.dart';
part 'src/media/implementation/WebAudioApiMixer.dart';
part 'src/media/implementation/WebAudioApiSound.dart';
part 'src/media/implementation/WebAudioApiSoundChannel.dart';
part 'src/media/implementation/MockSound.dart';
part 'src/media/implementation/MockSoundChannel.dart';

part 'src/text/FontStyleMetrics.dart';
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
part 'src/util/ResourceManagerResource.dart';
part 'src/util/TextureAtlas.dart';
part 'src/util/TextureAtlasFormat.dart';
part 'src/util/TextureAtlasFrame.dart';
part 'src/util/Tools.dart';
part 'src/util/ObjectPool.dart';

//-----------------------------------------------------------------------------

final bool _isLittleEndianSystem = _checkLittleEndianSystem();

final Future<bool> _isWebpSupported = _checkWebpSupport();

final Matrix _identityMatrix = new Matrix.fromIdentity();

final CanvasElement _dummyCanvas = new CanvasElement(width: 16, height: 16);
final CanvasRenderingContext2D _dummyCanvasContext = _dummyCanvas.context2D;

final num _backingStorePixelRatio = _dummyCanvasContext.backingStorePixelRatio == null ?
    1.0 : _dummyCanvasContext.backingStorePixelRatio.toDouble();

final num _devicePixelRatio = html.window.devicePixelRatio == null ?
    1.0 : html.window.devicePixelRatio;

final bool _isMobile = (() {
  var ua = html.window.navigator.userAgent.toLowerCase();
  return ua.indexOf("iphone") >= 0 || ua.indexOf("ipad") >= 0 || ua.indexOf("ipod") >= 0
  || ua.indexOf("android") >= 0 || ua.indexOf("webos") >= 0 || ua.indexOf("windows phone") >= 0;
})();

final int _screenMax = html.window.screen == null ? 1024 : max(html.window.screen.width, html.window.screen.height);
final bool _autoHiDpi = _devicePixelRatio > 1.0 && (!_isMobile || _screenMax > 480); // only recent devices (> iPhone4) and hi-dpi desktops
