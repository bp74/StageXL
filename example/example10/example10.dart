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

    var blurFilter = new BlurFilter(4, 4, BitmapFilterQuality.LOW);

    var blurBitmapData = new BitmapData(astronautRectangle.width, astronautRectangle.height, true);
    blurBitmapData.applyFilter(astronautBitmapData, astronautRectangle, new Point.zero(), blurFilter);

    var blurBitmap = new Bitmap(blurBitmapData);
    blurBitmap.x = 420;
    blurBitmap.y = 40;
    stage.addChild(blurBitmap);

    //-------------------------------------------
    // use a grayscale color matrix filter

    var grayscaleFilter = new ColorMatrixFilter.grayscale();

    var grayscaleBitmapData = new BitmapData(astronautRectangle.width, astronautRectangle.height, true);
    grayscaleBitmapData.applyFilter(astronautBitmapData, astronautRectangle, new Point.zero(), grayscaleFilter);

    var grayscaleBitmap = new Bitmap(grayscaleBitmapData);
    grayscaleBitmap.x = 60;
    grayscaleBitmap.y = 390;
    grayscaleBitmap.scaleX = grayscaleBitmap.scaleY = 0.5;
    stage.addChild(grayscaleBitmap);

    //-------------------------------------------
    // use a inverse color matrix filter

    var inverseFilter = new ColorMatrixFilter.invert();

    var invertBitmapData = new BitmapData(astronautRectangle.width, astronautRectangle.height, true);
    invertBitmapData.applyFilter(astronautBitmapData, astronautRectangle, new Point.zero(), inverseFilter);

    var invertBitmap = new Bitmap(invertBitmapData);
    invertBitmap.x = 220;
    invertBitmap.y = 390;
    invertBitmap.scaleX = invertBitmap.scaleY = 0.5;
    stage.addChild(invertBitmap);

    //-------------------------------------------
    // use drop-shadow filter

    var dropShadowFilter = new DropShadowFilter(10, PI / 4, Color.Black, 0.6, 4, 4);

    var dropShadowBitmapData = new BitmapData(160, 160, true);
    dropShadowBitmapData.applyFilter(flowerBitmapData, flowerRectangle, new Point(16, 16), dropShadowFilter);

    var dropShadowBitmap = new Bitmap(dropShadowBitmapData);
    dropShadowBitmap.x = 420;
    dropShadowBitmap.y = 390;
    stage.addChild(dropShadowBitmap);

    //-------------------------------------------
    // use glow filter

    var glowFilter = new GlowFilter(Color.Red, 0.6, 10, 10);

    var glowBitmapData= new BitmapData(160, 160, true);
    glowBitmapData.applyFilter(flowerBitmapData, flowerRectangle, new Point(16, 16), glowFilter);

    var glowBitmap = new Bitmap(glowBitmapData);
    glowBitmap.x = 580;
    glowBitmap.y = 390;
    stage.addChild(glowBitmap);

  });

}

