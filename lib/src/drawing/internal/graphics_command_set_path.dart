part of stagexl.drawing.internal;

class GraphicsCommandSetPath extends GraphicsCommand {

  final GraphicsPath path;
  GraphicsCommandSetPath(this.path);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.setPath(path);
  }
}
