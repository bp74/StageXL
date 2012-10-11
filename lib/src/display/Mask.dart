part of dartflash;

class Mask
{
  int _type;

  Rectangle _rectangle;
  Circle _circle;
  List<Point> _points;

  Mask.rectangle(num x, num y, num width, num height)
  {
    _type = 0;
    _rectangle = new Rectangle(x, y, width, height);
  }

  Mask.circle(num x, num y, num radius)
  {
    _type = 1;
    _circle = new Circle(x, y, radius);
  }

  Mask.custom(List<Point> points)
  {
    _type = 2;
    _points = points;

    if (_points.length < 3)
      throw new ArgumentError("A custom mask needs at least 3 points.");
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    var context = renderState.context;

    context.beginPath();

    switch(_type) {
      case 0:
        context.rect(_rectangle.x, _rectangle.y, _rectangle.width, _rectangle.height);
        break;

      case 1:
        context.arc(_circle.x, _circle.y, _circle.radius, 0, PI * 2.0, false);
        break;

      case 2:
        context.moveTo(_points[0].x, _points[0].y);

        for(int i = 1; i < _points.length; i++)
          context.lineTo(_points[i].x, _points[i].y);

        break;
    }

    context.clip();
  }

}
