#import('dart:html', prefix:"html");
#import('../../library/dartflash.dart');

Resource resource;

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  Stage stage = new Stage("myStage", html.document.query('#stage'));

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // prepare different Masks for later use
  //------------------------------------------------------------------
  
  List<Point> starPath = new List<Point>();

  for(int i = 0; i < 6; i++) {
    num a1 = Math.PI * (i * 60.0) / 180.0;
    num a2 = Math.PI * (i * 60.0 + 30.0) / 180.0;
    starPath.add(new Point(400.0 + 200.0 * Math.cos(a1), 350.0 + 200.0 * Math.sin(a1)));
    starPath.add(new Point(400.0 + 100.0 * Math.cos(a2), 350.0 + 100.0 * Math.sin(a2)));
  }

  Mask rectangleMask = new Mask.rectangle(100.0, 200.0, 600.0, 300.0);
  Mask circleMask = new Mask.circle(400.0, 350.0, 200.0);
  Mask customMask = new Mask.custom(starPath);

  //------------------------------------------------------------------
  // Use the Resource class to load some Bitmaps
  //------------------------------------------------------------------

  resource = new Resource();
  resource.addImage("buttonUp", "../images/ButtonUp.png");
  resource.addImage("buttonOver", "../images/ButtonOver.png");
  resource.addImage("buttonDown", "../images/ButtonDown.png");
  resource.addImage("flower1", "../images/Flower1.png");
  resource.addImage("flower2", "../images/Flower2.png");
  resource.addImage("flower3", "../images/Flower3.png");
  
  //------------------------------------------------------------------
  // Draw buttons for different masks and start animation
  //------------------------------------------------------------------

  resource.load().then((result)
  {
    Sprite animation = getAnimation();
    animation.pivotX = 400;
    animation.pivotY = 350;
    animation.x = 400;
    animation.y = 350;
    stage.addChild(animation);

    List<Sprite> buttons = [
      getButton("None", () => animation.mask = null),
      getButton("Rectangle", () => animation.mask = rectangleMask),
      getButton("Circle", () => animation.mask = circleMask),
      getButton("Custom", () => animation.mask = customMask),
      getButton("spin", () {
        Tween rotate = new Tween(animation, 2.0, Transitions.easeInOutBack);
        rotate.animate("rotation", Math.PI * 4);
        rotate.onComplete = () => animation.rotation = 0.0;
        Juggler.instance.add(rotate);
      })
    ];

    for(int b = 0; b < buttons.length; b++) {
      Sprite button = buttons[b];
      stage.addChild(button);

      button.x = (b < 4 ) ? 10 + b * 130 : 645;
      button.y = 10;
      button.scaleX = 0.5;
      button.scaleY = 0.5;
    }

  });
}

Sprite getAnimation()
{
  Sprite sprite = new Sprite();

  for(int i = 0; i < 150; i++) {
    int f = 1 + (Math.random() * 3.0).toInt();
    BitmapData bitmapData = resource.getBitmapData("flower$f");
    Bitmap bitmap = new Bitmap(bitmapData);
    bitmap.pivotX = 64;
    bitmap.pivotY = 64;
    bitmap.x = 64.0 + Math.random() * 672.0;
    bitmap.y = 164.0 + Math.random() * 372.0;
    sprite.addChild(bitmap);

    Tween tween = new Tween(bitmap, 180.0, Transitions.linear);
    tween.animate("rotation", Math.PI * 20);
    Juggler.instance.add(tween);
  }

  return sprite;
}


Sprite getButton(String text, Function clickHandler)
{
  Sprite button = new Sprite();

  Bitmap buttonUp = new Bitmap(resource.getBitmapData("buttonUp"));
  Bitmap buttonOver = new Bitmap(resource.getBitmapData("buttonOver"));
  Bitmap buttonDown = new Bitmap(resource.getBitmapData("buttonDown"));

  SimpleButton simpleButton = new SimpleButton(buttonUp, buttonOver, buttonDown, buttonOver);
  simpleButton.x = 20;
  simpleButton.y = 20;

  TextFormat textFormat = new TextFormat("Verdana", 30, Color.White, false);
  textFormat.align = TextFormatAlign.CENTER;

  TextField textField = new TextField();
  textField.defaultTextFormat = textFormat;
  textField.width = simpleButton.width;
  textField.height = 40;
  textField.text = text;
  textField.x = simpleButton.x;
  textField.y = simpleButton.y + 10;
  textField.mouseEnabled = false;

  button.addChild(simpleButton);
  button.addChild(textField);

  simpleButton.addEventListener(MouseEvent.CLICK, (me) => clickHandler());

  return button;
}


