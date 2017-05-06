part of stagexl.display;

class StageConsole extends DisplayObject {

  final String _fontImage =
      "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAcAAAAAOAQAAAACQy/GuAAABsE"
      "lEQVR4Aa3OMWsTUQDA8f97eV6fEpvT6YZgX4qDYwoOAdE+IQ5OfoXzG7S46KA8HZSC1PQLaN"
      "Cln8ElFxyaQWg3XZQLBAyi5BqjJDHeE7whoE7i7xP8+He1Wq38WGkLIFmyphryV2JQAQnIhw"
      "E6tQCR6Sc3dq80tsBmQVTrHlSeVZvT8flwr3p7u3/Q27va3MnMWKEA2e0oRAjI8uWN1f3rZ9"
      "YjhNNU392Ud7bPckGuf9LB62sblQ874E3OqbEEefRyrsNRywFs5sL5FOIuizSqQ0IO2JMApM"
      "AA4DQS/77+dZEBgMIhVor/Wi6nkAIgHAvAw0zTCz3fkCDOubJD3IorDgifH+8yydrNvleQsL"
      "IaNPDuB1zkMIH+8MjACAknnr564vCf28dOg4n5QrnFAoFu1JmNF70i3MPGQIT1DiTp91h0gA"
      "QAbGkfBeRrcjrYwgAImAOMYf7rDUhAKchC7rsgRDyYxYCLO33FoAUWBaTkFD5WgQQkhnzzkq"
      "MweTtq+7tMhnin9YTDF4/chDftUsKcoW97B2RQEIC24GDJWsNvDAWRVrjHUgmWhOMPEf/DT5"
      "NSmGlKVHTvAAAAAElFTkSuQmCC";

  final List<RenderTextureQuad> _glyphs = new List<RenderTextureQuad>();
  final Matrix _matrix = new Matrix.fromIdentity();
  final List<String> _lines = new List<String>();

  int _consoleWidth = 0;
  int _consoleHeight = 0;

  StageConsole() {
    BitmapData.load(_fontImage).then(_calculateGlyphs);
  }

  //----------------------------------------------------------------------------

  EventStream<Event> get onUpdate => this.on<Event>("Update");

  Iterable<String> get lines => _lines;

  //----------------------------------------------------------------------------

  void clear() {
    _lines.clear();
    _consoleWidth = 0;
    _consoleHeight = 0;
  }

  void print(String line) {
    _lines.add(line);
    _consoleWidth = line.length > _consoleWidth ? line.length : _consoleWidth;
    _consoleHeight = _consoleHeight + 1;
  }

  @override
  void render(RenderState renderState) {
    this.dispatchEvent(new Event("Update"));
    for (int y = 0; y < _consoleHeight; y++) {
      for (int x = 0; x < _consoleWidth; x++) {
        var index = x < _lines[y].length ? _lines[y].codeUnitAt(x) - 32 : 0;
        if (index < 0 || index >= 64) index = 0;
        _matrix.setTo(1.0, 0.0, 0.0, 1.0, x * 7, y * 14);
        renderState.push(_matrix, 1.0, BlendMode.NORMAL);
        renderState.renderTextureQuad(_glyphs[index]);
        renderState.pop();
      }
    }
  }

  //----------------------------------------------------------------------------

  void _calculateGlyphs(BitmapData fontBitmapData) {
    fontBitmapData.renderTexture.filtering = RenderTextureFiltering.NEAREST;
    for (int i = 0; i < 64; i++) {
      var rectangle = new Rectangle<int>(i * 7, 0, 7, 14);
      _glyphs.add(fontBitmapData.renderTextureQuad.cut(rectangle));
    }
  }
}
