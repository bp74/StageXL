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
  // Use the Resource class to load some Bitmaps
  //------------------------------------------------------------------

  // we cannot use embedded Bitmaps like we do it in a SWF file.
  // but the library provides an easy way to load resources.

  Resource resource = new Resource();
  resource.addImage("house", "../images/House.png");
  resource.addImage("sun", "../images/Sun.png");
  resource.addImage("tree", "../images/Tree.png");

  Future resourceLoader = resource.load();

  resourceLoader.then((result)
  {
    Bitmap house = new Bitmap(resource.getBitmapData("house"));
    house.x = 200;
    house.y = 200;
    stage.addChild(house);

    Bitmap tree = new Bitmap(resource.getBitmapData("tree"));
    tree.x = 330;
    tree.y = 200;
    stage.addChild(tree);

    Bitmap sun = new Bitmap(resource.getBitmapData("sun"));
    sun.x = 250;
    sun.y = 50;
    stage.addChild(sun);
  });

  // ToDo: handle the exception correctly
  resourceLoader.handleException((exception) => true);

}
