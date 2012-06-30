class MessageBox extends Sprite
{
  DelayedCall _showTimeout;
  Function _doneFunction;

  MessageBox(String text)
  {
    Bitmap background = new Bitmap(Grafix.resource.getBitmapData("MessageBox"));
    addChild(background);

    TextFormat textFormat = new TextFormat("Arial", 24, 0xFFFFFF, true);
    textFormat.align = TextFormatAlign.CENTER;

    TextField textField = new TextField();
    textField.defaultTextFormat = textFormat;
    textField.width = 240;
    textField.height = 200;
    textField.wordWrap = true;
    //textField.selectable = false;
    textField.text = text;
    textField.x = 47;
    textField.y = 130 - textField.textHeight / 2;
    //textField.filters = [new GlowFilter(0x000000, 0.7, 3, 3)];   // ToDo
    textField.mouseEnabled = false;
    addChild(textField);


    _showTimeout = null;

    addEventListener(MouseEvent.CLICK, _onClick);
  }

  //----------------------------------------------------------------------
  //----------------------------------------------------------------------

  void show(Function doneFunction)
  {
    this.parent.addChild(this);  // move to top
    this.x = - this.width;
    this.y = 150;

    _doneFunction = doneFunction;

    Tween tween = new Tween(this, 0.3, Transitions.easeOutCubic);
    tween.animate("x", 110);
    tween.onComplete = () => _showTimeout = Juggler.instance.delayCall(_hide, 10);

    Juggler.instance.add(tween);
  }

  //----------------------------------------------------------------------

  void _hide()
  {
    if (_showTimeout != null)
    {
      Juggler.instance.remove(_showTimeout);
      _showTimeout = null;

      _doneFunction();

      Tween tween = new Tween(this, 0.4, Transitions.easeInCubic);
      tween.animate("x", 800);
      tween.onComplete = () => this.parent.removeChild(this);

      Juggler.instance.add(tween);
    }
  }

  //----------------------------------------------------------------------

  void _onClick(MouseEvent me)
  {
    _hide();
  }
}
