part of stagexl.display_ex;

/// The [Mesh] class allows free form deformations of a [BitmapData] instance
/// by using triangles to form an arbitrary shape.
///
/// The vertices of the triangles are shared between different triangles.
/// Therefore you should define the vertices first and afterwards define the
/// triangles with the index number of the vertices. Each triangle needs three
/// indices, so the number of indices is three times the number of triangles.
///
/// To get a better understanding, let's take a look at two simple meshes:
/// The left mesh uses 9 vertices and 8 triangles (24 indices).
/// The right mesh uses 7 vertices and 6 triangles (18 indices).
///
///     0─────1─────2          0───────1
///     │   / │   / │         / \     / \
///     │  /  │  /  │        /   \   /   \
///     │ /   │ /   │       /     \ /     \
///     3─────4─────5      5───────6───────2
///     │   / │   / │       \     / \     /
///     │  /  │  /  │        \   /   \   /
///     │ /   │ /   │         \ /     \ /
///     6─────7─────8          4───────3
///
/// Use the [setVertex] and [setTriangleIndices] methods to form the mesh.
/// A vertex is defined by the XY and UV values. The XY values define the
/// position of the vertex in the local coordinate system of the Display
/// Object. The UV values define the pixel location in a 0.0 to 1.0
/// coordinate system of the BitmapData.

class Mesh extends DisplayObject {

  BitmapData bitmapData;

  final int indexCount;
  final int triangleCount;
  final int vertexCount;
  final Int16List ixList;
  final Float32List vxList;

  Float32List _vxListTemp;

  /// Create a new Mesh with [vertexCount] vertices and [triangleCount]
  /// triangles.

  Mesh(this.bitmapData, int vertexCount, int triangleCount)
      : indexCount = triangleCount * 3,
        triangleCount = triangleCount,
        vertexCount = vertexCount,
        ixList = new Int16List(triangleCount * 3),
        vxList = new Float32List(vertexCount * 4);

  /// Create a new grid shaped Mesh with the desired number of [columns]
  /// and [rows]. A 2x2 grid will create 9 vertices.

  factory Mesh.fromGrid(BitmapData bitmapData, int columns, int rows) {

    var width = bitmapData.width;
    var height = bitmapData.height;
    var vertexCount = (columns + 1) * (rows + 1);
    var triangleCount = 2 * columns * rows;
    var mesh = new Mesh(bitmapData, vertexCount, triangleCount);

    for (int r = 0, vertex = 0; r <= rows; r++) {
      for(int c = 0; c <= columns; c++) {
        var u = c / columns;
        var v = r / rows;
        var x = width * u;
        var y = height * v;
        mesh.setVertex(vertex++, x, y, u, v);
      }
    }

    for (int r = 0, triangle = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        var v0 = (r + 0) * (columns + 1) + c + 0;
        var v1 = (r + 0) * (columns + 1) + c + 1;
        var v2 = (r + 1) * (columns + 1) + c + 1;
        var v3 = (r + 1) * (columns + 1) + c + 0;
        mesh.setTriangleIndices(triangle++, v0, v1, v3);
        mesh.setTriangleIndices(triangle++, v1, v3, v2);
      }
    }

