class Grafix
{
  static Resource resource;

  //--------------------------------------------------------------------------------------------

  static Bitmap getChain(int color, int direction)
  {
    Bitmap bitmap = new Bitmap(resource.getTextureAtlas("Elements").getBitmapData("Chain${color}${direction}"));
    bitmap.pivotX = 25;
    bitmap.pivotY = 25;

    return bitmap;
  }

  //--------------------------------------------------------------------------------------------

  static Bitmap getLink(int color, int direction)
  {
    Bitmap bitmap = new Bitmap(resource.getTextureAtlas("Elements").getBitmapData("Link${color}${direction}"));
    bitmap.pivotX = 25;
    bitmap.pivotY = 25;

    return bitmap;
  }

  //--------------------------------------------------------------------------------------------

  static Bitmap getWhiteLink(int direction)
  {
    Bitmap bitmap = new Bitmap(resource.getTextureAtlas("Elements").getBitmapData("Link8${direction}"));
    bitmap.pivotX = 25;
    bitmap.pivotY = 25;

    return bitmap;
  }

  //--------------------------------------------------------------------------------------------

  static Bitmap getSpecial(String special)
  {
    Bitmap bitmap = new Bitmap(resource.getTextureAtlas("Elements").getBitmapData(special));
    bitmap.pivotX = 25;
    bitmap.pivotY = 25;

    return bitmap;
  }

  //--------------------------------------------------------------------------------------------

  static Sprite getLevelUpAnimation()
  {
    Sprite sprite = new Sprite();
    num offset = 0;

    TextureAtlas textureAtlas = resource.getTextureAtlas("Levelup");

    for(int i = 0; i < 7; i++)
    {
      Bitmap bitmap = new Bitmap(textureAtlas.getBitmapData("LevelUp${i}"));
      bitmap.x = - bitmap.width / 2;
      bitmap.y = - bitmap.height / 2;
      //bitmap.filters = [new GlowFilter(0x000000, 0.5, 30, 30)];  // ToDo

      Sprite subSprite = new Sprite();
      subSprite.addChild(bitmap);
      subSprite.x = offset + bitmap.width / 2;
      subSprite.scaleX = 0;
      subSprite.scaleY = 0;

      sprite.addChild(subSprite);

      Tween tween1 = new Tween(subSprite, 2.0, Transitions.easeOutElastic);
      tween1.animate("scaleX", 1.0);
      tween1.animate("scaleY", 1.0);
      tween1.delay = i * 0.05;

      Tween tween2 = new Tween(subSprite, 0.4, Transitions.linear);
      tween2.animate("scaleX", 0.0);
      tween2.animate("scaleY", 0.0);
      tween2.delay = 3.0;

      Juggler.instance.add(tween1);
      Juggler.instance.add(tween2);

      offset = offset + 5 + bitmap.width;
    }

    return sprite;
  }

  //--------------------------------------------------------------------------------------------

  static List<BitmapData> getJokerChain(int direction)
  {
    TextureAtlas textureAtlas = resource.getTextureAtlas("Elements");

    List<BitmapData> tmp = new List<BitmapData>();
    tmp.add(textureAtlas.getBitmapData("JokerChain${direction}0"));
    tmp.add(textureAtlas.getBitmapData("JokerChain${direction}1"));
    tmp.add(textureAtlas.getBitmapData("JokerChain${direction}2"));
    tmp.add(textureAtlas.getBitmapData("JokerChain${direction}3"));
    tmp.add(textureAtlas.getBitmapData("JokerChain${direction}4"));
    return tmp;
  }

  static List<BitmapData> getJokerLink(int direction)
  {
    TextureAtlas textureAtlas = resource.getTextureAtlas("Elements");

    List<BitmapData> tmp = new List<BitmapData>();
    tmp.add(textureAtlas.getBitmapData("JokerLink${direction}0"));
    tmp.add(textureAtlas.getBitmapData("JokerLink${direction}1"));
    tmp.add(textureAtlas.getBitmapData("JokerLink${direction}2"));
    tmp.add(textureAtlas.getBitmapData("JokerLink${direction}3"));
    tmp.add(textureAtlas.getBitmapData("JokerLink${direction}4"));
    return tmp;
  }

  static List<BitmapData> getLock(int color)
  {
    TextureAtlas textureAtlas = resource.getTextureAtlas("Locks");

    List<BitmapData> tmp = new List<BitmapData>();
    tmp.add(textureAtlas.getBitmapData("Lock${color}0"));
    tmp.add(textureAtlas.getBitmapData("Lock${color}1"));
    tmp.add(textureAtlas.getBitmapData("Lock${color}2"));
    tmp.add(textureAtlas.getBitmapData("Lock${color}3"));
    tmp.add(textureAtlas.getBitmapData("Lock${color}4"));
    return tmp;
  }

  static List<BitmapData> getHeads()
  {
    TextureAtlas textureAtlas = resource.getTextureAtlas("Head");

    List<BitmapData> tmp = new List<BitmapData>();
    tmp.add(textureAtlas.getBitmapData("Head1"));
    tmp.add(textureAtlas.getBitmapData("Head2"));
    tmp.add(textureAtlas.getBitmapData("Head3"));
    tmp.add(textureAtlas.getBitmapData("Head2"));
    tmp.add(textureAtlas.getBitmapData("Head1"));
    return tmp;
  }

  static List<BitmapData> getAlarms()
  {
    TextureAtlas textureAtlas = resource.getTextureAtlas("Alarm");

    List<BitmapData> tmp = new List<BitmapData>();
    tmp.add(textureAtlas.getBitmapData("Alarm0"));
    tmp.add(textureAtlas.getBitmapData("Alarm1"));
    tmp.add(textureAtlas.getBitmapData("Alarm2"));
    tmp.add(textureAtlas.getBitmapData("Alarm3"));
    tmp.add(textureAtlas.getBitmapData("Alarm4"));
    tmp.add(textureAtlas.getBitmapData("Alarm5"));
    return tmp;
  }
}