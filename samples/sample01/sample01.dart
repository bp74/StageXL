#import('dart:html', prefix:"html");
#import('../../library/dartflash.dart');

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  // the Stage is a wrapper over the HTML Canvas element.

  Stage stage = new Stage("myStage", html.document.query('#stage'));

  // the RenderLoop controls the flow of the program

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // from now on we have the well known Display List classes
  //------------------------------------------------------------------

  // Create a nice looking BitmapData

  BitmapData bitmapData = new BitmapData(100, 100);
  bitmapData.fillRect(new Rectangle(0, 0, 100, 100), 0xFFFF0000);
  bitmapData.fillRect(new Rectangle(10, 10, 80, 80), 0xFF00FF00);

  // Create a Bitmap with the nice looking BitmapData

  Bitmap bitmap = new Bitmap(bitmapData);
  bitmap.x = 100;
  bitmap.y = 100;
  bitmap.rotation = Math.PI / 8;

  // Add the Bitmap to the Stage

  stage.addChild(bitmap);

}



