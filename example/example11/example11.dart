library example11;

import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

part 'dot.dart';

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  var stage = new Stage("stage", html.document.query('#stage'));

  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // activate Multitouch input mode
  //------------------------------------------------------------------

 if (Multitouch.supportsTouchEvents) {
    Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
 } else {
   html.window.alert('''No touch screen detected!\n\nIf this device has a touch screen, please send a bug report to the StageXL issue tracker on github.''');
 }

  //------------------------------------------------------------------
  // add Touch Event handlers
  //------------------------------------------------------------------

  var dots = new Map<int, Dot>();
  var dotsLayer = new Sprite();
  dotsLayer.addTo(stage);

  void onTouchBegin(TouchEvent touchEvent) {
     var dot = new Dot(touchEvent.touchPointID, touchEvent.isPrimaryTouchPoint);
     dot.x = touchEvent.stageX;
     dot.y = touchEvent.stageY;
     dot.addTo(dotsLayer);
     dots[touchEvent.touchPointID] = dot;
  }

  void onTouchEnd(TouchEvent touchEvent) {
    var dot =  dots[touchEvent.touchPointID];
    dot.removeFromParent();
    dots.remove(touchEvent.touchPointID);
  }

  void onTouchCancel(TouchEvent touchEvent) {
    var dot =  dots[touchEvent.touchPointID];
    dot.removeFromParent();
    dots.remove(touchEvent.touchPointID);
  }

  void onTouchMove(TouchEvent touchEvent) {
    var dot =  dots[touchEvent.touchPointID];
    dot.x = touchEvent.stageX;
    dot.y = touchEvent.stageY;
  }

  void onTouchOut(TouchEvent touchEvent) {
    var dot =  dots[touchEvent.touchPointID];
    dot.visible = false;
  }

  void onTouchOver(TouchEvent touchEvent) {
    var dot =  dots[touchEvent.touchPointID];
    dot.visible = true;
  }

  var glass = new GlassPlate(800,600);
  glass.addTo(stage);
  glass.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
  glass.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
  glass.addEventListener(TouchEvent.TOUCH_CANCEL, onTouchCancel);
  glass.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
  glass.addEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
  glass.addEventListener(TouchEvent.TOUCH_OVER, onTouchOver);

}
