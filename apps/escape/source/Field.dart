class Field
{
  int _color;
  int _direction;
  String _special;

  num _x;
  num _y;
  bool _linked;
  bool _linkedJoker;
  bool _empty;

  DisplayObject _chainDisplayObject;
  DisplayObject _linkDisplayObject;
  DisplayObject _specialDisplayObject;

  //---------------------------------------------------------------------------------

  Field(int color, int direction)
  {
    _color = color;
    _direction = direction;
    _special = Special.None;

    _x = -1000;
    _y = -1000;
    _linked = false;
    _linkedJoker = false;
    _empty = false;

    _chainDisplayObject = null;
    _linkDisplayObject = null;
    _specialDisplayObject = null;
  }

  //---------------------------------------------------------------------------------

  int get color() => _color;
  void set color(int value)  { _color = value; }

  int get direction() => _direction;
  void set direction(int value) { _direction = value; }

  String get special() => _special;
  void set special(String value) { _special = value; }

  bool get linked() => _linked;
  void set linked(bool value) { _linked = value; }

  bool get linkedJoker() => _linkedJoker;
  void set linkedJoker(bool value) { _linkedJoker = value; }

  bool get empty() => _empty;
  void set empty(bool value) { _empty = value; }

  //---------------------------------------------------------------------------------

  bool couldLink(Field field)
  {
    bool link =
        field != null &&
        (field.color == _color || field.special == Special.Joker || _special == Special.Joker) &&
        field.special != Special.Block && _special != Special.Block;

    return link;
  }

  bool canLinkHorizontal(Field field)
  {
    bool link =
        field != null &&
        (field.color == _color || field.special == Special.Joker || _special == Special.Joker) &&
        field.direction == 0 && _direction == 0 &&
        field.special != Special.Block && _special != Special.Block;

    return link;
  }

  bool canLinkVertical(Field field)
  {
   bool link =
       field != null &&
       (field.color == _color || field.special == Special.Joker || _special == Special.Joker) &&
       field.direction == 1 && _direction == 1 &&
       field.special != Special.Block && _special != Special.Block;

    return link;
  }

  //---------------------------------------------------------------------------------

  num get x() => _x;

  void set x(num value)
  {
    _x = value;

    if (_chainDisplayObject != null) _chainDisplayObject.x = value;
    if (_linkDisplayObject != null) _linkDisplayObject.x = value;
    if (_specialDisplayObject != null) _specialDisplayObject.x = value;
  }

  //---------------------------------------------------------------------------------

  num get y() => _y;

  void set y(num value)
  {
   _y = value;

    if (_chainDisplayObject != null) _chainDisplayObject.y = value;
    if (_linkDisplayObject != null) _linkDisplayObject.y = value;
    if (_specialDisplayObject != null) _specialDisplayObject.y = value;
  }

  //---------------------------------------------------------------------------------

  num get sinScale() => 0;

  void set sinScale(num n)
  {
    if (_chainDisplayObject != null)
    {
      num s = 1 + 0.3 * Math.sin(n * Math.PI);

      _chainDisplayObject.scaleX = s;
      _chainDisplayObject.scaleY = s;
    }
  }

  //---------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------

  void updateDisplayObjects(Sprite chainLayer, Sprite linkLayer, Sprite specialLayer)
  {
    if (_chainDisplayObject != null)
    {
      _chainDisplayObject.parent.removeChild(_chainDisplayObject);
      _chainDisplayObject = null;
    }

    if (_linkDisplayObject != null)
    {
      _linkDisplayObject.parent.removeChild(_linkDisplayObject);
      _linkDisplayObject = null;
    }

    if (_specialDisplayObject != null)
    {
      _specialDisplayObject.parent.removeChild(_specialDisplayObject);
      _specialDisplayObject = null;
    }

    if (empty == false)
    {
      //----------------------------------
      // chainLayer

      switch(_special)
      {
        case Special.Joker:
          _chainDisplayObject = new SpecialJokerChain(_direction);
          _chainDisplayObject.x = _x;
          _chainDisplayObject.y = _y;
          chainLayer.addChild(_chainDisplayObject);
          break;

        case Special.Block:
          _chainDisplayObject = Grafix.getSpecial(Special.Block);
          _chainDisplayObject.x = _x;
          _chainDisplayObject.y = _y;
          chainLayer.addChild(_chainDisplayObject);
          break;

        default:
          _chainDisplayObject = Grafix.getChain(_color, _direction);
          _chainDisplayObject.x = _x;
          _chainDisplayObject.y = _y;
          chainLayer.addChild(_chainDisplayObject);
          break;
      }

      //----------------------------------
      // linkLayer

      if (_linked)
      {
        _linkDisplayObject = _linkedJoker ? new SpecialJokerLink(_direction) : Grafix.getLink(_color, _direction);
        _linkDisplayObject.x = _x + ((_direction == 0) ? 25 : 0);
        _linkDisplayObject.y = _y + ((_direction == 1) ? 25 : 0);
        linkLayer.addChild(_linkDisplayObject);
      }

      //----------------------------------
      // specialLayer

      switch(_special)
      {
        case Special.None: break;
        case Special.Block: break;
        case Special.Joker: break;
        default:
          _specialDisplayObject = new SpecialWobble(_special);
          _specialDisplayObject.x = _x;
          _specialDisplayObject.y = _y;
          specialLayer.addChild(_specialDisplayObject);
          break;
      }
    }
  }

}