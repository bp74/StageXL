part of stagexl.drawing;

class _GraphicsCommandArcTo extends _GraphicsCommand {

  num _controlX, _controlY;
  num _endX, _endY;
  num _radius;

  _GraphicsCommandArcTo(num controlX, num controlY, num endX, num endY, num radius) {
    _controlX = controlX.toDouble();
    _controlY = controlY.toDouble();
    _endX = endX.toDouble();
    _endY = endY.toDouble();
    _radius = radius.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.arcTo(_controlX, _controlY, _endX, _endY, _radius);
  }

  updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor) {

      var v0 = new Vector(bounds.cursorX, bounds.cursorY);
      var v1 = new Vector(_controlX, _controlY);
      var v2 = new Vector(_endX, _endY);
      var v01 = v1 - v0;
      var v12 = v2 - v1;

      var rads = v01.rads - v12.rads;
      var tn = tan(rads / 2);
      var ra = (tn > 0) ? _radius : -_radius;
      var tangent1 = v1 - v01.scaleLength(tn * ra);
      var tangent2 = v1 + v12.scaleLength(tn * ra);
      var center = tangent1 + v01.normalLeft().scaleLength(ra);

      var angle1 = (tangent1 - center).rads;
      var angle2 = (tangent2 - center).rads;

      if (tn < 0) { // clockwise
        if (angle2 < angle1) angle2 = angle2 + 2 * PI;
      } else { // anti clockwise
        if (angle1 < angle2) angle1 = angle1 + 2 * PI;
      }

      var arc = tangent1 - center;
      var arcAngle = angle2 - angle1;
      var arcSteps = (arcAngle * 30).abs() ~/ PI + 1;

      bounds.updatePath(bounds.cursorX, bounds.cursorY);

      for (var i = 0; i <= arcSteps; i++) {
        var v = center + arc.rotate(i * arcAngle / arcSteps);
        bounds.updatePath(v.x, v.y);
      }

      bounds.updateCursor(tangent2.x, tangent2.y);
    } else {
      bounds.updateCursor(_controlX, _controlY);
    }
  }
}