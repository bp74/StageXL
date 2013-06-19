part of stagexl;

class ObjectPool<T> {

  final List<T> _pool = new List<T>();
  final Function _valueFactory;

  int _poolCount = 0;

  ObjectPool(T valueFactory()) : _valueFactory = valueFactory;

  //---------------------------------------------------------------------------

  T pop() {

    if (_poolCount == 0) {
      return _valueFactory();
    } else {
      _poolCount--;
      return _pool[_poolCount];
    }
  }

  //---------------------------------------------------------------------------

  push(T value) {

    if (_poolCount == _pool.length) {
      _pool.add(value);
    } else {
      _pool[_poolCount] = value;
    }
    _poolCount++;
  }

  //---------------------------------------------------------------------------

  reset() {

    _pool.clear();
    _poolCount = 0;
  }
}

