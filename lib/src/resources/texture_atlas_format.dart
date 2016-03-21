part of stagexl.resources;

abstract class TextureAtlasFormat {

  static const TextureAtlasFormat JSON = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat JSONARRAY = const _TextureAtlasFormatJson();
  static const TextureAtlasFormat LIBGDX = const _TextureAtlasFormatLibGDX();
  static const TextureAtlasFormat STARLINGXML = const _TextureAtlasFormatStarlingXml();
  static const TextureAtlasFormat STARLINGJSON = const _TextureAtlasFormatStarlingJson();

  const TextureAtlasFormat();

  Future<TextureAtlas> load(TextureAtlasLoader textureAtlasLoader);
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

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

    int rotation = ensureBool(frameMap["rotated"]) ? 1 : 0;
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

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

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
    var renderTextureQuad;

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
            frameX, frameY, frameWidth, frameHeight,
            null, null);

        textureAtlas.frames.add(textureAtlasFrame);
      }
    }

    return textureAtlas;
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _TextureAtlasFormatStarlingXml  extends TextureAtlasFormat {

  const _TextureAtlasFormatStarlingXml();

  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    var source = await loader.getSource();
    var xmlRoot = parse(source).rootElement;
    var textureAtlas = new TextureAtlas();

    var imagePath = _getString(xmlRoot, "imagePath", "");
    var renderTextureQuad = await loader.getRenderTextureQuad(imagePath);

    for(var subTextureXml in xmlRoot.findAllElements("SubTexture")) {

      var name = _getString(subTextureXml, "name", "");
      var rotation = _getBool(subTextureXml, "rotated", false) ? 1 : 0;

      var frameX = _getInt(subTextureXml, "x", 0);
      var frameY = _getInt(subTextureXml, "y", 0);
      var frameWidth = _getInt(subTextureXml, "width", 0);
      var frameHeight = _getInt(subTextureXml, "height", 0);

      var offsetX = 0 - _getInt(subTextureXml, "frameX", 0);
      var offsetY = 0 - _getInt(subTextureXml, "frameY", 0);
      var originalWidth = _getInt(subTextureXml, "frameWidth", frameWidth);
      var originalHeight = _getInt(subTextureXml, "frameHeight", frameHeight);

      var textureAtlasFrame = new TextureAtlasFrame(
          textureAtlas, renderTextureQuad, name, rotation,
          offsetX, offsetY, originalWidth, originalHeight,
          frameX, frameY, frameWidth, frameHeight,
          null, null);

      textureAtlas.frames.add(textureAtlasFrame);
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  String _getAttributeValue(XmlElement xml, String name) {
    for(var attribute in xml.attributes) {
      if (attribute.name.local == name) return attribute.value;
    }
    return null;
  }

  String _getString(XmlElement xml, String name, String defaultValue) {
    var value = _getAttributeValue(xml, name);
    return value is String ? value : defaultValue;
  }

  int _getInt(XmlElement xml, String name, int defaultValue) {
    var value = _getAttributeValue(xml, name);
    return value is String ? int.parse(value) : defaultValue;
  }

  bool _getBool(XmlElement xml, String name, bool defaultValue) {
    var value = _getAttributeValue(xml, name);
    if (value == null) return defaultValue;
    if (value == "1" || value =="true") return true;
    if (value == "0" || value =="false") return false;
    throw new FormatException("Error converting '$name' to bool.");
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _TextureAtlasFormatStarlingJson extends TextureAtlasFormat {

  const _TextureAtlasFormatStarlingJson();

  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    var source = await loader.getSource();
    var json = JSON.decode(source);
    var textureAtlas = new TextureAtlas();

    var imagePath = _getString(json, "imagePath", "");
    var renderTextureQuad = await loader.getRenderTextureQuad(imagePath);

    for(var subTextureMap in json["SubTexture"]) {

      var name = _getString(subTextureMap, "name", "");
      var rotation = _getBool(subTextureMap, "rotated", false) ? 1 : 0;

      var frameX = _getInt(subTextureMap, "x", 0);
      var frameY = _getInt(subTextureMap, "y", 0);
      var frameWidth = _getInt(subTextureMap, "width", 0);
      var frameHeight = _getInt(subTextureMap, "height", 0);

      var offsetX = 0 - _getInt(subTextureMap, "frameX", 0);
      var offsetY = 0 - _getInt(subTextureMap, "frameY", 0);
      var originalWidth = _getInt(subTextureMap, "frameWidth", frameWidth);
      var originalHeight = _getInt(subTextureMap, "frameHeight", frameHeight);

      var textureAtlasFrame = new TextureAtlasFrame(
          textureAtlas, renderTextureQuad, name, rotation,
          offsetX, offsetY, originalWidth, originalHeight,
          frameX, frameY, frameWidth, frameHeight,
          null, null);

      textureAtlas.frames.add(textureAtlasFrame);
    }

    return textureAtlas;
  }

  //---------------------------------------------------------------------------

  String _getString(Map map, String name, String defaultValue) {
    var value = map[name];
    return value is String ? value : defaultValue;
  }

  int _getInt(Map map, String name, int defaultValue) {
    var value = map[name];
    return value is int ? value : defaultValue;
  }

  bool _getBool(Map map, String name, bool defaultValue) {
    var value = map[name];
    return value is bool ? value : defaultValue;
  }
}

