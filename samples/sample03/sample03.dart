#import('dart:html', prefix:"html");
#import('../../library/dartflash.dart');

#source('world.dart');

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

  Resource resource = new Resource();
  resource.addImage("house", "../images/House.png");
  resource.addImage("sun", "../images/Sun.png");
  resource.addImage("tree", "../images/Tree.png");

  Future resourceLoader = resource.load();

  resourceLoader.then((result)
  {
    // Place the World on the stage

    World world = new World(resource);
    world.x = 10;
    world.y = 20;
    stage.addChild(world);

    // Only one World? We want many worlds ....

    num posX = 0;

    for(int i = 0; i < 5; i++)
    {
      World otherWorld = new World(resource);
      otherWorld.scaleX = 1.0 - i * 0.1;
      otherWorld.scaleY = 1.0 - i * 0.1;
      otherWorld.x = posX;
      otherWorld.y = 500 - otherWorld.height;
      stage.addChild(otherWorld);

      posX = posX + otherWorld.width + 10;
    }

  });

  // ToDo: handle the exception correctly
  resourceLoader.handleException((exception) => true);

}
