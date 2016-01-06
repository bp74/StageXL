part of stagexl.drawing.internal;

/// The base class for all graphics commands

abstract class GraphicsCommand {
  void updateContext(GraphicsContext context) {
    // override in command.
  }
}

/// The base class for all graphics fill commands

abstract class GraphicsCommandFill extends GraphicsCommand {
  GraphicsMesh mesh = null;
  GraphicsCommandFill();
}

/// The base class for all graphics stroke commands

abstract class GraphicsCommandStroke extends GraphicsCommand {
  final double width;
  final JointStyle jointStyle;
  final CapsStyle capsStyle;
  GraphicsMesh mesh = null;
  GraphicsCommandStroke(this.width, this.jointStyle, this.capsStyle);
}
