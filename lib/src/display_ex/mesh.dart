part of stagexl.display_ex;

/// The [Mesh] class allows free form deformations of a [BitmapData] instance
/// by using triangles to form an arbitrary shape.
///
/// Use the vertex- and index-list to build a mesh of triangles. Later you can
/// change the vertices or indices to animate or change the mesh in any way
/// you want. A triangle is defined by 3 vertices. Vertices are shared between
/// triangles and therefore you need less vertices than indices.
///
/// Below are two simple meshes:
/// The left mesh uses 9 vertices and 24 indices for 8 triangles.
/// The right mesh uses 7 vertices and 18 indices for 6 triangles.
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
/// Use the [setVertex] or [setIndex] methods to deform this meshes. A vertex
/// is defined by the XY and UV values. The XY values define the position of
/// the vertex in the local coordinate system of the Display Object. The UV
/// values define the pixel location in a 0.0 to 1.0 coordinate system of the
/// BitmapData.

class Mesh extends DisplayObject {

  BitmapData bitmapData;

  final int vertexCount;
  final int indexCount;
  final Float32List xyList;
  final Float32List uvList;
  final Int16List indexList;

  final Float32List _uvTemp;
  final Rectangle<num> _bounds;

  Mesh(this.bitmapData, int vertexCount, int indexCount) :
    vertexCount = vertexCount,
    indexCount = indexCount,
    xyList = new Float32List(vertexCount * 2),
    uvList = new Float32List(vertexCount * 2),
    indexList = new Int16List(indexCount),
    _uvTemp = new Float32List(vertexCount * 2),
    _bounds = new Rectangle<double>(0.0, 0.0, 0.0, 0.0);

  factory Mesh.fromGrid(BitmapData bitmapData, int columns, int rows) {

    var width = bitmapData.width;
    var height = bitmapData.height;
    var vertexCount = (columns + 1) * (rows + 1);
    var indexCount = 3 * 2 * columns * rows;
    var mesh = new Mesh(bitmapData, vertexCount, indexCount);

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
        mesh.setIndexTriangle(triangle++, v0, v1, v3);
        mesh.setIndexTriangle(triangle++, v1, v3, v2);
      }
    }

    return mesh;
  }

  //---------------------------------------------------------------------------

 /// Change the XY and UV values of the vertex.
 ///
  void setVertex(int vertex, num x, num y, num u, num v) {
    xyList[vertex * 2 + 0] = x.toDouble();
    xyList[vertex * 2 + 1] = y.toDouble();
    uvList[vertex * 2 + 0] = u.toDouble();
    uvList[vertex * 2 + 1] = v.toDouble();
  }

  /// Change the XY values of the vertex.
  ///
  /// The XY values define the position of the vertex in the local coordinate
  /// system of the Display Object.

  void setVertexXY(int vertex, num x, num y) {
    xyList[vertex * 2 + 0] = x.toDouble();
    xyList[vertex * 2 + 1] = y.toDouble();
  }

  /// Change the UV values of the vertex.
  ///
  /// The UV values define the pixel location in a 0.0 to 1.0 coordinate system
  /// of the BitmapData.

  void setVertexUV(int vertex, num u, num v) {
    uvList[vertex * 2 + 0] = u.toDouble();
    uvList[vertex * 2 + 1] = v.toDouble();
  }

  /// Change the vertex for a given index.

  void setIndex(int index, int vertex) {
    indexList[index] = vertex;
  }

  /// Change the vertices for a given triangle.

  void setIndexTriangle(int triangle, int v1, int v2, int v3) {
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

    for(int i = 0; i < indexList.length; i++) {
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

    for(int i = 0; i < indexList.length - 2; i += 3) {

      int i1 = indexList[i + 0];
      int i2 = indexList[i + 1];
      int i3 = indexList[i + 2];

      num ax = xyList[i1 * 2 + 0];
      num ay = xyList[i1 * 2 + 1];
      num bx = xyList[i2 * 2 + 0];
      num by = xyList[i2 * 2 + 1];
      num cx = xyList[i3 * 2 + 0];
      num cy = xyList[i3 * 2 + 1];

      if (localX < ax && localX < bx && localX < cx) continue;
      if (localX > ax && localX > bx && localX > cx) continue;
      if (localY < ay && localY < by && localY < cy) continue;
      if (localY > ay && localY > by && localY > cy) continue;

      num v0x = cx - ax;
      num v0y = cy - ay;
      num v1x = bx - ax;
      num v1y = by - ay;
      num v2x = localX - ax;
      num v2y = localY - ay;

      num dot00 = v0x * v0x + v0y * v0y;
      num dot01 = v0x * v1x + v0y * v1y;
      num dot02 = v0x * v2x + v0y * v2y;
      num dot11 = v1x * v1x + v1y * v1y;
      num dot12 = v1x * v2x + v1y * v2y;

      num u = (dot11 * dot02 - dot01 * dot12) / (dot00 * dot11 - dot01 * dot01);
      num v = (dot00 * dot12 - dot01 * dot02) / (dot00 * dot11 - dot01 * dot01);

      if ((u >= 0) && (v >= 0) && (u + v < 1)) return this;
    }

    return null;
  }

  @override
  void render(RenderState renderState) {
    if (this.bitmapData != null) {
      if (renderState.renderContext is RenderContextWebGL) {
        _renderWebGL(renderState);
      } else {
        _renderMaskCanvas(renderState);
      }
    }
  }

  //---------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    RenderContextWebGL renderContext = renderState.renderContext;
    var renderProgram = renderContext.renderProgramMesh;
    var renderTextureQuad = bitmapData.renderTextureQuad;
    var globalMatrix = renderState.globalMatrix;
    var globalAlpha = renderState.globalAlpha;

    var u1 = renderTextureQuad.uvList[0];
    var v1 = renderTextureQuad.uvList[1];
    var u2 = renderTextureQuad.uvList[4];
    var v2 = renderTextureQuad.uvList[5];

    if (renderTextureQuad.rotation == 0 || renderTextureQuad.rotation == 2) {
      for (int i = 0; i < uvList.length - 1; i += 2) {
        _uvTemp[i + 0] = u1 + uvList[i + 0] * (u2 - u1);
        _uvTemp[i + 1] = v1 + uvList[i + 1] * (v2 - v1);
      }
    } else {
      for (int i = 0; i < uvList.length - 1; i += 2) {
        _uvTemp[i + 0] = u1 + uvList[i + 1] * (u2 - u1);
        _uvTemp[i + 1] = v1 + uvList[i + 0] * (v2 - v1);
      }
    }

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateBlendMode(renderState.globalBlendMode);
    renderContext.activateRenderTexture(renderTextureQuad.renderTexture);

    renderProgram.globalMatrix = globalMatrix;
    renderProgram.renderMesh(
        indexCount, indexList,
        vertexCount, xyList, _uvTemp,
        1.0, 1.0, 1.0, globalAlpha);
  }

  void _renderMaskCanvas(RenderState renderState) {
    // TODO: Render Mesh for Canvas2D
  }

}