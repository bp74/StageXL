library stagexl.drawing;

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show CanvasElement, CanvasRenderingContext2D, CanvasGradient, CanvasPattern;

import 'geom.dart';
import 'engine.dart';
import 'internal/tools.dart';

part 'drawing/caps_style.dart';
part 'drawing/graphics.dart';
part 'drawing/graphics_bounds.dart';
part 'drawing/graphics_command.dart';
part 'drawing/graphics_command_fill.dart';
part 'drawing/graphics_command_stroke.dart';
part 'drawing/graphics_gradient.dart';
part 'drawing/graphics_pattern.dart';
part 'drawing/joint_style.dart';

part 'drawing/commands/graphics_command_arc.dart';
part 'drawing/commands/graphics_command_arc_to.dart';
part 'drawing/commands/graphics_command_begin_path.dart';
part 'drawing/commands/graphics_command_bezier_curve_to.dart';
part 'drawing/commands/graphics_command_close_path.dart';
part 'drawing/commands/graphics_command_fill_color.dart';
part 'drawing/commands/graphics_command_fill_gradient.dart';
part 'drawing/commands/graphics_command_fill_pattern.dart';
part 'drawing/commands/graphics_command_line_to.dart';
part 'drawing/commands/graphics_command_move_to.dart';
part 'drawing/commands/graphics_command_quadratic_curve_to.dart';
part 'drawing/commands/graphics_command_rect.dart';
part 'drawing/commands/graphics_command_stroke_color.dart';
part 'drawing/commands/graphics_command_stroke_gradient.dart';
part 'drawing/commands/graphics_command_stroke_pattern.dart';

final CanvasElement _dummyCanvas = new CanvasElement(width: 16, height: 16);
final CanvasRenderingContext2D _dummyCanvasContext = _dummyCanvas.context2D;
