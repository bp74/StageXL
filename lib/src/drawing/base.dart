library stagexl.drawing.base;

import 'dart:html' show CanvasRenderingContext2D, CanvasGradient, CanvasPattern;

import '../internal/tools.dart';
import '../engine.dart';
import '../geom.dart';

part 'base/graphics_command.dart';
part 'base/graphics_context.dart';
part 'base/graphics_gradient.dart';
part 'base/graphics_pattern.dart';

enum JointStyle { MITER, ROUND, BEVEL }
enum CapsStyle { NONE, ROUND, SQUARE }
