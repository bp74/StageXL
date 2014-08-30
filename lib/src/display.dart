library stagexl.display;

import 'dart:js';
import 'dart:async';
import 'dart:web_gl' as gl;
import 'dart:math' as math;
import 'dart:html' as html;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show ImageElement;
import 'dart:html' show CanvasElement, CanvasRenderingContext2D, CanvasGradient, CanvasPattern;

import 'animation.dart';
import 'geom.dart';
import 'engine.dart';
import 'events.dart';
import 'ui.dart';

import 'internal/environment.dart' as env;
import 'internal/tools.dart';

part 'display/bitmap.dart';
part 'display/bitmap_data.dart';
part 'display/bitmap_data_channel.dart';
part 'display/bitmap_data_update_batch.dart';
part 'display/bitmap_data_load_options.dart';
part 'display/bitmap_drawable.dart';
part 'display/bitmap_filter.dart';
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
part 'display/render_loop.dart';
part 'display/shape.dart';
part 'display/simple_button.dart';
part 'display/sprite.dart';
part 'display/stage.dart';

final Matrix _identityMatrix = new Matrix.fromIdentity();
final CanvasElement _dummyCanvas = new CanvasElement(width: 16, height: 16);
final CanvasRenderingContext2D _dummyCanvasContext = _dummyCanvas.context2D;

//-----------------------------------------------------------------------------

@deprecated
class Shadow {
  int color;
  num offsetX;
  num offsetY;
  num blur;
  DisplayObject targetSpace;
  Shadow(this.color, this.offsetX, this.offsetY, this.blur);
}

