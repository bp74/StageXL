part of stagexl.drawing;

class GraphicsCommandDecode extends GraphicsCommand {

  String _text;

  static const Map _BASE_64 = const {
    "A": 0,"B": 1,"C": 2,"D": 3,"E": 4,"F": 5,"G": 6,"H": 7,
    "I": 8,"J": 9,"K":10,"L":11,"M":12,"N":13,"O":14,"P":15,
    "Q":16,"R":17,"S":18,"T":19,"U":20,"V":21,"W":22,"X":23,
    "Y":24,"Z":25,"a":26,"b":27,"c":28,"d":29,"e":30,"f":31,
    "g":32,"h":33,"i":34,"j":35,"k":36,"l":37,"m":38,"n":39,
    "o":40,"p":41,"q":42,"r":43,"s":44,"t":45,"u":46,"v":47,
    "w":48,"x":49,"y":50,"z":51,"0":52,"1":53,"2":54,"3":55,
    "4":56,"5":57,"6":58,"7":59,"8":60,"9":61,"+":62,"/":63};

  GraphicsCommandDecode(String text) : _text = text;

  //---------------------------------------------------------------------------

  String get text => _text;

  set text(String value) {
    _text = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {

    var base64 = _BASE_64;

    var instructions = [
      context.moveTo,
      context.lineTo,
      context.quadraticCurveTo,
      context.bezierCurveTo,
      context.closePath
    ];

    List<int> paramCount = [2, 2, 4, 6, 0];
    List<num> params = new List<num>();
    var x = 0.0, y = 0.0;
    var i = 0, l = text.length;

    while (i < l) {

      var c = text[i];
      var n = base64[c];

      // highest order bits 1-3 code for operation.
      var fi = n >> 3;
      var f = instructions[fi];

      // check that we have a valid instruction & that the unused bits are empty:

      if (f == null || (n & 3) > 0) {
        throw new StateError("bad path data (@$i): $c");
      }

      var pl = paramCount[fi];
      if (fi == 0) x = y = 0.0;

      // move operations reset the position.

      params.length = 0;
      i++;

      // 4th header bit indicates number size for this operation.

      var charCount = (n >> 2 & 1) + 2;

      for (var p = 0; p < pl; p++) {
        var v = base64[text[i]];
        var sign = (v >> 5) > 0 ? -1 : 1;
        v = ((v & 31) << 6) | (base64[text[i + 1]]);
        if (charCount == 3) v = (v << 6) | (base64[text[i + 2]]);
        var w = sign * v / 10;
        if (p % 2 > 0) x = (w += x); else y = (w += y);
        params.add(w);
        i += charCount;
      }

      Function.apply(f, params);
    }
  }

}
