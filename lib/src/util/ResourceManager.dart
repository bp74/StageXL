part of dartflash;

@deprecated
class Resource extends ResourceManager {

}

class ResourceManager {
  
  Map<String, ResourceManagerResource> _resources;
  
  ResourceManager() {
    _resources = new Map<String, ResourceManagerResource>();
  }

  //-------------------------------------------------------------------------------------------------

  void _addResourceManagerResource(ResourceManagerResource resource) {
    
    var kind = resource.kind;
    var name = resource.name;
    var key = "$kind.$name";
    
    if (_resources.containsKey(key))
      throw new StateError("ResourceManager already contains a resource called '$name'");
    
    _resources[key] = resource;    
  }
  
  dynamic _getResourceManagerResource(String kind, String name) {
    
    var key = "$kind.$name";
    
    if (_resources.containsKey(key) == false)
      throw new StateError("ResourceManager does not contains a resource called '$name'");
    
    return _resources[key];
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  @deprecated
  void addImage(String name, String url) {
    addBitmapData(name, url); 
  }
  
  void addBitmapData(String name, String url) {
    
    var resource = new ResourceManagerResource("BitmapData", name, url);
    resource._load(BitmapData.load(url));
    
    _addResourceManagerResource(resource);
  }

  void addSound(String name, String url) {
    
    var resource = new ResourceManagerResource("Sound", name, url);
    resource._load(Sound.load(url));
    
    _addResourceManagerResource(resource);
  }

  void addTextureAtlas(String name, String url, String textureAtlasFormat) {
    
    var resource = new ResourceManagerResource("TextureAtlas", name, url);
    resource._load(TextureAtlas.load(url, textureAtlasFormat));
    
    _addResourceManagerResource(resource);
  }
  
  void addFlumpLibrary(String name, String url) {
    
    var resource = new ResourceManagerResource("FlumpLibrary", name, url);
    resource._load(FlumpLibrary.load(url));
    
    _addResourceManagerResource(resource);
  }

  void addText(String name, String text) {
    var resource = new ResourceManagerResource("Text", name, "");
    resource._load(new Future.immediate(text));
    
    _addResourceManagerResource(resource);
  }

  //-------------------------------------------------------------------------------------------------

  Future<ResourceManager> load() {
    
    var loaders = this.pendingResources.map((r) => r._loader);
    
    return Future.wait(loaders).then((value) {
      
      var errors = this.failedResources;
      if (errors.length > 0)
        throw new StateError("Failed to load ${errors.length} resource(s).");
      
      return this;
    });
  }
  
  List<ResourceManagerResource> get pendingResources {
    return _resources.values.where((r) => r.resource == null).toList();
  }

  List<ResourceManagerResource> get failedResources {
    return _resources.values.where((r) => r.error != null).toList();
  }
  
  List<ResourceManagerResource> get resources {
    return _resources.values.toList();
  }
  
  //-------------------------------------------------------------------------------------------------
  
  BitmapData getBitmapData(String name) {
    return _getResourceManagerResource("BitmapData", name).resource;
  }

  Sound getSound(String name) {
    return _getResourceManagerResource("Sound", name).resource;
  }

  TextureAtlas getTextureAtlas(String name) {
    return _getResourceManagerResource("TextureAtlas", name).resource;
  }

  FlumpLibrary getFlumpLibrary(String name) {
    return _getResourceManagerResource("FlumpLibrary", name).resource;
  }
  
  String getText(String name) {
    return _getResourceManagerResource("Text", name).resource;
  }

}
