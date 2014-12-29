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

  final int vertexCount;
  final int indexCount;
  final int triangleCount;
  final Float32List xyList;
  final Float32List uvList;
  final Int16List indexList;

  final Float32List _uvTemp;

  /// Create a new Mesh with [vertexCount] vertices and [triangleCount]
  /// triangles.

  Mesh(this.bitmapData, int vertexCount, int triangleCount) :
    vertexCount = vertexCount,
    triangleCount = triangleCount,
    indexCount = triangleCount * 3,
    xyList = new Float32List(vertexCount * 2),
    uvList = new Float32List(vertexCount * 2),
    indexList = new Int16List(triangleCount * 3),
    _uvTemp = new Float32List(vertexCount * 2);

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
      for(int c = 0; c < columns; c++) {
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
    xyList[vertex * 2 + 0] = x.toDouble();
    xyList[vertex * 2 + 1] = y.toDouble();
    uvList[vertex * 2 + 0] = u.toDouble();
    uvList[vertex * 2 + 1] = v.toDouble();
  }

  /// Set the XY values of a vertex.
  ///
  /// The XY values define the position of the vertex in the local coordinate
  /// system of the Display Object.

  void setVertexXY(int vertex, num x, num y) {
    xyList[vertex * 2 + 0] = x.toDouble();
    xyList[vertex * 2 + 1] = y.toDouble();
  }

  /// Set the UV values of a vertex.
  ///
  /// The UV values define the pixel location in a 0.0 to 1.0 coordinate system
  /// of the BitmapData.

  void setVertexUV(int vertex, num u, num v) {
    uvList[vertex * 2 + 0] = u.toDouble();
    uvList[vertex * 2 + 1] = v.toDouble();
  }

  /// Set the corresponding vertex for an index.

  void setIndex(int index, int vertex) {
    indexList[index] = vertex;
  }

  /// Set the corresponding vertices for the triangle indices.

  void setTriangleIndices(int triangle, int v1, int v2, int v3) {
    indexList[triangle * 3 + 0] = v1;
    indexList[triangle * 3 + 1] = v2;
    indexList[triangle * 3 + 2] = v3;
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {

    double left = double.INFINITY;
    double top = double.INFINITY;
    double right = double.NEGATIVE_INFINITY;
    double bottom = double.NEGATIVE_INFINITY;

    for (int i = 0; i < indexList.length; i++) {
      int index = indexList[i + 0];
      num vertexX = xyList[index * 2 + 0];
      num vertexY = xyList[index * 2 + 1];
      if (left > vertexX) left = vertexX;
      if (right < vertexX) right = vertexX;
      if (top > vertexY) top = vertexY;
      if (bottom < vertexY) bottom = vertexY;
    }

    return new Rectangle<num>(left, top, right - left, bottom - top);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {

    for (int i = 0; i < indexList.length - 2; i += 3) {

      int i1 = indexList[i + 0];
      int i2 = indexList[i + 1];
      int i3 = indexList[i + 2];

      num x1 = xyList[i1 * 2 + 0];
      num y1 = xyList[i1 * 2 + 1];
      num x2 = xyList[i2 * 2 + 0];
      num y2 = xyList[i2 * 2 + 1];
      num x3 = xyList[i3 * 2 + 0];
      num y3 = xyList[i3 * 2 + 1];

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

    var u1 = renderTextureQuad.uvList[0];
    var v1 = renderTextureQuad.uvList[1];
    var u2 = renderTextureQuad.uvList[4];
    var v2 = renderTextureQuad.uvList[5];
    var rotation = renderTextureQuad.rotation;
    var horizontal = rotation == 0 || rotation == 2;

    for (int i = 0; i < uvList.length - 1; i += 2) {
      var u = horizontal ? uvList[i + 0] : uvList[i + 1];
      var v = horizontal ? uvList[i + 1] : uvList[i + 0];
      _uvTemp[i + 0] = u1 + (u2 - u1) * u;
      _uvTemp[i + 1] = v1 + (v2 - v1) * v;
    }

    renderContext.renderMesh(
        renderState, renderTexture,
        indexCount, indexList,
        vertexCount, xyList, _uvTemp);
  }
}
