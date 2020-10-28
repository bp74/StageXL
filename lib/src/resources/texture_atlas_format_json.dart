part of stagexl.resources;

class _TextureAtlasFormatJson extends TextureAtlasFormat {
  const _TextureAtlasFormatJson();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {
    var source = await loader.getSource();
    var pixelRatio = loader.getPixelRatio();
    var textureAtlas = TextureAtlas(pixelRatio);

    var json = jsonDecode(source);
    var frames = json['frames'];
    var meta = json['meta'] as Map;
    var image = meta['image'] as String;
    var renderTextureQuad = await loader.getRenderTextureQuad(image);

    if (frames is List) {
      for (var frame in frames) {
        var frameMap = frame as Map;
        var fileName = frameMap['filename'] as String;
        var frameName = getFilenameWithoutExtension(fileName);
        _createFrame(
            textureAtlas, renderTextureQuad, frameName, frameMap, meta);
      }
    }

    if (frames is Map) {
      for (var fileName in frames.keys as Iterable<String>) {
        var frameMap = frames[fileName] as Map;
        var frameName = getFilenameWithoutExtension(fileName);
        _createFrame(
            textureAtlas, renderTextureQuad, frameName, frameMap, meta);
      }
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  void _createFrame(
      TextureAtlas textureAtlas,
      RenderTextureQuad renderTextureQuad,
      String frameName,
      Map frameMap,
      Map metaMap) {
    var rotation = (frameMap['rotated'] as bool? ?? false) ? 1 : 0;
    var offsetX = frameMap['spriteSourceSize']['x'] as int;
    var offsetY = frameMap['spriteSourceSize']['y'] as int;
    var originalWidth = frameMap['sourceSize']['w'] as int;
    var originalHeight = frameMap['sourceSize']['h'] as int;
    var frameX = frameMap['frame']['x'] as int;
    var frameY = frameMap['frame']['y'] as int;
    var frameWidth = frameMap['frame'][rotation == 0 ? 'w' : 'h'] as int;
    var frameHeight = frameMap['frame'][rotation == 0 ? 'h' : 'w'] as int;

    Float32List? vxList;
    Int16List? ixList;

    if (frameMap.containsKey('vertices')) {
      var vertices = frameMap['vertices'] as List;
      var verticesUV = frameMap['verticesUV'] as List?;
      var triangles = frameMap['triangles'] as List;
      var width = metaMap['size']['w'].toInt();
      var height = metaMap['size']['h'].toInt();

      vxList = Float32List(vertices.length * 4);
      ixList = Int16List(triangles.length * 3);

      for (var i = 0, j = 0; i <= vxList.length - 4; i += 4, j += 1) {
        vxList[i + 0] = vertices[j][0] * 1.0;
        vxList[i + 1] = vertices[j][1] * 1.0;
        vxList[i + 2] = verticesUV![j][0] / width;
        vxList[i + 3] = verticesUV[j][1] / height;
      }

      for (var i = 0, j = 0; i <= ixList.length - 3; i += 3, j += 1) {
        ixList[i + 0] = triangles[j][0];
        ixList[i + 1] = triangles[j][1];
        ixList[i + 2] = triangles[j][2];
      }
    }

    var taf = TextureAtlasFrame(
        textureAtlas,
        renderTextureQuad,
        frameName,
        rotation,
        offsetX,
        offsetY,
        originalWidth,
        originalHeight,
        frameX,
        frameY,
        frameWidth,
        frameHeight,
        vxList,
        ixList);

    textureAtlas.frames.add(taf);
  }
}
