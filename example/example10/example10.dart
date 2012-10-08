#import('dart:math');
#import('dart:html', prefix:'html');
#import('package:dartflash/dartflash.dart');

Stage stage;
RenderLoop renderLoop;
Resource resource;

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stage = new Stage("stage", html.document.query('#stage'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Use the Resource class to load some Bitmaps and Sounds
  //------------------------------------------------------------------

  resource = new Resource();
  resource.addImage("astronaut", "../common/images/Astronaut.jpg");
  resource.addImage("flower", "../common/images/Flower3.png");

  resource.load().then((result) {

    var flowerBitmapData = resource.getBitmapData("flower");
    var flowerRectangle = new Rectangle(0, 0, flowerBitmapData.width, flowerBitmapData.height);

    var astronautBitmapData = resource.getBitmapData("astronaut");
    var astronautRectangle = new Rectangle(0, 0, astronautBitmapData.width, astronautBitmapData.height);

    //-------------------------------------------
    // draw the original astronaut

    var bitmapAstronaut = new Bitmap(astronautBitmapData);
    bitmapAstronaut.x = 60;
    bitmapAstronaut.y = 40;
    stage.addChild(bitmapAstronaut);

    //-------------------------------------------
    // use a blur filter for the astronaut

    var blurBitmapData = new BitmapData(astronautRectangle.width, astronautRectangle.height, true);
    var blurBitmap = new Bitmap(blurBitmapData);
    blurBitmap.x = 420;
    blurBitmap.y = 40;
    stage.addChild(blurBitmap);

    var blurFilter = new BlurFilter(4, 4);
    blurBitmapData.applyFilter(astronautBitmapData, astronautRectangle, new Point.zero(), blurFilter);

    //-------------------------------------------
    // use a grayscale color matrix filter

    var grayscaleBitmapData = new BitmapData(astronautRectangle.width, astronautRectangle.height, true);
    var grayscaleBitmap = new Bitmap(grayscaleBitmapData);
    grayscaleBitmap.x = 60;
    grayscaleBitmap.y = 390;
    grayscaleBitmap.scaleX = grayscaleBitmap.scaleY = 0.5;
    stage.addChild(grayscaleBitmap);

    var grayscaleFilter = new ColorMatrixFilter.grayscale();
    grayscaleBitmapData.applyFilter(astronautBitmapData, astronautRectangle, new Point.zero(), grayscaleFilter);


    //-------------------------------------------
    // use a inverse color matrix filter

    var invertBitmapData = new BitmapData(astronautRectangle.width, astronautRectangle.height, true);
    var invertBitmap = new Bitmap(invertBitmapData);
    invertBitmap.x = 220;
    invertBitmap.y = 390;
    invertBitmap.scaleX = invertBitmap.scaleY = 0.5;
    stage.addChild(invertBitmap);

    var inverseFilter = new ColorMatrixFilter.invert();
    invertBitmapData.applyFilter(astronautBitmapData, astronautRectangle, new Point.zero(), inverseFilter);

    //-------------------------------------------
    // use drop-shadow filter

    var dropShadowBitmapData = new BitmapData(160, 160, true);
    var dropShadowBitmap = new Bitmap(dropShadowBitmapData);
    dropShadowBitmap.x = 420;
    dropShadowBitmap.y = 390;
    stage.addChild(dropShadowBitmap);

    var dropShadowFilter = new DropShadowFilter(10, PI / 4, Color.Black, 0.6, 8, 8);
    dropShadowBitmapData.applyFilter(flowerBitmapData, flowerRectangle, new Point(16, 16), dropShadowFilter);

    //-------------------------------------------
    // use glow filter

    var glowBitmapData= new BitmapData(160, 160, true);
    var glowBitmap = new Bitmap(glowBitmapData);
    glowBitmap.x = 580;
    glowBitmap.y = 390;
    stage.addChild(glowBitmap);

    var glowFilter = new GlowFilter(Color.Red, 0.6, 16, 16);
    glowBitmapData.applyFilter(flowerBitmapData, flowerRectangle, new Point(16, 16), glowFilter);

  });

}

