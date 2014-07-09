library stagexl;

import 'dart:js';
import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:html' as html;
import 'dart:web_gl' as gl;
import 'dart:typed_data';

import 'dart:html' show
  Element, ImageElement, AudioElement, HttpRequest,
  CanvasElement, CanvasRenderingContext2D, CanvasImageSource,
  CanvasPattern, CanvasGradient, ImageData;

import 'dart:web_audio' show
  AudioContext, AudioBuffer, AudioBufferSourceNode,
  AudioNode, GainNode, PannerNode, DynamicsCompressorNode,
  ChannelSplitterNode, ChannelMergerNode;

//-----------------------------------------------------------------------------

import 'src/geom/circle.dart';
import 'src/geom/matrix.dart';
import 'src/geom/point.dart';
import 'src/geom/polygon.dart';
import 'src/geom/rectangle.dart';
import 'src/geom/vector.dart';

export 'src/geom/circle.dart';
export 'src/geom/matrix.dart';
export 'src/geom/point.dart';
export 'src/geom/polygon.dart';
export 'src/geom/rectangle.dart';
export 'src/geom/vector.dart';

part 'src/animation/animatable.dart';
part 'src/animation/animation_chain.dart';
part 'src/animation/animation_group.dart';
part 'src/animation/delayed_call.dart';
part 'src/animation/juggler.dart';
part 'src/animation/transition.dart';
part 'src/animation/transition_function.dart';
part 'src/animation/tween.dart';

part 'src/display/bitmap.dart';
part 'src/display/bitmap_data.dart';
part 'src/display/bitmap_data_channel.dart';
part 'src/display/bitmap_data_load_options.dart';
part 'src/display/bitmap_drawable.dart';
part 'src/display/button_helper.dart';
part 'src/display/caps_style.dart';
part 'src/display/color_transform.dart';
part 'src/display/composite_operation.dart';
part 'src/display/display_object.dart';
part 'src/display/display_object_container.dart';
part 'src/display/graphics.dart';
part 'src/display/graphics_command.dart';
part 'src/display/graphics_gradient.dart';
part 'src/display/graphics_pattern.dart';
part 'src/display/interactive_object.dart';
part 'src/display/joint_style.dart';
part 'src/display/mask.dart';
part 'src/display/movie_clip.dart';
part 'src/display/shadow.dart';
part 'src/display/shape.dart';
part 'src/display/simple_button.dart';
part 'src/display/sprite.dart';
part 'src/display/stage.dart';

part 'src/displayEx/flip_book.dart';
part 'src/displayEx/gauge.dart';
part 'src/displayEx/glass_plate.dart';
part 'src/displayEx/html_object.dart';
part 'src/displayEx/scale9_bitmap.dart';
part 'src/displayEx/time_gauge.dart';
part 'src/displayEx/warp.dart';

part 'src/engine/render_context.dart';
part 'src/engine/render_context_canvas.dart';
part 'src/engine/render_context_webgl.dart';
part 'src/engine/render_frame_buffer.dart';
part 'src/engine/render_loop.dart';
part 'src/engine/render_program.dart';
part 'src/engine/render_program_quad.dart';
part 'src/engine/render_program_triangle.dart';
part 'src/engine/render_state.dart';
part 'src/engine/render_texture.dart';
part 'src/engine/render_texture_quad.dart';

part 'src/events/broadcast_event.dart';
part 'src/events/event.dart';
part 'src/events/event_dispatcher.dart';
part 'src/events/event_phase.dart';
part 'src/events/event_stream.dart';
part 'src/events/event_stream_provider.dart';
part 'src/events/event_stream_subscription.dart';
part 'src/events/keyboard_event.dart';
part 'src/events/mouse_event.dart';
part 'src/events/text_event.dart';
part 'src/events/touch_event.dart';

part 'src/filters/alpha_mask_filter.dart';
part 'src/filters/bitmap_filter.dart';
part 'src/filters/bitmap_filter_program.dart';
part 'src/filters/blur_filter.dart';
part 'src/filters/color_matrix_filter.dart';
part 'src/filters/displacement_map_filter.dart';
part 'src/filters/drop_shadow_filter.dart';
part 'src/filters/glow_filter.dart';

part 'src/media/sound.dart';
part 'src/media/sound_channel.dart';
part 'src/media/sound_load_options.dart';
part 'src/media/sound_mixer.dart';
part 'src/media/sound_transform.dart';
part 'src/media/implementation/audio_element_mixer.dart';
part 'src/media/implementation/audio_element_sound.dart';
part 'src/media/implementation/audio_element_sound_channel.dart';
part 'src/media/implementation/mock_sound.dart';
part 'src/media/implementation/mock_sound_channel.dart';
part 'src/media/implementation/web_audio_api_mixer.dart';
part 'src/media/implementation/web_audio_api_sound.dart';
part 'src/media/implementation/web_audio_api_sound_channel.dart';

part 'src/text/font_style_metrics.dart';
part 'src/text/text_field.dart';
part 'src/text/text_field_auto_size.dart';
part 'src/text/text_field_type.dart';
part 'src/text/text_format.dart';
part 'src/text/text_format_align.dart';
part 'src/text/text_line_metrics.dart';

part 'src/ui/color.dart';
part 'src/ui/key_location.dart';
part 'src/ui/mouse.dart';
part 'src/ui/mouse_cursor.dart';
part 'src/ui/multitouch.dart';

part 'src/util/image_loader.dart';
part 'src/util/object_pool.dart';
part 'src/util/resource_manager.dart';
part 'src/util/resource_manager_resource.dart';
part 'src/util/sound_sprite.dart';
part 'src/util/sound_sprite_segment.dart';
part 'src/util/sprite_sheet.dart';
part 'src/util/texture_atlas.dart';
part 'src/util/texture_atlas_format.dart';
part 'src/util/texture_atlas_frame.dart';
part 'src/util/tools.dart';

//-----------------------------------------------------------------------------

final bool _autoHiDpi = _checkHiDpi();
final bool _isMobile = _checkMobileDevice();
final bool _isCocoonJS = _checkCocoonJS();
final Future<bool> _isWebpSupported = _checkWebpSupport();

final Matrix _identityMatrix = new Matrix.fromIdentity();

final CanvasElement _dummyCanvas = new CanvasElement(width: 16, height: 16);
final CanvasRenderingContext2D _dummyCanvasContext = _dummyCanvas.context2D;

final num _devicePixelRatio = html.window.devicePixelRatio == null ?
    1.0 : html.window.devicePixelRatio;

