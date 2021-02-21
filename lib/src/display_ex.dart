/// More advanced display objects for special use cases built on top of
/// the basic display objects.
///
library stagexl.display_ex;

import 'dart:async';
import 'dart:html' show CssStyleDeclaration, Element;
import 'dart:math' hide Point, Rectangle;
import 'dart:typed_data';

import 'animation.dart';
import 'display.dart';
import 'engine.dart';
import 'events.dart';
import 'geom.dart';
import 'internal/tools.dart';
import 'media.dart' show Video;
import 'ui/color.dart';

part 'display_ex/canvas_shadow_wrapper.dart';
part 'display_ex/flip_book.dart';
part 'display_ex/gauge.dart';
part 'display_ex/glass_plate.dart';
part 'display_ex/html_object.dart';
part 'display_ex/mesh.dart';
part 'display_ex/scale9_bitmap.dart';
part 'display_ex/time_gauge.dart';
part 'display_ex/video_object.dart';
part 'display_ex/viewport_container.dart';
part 'display_ex/warp.dart';
