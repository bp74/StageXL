library stagexl.all;

import 'dart:js';
import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:html' as html;
import 'dart:web_gl' as gl;
import 'dart:typed_data';

import 'dart:html' show Element, ImageElement, AudioElement, HttpRequest,
    CanvasElement, CanvasRenderingContext2D, CanvasImageSource, CanvasPattern,
    CanvasGradient, ImageData;

//-----------------------------------------------------------------------------

import 'internal/environment.dart' as env;
import 'internal/tools.dart';

import 'engine.dart';
import 'events.dart';
import 'geom.dart';
import 'media.dart';
import 'ui.dart';

part 'animation/animatable.dart';
part 'animation/animation_chain.dart';
part 'animation/animation_group.dart';
part 'animation/delayed_call.dart';
part 'animation/juggler.dart';
part 'animation/transition.dart';
part 'animation/transition_function.dart';
part 'animation/tween.dart';

part 'display/bitmap.dart';
part 'display/bitmap_data.dart';
part 'display/bitmap_data_channel.dart';
part 'display/bitmap_data_update_batch.dart';
part 'display/bitmap_data_load_options.dart';
part 'display/bitmap_drawable.dart';
part 'display/button_helper.dart';
part 'display/caps_style.dart';
part 'display/color_transform.dart';
part 'display/display_object.dart';
part 'display/display_object_container.dart';
part 'display/graphics.dart';
part 'display/graphics_command.dart';
part 'display/graphics_gradient.dart';
part 'display/graphics_pattern.dart';
part 'display/interactive_object.dart';
part 'display/joint_style.dart';
part 'display/mask.dart';
part 'display/movie_clip.dart';
part 'display/render_loop.dart';
part 'display/shape.dart';
part 'display/simple_button.dart';
part 'display/sprite.dart';
part 'display/stage.dart';

part 'displayEx/bitmap_container.dart';
part 'displayEx/bitmap_container_program.dart';
part 'displayEx/canvas_shadow_wrapper.dart';
part 'displayEx/flip_book.dart';
part 'displayEx/gauge.dart';
part 'displayEx/glass_plate.dart';
part 'displayEx/html_object.dart';
part 'displayEx/scale9_bitmap.dart';
part 'displayEx/time_gauge.dart';
part 'displayEx/warp.dart';

part 'filters/alpha_mask_filter.dart';
part 'filters/bitmap_filter.dart';
part 'filters/bitmap_filter_program.dart';
part 'filters/blur_filter.dart';
part 'filters/color_matrix_filter.dart';
part 'filters/displacement_map_filter.dart';
part 'filters/drop_shadow_filter.dart';
part 'filters/flatten_filter.dart';
part 'filters/glow_filter.dart';

part 'resources/resource_manager.dart';
part 'resources/resource_manager_resource.dart';
part 'resources/sound_sprite.dart';
part 'resources/sound_sprite_segment.dart';
part 'resources/sprite_sheet.dart';
part 'resources/texture_atlas.dart';
part 'resources/texture_atlas_format.dart';
part 'resources/texture_atlas_frame.dart';

part 'text/font_style_metrics.dart';
part 'text/text_field.dart';
part 'text/text_field_auto_size.dart';
part 'text/text_field_type.dart';
part 'text/text_format.dart';
part 'text/text_format_align.dart';
part 'text/text_line_metrics.dart';

part 'ui/key_location.dart';
part 'ui/mouse.dart';
part 'ui/mouse_cursor.dart';
part 'ui/multitouch.dart';

//-----------------------------------------------------------------------------

final Matrix _identityMatrix = new Matrix.fromIdentity();

final CanvasElement _dummyCanvas = new CanvasElement(width: 16, height: 16);
final CanvasRenderingContext2D _dummyCanvasContext = _dummyCanvas.context2D;

