part of stagexl.drawing.internal;

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

//-----------------------------------------------------------------------------

class GraphicsCommandMeshColor extends GraphicsCommand {

  final GraphicsMesh mesh;
  final int color;

  GraphicsCommandMeshColor(this.mesh, this.color);

  @override
  void updateContext(GraphicsContextBase context) {
    context.meshColor(this);
  }
}


