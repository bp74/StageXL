part of stagexl.drawing;

class GraphicsGradientColorStop {
  final num offset;
  final int color;
  GraphicsGradientColorStop(this.offset, this.color);
}

class GraphicsGradient {

  final num startX;
  final num startY;
  final num startRadius;
  final num endX;
  final num endY;
  final num endRadius;

  final List<GraphicsGradientColorStop> colorStops;
  final String kind;

  GraphicsGradient.linear(this.startX, this.startY, this.endX, this.endY) :
      this.startRadius = 0.0,
      this.endRadius = 0.0,
      this.kind = "linear",
      this.colorStops = new List<GraphicsGradientColorStop>();

  GraphicsGradient.radial(this.startX, this.startY, this.startRadius, this.endX, this.endY, this.endRadius) :
      this.kind = "radial",
      this.colorStops = new List<GraphicsGradientColorStop>();

  //---------------------------------------------------------------------------

  void addColorStop(num offset, int color) {
    var colorStop = new GraphicsGradientColorStop(offset, color);
    this.colorStops.add(colorStop);
  }

}
