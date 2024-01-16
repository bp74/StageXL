part of '../display_ex.dart';

/// The Scale9Bitmap display object divides it's BitmapData into a 3x3 grid
/// defined by the [grid] rectangle. The corners of the grid are rendered
/// in it's orignal form. The fields between the corners are scaled to get
/// the size defined by the [width] and [height] properties.

class Scale9Bitmap extends Bitmap {
  Rectangle<num> _grid;
  num _width = 0.0;
  num _height = 0.0;

  final List<RenderTextureQuad?> _slices = List.filled(9, null);

  Scale9Bitmap(BitmapData bitmapData, Rectangle<num> grid)
      : _grid = grid,
        super(bitmapData) {
    _width = bitmapData.width;
    _height = bitmapData.height;
    _updateRenderTextureQuads();
  }

  //---------------------------------------------------------------------------

  /// Gets and sets the width of this Scale9Bitmap. In contrast to other
  /// display objects, this does not affect the scaleX factor.

  @override
  num get width => _width;

  @override
  set width(num value) {
    _width = value;
  }

  /// Gets and sets the height of this Scale9Bitmap. In contrast to other
  /// display objects, this does not affect the scaleY factor.

  @override
  num get height => _height;

  @override
  set height(num value) {
    _height = value;
  }

  /// Gets and sets the grid rectangle within the BitmapData to be scaled.

  Rectangle<num> get grid => _grid;

  set grid(Rectangle<num> value) {
    _grid = value;
    _updateRenderTextureQuads();
  }

  /// Gets and sets the BitmapData of this Scale9Bitmap.

  @override
  set bitmapData(BitmapData? value) {
    super.bitmapData = value;
    _updateRenderTextureQuads();
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds => Rectangle<num>(0.0, 0.0, _width, _height);

  @override
  DisplayObject? hitTestInput(num localX, num localY) {
    if (localX < 0.0 || localX >= _width) return null;
    if (localY < 0.0 || localY >= _height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {
    // We could use renderState.renderTextureMesh, it would work great with
    // the WebGL renderer but not so good with the Canvas2D renderer.

    // If first slice set, all the rest should be too
    if (_slices.first == null) return;

    final globalMatrix = renderState.globalMatrix;
    final renderContext = renderState.renderContext;
    final tempMatrix = globalMatrix.clone();

    final w0 = _slices[0]!.targetWidth;
    final h0 = _slices[0]!.targetHeight;
    final w1 = _slices[4]!.targetWidth;
    final h1 = _slices[4]!.targetHeight;
    final w2 = _slices[8]!.targetWidth;
    final h2 = _slices[8]!.targetHeight;

    for (var j = 0; j < 3; j++) {
      final sh = j == 0
          ? h0
          : j == 2
              ? h2
              : h1;
      final th = j == 0
          ? h0
          : j == 2
              ? h2
              : height - h0 - h2;
      final ty = j == 0
          ? 0
          : j == 1
              ? h0
              : height - h2;
      for (var i = 0; i < 3; i++) {
        final sw = i == 0
            ? w0
            : i == 2
                ? w2
                : w1;
        final tw = i == 0
            ? w0
            : i == 2
                ? w2
                : width - w0 - w2;
        final tx = i == 0
            ? 0
            : i == 1
                ? w0
                : width - w2;
        globalMatrix.setTo(tw / sw, 0, 0, th / sh, tx, ty);
        globalMatrix.concat(tempMatrix);
        renderContext.renderTextureQuad(renderState, _slices[i + j * 3]!);
      }
    }

    globalMatrix.copyFrom(tempMatrix);
  }

  //---------------------------------------------------------------------------

  void _updateRenderTextureQuads() {
    if (bitmapData == null) return;

    final rtq = bitmapData!.renderTextureQuad;

    const x0 = 0;
    final x1 = (rtq.pixelRatio * grid.left).round();
    final x2 = (rtq.pixelRatio * grid.right).round();
    final x3 = rtq.sourceRectangle.width;

    const y0 = 0;
    final y1 = (rtq.pixelRatio * grid.top).round();
    final y2 = (rtq.pixelRatio * grid.bottom).round();
    final y3 = rtq.sourceRectangle.height;

    for (var j = 0; j < 3; j++) {
      final y = j == 0
          ? y0
          : j == 1
              ? y1
              : y2;
      final h = (j == 0
              ? y1
              : j == 1
                  ? y2
                  : y3) -
          y;
      for (var i = 0; i < 3; i++) {
        final x = i == 0
            ? x0
            : i == 1
                ? x1
                : x2;
        final w = (i == 0
                ? x1
                : i == 1
                    ? x2
                    : x3) -
            x;
        final source = Rectangle<int>(x, y, w, h);
        final offset = Rectangle<int>(0, 0, w, h);
        final slice = RenderTextureQuad.slice(rtq, source, offset);
        _slices[i + j * 3] = slice;
      }
    }
  }
}
