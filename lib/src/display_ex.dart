/// More advanced display objects for special use cases built on top of
/// the basic display objects.
///
library stagexl.display_ex;

import 'dart:web_gl' as gl;
import 'dart:typed_data';
import 'dart:math' hide Point, Rectangle;
import 'dart:html' show CanvasRenderingContext2D, CssStyleDeclaration, Element;

import 'animation.dart';
import 'engine.dart';
import 'events.dart';
import 'display.dart';
import 'geom.dart';
import 'internal/tools.dart';
import 'ui/color.dart';

part 'display_ex/bitmap_container.dart';
part 'display_ex/bitmap_container_program.dart';
part 'display_ex/canvas_shadow_wrapper.dart';
part 'display_ex/flip_book.dart';
part 'display_ex/gauge.dart';
part 'display_ex/glass_plate.dart';
part 'display_ex/html_object.dart';
part 'display_ex/scale9_bitmap.dart';
part 'display_ex/time_gauge.dart';
part 'display_ex/warp.dart';

final Matrix _identityMatrix = new Matrix.fromIdentity();
