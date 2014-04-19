part of stagexl;

class ResourceManager extends EventDispatcher {

  final Map<String, ResourceManagerResource> _resources = new Map<String, ResourceManagerResource>();

  static const EventStreamProvider<Event> progressEvent = const EventStreamProvider<Event>(Event.PROGRESS);
  EventStream<Event> get onProgress => ResourceManager.progressEvent.forTarget(this);

  //-----------------------------------------------------------------------------------------------

  bool _containsResource(String kind, String name) {
    var key = "$kind.$name";
    return _resources.containsKey(key);
  }

  _addResource(String kind, String name, String url, Future loader) {

    var key = "$kind.$name";
    var resource = new ResourceManagerResource(kind, name, url, loader);

    if (_resources.containsKey(key)) {
      throw new StateError("ResourceManager already contains a resource called '$name'");
    } else {
      _resources[key] = resource;
    }

    resource.complete.then((_) {
      this.dispatchEvent(new Event(Event.PROGRESS));
    });
  }

  dynamic _getResourceValue(String kind, String name) {

    var key = "$kind.$name";
    var resource = _resources[key];

    if (resource == null) {
      throw new StateError("Resource '$name' does not exist.");
    } else if (resource.value != null) {
      return resource.value;
    } else if (resource.error != null) {
      throw resource.error;
    } else {
      throw new StateError("Resource '$name' has not finished loading yet.");
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  Future<ResourceManager> load() {

    var futures = this.pendingResources.map((r) => r.complete);

    return Future.wait(futures).then((value) {
      var errors = this.failedResources.length;
      if (errors > 0) {
        throw new StateError("Failed to load $errors resource(s).");
      } else {
        return this;
      }
    });
  }

  //-----------------------------------------------------------------------------------------------

  List<ResourceManagerResource> get finishedResources {
    return _resources.values.where((r) => r.value != null).toList();
  }

  List<ResourceManagerResource> get pendingResources {
    return _resources.values.where((r) => r.value == null && r.error == null).toList();
  }

  List<ResourceManagerResource> get failedResources {
    return _resources.values.where((r) => r.error != null).toList();
  }

  List<ResourceManagerResource> get resources {
    return _resources.values.toList();
  }

  //-----------------------------------------------------------------------------------------------

  bool containsBitmapData(String name) => _containsResource("BitmapData", name);
  bool containsSound(String name) => _containsResource("Sound", name);
  bool containsSoundSprite(String name) => _containsResource("SoundSprite", name);
  bool containsTextureAtlas(String name) => _containsResource("TextureAtlas", name);
  bool containsTextFile(String name) => _containsResource("TextFile", name);
  bool containsText(String name) => _containsResource("Text", name);
  bool containsCustomObject(String name) => _containsResource("CustomObject", name);

  //-----------------------------------------------------------------------------------------------

  void addBitmapData(String name, String url, [BitmapDataLoadOptions bitmapDataLoadOptions = null]) {
    _addResource("BitmapData", name, url, BitmapData.load(url, bitmapDataLoadOptions));
  }

  void addSound(String name, String url, [SoundLoadOptions soundFileSupport = null]) {
    _addResource("Sound", name, url, Sound.load(url, soundFileSupport));
  }

  void addSoundSprite(String name, String url) {
    _addResource("SoundSprite", name, url, SoundSprite.load(url));
  }

  void addTextureAtlas(String name, String url, String textureAtlasFormat) {
    _addResource("TextureAtlas", name, url, TextureAtlas.load(url, textureAtlasFormat));
  }

  void addTextFile(String name, String url) {
    _addResource("TextFile", name, url,
        HttpRequest.getString(url).then((text) => text, onError: (error) {
          throw new StateError("Failed to load text file.");
        }));
  }

  void addText(String name, String text) {
    _addResource("Text", name, "", new Future.value(text));
  }

  void addCustomObject(String name, Future loader) {
    _addResource("CustomObject", name, "", loader);
  }

  //-----------------------------------------------------------------------------------------------

  BitmapData getBitmapData(String name) {
    var value = _getResourceValue("BitmapData", name);
    if (value is! BitmapData) throw "dart2js_hint";
    return value;
  }

  Sound getSound(String name) {
    var value = _getResourceValue("Sound", name);
    if (value is! Sound) throw "dart2js_hint";
    return value;
  }

  SoundSprite getSoundSprite(String name) {
    var value = _getResourceValue("SoundSprite", name);
    if (value is! SoundSprite) throw "dart2js_hint";
    return value;
  }

  TextureAtlas getTextureAtlas(String name) {
    var value = _getResourceValue("TextureAtlas", name);
    if (value is! TextureAtlas) throw "dart2js_hint";
    return value;
  }

  String getTextFile(String name) {
    var value = _getResourceValue("TextFile", name);
    if (value is! String) throw "dart2js_hint";
    return value;
  }

  String getText(String name) {
    var value = _getResourceValue("Text", name);
    if (value is! String) throw "dart2js_hint";
    return value;
  }

  dynamic getCustomObject(String name) {
    return _getResourceValue("CustomObject", name);
  }

}
