part of stagexl.resources;

class TextureAtlas {

  final List<TextureAtlasFrame> frames = new List<TextureAtlasFrame>();

  static Future<TextureAtlas> load(
      String url, TextureAtlasFormat textureAtlasFormat, [
      BitmapDataLoadOptions bitmapDataLoadOptions]) {

    return textureAtlasFormat.load(url, bitmapDataLoadOptions);
  }

  List<String> get frameNames => frames.map((f) => f.name).toList(growable: false);

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name) {

    for(int i = 0; i < frames.length; i++) {
      var frame = frames[i];
      if (frame.name == name) return frame.getBitmapData();
    }

    throw new ArgumentError("TextureAtlasFrame not found: '$name'");
  }

  //-------------------------------------------------------------------------------------------------

  List<BitmapData> getBitmapDatas(String namePrefix) {

    var bitmapDataList = new List<BitmapData>();

    for(int i = 0; i < frames.length; i++) {
      var frame = frames[i];
      if (frame.name.startsWith(namePrefix)) {
        bitmapDataList.add(frame.getBitmapData());
      }
    }

    return bitmapDataList;
  }

}
