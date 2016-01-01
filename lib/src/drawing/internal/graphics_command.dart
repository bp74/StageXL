part of stagexl.drawing.internal;

/// The base class for all graphics commands

abstract class GraphicsCommand {

  void updateContext(GraphicsContext context) {
    // override in command.
  }
}

//-----------------------------------------------------------------------------

/// The base class for all graphics fill commands

abstract class GraphicsCommandFill extends GraphicsCommand {

}

//-----------------------------------------------------------------------------

/// The base class for all graphics strokte commands

abstract class GraphicsCommandStroke extends GraphicsCommand {

  final double width;
  final String jointStyle;
  final String capsStyle;

  GraphicsCommandStroke(this.width, this.jointStyle, this.capsStyle);
}

//-----------------------------------------------------------------------------

/// An internal graphics command used by the graphics command compiler

class GraphicsCommandSetPath extends GraphicsCommand {

  final GraphicsPath path;

  GraphicsCommandSetPath(this.path);

  @override
  void updateContext(GraphicsContext context) {
    context.setPath(path);
  }
}

//-----------------------------------------------------------------------------

/// An internal graphics command used by the graphics command compiler

class GraphicsCommandSetStroke extends GraphicsCommand {

  final GraphicsStroke stroke;

  GraphicsCommandSetStroke(this.stroke);

  @override
  void updateContext(GraphicsContext context) {
    context.setStroke(stroke);
  }
}

