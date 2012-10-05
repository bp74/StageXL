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

  resource.load().then((result) {

    // get the astronaut bitmap
    var bitmapDataAstronaut = resource.getBitmapData("astronaut");
    var bitmapAstronaut = new Bitmap(bitmapDataAstronaut);
    bitmapAstronaut.x = 60;
    bitmapAstronaut.y = 40;
    stage.addChild(bitmapAstronaut);

    var rect = new Rectangle(0, 0, bitmapDataAstronaut.width, bitmapDataAstronaut.height);

    //-------------------------------------------
    // use a blur filter

    var blurFilter = new BlurFilter(4, 4, BitmapFilterQuality.LOW);
    var bitmapDataBlurFilter = new BitmapData(rect.width, rect.height, true);
    bitmapDataBlurFilter.applyFilter(bitmapDataAstronaut, rect, new Point.zero(), blurFilter);

    var bitmapBlurFilter = new Bitmap(bitmapDataBlurFilter);
    bitmapBlurFilter.x = 420;
    bitmapBlurFilter.y = 40;
    stage.addChild(bitmapBlurFilter);

    //-------------------------------------------
    // use a grayscale color matrix filter

    var grayscaleFilter = new ColorMatrixFilter.grayscale();
    var bitmapDataGrayscale = new BitmapData(rect.width, rect.height, true);
    bitmapDataGrayscale.applyFilter(bitmapDataAstronaut, rect, new Point.zero(), grayscaleFilter);

    var bitmapGrayscale = new Bitmap(bitmapDataGrayscale);
    bitmapGrayscale.x = 60;
    bitmapGrayscale.y = 390;
    bitmapGrayscale.scaleX = bitmapGrayscale.scaleY = 0.5;
    stage.addChild(bitmapGrayscale);

    //-------------------------------------------
    // use a inverse color matrix filter

    var inverseFilter = new ColorMatrixFilter.invert();
    var bitmapDataInverse = new BitmapData(rect.width, rect.height, true);
    bitmapDataInverse.applyFilter(bitmapDataAstronaut, rect, new Point.zero(), inverseFilter);

    var bitmapInverse = new Bitmap(bitmapDataInverse);
    bitmapInverse.x = 220;
    bitmapInverse.y = 390;
    bitmapInverse.scaleX = bitmapInverse.scaleY = 0.5;
    stage.addChild(bitmapInverse);

  });

}

