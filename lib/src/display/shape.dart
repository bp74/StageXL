part of stagexl.display;

class Shape extends DisplayObject {

  Graphics graphics = new Graphics();

  @override
  Rectangle<num> get bounds {
    return graphics != null ? graphics.bounds : super.bounds;
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    if (graphics == null) return null;
    if (graphics.hitTestInput(localX, localY)) return this;
    return null;
  }

  @override
  void render(RenderState renderState) {
    if (graphics != null) graphics.render(renderState);
  }
}
