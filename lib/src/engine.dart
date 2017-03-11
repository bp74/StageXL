/// This are the classes for the underlying rendering engine for the
/// display list. Most users won't need to use this classes in their
/// applications.
///
/// The render engine of StageXL supports the Canvas2D API for older browsers
/// and the more performant and flexible WebGL API for newer browsers.
/// The [RenderContext] and [RenderState] classes do abstract the internal
/// differences of those two render pathes.
///
/// Another basic building block of the engine are the [RenderTexture] and
/// [RenderTextureQuad] classes. More advanced uses may even implement custom
/// WebGL shaders by extending the [RenderProgram] class.
///
library stagexl.engine;

import 'dart:async';
import 'dart:math' as math;
import 'dart:web_gl' as gl;
import 'dart:typed_data';

import 'dart:html'
    show window, ImageElement, CanvasElement, CanvasRenderingContext2D, CanvasImageSource, ImageData, VideoElement, CanvasGradient;

import 'geom/matrix.dart';
import 'geom/matrix_3d.dart';
import 'geom/rectangle.dart';
import 'internal/tools.dart';
import 'drawing.dart';

part 'engine/blend_mode.dart';
part 'engine/render_buffer_index.dart';
part 'engine/render_buffer_vertex.dart';
part 'engine/render_context.dart';
part 'engine/render_context_canvas.dart';
part 'engine/render_context_webgl.dart';
part 'engine/render_filter.dart';
part 'engine/render_frame_buffer.dart';
part 'engine/render_loop_base.dart';
part 'engine/render_mask.dart';
part 'engine/render_object.dart';
part 'engine/render_program.dart';
part 'engine/render_program_tinted.dart';
part 'engine/render_program_simple.dart';
part 'engine/render_program_triangle.dart';
part 'engine/render_program_linear_gradient.dart';
part 'engine/render_program_radial_gradient.dart';
part 'engine/render_state.dart';
part 'engine/render_statistics.dart';
part 'engine/render_stencil_buffer.dart';
part 'engine/render_texture.dart';
part 'engine/render_texture_filtering.dart';
part 'engine/render_texture_quad.dart';
part 'engine/render_texture_wrapping.dart';
