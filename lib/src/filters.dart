/// Filters are used to change the visual appearance of your display objects.
/// Add drop shadows, blur effects, color transformations or other effects
/// in real time (only available if WebGL is available).
///
/// It is recommended to use filters only if WebGL is available. If WebGL is
/// not available and you have to use the Canvas2D renderer, filters are only
/// visible if you apply a cache to your display objects. This is a time
/// consuming operation performed on the CPU.
///
/// Sample: <http://www.stagexl.org/samples/filter/>
///
library stagexl.filters;

import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:html' show CanvasElement, CanvasRenderingContext2D, ImageData;
import 'dart:web_gl' as gl;
import 'dart:typed_data';

import 'display.dart';
import 'engine.dart';
import 'geom.dart';
import 'internal/environment.dart' as env;
import 'internal/filter_helpers.dart';
import 'internal/tools.dart';

part 'filters/alpha_mask_filter.dart';
part 'filters/bitmap_filter_program.dart';
part 'filters/blur_filter.dart';
part 'filters/color_matrix_filter.dart';
part 'filters/displacement_map_filter.dart';
part 'filters/drop_shadow_filter.dart';
part 'filters/flatten_filter.dart';
part 'filters/glow_filter.dart';
