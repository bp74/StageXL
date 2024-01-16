part of '../resources.dart';

class ResourceManagerResource {
  final String kind;
  final String name;
  final String url;
  dynamic _value;
  dynamic _error;
  final Completer<ResourceManagerResource> _completer =
      Completer<ResourceManagerResource>();

  ResourceManagerResource(this.kind, this.name, this.url, Future loader) {
    loader.then((resource) {
      _value = resource;
    }).catchError((Object error) {
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

  Future<ResourceManagerResource> get complete => _completer.future;
}
