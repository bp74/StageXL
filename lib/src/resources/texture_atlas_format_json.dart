part of stagexl.resources;

class _TextureAtlasFormatJson extends TextureAtlasFormat {

  const _TextureAtlasFormatJson();

  @override
  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    var source = await loader.getSource();
    var json = JSON.decode(source);
    var frames = json["frames"];
    var meta = json["meta"] as Map;
    var image = meta["image"] as String;

    var textureAtlas = new TextureAtlas();
    var renderTextureQuad = await loader.getRenderTextureQuad(image);

    if (frames is List) {
      for (var frame in frames) {
        var frameMap = frame as Map;
        var fileName = frameMap["filename"] as String;
        var frameName = getFilenameWithoutExtension(fileName);
        _createFrame(textureAtlas, renderTextureQuad, frameName, frameMap, meta);
      }
    }

    if (frames is Map) {
      for (String fileName in frames.keys) {
        var frameMap = frames[fileName] as Map;
        var frameName = getFilenameWithoutExtension(fileName);
        _createFrame(textureAtlas, renderTextureQuad, frameName, frameMap, meta);
      }
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  void _createFrame(
      TextureAtlas textureAtlas,
      RenderTextureQuad renderTextureQuad,
      String frameName, Map frameMap, Map metaMap) {

    int rotation = ensureBool(frameMap["rotated"] as bool) ? 1 : 0;
    int offsetX = ensureInt(frameMap["spriteSourceSize"]["x"]);
    int offsetY = ensureInt(frameMap["spriteSourceSize"]["y"]);
    int originalWidth = ensureInt(frameMap["sourceSize"]["w"]);
    int originalHeight = ensureInt(frameMap["sourceSize"]["h"]);
    int frameX = ensureInt(frameMap["frame"]["x"]);
    int frameY = ensureInt(frameMap["frame"]["y"]);
    int frameWidth = ensureInt(frameMap["frame"][rotation == 0 ? "w" : "h"]);
    int frameHeight = ensureInt(frameMap["frame"][rotation == 0 ? "h" : "w"]);

    Float32List vxList;
    Int16List ixList;

    if (frameMap.containsKey("vertices")) {

      var vertices = frameMap["vertices"] as List;
      var verticesUV = frameMap["verticesUV"] as List;
      var triangles = frameMap["triangles"] as List;
      var width = metaMap["size"]["w"].toInt();
      var height = metaMap["size"]["h"].toInt();

      vxList = new Float32List(vertices.length * 4);
      ixList = new Int16List(triangles.length * 3);

      for (int i = 0, j = 0; i <= vxList.length - 4; i += 4, j +=1) {
        vxList[i + 0] = vertices[j][0] * 1.0;
        vxList[i + 1] = vertices[j][1] * 1.0;
        vxList[i + 2] = verticesUV[j][0] / width;
        vxList[i + 3] = verticesUV[j][1] / height;
      }

      for (int i = 0, j = 0; i <= ixList.length - 3; i += 3, j += 1) {
        ixList[i + 0] = triangles[j][0];
        ixList[i + 1] = triangles[j][1];
        ixList[i + 2] = triangles[j][2];
      }
    }

    var taf = new TextureAtlasFrame(
        textureAtlas, renderTextureQuad, frameName, rotation,
        offsetX, offsetY, originalWidth, originalHeight,
        frameX, frameY, frameWidth, frameHeight,
        vxList, ixList);

    textureAtlas.frames.add(taf);
  }
}