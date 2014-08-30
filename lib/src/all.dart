library stagexl.all;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' as html;
import 'dart:web_gl' as gl;
import 'dart:typed_data';

import 'dart:html' show Element, ImageElement, AudioElement, HttpRequest,
    CanvasElement, CanvasRenderingContext2D, CanvasImageSource, CanvasPattern,
    CanvasGradient, ImageData;

//-----------------------------------------------------------------------------

import 'internal/tools.dart';

import 'animation.dart';
import 'display.dart';
import 'engine.dart';
import 'events.dart';
import 'geom.dart';
import 'text.dart';
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

//-----------------------------------------------------------------------------

final Matrix _identityMatrix = new Matrix.fromIdentity();

