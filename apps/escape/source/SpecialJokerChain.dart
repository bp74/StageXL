class SpecialJokerChain extends Sprite implements IAnimatable
{
  Bitmap _bitmap;
  List<BitmapData> _jokerBitmapDatas;
  num _currentTime;

  SpecialJokerChain(int direction)
  {
    this.mouseEnabled = false;

    _currentTime = 0.0;
    _jokerBitmapDatas = Grafix.getJokerChain(direction);

    _bitmap = new Bitmap(_jokerBitmapDatas[0]);
    _bitmap.x = -25;
    _bitmap.y = -25;
    addChild(_bitmap);

    addEventListener(Event.ADDED_TO_STAGE, (e) => Juggler.instance.add(this));
    addEventListener(Event.REMOVED_FROM_STAGE, (e) => Juggler.instance.remove(this));
  }

  //------------------------------------------------

  bool advanceTime(num time)
  {
    _currentTime += time;

    int frame = (_currentTime * 10).toInt() % _jokerBitmapDatas.length;
    _bitmap.bitmapData = _jokerBitmapDatas[frame];

    return true;
  }

}