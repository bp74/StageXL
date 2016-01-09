part of stagexl.drawing.base;

/// The base class for all graphics commands

abstract class GraphicsCommand {

  void updateContext(GraphicsContext context);
}

/// The base class for all graphics fill commands

abstract class GraphicsCommandFill extends GraphicsCommand {
  GraphicsCommandFill();
}

/// The base class for all graphics stroke commands

abstract class GraphicsCommandStroke extends GraphicsCommand {
  final double width;
  final JointStyle jointStyle;
  final CapsStyle capsStyle;
  GraphicsCommandStroke(this.width, this.jointStyle, this.capsStyle);
}
