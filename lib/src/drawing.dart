library stagexl.drawing;

import 'dart:typed_data';
import 'dart:math' show PI, sqrt, sin, cos, tan, atan2, pow;
import 'dart:html' show CanvasRenderingContext2D, CanvasElement, CanvasGradient, CanvasPattern;

import 'geom.dart';
import 'engine.dart';
import 'internal/tools.dart';
import 'internal/jenkins_hash.dart';
import 'internal/shared_cache.dart';

part 'drawing/graphics.dart';
part 'drawing/graphics_command.dart';
part 'drawing/graphics_context.dart';
part 'drawing/graphics_enums.dart';
part 'drawing/graphics_gradient.dart';
part 'drawing/graphics_gradient_program.dart';
part 'drawing/graphics_pattern.dart';

part 'drawing/commands/graphics_command_arc.dart';
part 'drawing/commands/graphics_command_arc_elliptical.dart';
part 'drawing/commands/graphics_command_arc_to.dart';
part 'drawing/commands/graphics_command_begin_path.dart';
part 'drawing/commands/graphics_command_bezier_curve_to.dart';
part 'drawing/commands/graphics_command_circle.dart';
part 'drawing/commands/graphics_command_close_path.dart';
part 'drawing/commands/graphics_command_decode.dart';
part 'drawing/commands/graphics_command_ellipse.dart';
part 'drawing/commands/graphics_command_fill.dart';
part 'drawing/commands/graphics_command_fill_color.dart';
part 'drawing/commands/graphics_command_fill_gradient.dart';
part 'drawing/commands/graphics_command_fill_pattern.dart';
part 'drawing/commands/graphics_command_line_to.dart';
part 'drawing/commands/graphics_command_move_to.dart';
part 'drawing/commands/graphics_command_quadratic_curve_to.dart';
part 'drawing/commands/graphics_command_rect.dart';
part 'drawing/commands/graphics_command_rect_round.dart';
part 'drawing/commands/graphics_command_stroke.dart';
part 'drawing/commands/graphics_command_stroke_color.dart';
part 'drawing/commands/graphics_command_stroke_gradient.dart';
part 'drawing/commands/graphics_command_stroke_pattern.dart';

part 'drawing/internal/graphics_command.dart';
part 'drawing/internal/graphics_context_base.dart';
part 'drawing/internal/graphics_context_bounds.dart';
part 'drawing/internal/graphics_context_canvas.dart';
part 'drawing/internal/graphics_context_compiler.dart';
part 'drawing/internal/graphics_context_hittest.dart';
part 'drawing/internal/graphics_context_render.dart';
part 'drawing/internal/graphics_mesh.dart';
part 'drawing/internal/graphics_mesh_segment.dart';
part 'drawing/internal/graphics_path.dart';
part 'drawing/internal/graphics_path_segment.dart';
part 'drawing/internal/graphics_stroke.dart';
part 'drawing/internal/graphics_stroke_segment.dart';
