#import('dart:html', prefix:"html");
#import('../../library/dartflash.dart');

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  Stage stage = new Stage("myStage", html.document.query('#stage'));

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Draw a cloud with vectors
  //------------------------------------------------------------------

  var gradient = new GraphicsGradient.linear(230, 0, 370, 200);
  gradient.addColorStop(0, 0xFF8ED6FF);
  gradient.addColorStop(1, 0xFF004CB3);

  Shape shape = new Shape();
  shape.pivotX = 278;
  shape.pivotY = 90;
  shape.x = 400;
  shape.y = 300;
  stage.addChild(shape);

  shape.graphics.beginPath();
  shape.graphics.moveTo(170, 80);
  shape.graphics.bezierCurveTo(130, 100, 130, 150, 230, 150);
  shape.graphics.bezierCurveTo(250, 180, 320, 180, 340, 150);
  shape.graphics.bezierCurveTo(420, 150, 420, 120, 390, 100);
  shape.graphics.bezierCurveTo(430, 40, 370, 30, 340, 50);
  shape.graphics.bezierCurveTo(320, 5, 250, 20, 250, 50);
  shape.graphics.bezierCurveTo(200, 5, 150, 20, 170, 80);
  shape.graphics.closePath();

  shape.graphics.fillGradient(gradient);
  shape.graphics.strokeColor(Color.Blue, 5);

  //------------------------------------------------------------------
  // Add some animation
  //------------------------------------------------------------------

  Tween tween1 = new Tween(shape, 3.0, Transitions.easeInOutBack);
  tween1.animate("scaleX", 2.5);
  tween1.animate("scaleY", 2.5);
  tween1.delay = 1.0;

  Tween tween2 = new Tween(shape, 3.0, Transitions.easeInOutBack);
  tween2.animate("scaleX", 1);
  tween2.animate("scaleY", 1);
  tween2.delay = 5.0;

  Juggler.instance.add(tween1);
  Juggler.instance.add(tween2);
}
