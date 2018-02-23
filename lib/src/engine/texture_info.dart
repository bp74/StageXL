part of stagexl.engine;

class TextureInfo {

  int target = gl.TEXTURE_2D;
  int pixelFormat = gl.RGBA;
  int pixelType = gl.UNSIGNED_BYTE;

  @override
  bool operator == (Object other) =>
    other is TextureInfo
        && other.target == target
        && other.pixelFormat == pixelFormat
        && other.pixelType == pixelType;

  @override
  int get hashCode => JenkinsHash.hash3(target, pixelFormat, pixelType);
}

