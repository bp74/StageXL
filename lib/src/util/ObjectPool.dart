part of stagexl;

class ObjectPool<T> {
  
  final List<T> _pool = new List<T>();
  final Function _valueFactory;
  
  int _poolCount = 0;
  
  ObjectPool(T valueFactory()) : _valueFactory = valueFactory;
  
  //---------------------------------------------------------------------------
 
  T pop() {
    
    var poolCount = _poolCount;
    if (poolCount is! int) throw "dartjs_hint";
    
    if (poolCount == 0) {
      return _valueFactory();
    } else {
      _poolCount = poolCount - 1;
      return _pool[_poolCount];
    }
  }
  
  //---------------------------------------------------------------------------
  
  push(T value) {
    
    var poolCount = _poolCount;
    if (poolCount is! int) throw "dartjs_hint";
    
    if (poolCount == _pool.length) {
      _pool.add(value);
    } else {
      _pool[poolCount] = value;
    }
    _poolCount = poolCount + 1;
  }
  
  //---------------------------------------------------------------------------
  
  reset() {
    
    _pool.clear();
    _poolCount = 0;
  }
}

