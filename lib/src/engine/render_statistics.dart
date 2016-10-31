part of stagexl.engine;

class RenderStatistics {

  int drawCount = 0;
  int vertexCount = 0;
  int indexCount = 0;

  void reset() {
    this.drawCount = 0;
    this.vertexCount = 0;
    this.indexCount = 0;
  }

  @override
  String toString() {
    return "RenderStatistics: $drawCount draws, $vertexCount verices, $indexCount indices";
  }
}
