part of stagexl;

class GraphicsGradient {

  String _kind;
  num _startX;
  num _startY;
  num _startRadius;
  num _endX;
  num _endY;
  num _endRadius;
  List _colorStops;

  GraphicsGradient.linear(num startX, num startY, num endX, num endY) {
     _kind = "linear";
     _startX = startX;
     _startY = startY;
     _endX = endX;
     _endY = endY;
     _colorStops = new List();
  }

  GraphicsGradient.radial(num startX, num startY, num startRadius, num endX, num endY, num endRadius) {
    _kind = "radial";
    _startX = startX;
    _startY = startY;
    _startRadius = startRadius;
    _endX = endX;
    _endY = endY;
    _endRadius = endRadius;
    _colorStops = new List();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void addColorStop(num offset, int color) {
    _colorStops.add({"offset" : offset, "color" : _color2rgba(color)});
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  CanvasGradient getCanvasGradient(CanvasRenderingContext2D context) {

    // ToDo: Maybe we should cache the CanvasGradient for a given context.
    // This could improve performance!

    CanvasGradient canvasGradient;

    if (_kind == "linear")
      canvasGradient = context.createLinearGradient(_startX, _startY, _endX, _endY);

    if (_kind == "radial")
      canvasGradient = context.createRadialGradient(_startX, _startY, _startRadius, _endX, _endY, _endRadius);

    for(var colorStop in _colorStops)
      canvasGradient.addColorStop(colorStop["offset"], colorStop["color"]);

    return canvasGradient;
  }


}
