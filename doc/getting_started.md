# Getting started with StageXL

Learn the basic steps to build an application with StageXL. A more detailed getting started guide is available on the StageXL hompage: <http://www.stagexl.org/docs/getting-started.html>

### Package Import

To use StageXL in your application you have to add a depedency in your pubspec.yaml file. StageXL is hosted on the Pub package manager for Dart, so all you have to do is this:

    name: BestGameEver
    description: the best game on the web!
    dependencies: 
      stagexl: any

### HTML Code

You can use the standard Web application template from the Dart Editor to get started. But you have to add a Canvas element which will be the drawing area for StageXL.   

    <canvas id="stageCanvas" width="320" height="240"></canvas>

### Dart Code

The following code shows how to initialize the main drawing area (Stage) and how to put an image (BitmapData) to the screen. The image will be rotated, scaled and placed in the coordinate system of the Stage.

    import 'dart:html' as html;    
    import 'package:stagexl/stagexl.dart';

    void main() {

      // The Stage is a wrapper over the HTML canvas element.
      CanvasElement canvas = html.querySelector('#stageCanvas')
      Stage stage = new Stage(canvas);

      // The RenderLoop controls the flow of the program
      RenderLoop renderLoop = new RenderLoop();
      renderLoop.addStage(stage);

      // Start loading an image (BitmapData) and continue when done
      Future<BitmapData> future = BitmapData.loadImage('Flower.png');
      future.then((BitmapData bitmapData) {

        // A Bitmap is the display object you can add to the display list.
        Bitmap bitmap = new Bitmap(bitmapData);
        bitmap.scaleX = 0.5;
        bitmap.scaleY = 0.5;
        bitmap.rotation = PI / 8;
        bitmap.x = 50;
        bitmap.y = 30;

        // Add the Bitmap to the display list.
        stage.addChild(bitmap);
      });
    }

## Documentation

To learn more about the StageXL library please read the Wiki articles on the StageXL homepage. Learn about the Display List, how to animate your display objects with the Juggler animation framework, how to draw vector graphics and many other things here:

<http://www.stagexl.org/docs/wiki-articles.html> 

You are welcome to ask questions on the StageXL forum. Maybe your question was alread asked and you can find the answer right away. So please feel free and ask anything StageXL related here:

<http://www.stagexl.org/forum.html>

Or check out some of the more advances samples here: 

<http://www.stagexl.org/samples><br/>
<https://github.com/bp74/StageXL_Samples>
