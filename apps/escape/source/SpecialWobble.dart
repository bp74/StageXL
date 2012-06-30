class SpecialWobble extends Sprite implements IAnimatable
{
  Bitmap _bitmap;
  num _currentTime;

  SpecialWobble(String special)
  {
    this.mouseEnabled = false;

    _currentTime = 0.0;
    _bitmap = Grafix.getSpecial(special);

    addChild(_bitmap);

    addEventListener(Event.ADDED_TO_STAGE, (e) => Juggler.instance.add(this));
    addEventListener(Event.REMOVED_FROM_STAGE, (e) => Juggler.instance.remove(this));
  }

  //------------------------------------------------

  bool advanceTime(num time)
  {
    _currentTime += time;

    this.rotation = Math.sin(_currentTime * 7) * 10 * Math.PI / 180;

    return true;
  }

}