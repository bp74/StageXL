/// The main classes for the display list. This are the most important class
/// you will need to build your application.
///
/// The [Stage] is the main rendering surface of your application. All objects
/// of the display list do inherit the properties from [DisplayObject]. Your
/// images and artworks are stored in [BitmapData] objects and added to the
/// display list by creating [Bitmap] instances. To group your display objects
/// please use the [Sprite] or [DisplayObjectContainer] base class.
///
/// To get more information about the display list and how to create a stage,
/// please read the wiki article about the basics of StageXL here:
/// [Introducing StageXL](http://www.stagexl.org/docs/wiki-articles.html?article=introduction)
///
library stagexl.display;

import 'dart:js';
import 'dart:async';
import 'dart:web_gl' as gl;
import 'dart:math' as math;
import 'dart:html' as html;
import 'dart:typed_data';

import 'dart:math' hide Point, Rectangle;
import 'dart:html' show ImageElement, VideoElement;
import 'dart:html' show CanvasElement, CanvasRenderingContext2D, CanvasGradient, CanvasPattern;

import 'animation.dart';
import 'drawing.dart';
import 'geom.dart';
import 'engine.dart';
import 'events.dart';
import 'ui.dart';
import 'internal/tools.dart';
import 'internal/image_loader.dart';
import 'internal/environment.dart' as env;

part 'display/bitmap.dart';
part 'display/bitmap_data.dart';
part 'display/bitmap_data_channel.dart';
part 'display/bitmap_data_update_batch.dart';
part 'display/bitmap_data_load_options.dart';
part 'display/bitmap_drawable.dart';
part 'display/bitmap_filter.dart';
part 'display/bitmap_filter_program.dart';
part 'display/color_transform.dart';
part 'display/display_object.dart';
part 'display/display_object_cache.dart';
part 'display/display_object_children.dart';
part 'display/display_object_container.dart';
part 'display/display_object_container_3d.dart';
part 'display/display_object_parent.dart';
part 'display/interactive_object.dart';
part 'display/mask.dart';
part 'display/render_loop.dart';
part 'display/shape.dart';
part 'display/simple_button.dart';
part 'display/sprite.dart';
part 'display/sprite_3d.dart';
part 'display/stage.dart';
part 'display/stage_options.dart';
part 'display/stage_tools.dart';

final Matrix _tmpMatrix = new Matrix.fromIdentity();
final Matrix _identityMatrix = new Matrix.fromIdentity();
