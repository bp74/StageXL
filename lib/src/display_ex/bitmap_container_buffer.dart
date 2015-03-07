part of stagexl.display_ex;

class _BitmapContainerBuffer {

  int contextIdentifier = -1;
  Float32List vertexList = null;
  gl.Buffer vertexBuffer = null;
  gl.RenderingContext renderingContext = null;

  _BitmapContainerBuffer(int size) {
    this.vertexList = new Float32List(size);
  }

  void dispose() {
    if (this.vertexBuffer != null) {
      this.renderingContext.deleteBuffer(this.vertexBuffer);
      this.renderingContext = null;
      this.vertexBuffer = null;
      this.contextIdentifier = -1;
    }
  }

  void activate(RenderContextWebGL renderContext) {
    if (this.contextIdentifier != renderContext.contextIdentifier) {
      this.renderingContext = renderContext.rawContext;
      this.contextIdentifier = renderContext.contextIdentifier;
      this.vertexBuffer = this.renderingContext.createBuffer();
      this.renderingContext.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
      this.renderingContext.bufferData(gl.ARRAY_BUFFER, vertexList, gl.DYNAMIC_DRAW);
    }
  }

}