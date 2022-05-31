part of stagexl.resources;

class ResourceManagerResource {
  final String kind;
  final String name;
  final String url;
  dynamic _value;
  dynamic _error;
  Function? cancel;
  Function? _progress;
  final Completer<ResourceManagerResource> _completer = Completer<ResourceManagerResource>();

  ResourceManagerResource(this.kind, this.name, this.url, Future loader, {Function? progress, this.cancel,}) : _progress = progress {
    loader.then((resource) {
      _value = resource;
    }).catchError((error) {
      _error = error;
    }).whenComplete(() {
      _completer.complete(this);
    });
  }

  @override
  String toString() =>
      'ResourceManagerResource [kind=$kind, name=$name, url = $url]';

  //---------------------------------------------------------------------------

  dynamic get value => _value;
  Object? get error => _error;
  num? get progress {
    if (_progress != null) {
      return _progress!() as num?;
    }
    return null;
  }
  set progressLookup (Function? cb){
    _progress = cb;
  }

  Future<ResourceManagerResource> get complete => _completer.future;
}
