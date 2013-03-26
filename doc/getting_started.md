# Getting started with StageXL

Learn the basic steps to build an application with StageXL.

## Sample Application

The following code will show you how to initialize the main drawing area (Stage) and how to put an image (BitmapData) to the screen. The image will be rotated, scaled and placed in the coordinate system of the Stage.

### HTML Code

    <canvas id="stageCanvas" width="320" height="240"></canvas>

### Dart Code

    // the Stage is a wrapper over the HTML canvas element.
    Stage stage = new Stage('myStage', html.query('#stageCanvas'));

    // the RenderLoop controls the flow of the program
    RenderLoop renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

    // start loading an image (BitmapData) and continue when finished
    Future<BitmapData> future = BitmapData.loadImage('Flower.png');
    future.then((BitmapData bitmapData)
    {
      Bitmap bitmap = new Bitmap(bitmapData);
      bitmap.scaleX = bitmap.scaleY = 0.5;
      bitmap.rotation = PI / 8;
      bitmap.x = 50;
      bitmap.y = 30;
      stage.addChild(bitmap);
    });

### Examples

Please take a look at the example directory for more advanced examples. Those examples will show you the basic building blocks of StageXL. If you have some experience with the Adobe Flash API you will be pleasantly surprised :) 

There is another github repository which contains a game which was ported from Adobe Flash to HTML5 using the StageXL library. Because of the similarity between Dart and ActionScript and by using the StageXL library the port was finished in only 6 hours. The full source code is available here: <https://github.com/bp74/StageXL_Escape>.


## Package Import

Add the StageXL depedency to your pubspec.yaml ...

    name: BestGameEver
    description: the best game on the web!
    dependencies: 
      stagexl: { git: https://github.com/bp74/StageXL.git }

... then import the library in your Dart code.

    import 'package:stagexl/stagexl.dart';

## Resources

Visit our main website [www.stagexl.org](http://www.stagexl.org) to get more information about StageXL. 

* [API Reference](http://www.stagexl.org/docs/api/stagexl.html)
* [Wiki Articles](http://www.stagexl.org/docs/wiki-articles.html)
* [Demo Performance](http://www.stagexl.org/demos/performance.html)
* [Demo Masking](http://www.stagexl.org/demos/masking.html)
* [Demo MovieClip](http://www.stagexl.org/demos/flipbook.html)
* [FAQ](http://www.stagexl.org/docs/faq.html)