    return mesh;
  }

  //---------------------------------------------------------------------------

  /// Set the XY and UV values of a vertex.
  ///
  /// The XY values define the position of the vertex in the local coordinate
  /// system of the Display Object. The UV values define the pixel location in
  /// a 0.0 to 1.0 coordinate system of the BitmapData.

  void setVertex(int vertex, num x, num y, num u, num v) {
    var offset = vertex << 2;
    vxList[offset + 0] = x.toDouble();
    vxList[offset + 1] = y.toDouble();
    vxList[offset + 2] = u.toDouble();
    vxList[offset + 3] = v.toDouble();
  }

  /// Set the XY values of a vertex.
  ///
  /// The XY values define the position of the vertex in the local coordinate
  /// system of the Display Object.

  void setVertexXY(int vertex, num x, num y) {
    var offset = vertex << 2;
    vxList[offset + 0] = x.toDouble();
    vxList[offset + 1] = y.toDouble();
  }

  /// Set the UV values of a vertex.
  ///
  /// The UV values define the pixel location in a 0.0 to 1.0 coordinate system
  /// of the BitmapData.

  void setVertexUV(int vertex, num u, num v) {
    var offset = vertex << 2;
    vxList[offset + 2] = u.toDouble();
    vxList[offset + 3] = v.toDouble();
  }

  /// Set the corresponding vertex for an index.

  void setIndex(int index, int vertex) {
    ixList[index] = vertex;
  }

  /// Set the corresponding vertices for the triangle indices.

  void setTriangleIndices(int triangle, int v1, int v2, int v3) {
    var offset = triangle * 3;
    ixList[offset + 0] = v1;
    ixList[offset + 1] = v2;
    ixList[offset + 2] = v3;
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {

    double left = double.INFINITY;
    double top = double.INFINITY;
    double right = double.NEGATIVE_INFINITY;
    double bottom = double.NEGATIVE_INFINITY;

    for (int i = 0; i < ixList.length; i++) {
      int index = ixList[i + 0];
      var vertexX = vxList[(index << 2) + 0];
      var vertexY = vxList[(index << 2) + 1];
      if (left > vertexX) left = vertexX;
      if (right < vertexX) right = vertexX;
      if (top > vertexY) top = vertexY;
      if (bottom < vertexY) bottom = vertexY;
    }

    return new Rectangle<num>(left, top, right - left, bottom - top);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {

    for (int i = 0; i < ixList.length - 2; i += 3) {

      int i1 = ixList[i + 0] << 2;
      int i2 = ixList[i + 1] << 2;
      int i3 = ixList[i + 2] << 2;

      num x1 = vxList[i1 + 0];
      num y1 = vxList[i1 + 1];
      num x2 = vxList[i2 + 0];
      num y2 = vxList[i2 + 1];
      num x3 = vxList[i3 + 0];
      num y3 = vxList[i3 + 1];

      if (localX < x1 && localX < x2 && localX < x3) continue;
      if (localX > x1 && localX > x2 && localX > x3) continue;
      if (localY < y1 && localY < y2 && localY < y3) continue;
      if (localY > y1 && localY > y2 && localY > y3) continue;

      num vx1 = x3 - x1;
      num vy1 = y3 - y1;
      num vx2 = x2 - x1;
      num vy2 = y2 - y1;
      num vx3 = localX - x1;
      num vy3 = localY - y1;

      num dot11 = vx1 * vx1 + vy1 * vy1;
      num dot12 = vx1 * vx2 + vy1 * vy2;
      num dot13 = vx1 * vx3 + vy1 * vy3;
      num dot22 = vx2 * vx2 + vy2 * vy2;
      num dot23 = vx2 * vx3 + vy2 * vy3;

      num u = (dot22 * dot13 - dot12 * dot23) / (dot11 * dot22 - dot12 * dot12);
      num v = (dot11 * dot23 - dot12 * dot13) / (dot11 * dot22 - dot12 * dot12);

      if ((u >= 0) && (v >= 0) && (u + v < 1)) return this;
    }

    return null;
  }

  @override
  void render(RenderState renderState) {

    var renderContext = renderState.renderContext;
    var renderTextureQuad = bitmapData.renderTextureQuad;
    var renderTexture = bitmapData.renderTexture;

    var matrix = renderTextureQuad.samplerMatrix;
    var ma = matrix.a * bitmapData.width;
    var mb = matrix.b * bitmapData.width;
    var mc = matrix.c * bitmapData.height;
    var md = matrix.d * bitmapData.height;
    var mx = matrix.tx;
    var my = matrix.tx;

    _vxListTemp = _vxListTemp ?? new Float32List(vxList.length);

    for (int i = 0; i < _vxListTemp.length - 3; i += 4) {
      var x = vxList[i + 2];
      var y = vxList[i + 3];
      _vxListTemp[i + 0] = vxList[i + 0];
      _vxListTemp[i + 1] = vxList[i + 1];
      _vxListTemp[i + 2] = mx + x * ma + y * mc;
      _vxListTemp[i + 3] = my + x * mb + y * md;
    }

    renderContext.renderTextureMesh(
        renderState, renderTexture,
        ixList, _vxListTemp);
  }
}
