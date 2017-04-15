part of stagexl.display_ex;

class ViewportContainer extends DisplayObjectContainer {

  Mask _viewportMask;
  Rectangle<num> _viewportRectangle;
  Matrix _viewportMatrix = new Matrix.fromIdentity();

  Rectangle<num> get viewport {
    return _viewportRectangle.clone();
  }

  set viewport(Rectangle<num> value) {
    _viewportRectangle = value?.clone();
    if (value != null) {
      _viewportMatrix.identity();
      _viewportMatrix.translate(0.0 - value.left, 0.0 - value.top);
      _viewportMask = new Mask.rectangle(0.0, 0.0, value.width, value.height);
    }
  }

  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    if (_viewportRectangle == null) {
      return super.bounds;
    } else {
      return _viewportRectangle?.clone();
    }
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    if (_viewportRectangle == null) {
      return super.hitTestInput(localX, localY);
    } else if (_viewportMask.hitTest(localX, localY)) {
      num x = localX + _viewportRectangle.left;
      num y = localY + _viewportRectangle.top;
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
