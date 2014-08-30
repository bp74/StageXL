library stagexl.text;

import 'dart:html' as html;
import 'dart:html' show CanvasElement, CanvasRenderingContext2D, Element;
import 'dart:math' hide Point, Rectangle;

import 'display.dart';
import 'engine.dart';
import 'events.dart';
import 'geom.dart';
import 'ui.dart';
import 'internal/environment.dart' as env;
import 'internal/tools.dart';

part 'text/font_style_metrics.dart';
part 'text/text_field.dart';
part 'text/text_field_auto_size.dart';
part 'text/text_field_type.dart';
part 'text/text_format.dart';
part 'text/text_format_align.dart';
part 'text/text_line_metrics.dart';

final CanvasElement _dummyCanvas = new CanvasElement(width: 16, height: 16);
final CanvasRenderingContext2D _dummyCanvasContext = _dummyCanvas.context2D;

