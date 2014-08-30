library stagexl.all;

import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:html' as html;
import 'dart:web_gl' as gl;
import 'dart:typed_data';

import 'dart:html' show Element, ImageElement, AudioElement, HttpRequest,
    CanvasElement, CanvasRenderingContext2D, CanvasImageSource, CanvasPattern,
    CanvasGradient, ImageData;

//-----------------------------------------------------------------------------

import 'filters/image_data_helpers.dart';
import 'internal/environment.dart' as env;
import 'internal/tools.dart';

import 'animation.dart';
import 'display.dart';
import 'engine.dart';
import 'events.dart';
import 'geom.dart';
import 'ui.dart';

part 'displayEx/bitmap_container.dart';
part 'displayEx/bitmap_container_program.dart';
part 'displayEx/button_helper.dart';
part 'displayEx/canvas_shadow_wrapper.dart';
part 'displayEx/flip_book.dart';
part 'displayEx/gauge.dart';
part 'displayEx/glass_plate.dart';
part 'displayEx/html_object.dart';
part 'displayEx/movie_clip.dart';
part 'displayEx/scale9_bitmap.dart';
part 'displayEx/time_gauge.dart';
part 'displayEx/warp.dart';

part 'filters/alpha_mask_filter.dart';
part 'filters/bitmap_filter_program.dart';
part 'filters/blur_filter.dart';
part 'filters/color_matrix_filter.dart';
part 'filters/displacement_map_filter.dart';
part 'filters/drop_shadow_filter.dart';
part 'filters/flatten_filter.dart';
part 'filters/glow_filter.dart';

part 'text/font_style_metrics.dart';
part 'text/text_field.dart';
part 'text/text_field_auto_size.dart';
part 'text/text_field_type.dart';
part 'text/text_format.dart';
part 'text/text_format_align.dart';
part 'text/text_line_metrics.dart';

//-----------------------------------------------------------------------------

final Matrix _identityMatrix = new Matrix.fromIdentity();

final CanvasElement _dummyCanvas = new CanvasElement(width: 16, height: 16);
final CanvasRenderingContext2D _dummyCanvasContext = _dummyCanvas.context2D;

