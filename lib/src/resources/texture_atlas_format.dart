part of stagexl.resources;

abstract class TextureAtlasFormat {

  static const TextureAtlasFormat JSON = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat JSONARRAY = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat LIBGDX = const _TextureAtlasFormatLibGDX();

  const TextureAtlasFormat();

  Future<TextureAtlas> load(TextureAtlasLoader textureAtlasLoader);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasFormatJson extends TextureAtlasFormat {

  const _TextureAtlasFormatJson();

  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    var source = await loader.getSource();
    var json = JSON.decode(source);
    var frames = json["frames"];
    var meta = json["meta"];
    var image = meta["image"];

    var textureAtlas = new TextureAtlas();
    var renderTextureQuad = await loader.getRenderTextureQuad(image);

    if (frames is List) {
      for (var frame in frames) {
        var frameMap = frame as Map;
        var fileName = frameMap["filename"] as String;
        var frameName = getFilenameWithoutExtension(fileName);
        var taf = _createFrame(textureAtlas, renderTextureQuad, frameName, frameMap);
        textureAtlas.frames.add(taf);
      }
    }

    if (frames is Map) {
      for (String fileName in frames.keys) {
        var frameMap = frames[fileName] as Map;
        var frameName = getFilenameWithoutExtension(fileName);
        var taf = _createFrame(textureAtlas, renderTextureQuad, frameName, frameMap);
        textureAtlas.frames.add(taf);
      }
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  TextureAtlasFrame _createFrame(
      TextureAtlas textureAtlas, RenderTextureQuad renderTextureQuad,
      String frameName, Map frameMap) {

    int rotation = ensureBool(frameMap["rotated"]) ? 1 : 0;
    int offsetX = ensureInt(frameMap["spriteSourceSize"]["x"]);
    int offsetY = ensureInt(frameMap["spriteSourceSize"]["y"]);
    int originalWidth = ensureInt(frameMap["sourceSize"]["w"]);
    int originalHeight = ensureInt(frameMap["sourceSize"]["h"]);
    int frameX = ensureInt(frameMap["frame"]["x"]);
    int frameY = ensureInt(frameMap["frame"]["y"]);
    int frameWidth = ensureInt(frameMap["frame"][rotation == 0 ? "w" : "h"]);
    int frameHeight = ensureInt(frameMap["frame"][rotation == 0 ? "h" : "w"]);

    return new TextureAtlasFrame(
        textureAtlas, renderTextureQuad, frameName, rotation,
        offsetX, offsetY, originalWidth, originalHeight,
        frameX, frameY, frameWidth, frameHeight);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _TextureAtlasFormatLibGDX extends TextureAtlasFormat {

  const _TextureAtlasFormatLibGDX();

  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    RegExp splitRexExp = new RegExp(r"\r\n|\r|\n");
    RegExp dataRexExp = new RegExp(r"^\s*([a-z]+):\s([A-Za-z0-9\s,]+)");
    TextureAtlas textureAtlas = new TextureAtlas();

    var source = await loader.getSource();
    var lines = source.split(splitRexExp);
    var lineIndex = 0;
    var imageBlock = true;
    var renderTextureQuad = null;

    //-----------------------------------------------------

    while (lineIndex < lines.length) {
      var line = lines[lineIndex].trim();

      if (line.length == 0) {

        imageBlock = true;
        lineIndex++;

      } else if (imageBlock) {

        imageBlock = false;
        renderTextureQuad = await loader.getRenderTextureQuad(line);

        while (++lineIndex < lines.length) {
          var imageMatch = dataRexExp.firstMatch(lines[lineIndex]);
          if (imageMatch == null) break;
          // size: 355,139
          // format: RGBA8888
          // filter: Linear,Linear
          // repeat: none
        }

      } else {

        var frameName = line;
        var frameRotation = 0;
        var frameX = 0, frameY = 0;
        var frameWidth = 0, frameHeight = 0;
        var originalWidth = 0, originalHeight = 0;
        var offsetX = 0, offsetY = 0;

        while (++lineIndex < lines.length) {

          var frameMatch = dataRexExp.firstMatch(lines[lineIndex]);
          if (frameMatch == null) break;

          var key = frameMatch[1];
          var values = frameMatch[2].split(",").map((s) => s.trim()).toList();

          if (key == "rotate" && values.length == 1) {
            frameRotation = (values[0] == "true") ? 3 : 0;
          } else if (key == "xy" && values.length == 2) {
            frameX = int.parse(values[0]);
            frameY = int.parse(values[1]);
          } else if (key == "size" && values.length == 2) {
            frameWidth = int.parse(values[frameRotation == 0 ? 0 : 1]);
            frameHeight = int.parse(values[frameRotation == 0 ? 1 : 0]);
          } else if (key == "orig" && values.length == 2) {
            originalWidth = int.parse(values[0]);
            originalHeight = int.parse(values[1]);
          } else if (key == "offset" && values.length == 2) {
            offsetX = int.parse(values[0]);
            offsetY = int.parse(values[1]);
          }
        }

        var textureAtlasFrame = new TextureAtlasFrame(
            textureAtlas, renderTextureQuad, frameName, frameRotation,
            offsetX, offsetY, originalWidth, originalHeight,
            frameX, frameY, frameWidth, frameHeight);

        textureAtlas.frames.add(textureAtlasFrame);
      }
    }

    return textureAtlas;
  }
}
