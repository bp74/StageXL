part of stagexl.display_ex;

class ViewportContainer extends DisplayObjectContainer {
  Mask? _viewportMask;
  Rectangle<num>? _viewportRectangle;
  final Matrix _viewportMatrix = Matrix.fromIdentity();

  Rectangle<num>? get viewport {
    return _viewportRectangle?.clone();
  }

  set viewport(Rectangle<num>? value) {
    if (value == null) return;

    _viewportRectangle = value.clone();
    _viewportMatrix.identity();
    _viewportMatrix.translate(0.0 - value.left, 0.0 - value.top);
    _viewportMask = Mask.rectangle(0.0, 0.0, value.width, value.height);
  }

  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    if (_viewportRectangle == null) {
      return super.bounds;
    } else {
      return _viewportRectangle!.clone();
    }
  }

  @override
  DisplayObject? hitTestInput(num localX, num localY) {
    if (_viewportRectangle == null) {
      return super.hitTestInput(localX, localY);
    } else if (_viewportMask!.hitTest(localX, localY)) {
      var x = localX + _viewportRectangle!.left;
      var y = localY + _viewportRectangle!.top;
      return super.hitTestInput(x, y);
    } else {
      return null;
    }
  }

  @override
  void render(RenderState renderState) {
    if (_viewportRectangle == null) {
      super.render(renderState);
    } else {
      renderState.renderContext.beginRenderMask(renderState, _viewportMask);
      renderState.push(_viewportMatrix, 1.0, renderState.globalBlendMode);
      super.render(renderState);
      renderState.pop();
      renderState.renderContext.endRenderMask(renderState, _viewportMask);
    }
  }
}
