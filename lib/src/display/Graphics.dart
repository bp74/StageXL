part of dartflash;

class Graphics
{
  final List<_GraphicsCommand> _commands = new List<_GraphicsCommand>();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  clear() =>
      _commands.clear();

  beginPath() =>
      _commands.add(new _GraphicsCommand("beginPath"));
  closePath() =>
      _commands.add(new _GraphicsCommand("closePath"));

  moveTo(num x, num y) =>
      _commands.add(new _GraphicsCommand("moveTo", [x, y]));

  lineTo(num x, num y) =>
      _commands.add(new _GraphicsCommand("lineTo", [x, y]));

  arcTo(num controlX, num controlY, num endX, num endY, num radius) =>
      _commands.add(new _GraphicsCommand("arcTo", [controlX, controlY, endX, endY, radius]));

  quadraticCurveTo(num controlX, num controlY, num endX, num endY) =>
      _commands.add(new _GraphicsCommand("quadraticCurveTo", [controlX, controlY, endX, endY]));

  bezierCurveTo(num controlX1, num controlY1, num controlX2, num controlY2, num endX, num endY) =>
      _commands.add(new _GraphicsCommand("bezierCurveTo", [controlX1, controlY1, controlX2, controlY2, endX, endY]));

  arc(num x, num y, num radius, num startAngle, num endAngle, bool antiClockwise) =>
      _commands.add(new _GraphicsCommand("arc", [x, y, radius, startAngle, endAngle, antiClockwise]));

  rect(num x, num y, num width, num height) =>
      _commands.add(new _GraphicsCommand("rect", [x,y,width, height]));

  strokeColor(int color, [int width = 1, String joints = JointStyle.ROUND, String caps = CapsStyle.ROUND]) =>
      _commands.add(new _GraphicsCommand("strokeColor", [_color2rgba(color), width, joints, caps]));

  strokeGradient(GraphicsGradient gradient, [int width = 1, String joints = JointStyle.ROUND, String caps = CapsStyle.ROUND]) =>
      _commands.add(new _GraphicsCommand("strokeGradient", [gradient, width, joints, caps]));

  strokePattern(GraphicsPattern pattern, [int width = 1, String joints = JointStyle.ROUND, String caps = CapsStyle.ROUND]) =>
      _commands.add(new _GraphicsCommand("strokePattern", [pattern, width, joints, caps]));

  fillColor(int color) =>
      _commands.add(new _GraphicsCommand("fillColor", [_color2rgba(color)]));

  fillGradient(GraphicsGradient gradient) =>
      _commands.add(new _GraphicsCommand("fillGradient", [gradient]));

  fillPattern(GraphicsPattern pattern) =>
      _commands.add(new _GraphicsCommand("fillPattern", [pattern]));

  //-------------------------------------------------------------------------------------------------

  rectRound(num x, num y, num width, num height, num ellipseWidth, num ellipseHeight)
  {
    _commands.add(new _GraphicsCommand("moveTo", [x + ellipseWidth, y]));
    _commands.add(new _GraphicsCommand("lineTo", [x + width - ellipseWidth, y]));
    _commands.add(new _GraphicsCommand("quadraticCurveTo", [x + width, y, x + width, y + ellipseHeight]));
    _commands.add(new _GraphicsCommand("lineTo", [x + width, y + height - ellipseHeight]));
    _commands.add(new _GraphicsCommand("quadraticCurveTo", [x + width, y + height, x + width - ellipseWidth, y + height]));
    _commands.add(new _GraphicsCommand("lineTo", [x + ellipseWidth, y + height]));
    _commands.add(new _GraphicsCommand("quadraticCurveTo", [x, y + height, x, y + height - ellipseHeight]));
    _commands.add(new _GraphicsCommand("lineTo", [x, y + ellipseHeight]));
    _commands.add(new _GraphicsCommand("quadraticCurveTo", [x, y, x + ellipseWidth, y]));
  }

  //-------------------------------------------------------------------------------------------------

  circle(num x, num y, num radius)
  {
    _commands.add(new _GraphicsCommand("moveTo", [x + radius, y]));
    _commands.add(new _GraphicsCommand("arc", [x, y, radius, 0, PI * 2, false]));
  }

  //-------------------------------------------------------------------------------------------------

  ellipse(num x, num y, num width, num height)
  {
    num kappa = 0.5522848;
    num ox = (width / 2) * kappa;
    num oy = (height / 2) * kappa;
    num x1 = x - width / 2;
    num y1 = y - height / 2;
    num x2 = x + width / 2;
    num y2 = y + height / 2;
    num xm = x;
    num ym = y;

    _commands.add(new _GraphicsCommand("moveTo", [x1, ym]));
    _commands.add(new _GraphicsCommand("bezierCurveTo", [x1, ym - oy, xm - ox, y1, xm, y1]));
    _commands.add(new _GraphicsCommand("bezierCurveTo", [xm + ox, y1, x2, ym - oy, x2, ym]));
    _commands.add(new _GraphicsCommand("bezierCurveTo", [x2, ym + oy, xm + ox, y2, xm, y2]));
    _commands.add(new _GraphicsCommand("bezierCurveTo", [xm - ox, y2, x1, ym + oy, x1, ym]));
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    var context = renderState.context;

    context.save();

    for(var command in _commands)
    {
      List args = command.arguments;

      switch(command.name)
      {
        case "beginPath":
          context.beginPath();
          break;

        case "closePath":
          context.closePath();
          break;

        case "moveTo":
          context.moveTo(args[0], args[1]);
          break;

        case "lineTo":
          context.lineTo(args[0], args[1]);
          break;

        case "arcTo":
          context.arcTo(args[0], args[1], args[2], args[3], args[4]);
          break;

        case "quadraticCurveTo":
          context.quadraticCurveTo(args[0], args[1], args[2], args[3]);
          break;

        case "bezierCurveTo":
          context.bezierCurveTo(args[0], args[1], args[2], args[3], args[4], args[5]);
          break;

        case "arc":
          context.arc(args[0], args[1], args[2], args[3], args[4], args[5]);
          break;

        case "rect":
          context.rect(args[0], args[1], args[2], args[3]);
          break;

        case "strokeColor":
          context.strokeStyle = args[0];
          context.lineWidth = args[1];
          context.lineJoin = args[2];
          context.lineCap = args[3];
          context.stroke();
          break;

        case "strokeGradient":
          context.strokeStyle = args[0]._getCanvasGradient(context);
          context.lineWidth = args[1];
          context.lineJoin = args[2];
          context.lineCap = args[3];
          context.stroke();
          break;

        case "strokePattern":
          context.strokeStyle = args[0]._getCanvasPattern(context);
          context.lineWidth = args[1];
          context.lineJoin = args[2];
          context.lineCap = args[3];

          Matrix matrix = args[0]._matrix;

          if (matrix != null) {
            context.save();
            context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
            context.stroke();
            context.restore();
          } else {
            context.stroke();
          }
          break;

        case "fillColor":
          context.fillStyle = args[0];
          context.fill();
          break;

        case "fillGradient":
          context.fillStyle = args[0].getCanvasGradient(context);
          context.fill();
          break;

        case "fillPattern":
          context.fillStyle = args[0].getCanvasPattern(context);

          Matrix matrix = args[0]._matrix;

          if (matrix != null) {
            context.save();
            context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
            context.fill();
            context.restore();
          } else {
            context.fill();
          }
          break;
      }
    }

    context.restore();
  }

}
