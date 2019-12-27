part of stagexl.engine;

class RenderStatistics {
  int drawCount = 0;
  int vertexCount = 0;
  int indexCount = 0;

  void reset() {
    drawCount = 0;
    vertexCount = 0;
    indexCount = 0;
  }

  @override
  String toString() {
    return 'RenderStatistics: $drawCount draws, $vertexCount verices, $indexCount indices';
  }
}
