part of stagexl.drawing;

/// The base class for all graphics commands

abstract class GraphicsCommand {

  Graphics _graphics = null;

  Graphics get graphics => _graphics;

  void updateContext(GraphicsContext context);
  void invalidate() => _graphics?.invalidate(this);
}

