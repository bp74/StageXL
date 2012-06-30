class Head extends Sprite
{
  List<BitmapData> _headBitmapDatas;
  Bitmap _headBitmap;

  Tween _nodTween;

  //--------------------------------------------------------------------------------------------

  Head()
  {
    _headBitmapDatas = Grafix.getHeads();

    _headBitmap = new Bitmap(_headBitmapDatas[0]);
    _headBitmap.x = -_headBitmap.width / 2;
    _headBitmap.y = -_headBitmap.height / 2;

    addChild(_headBitmap);

    _nodTween = null;
  }

  //--------------------------------------------------------------------------------------------

  void nod(int count)
  {
    Juggler.instance.remove(_nodTween);

    _nodTween = new Tween(this, 0.5 * count, Transitions.linear);

    _nodTween.animateValue((value) {
      _headBitmap.bitmapData = _headBitmapDatas[((value * _headBitmapDatas.length) % _headBitmapDatas.length).toInt()];
      _headBitmap.y = Math.sin(value * 2 * Math.PI) * 3 - _headBitmap.height / 2;
    }, 0, count);

    Juggler.instance.add(_nodTween);
  }

  void nodStop()
  {
    Juggler.instance.remove(_nodTween);
    _headBitmap.bitmapData = _headBitmapDatas[0];
  }

}