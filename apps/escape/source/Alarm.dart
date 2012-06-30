class Alarm extends Sprite
{
  List<BitmapData> _alarmBitmapDatas;
  Bitmap _alarmBitmap;

  Sound _warning;
  SoundChannel _warningChannel;
  Tween _tween;

  //--------------------------------------------------------------------------------------------

  Alarm()
  {
    _warning = Sounds.resource.getSound("Warning");
    _warningChannel = null;

    _alarmBitmapDatas = Grafix.getAlarms();
    _alarmBitmap = new Bitmap(_alarmBitmapDatas[0]);

    addChild(_alarmBitmap);
  }

  //--------------------------------------------------------------------------------------------

  void start()
  {
    _warningChannel = _warning.play();

    Juggler.instance.remove(_tween);

    _tween = new Tween(this, 9.0, Transitions.linear);
    _tween.animateValue((value)
    {
      int frame = value.toInt() % 8;

      if (frame <= 4)
         _alarmBitmap.bitmapData = _alarmBitmapDatas[frame + 1];
        else
         _alarmBitmap.bitmapData = _alarmBitmapDatas[8 - frame];
    }, 0, 80);

    Juggler.instance.add(_tween);
  }

  void stop()
  {
    if (_warningChannel != null)
    {
      _warningChannel.stop();
      _warningChannel = null;
    }

    Juggler.instance.remove(_tween);
    _alarmBitmap.bitmapData = _alarmBitmapDatas[0];
  }


}