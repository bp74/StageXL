part of '../../drawing.dart';

class GraphicsCommandSetLineDash extends GraphicsCommand {
  final List<num> _segments;
  final num _lineDashOffset;

  GraphicsCommandSetLineDash(this._segments, this._lineDashOffset);

  @override
  void updateContext(GraphicsContext context) {
    context.setLineDash(_segments, _lineDashOffset);
  }
}
