part of stagexl.display_ex;

/// This class is a replacement for the deprecated shadow property of the
/// DisplayObject class. Please consider to use the DropShadowFilter class
/// which is the recommended technique to render shadows in WebGL.
///
/// The CanvasShadowWrapper takes an arbitrary DisplayObject and renders
/// it with a drop shadow if the render engine is Cancas2D (not WebGL).
///
/// Example with deprecated shadow property:
///
///     var spaceship = new Spaceship();
///     spaceship.x = 160;
///     spaceship.y = 200;
///     spaceship.shadow = new Shadow(Color.Black, 10, 10, 5);
///     stage.addChild(spaceship);
///
/// Example with the CanvasShadowWrapper class:
///
///     var spaceship = new Spaceship();
///     spaceship.x = 160;
///     spaceship.y = 200;
///     var shadow = new CanvasShadowWrapper(spaceship, Color.Black, 10, 10, 5);
///     stage.addChild(shadow);
///
class CanvasShadowWrapper extends DisplayObject {

  final DisplayObject displayObject;

  int shadowColor;
  num shadowOffsetX;
  num shadowOffsetY;
  num shadowBlur;

  CanvasShadowWrapper(this.displayObject, [
    this.shadowColor = Color.Black,
    this.shadowOffsetX = 10.0, this.shadowOffsetY = 10.0,
    this.shadowBlur = 0.0]);

  //-----------------------------------------------------------------------------------------------

  _throwUnsupportedError() {
    throw new UnsupportedError("CanvasShadowWrapper does not implement this property or method.");
  }

  void set x(num value) { _throwUnsupportedError(); }
  void set y(num value) { _throwUnsupportedError(); }
  void set pivotX(num value) { _throwUnsupportedError(); }
  void set pivotY(num value) { _throwUnsupportedError(); }
  void set scaleX(num value) { _throwUnsupportedError(); }
  void set scaleY(num value) { _throwUnsupportedError(); }
  void set skewX(num value) { _throwUnsupportedError(); }
  void set skewY(num value) { _throwUnsupportedError(); }
  void set rotation(num value) { _throwUnsupportedError(); }
  void set alpha(num value) { _throwUnsupportedError(); }
  void set mask(Mask mask) { _throwUnsupportedError(); }

  //-----------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {
    var matrix = this.displayObject.transformationMatrix;
    num deltaX = localX - matrix.tx;
    num deltaY = localY - matrix.ty;
    num childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
    num childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;
    return this.displayObject.hitTestInput(childX, childY);
  }

  //-----------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextCanvas) {

      RenderContextCanvas renderContextCanvas = renderContext as RenderContextCanvas;
      CanvasRenderingContext2D rawContext = renderContextCanvas.rawContext;
      Matrix shadowMatrix = renderState.globalMatrix;

      rawContext.save();
      rawContext.shadowColor = color2rgba(shadowColor);
      rawContext.shadowBlur = sqrt(shadowMatrix.det) * shadowBlur;
      rawContext.shadowOffsetX = shadowOffsetX * shadowMatrix.a + shadowOffsetY * shadowMatrix.c;
      rawContext.shadowOffsetY = shadowOffsetX * shadowMatrix.b + shadowOffsetY * shadowMatrix.d;
      renderState.renderObject(this.displayObject);
      rawContext.restore();

    } else {

      renderState.renderObject(this.displayObject);
    }
  }
}

