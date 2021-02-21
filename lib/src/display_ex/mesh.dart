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

  Float32List? _vxListTemp;

  /// Create a new Mesh with [vertexCount] vertices and [triangleCount]
  /// triangles.

  Mesh(this.bitmapData, this.vertexCount, this.triangleCount)
      : indexCount = triangleCount * 3,
        ixList = Int16List(triangleCount * 3),
        vxList = Float32List(vertexCount * 4);

  /// Create a new grid shaped Mesh with the desired number of [columns]
  /// and [rows]. A 2x2 grid will create 9 vertices.

  factory Mesh.fromGrid(BitmapData bitmapData, int columns, int rows) {
    final width = bitmapData.width;
    final height = bitmapData.height;
    final vertexCount = (columns + 1) * (rows + 1);
    final triangleCount = 2 * columns * rows;
    final mesh = Mesh(bitmapData, vertexCount, triangleCount);

    for (var r = 0, vertex = 0; r <= rows; r++) {
      for (var c = 0; c <= columns; c++) {
        final u = c / columns;
        final v = r / rows;
        final x = width * u;
        final y = height * v;
        mesh.setVertex(vertex++, x, y, u, v);
      }
    }

    for (var r = 0, triangle = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final v0 = (r + 0) * (columns + 1) + c + 0;
        final v1 = (r + 0) * (columns + 1) + c + 1;
        final v2 = (r + 1) * (columns + 1) + c + 1;
        final v3 = (r + 1) * (columns + 1) + c + 0;
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
    final offset = vertex << 2;
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
    final offset = vertex << 2;
    vxList[offset + 0] = x.toDouble();
    vxList[offset + 1] = y.toDouble();
  }

  /// Set the UV values of a vertex.
  ///
  /// The UV values define the pixel location in a 0.0 to 1.0 coordinate system
  /// of the BitmapData.

  void setVertexUV(int vertex, num u, num v) {
    final offset = vertex << 2;
    vxList[offset + 2] = u.toDouble();
    vxList[offset + 3] = v.toDouble();
  }

  /// Set the corresponding vertex for an index.

  void setIndex(int index, int vertex) {
    ixList[index] = vertex;
  }

  /// Set the corresponding vertices for the triangle indices.

  void setTriangleIndices(int triangle, int v1, int v2, int v3) {
    final offset = triangle * 3;
    ixList[offset + 0] = v1;
    ixList[offset + 1] = v2;
    ixList[offset + 2] = v3;
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;

    for (var i = 0; i < ixList.length; i++) {
      final index = ixList[i + 0];
      final vertexX = vxList[(index << 2) + 0];
      final vertexY = vxList[(index << 2) + 1];
      if (left > vertexX) left = vertexX;
      if (right < vertexX) right = vertexX;
      if (top > vertexY) top = vertexY;
      if (bottom < vertexY) bottom = vertexY;
    }

    return Rectangle<num>(left, top, right - left, bottom - top);
  }

  @override
  DisplayObject? hitTestInput(num localX, num localY) {
    for (var i = 0; i < ixList.length - 2; i += 3) {
      final i1 = ixList[i + 0] << 2;
      final i2 = ixList[i + 1] << 2;
      final i3 = ixList[i + 2] << 2;

      final x1 = vxList[i1 + 0];
      final y1 = vxList[i1 + 1];
      final x2 = vxList[i2 + 0];
      final y2 = vxList[i2 + 1];
      final x3 = vxList[i3 + 0];
      final y3 = vxList[i3 + 1];

      if (localX < x1 && localX < x2 && localX < x3) continue;
      if (localX > x1 && localX > x2 && localX > x3) continue;
      if (localY < y1 && localY < y2 && localY < y3) continue;
      if (localY > y1 && localY > y2 && localY > y3) continue;

      final vx1 = x3 - x1;
      final vy1 = y3 - y1;
      final vx2 = x2 - x1;
      final vy2 = y2 - y1;
      final vx3 = localX - x1;
      final vy3 = localY - y1;

      final dot11 = vx1 * vx1 + vy1 * vy1;
      final dot12 = vx1 * vx2 + vy1 * vy2;
      final dot13 = vx1 * vx3 + vy1 * vy3;
      final dot22 = vx2 * vx2 + vy2 * vy2;
      final dot23 = vx2 * vx3 + vy2 * vy3;

      final u =
          (dot22 * dot13 - dot12 * dot23) / (dot11 * dot22 - dot12 * dot12);
      final v =
          (dot11 * dot23 - dot12 * dot13) / (dot11 * dot22 - dot12 * dot12);

      if ((u >= 0) && (v >= 0) && (u + v < 1)) return this;
    }

    return null;
  }

  @override
  void render(RenderState renderState) {
    final renderContext = renderState.renderContext;
    final renderTextureQuad = bitmapData.renderTextureQuad;
    final renderTexture = bitmapData.renderTexture;

    final matrix = renderTextureQuad.samplerMatrix;
    final ma = matrix.a * bitmapData.width;
    final mb = matrix.b * bitmapData.width;
    final mc = matrix.c * bitmapData.height;
    final md = matrix.d * bitmapData.height;
    final mx = matrix.tx;
    final my = matrix.tx;

    final vxListTemp = _vxListTemp ?? Float32List(vxList.length);
    _vxListTemp = vxListTemp;

    for (var i = 0; i < vxListTemp.length - 3; i += 4) {
      final x = vxList[i + 2];
      final y = vxList[i + 3];
      vxListTemp[i + 0] = vxList[i + 0];
      vxListTemp[i + 1] = vxList[i + 1];
      vxListTemp[i + 2] = mx + x * ma + y * mc;
      vxListTemp[i + 3] = my + x * mb + y * md;
    }

    renderContext.renderTextureMesh(
        renderState, renderTexture, ixList, vxListTemp);
  }
}
