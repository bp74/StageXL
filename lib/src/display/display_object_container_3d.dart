part of stagexl.display;

/// The abstract [DisplayObjectContainer3D] class enables 3D transformations
/// of 2D display objects.
///
/// Use the [rotationX], [rotationY] and [rotationZ] properties to rotate the
/// display object in 3D space. Use the [offsetX], [offsetY] and [offsetZ]
/// properties to move the display object in 3D space.
///
abstract class DisplayObjectContainer3D
    extends DisplayObjectContainer
    implements TweenObject3D {

  PerspectiveProjection perspectiveProjection = new PerspectiveProjection();

  num _offsetX = 0.0;
  num _offsetY = 0.0;
  num _offsetZ = 0.0;
  num _rotationX = 0.0;
  num _rotationY = 0.0;
  num _rotationZ = 0.0;

  bool _transformationMatrix3DRefresh = false;
  final Matrix3D _transformationMatrix3D = new Matrix3D.fromIdentity();
  final Matrix3D _projectionMatrix3D = new Matrix3D.fromIdentity();
  final Matrix3D _tmpMatrix3D = new Matrix3D.fromIdentity();
  final Matrix _tmpMatrix2D = new Matrix.fromIdentity();

  //---------------------------------------------------------------------------

  /// The offset to the x-axis for all children in 3D space.

  num get offsetX => _offsetX;

  set offsetX(num value) {
    if (value is num) _offsetX = value;
    _transformationMatrix3DRefresh = true;
  }

  /// The offset to the y-axis for all children in 3D space.

  num get offsetY => _offsetY;

  set offsetY(num value) {
    if (value is num) _offsetY = value;
    _transformationMatrix3DRefresh = true;
  }

  /// The offset to the z-axis for all children in 3D space.

  num get offsetZ => _offsetZ;

  set offsetZ(num value) {
    if (value is num) _offsetZ = value;
    _transformationMatrix3DRefresh = true;
  }

  /// The x-axis rotation in 3D space.

  num get rotationX => _rotationX;

  set rotationX(num value) {
    if (value is num) _rotationX = value;
    _transformationMatrix3DRefresh = true;
  }

  /// The y-axis rotation in 3D space.

  num get rotationY => _rotationY;

  set rotationY(num value) {
    if (value is num) _rotationY = value;
    _transformationMatrix3DRefresh = true;
  }

  /// The z-axis rotation in 3D space.

  num get rotationZ => _rotationZ;

  set rotationZ(num value) {
    if (value is num) _rotationZ = value;
    _transformationMatrix3DRefresh = true;
  }

  //---------------------------------------------------------------------------

  Matrix3D get transformationMatrix3D {

    if (_transformationMatrix3DRefresh) {
      _transformationMatrix3DRefresh = false;
      _transformationMatrix3D.setIdentity();
      _transformationMatrix3D.rotateX(0.0 - rotationX);
      _transformationMatrix3D.rotateY(0.0 + rotationY);
      _transformationMatrix3D.rotateZ(0.0 - rotationZ);
      _transformationMatrix3D.translate(offsetX, offsetY, offsetZ);
    }

    return _transformationMatrix3D;
  }

  //---------------------------------------------------------------------------

  Matrix3D get projectionMatrix3D {
    _calculateProjectionMatrix(_identityMatrix);
    return _projectionMatrix3D;
  }

  //---------------------------------------------------------------------------

  bool get isForwardFacing {

    var matrix = this.globalTransformationMatrix3D;

    num m00 = matrix.m00;
    num m10 = matrix.m10;
    num m30 = matrix.m30;
    num m01 = matrix.m01;
    num m11 = matrix.m11;
    num m31 = matrix.m31;
    num m03 = matrix.m03;
    num m13 = matrix.m13;
    num m33 = matrix.m33;

    num x1 = (0.0 + m30) / (0.0 + m33);
    num y1 = (0.0 + m31) / (0.0 + m33);
    num x2 = (m00 + m30) / (m03 + m33);
    num y2 = (m01 + m31) / (m03 + m33);
    num x3 = (m10 + m30) / (m13 + m33);
    num y3 = (m11 + m31) / (m13 + m33);

    return x1 * (y3 - y2) + x2 * (y1 - y3) + x3 * (y2 - y1) <= 0;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get boundsTransformed {
    var rectangle = this.bounds;
    _calculateProjectionMatrix(this.transformationMatrix);
    return _projectionMatrix3D.transformRectangle(rectangle, rectangle);
  }

  //---------------------------------------------------------------------------

  @override
  Point<num> localToParent(Point<num> localPoint, [Point<num> returnPoint]) {
    _calculateProjectionMatrix(this.transformationMatrix);
    return _projectionMatrix3D.transformPoint(localPoint, returnPoint);
  }

  //---------------------------------------------------------------------------

  @override
  Point<num> parentToLocal(Point<num> parentPoint, [Point<num> returnPoint]) {
    _calculateProjectionMatrix(this.transformationMatrix);
    return _projectionMatrix3D.transformPointInverse(parentPoint, returnPoint);
  }

  //---------------------------------------------------------------------------

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    var point = new Point<num>(localX, localY);
    _calculateProjectionMatrix(_identityMatrix);
    _projectionMatrix3D.transformPointInverse(point, point);
    return super.hitTestInput(point.x, point.y);
  }

  //---------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {

    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextWebGL) {

      var globalMatrix = renderState.globalMatrix;
      var activeProjectionMatrix = renderContext.activeProjectionMatrix;

      _tmpMatrix2D.copyFromAndInvert(globalMatrix);
      _tmpMatrix3D.copyFromMatrix3D(activeProjectionMatrix);

      _calculateProjectionMatrix(globalMatrix);
      _projectionMatrix3D.concat(activeProjectionMatrix);
      _projectionMatrix3D.prepend2D(_tmpMatrix2D);

      renderContext.activateProjectionMatrix(_projectionMatrix3D);
      _renderWithProjection(renderState);
      renderContext.activateProjectionMatrix(_tmpMatrix3D);
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void _calculateProjectionMatrix(Matrix matrix) {

    var perspectiveMatrix3D = this.perspectiveProjection.perspectiveMatrix3D;
    var transformationMatrix3D = this.transformationMatrix3D;
    var pivotX = this.pivotX.toDouble();
    var pivotY = this.pivotY.toDouble();

    _projectionMatrix3D.copyFromMatrix2D(matrix);
    _projectionMatrix3D.prependTranslation(pivotX, pivotY, 0.0);
    _projectionMatrix3D.prepend(perspectiveMatrix3D);
    _projectionMatrix3D.prepend(transformationMatrix3D);
    _projectionMatrix3D.prependTranslation(-pivotX, -pivotY, 0.0);
  }

  void _renderWithProjection(RenderState renderState) {
    super.render(renderState);
  }
}
