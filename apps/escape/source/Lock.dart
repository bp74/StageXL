class Lock extends Sprite
{
  int _color;
  Bitmap _bitmap;
  List<BitmapData> _lockBitmapDatas;
  bool _locked;

  Lock(int color)
  {
    _color = color;
    _lockBitmapDatas = Grafix.getLock(color);
    _locked = true;

    _bitmap = new Bitmap(_lockBitmapDatas[0]);
    _bitmap.x = -34;
    _bitmap.y = -50;

    addChild(_bitmap);
  }

  //-----------------------------------------------------------------

  bool get locked() => _locked;
  void set locked(bool value) { _locked = value; }

  //-----------------------------------------------------------------

  void showLocked(bool locked)
  {
    _bitmap.bitmapData = _lockBitmapDatas[locked ? 0 : 4];
  }

  void showHappy()
  {
    Tween tween1 = new Tween(this, 2.0, Transitions.easeOutCubic);
    tween1.animateValue((value) => scaleX = scaleY = 1.0 + 0.2 * Math.sin(value * 4 * Math.PI), 0.0, 1.0);

    Tween tween2 = new Tween(this, 0.2, Transitions.easeOutCubic);
    tween2.animate("alpha", 0.0);
    tween2.delay = 2.0;
    tween2.onComplete = () => showLocked(_locked);

    Tween tween3 = new Tween(this, 0.2, Transitions.easeInCubic);
    tween3.animate("alpha", 1);
    tween3.delay = 2.2;

    Juggler.instance.add(tween1);
    Juggler.instance.add(tween2);
    Juggler.instance.add(tween3);
  }

}