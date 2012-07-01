function Isolate() {}
init();

var $$ = {};
var $ = Isolate.$isolateProperties;
$$.ExceptionImplementation = {"":
 ["_msg"],
 super: "Object",
 toString$0: function() {
  var t1 = this._msg;
  return t1 == null ? 'Exception' : 'Exception: ' + $.S(t1);
 },
 is$Exception: true
};

$$.FutureImpl = {"":
 ["_completionListeners", "_exceptionHandlers", "_successListeners", "_exceptionHandled", "_stackTrace", "_exception", "_value", "_isComplete"],
 super: "Object",
 _setException$2: function(exception, stackTrace) {
  if (exception == null) throw $.captureStackTrace($.IllegalArgumentException$1(null));
  if (this._isComplete === true) throw $.captureStackTrace($.FutureAlreadyCompleteException$0());
  this._exception = exception;
  this._stackTrace = stackTrace;
  this._complete$0();
 },
 _setValue$1: function(value) {
  if (this._isComplete === true) throw $.captureStackTrace($.FutureAlreadyCompleteException$0());
  this._value = value;
  this._complete$0();
 },
 _complete$0: function() {
  this._isComplete = true;
  try {
    var t1 = this._exception;
    if (!(t1 == null)) {
      for (t1 = $.iterator(this._exceptionHandlers); t1.hasNext$0() === true; ) {
        var handler = t1.next$0();
        if ($.eqB(handler.$call$1(this._exception), true)) {
          this._exceptionHandled = true;
          break;
        }
      }
    }
    if (this.get$hasValue() === true) {
      for (t1 = $.iterator(this._successListeners); t1.hasNext$0() === true; ) {
        var listener = t1.next$0();
        listener.$call$1(this.get$value());
      }
    } else {
      if (this._exceptionHandled !== true && $.gtB($.get$length(this._successListeners), 0)) throw $.captureStackTrace(this._exception);
    }
  } finally {
    for (t1 = $.iterator(this._completionListeners); t1.hasNext$0() === true; ) {
      var listener0 = t1.next$0();
      try {
        listener0.$call$1(this);
      } catch (exception) {
        $.unwrapException(exception);
      }
    }
  }
 },
 handleException$1: function(onException) {
  if (this._exceptionHandled === true) return;
  if (this._isComplete === true) {
    if (!$.eqNullB(this._exception)) this._exceptionHandled = onException.$call$1(this._exception);
  } else $.add$1(this._exceptionHandlers, onException);
 },
 then$1: function(onSuccess) {
  if (this.get$hasValue() === true) onSuccess.$call$1(this.get$value());
  else {
    if (this.get$isComplete() !== true) $.add$1(this._successListeners, onSuccess);
    else {
      if (this._exceptionHandled !== true) throw $.captureStackTrace(this._exception);
    }
  }
 },
 get$hasValue: function() {
  if (this.get$isComplete() === true) {
    var t1 = this._exception;
    t1 = t1 == null;
  } else t1 = false;
  return t1;
 },
 get$isComplete: function() {
  return this._isComplete;
 },
 get$exception: function() {
  if (this.get$isComplete() !== true) throw $.captureStackTrace($.FutureNotCompleteException$0());
  return this._exception;
 },
 get$value: function() {
  if (this.get$isComplete() !== true) throw $.captureStackTrace($.FutureNotCompleteException$0());
  var t1 = this._exception;
  if (!(t1 == null)) throw $.captureStackTrace(t1);
  return this._value;
 }
};

$$.CompleterImpl = {"":
 ["_futureImpl"],
 super: "Object",
 completeException$2: function(exception, stackTrace) {
  this._futureImpl._setException$2(exception, stackTrace);
 },
 completeException$1: function(exception) {
  return this.completeException$2(exception,null)
},
 complete$1: function(value) {
  this._futureImpl._setValue$1(value);
 },
 get$future: function() {
  return this._futureImpl;
 }
};

$$.HashMapImplementation = {"":
 ["_numberOfDeleted", "_numberOfEntries", "_loadLimit", "_values", "_keys?"],
 super: "Object",
 toString$0: function() {
  return $.mapToString(this);
 },
 containsKey$1: function(key) {
  return !$.eqB(this._probeForLookup$1(key), -1);
 },
 forEach$1: function(f) {
  var length$ = $.get$length(this._keys);
  if (typeof length$ !== 'number') return this.forEach$1$bailout(1, f, length$);
  for (var i = 0; i < length$; ++i) {
    var key = $.index(this._keys, i);
    !(key == null) && !(key === $.CTC1) && f.$call$2(key, $.index(this._values, i));
  }
 },
 forEach$1$bailout: function(state, f, length$) {
  for (var i = 0; $.ltB(i, length$); ++i) {
    var key = $.index(this._keys, i);
    !(key == null) && !(key === $.CTC1) && f.$call$2(key, $.index(this._values, i));
  }
 },
 get$length: function() {
  return this._numberOfEntries;
 },
 isEmpty$0: function() {
  return $.eq(this._numberOfEntries, 0);
 },
 operator$index$1: function(key) {
  var index = this._probeForLookup$1(key);
  if (typeof index !== 'number') return this.operator$index$1$bailout(1, index, 0);
  if (index < 0) return;
  var t1 = this._values;
  if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.operator$index$1$bailout(2, t1, index);
  if (index !== (index | 0)) throw $.iae(index);
  var t2 = t1.length;
  if (index < 0 || index >= t2) throw $.ioore(index);
  return t1[index];
 },
 operator$index$1$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      index = env0;
      break;
    case 2:
      t1 = env0;
      index = env1;
      break;
  }
  switch (state) {
    case 0:
      var index = this._probeForLookup$1(key);
    case 1:
      state = 0;
      if ($.ltB(index, 0)) return;
      var t1 = this._values;
    case 2:
      state = 0;
      return $.index(t1, index);
  }
 },
 operator$indexSet$2: function(key, value) {
  this._ensureCapacity$0();
  var index = this._probeForAdding$1(key);
  var t1 = $.index(this._keys, index);
  if (!(t1 == null)) {
    t1 = $.index(this._keys, index);
    t1 = t1 === $.CTC1;
  } else t1 = true;
  if (t1) this._numberOfEntries = $.add(this._numberOfEntries, 1);
  $.indexSet(this._keys, index, key);
  $.indexSet(this._values, index, value);
 },
 clear$0: function() {
  this._numberOfEntries = 0;
  this._numberOfDeleted = 0;
  var length$ = $.get$length(this._keys);
  if (typeof length$ !== 'number') return this.clear$0$bailout(1, length$);
  for (var i = 0; i < length$; ++i) {
    $.indexSet(this._keys, i, null);
    $.indexSet(this._values, i, null);
  }
 },
 clear$0$bailout: function(state, length$) {
  for (var i = 0; $.ltB(i, length$); ++i) {
    $.indexSet(this._keys, i, null);
    $.indexSet(this._values, i, null);
  }
 },
 _grow$1: function(newCapacity) {
  var capacity = $.get$length(this._keys);
  if (typeof capacity !== 'number') return this._grow$1$bailout(1, newCapacity, capacity, 0, 0);
  this._loadLimit = $._computeLoadLimit(newCapacity);
  var oldKeys = this._keys;
  if (typeof oldKeys !== 'string' && (typeof oldKeys !== 'object' || oldKeys === null || (oldKeys.constructor !== Array && !oldKeys.is$JavaScriptIndexingBehavior()))) return this._grow$1$bailout(2, newCapacity, oldKeys, capacity, 0);
  var oldValues = this._values;
  if (typeof oldValues !== 'string' && (typeof oldValues !== 'object' || oldValues === null || (oldValues.constructor !== Array && !oldValues.is$JavaScriptIndexingBehavior()))) return this._grow$1$bailout(3, newCapacity, oldKeys, oldValues, capacity);
  this._keys = $.List(newCapacity);
  var t1 = $.List(newCapacity);
  $.setRuntimeTypeInfo(t1, ({E: 'V'}));
  this._values = t1;
  for (var i = 0; i < capacity; ++i) {
    t1 = oldKeys.length;
    if (i < 0 || i >= t1) throw $.ioore(i);
    var t2 = oldKeys[i];
    if (t2 == null || t2 === $.CTC1) continue;
    t1 = oldValues.length;
    if (i < 0 || i >= t1) throw $.ioore(i);
    var t3 = oldValues[i];
    var newIndex = this._probeForAdding$1(t2);
    $.indexSet(this._keys, newIndex, t2);
    $.indexSet(this._values, newIndex, t3);
  }
  this._numberOfDeleted = 0;
 },
 _grow$1$bailout: function(state, env0, env1, env2, env3) {
  switch (state) {
    case 1:
      var newCapacity = env0;
      capacity = env1;
      break;
    case 2:
      newCapacity = env0;
      oldKeys = env1;
      capacity = env2;
      break;
    case 3:
      newCapacity = env0;
      oldKeys = env1;
      oldValues = env2;
      capacity = env3;
      break;
  }
  switch (state) {
    case 0:
      var capacity = $.get$length(this._keys);
    case 1:
      state = 0;
      this._loadLimit = $._computeLoadLimit(newCapacity);
      var oldKeys = this._keys;
    case 2:
      state = 0;
      var oldValues = this._values;
    case 3:
      state = 0;
      this._keys = $.List(newCapacity);
      var t1 = $.List(newCapacity);
      $.setRuntimeTypeInfo(t1, ({E: 'V'}));
      this._values = t1;
      for (var i = 0; $.ltB(i, capacity); ++i) {
        var key = $.index(oldKeys, i);
        if (key == null || key === $.CTC1) continue;
        var value = $.index(oldValues, i);
        var newIndex = this._probeForAdding$1(key);
        $.indexSet(this._keys, newIndex, key);
        $.indexSet(this._values, newIndex, value);
      }
      this._numberOfDeleted = 0;
  }
 },
 _ensureCapacity$0: function() {
  var newNumberOfEntries = $.add(this._numberOfEntries, 1);
  if ($.geB(newNumberOfEntries, this._loadLimit)) {
    this._grow$1($.mul($.get$length(this._keys), 2));
    return;
  }
  var numberOfFree = $.sub($.sub($.get$length(this._keys), newNumberOfEntries), this._numberOfDeleted);
  $.gtB(this._numberOfDeleted, numberOfFree) && this._grow$1($.get$length(this._keys));
 },
 _probeForLookup$1: function(key) {
  var hash = $._firstProbe($.hashCode(key), $.get$length(this._keys));
  for (var numberOfProbes = 1; true; ) {
    var existingKey = $.index(this._keys, hash);
    if (existingKey == null) return -1;
    if ($.eqB(existingKey, key)) return hash;
    var numberOfProbes0 = numberOfProbes + 1;
    hash = $._nextProbe(hash, numberOfProbes, $.get$length(this._keys));
    numberOfProbes = numberOfProbes0;
  }
 },
 _probeForAdding$1: function(key) {
  var hash = $._firstProbe($.hashCode(key), $.get$length(this._keys));
  if (hash !== (hash | 0)) return this._probeForAdding$1$bailout(1, key, hash, 0, 0, 0);
  for (var numberOfProbes = 1, insertionIndex = -1; true; ) {
    var t1 = this._keys;
    if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this._probeForAdding$1$bailout(2, numberOfProbes, hash, key, insertionIndex, t1);
    var t2 = t1.length;
    if (hash < 0 || hash >= t2) throw $.ioore(hash);
    t1 = t1[hash];
    if (t1 == null) {
      if (insertionIndex < 0) return hash;
      return insertionIndex;
    }
    if ($.eqB(t1, key)) return hash;
    if (insertionIndex < 0 && $.CTC1 === t1) insertionIndex = hash;
    var numberOfProbes0 = numberOfProbes + 1;
    hash = $._nextProbe(hash, numberOfProbes, $.get$length(this._keys));
    if (hash !== (hash | 0)) return this._probeForAdding$1$bailout(3, key, numberOfProbes0, insertionIndex, hash, 0);
    numberOfProbes = numberOfProbes0;
  }
 },
 _probeForAdding$1$bailout: function(state, env0, env1, env2, env3, env4) {
  switch (state) {
    case 1:
      var key = env0;
      hash = env1;
      break;
    case 2:
      numberOfProbes = env0;
      hash = env1;
      key = env2;
      insertionIndex = env3;
      t1 = env4;
      break;
    case 3:
      key = env0;
      numberOfProbes0 = env1;
      insertionIndex = env2;
      hash = env3;
      break;
  }
  switch (state) {
    case 0:
      var hash = $._firstProbe($.hashCode(key), $.get$length(this._keys));
    case 1:
      state = 0;
      var numberOfProbes = 1;
      var insertionIndex = -1;
    case 2:
    case 3:
      L0: while (true) {
        switch (state) {
          case 0:
            if (!true) break L0;
            var t1 = this._keys;
          case 2:
            state = 0;
            var existingKey = $.index(t1, hash);
            if (existingKey == null) {
              if ($.ltB(insertionIndex, 0)) return hash;
              return insertionIndex;
            }
            if ($.eqB(existingKey, key)) return hash;
            if ($.ltB(insertionIndex, 0) && $.CTC1 === existingKey) insertionIndex = hash;
            var numberOfProbes0 = numberOfProbes + 1;
            hash = $._nextProbe(hash, numberOfProbes, $.get$length(this._keys));
          case 3:
            state = 0;
            numberOfProbes = numberOfProbes0;
        }
      }
  }
 },
 HashMapImplementation$0: function() {
  this._numberOfEntries = 0;
  this._numberOfDeleted = 0;
  this._loadLimit = $._computeLoadLimit(8);
  this._keys = $.List(8);
  var t1 = $.List(8);
  $.setRuntimeTypeInfo(t1, ({E: 'V'}));
  this._values = t1;
 },
 is$Map: function() { return true; }
};

$$.HashSetImplementation = {"":
 ["_backingMap?"],
 super: "Object",
 toString$0: function() {
  return $.collectionToString(this);
 },
 iterator$0: function() {
  var t1 = $.HashSetIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({E: 'E'}));
  return t1;
 },
 get$length: function() {
  return $.get$length(this._backingMap);
 },
 isEmpty$0: function() {
  return $.isEmpty(this._backingMap);
 },
 forEach$1: function(f) {
  var t1 = ({});
  t1.f_1 = f;
  $.forEach(this._backingMap, new $.Closure25(t1));
 },
 contains$1: function(value) {
  return this._backingMap.containsKey$1(value);
 },
 add$1: function(value) {
  var t1 = this._backingMap;
  if (typeof t1 !== 'object' || t1 === null || ((t1.constructor !== Array || !!t1.immutable$list) && !t1.is$JavaScriptIndexingBehavior())) return this.add$1$bailout(1, t1, value);
  if (value !== (value | 0)) throw $.iae(value);
  var t2 = t1.length;
  if (value < 0 || value >= t2) throw $.ioore(value);
  t1[value] = value;
 },
 add$1$bailout: function(state, t1, value) {
  $.indexSet(t1, value, value);
 },
 clear$0: function() {
  $.clear(this._backingMap);
 },
 HashSetImplementation$0: function() {
  this._backingMap = $.HashMapImplementation$0();
 },
 is$Collection: function() { return true; }
};

$$.HashSetIterator = {"":
 ["_nextValidIndex", "_entries"],
 super: "Object",
 _advance$0: function() {
  var t1 = this._entries;
  if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this._advance$0$bailout(1, t1);
  var length$ = t1.length;
  var entry = null;
  do {
    var t2 = this._nextValidIndex + 1;
    this._nextValidIndex = t2;
    if ($.geB(t2, length$)) break;
    t2 = this._nextValidIndex;
    if (t2 !== (t2 | 0)) throw $.iae(t2);
    var t3 = t1.length;
    if (t2 < 0 || t2 >= t3) throw $.ioore(t2);
    entry = t1[t2];
  } while ((entry == null || entry === $.CTC1));
 },
 _advance$0$bailout: function(state, t1) {
  var length$ = $.get$length(t1);
  var entry = null;
  do {
    var t2 = $.add(this._nextValidIndex, 1);
    this._nextValidIndex = t2;
    if ($.geB(t2, length$)) break;
    entry = $.index(t1, this._nextValidIndex);
  } while ((entry == null || entry === $.CTC1));
 },
 next$0: function() {
  if (this.hasNext$0() !== true) throw $.captureStackTrace($.CTC0);
  var t1 = this._entries;
  if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.next$0$bailout(1, t1);
  var t2 = this._nextValidIndex;
  if (t2 !== (t2 | 0)) throw $.iae(t2);
  var t3 = t1.length;
  if (t2 < 0 || t2 >= t3) throw $.ioore(t2);
  t2 = t1[t2];
  this._advance$0();
  return t2;
 },
 next$0$bailout: function(state, t1) {
  var res = $.index(t1, this._nextValidIndex);
  this._advance$0();
  return res;
 },
 hasNext$0: function() {
  var t1 = this._nextValidIndex;
  if (typeof t1 !== 'number') return this.hasNext$0$bailout(1, t1, 0);
  var t2 = this._entries;
  if (typeof t2 !== 'string' && (typeof t2 !== 'object' || t2 === null || (t2.constructor !== Array && !t2.is$JavaScriptIndexingBehavior()))) return this.hasNext$0$bailout(2, t1, t2);
  var t3 = t2.length;
  if (t1 >= t3) return false;
  if (t1 !== (t1 | 0)) throw $.iae(t1);
  if (t1 < 0 || t1 >= t3) throw $.ioore(t1);
  t1 = t2[t1];
  t1 === $.CTC1 && this._advance$0();
  t1 = this._nextValidIndex;
  if (typeof t1 !== 'number') return this.hasNext$0$bailout(3, t1, t2);
  return t1 < t2.length;
 },
 hasNext$0$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      t1 = env0;
      break;
    case 2:
      t1 = env0;
      t2 = env1;
      break;
    case 3:
      t1 = env0;
      t2 = env1;
      break;
  }
  switch (state) {
    case 0:
      var t1 = this._nextValidIndex;
    case 1:
      state = 0;
      var t2 = this._entries;
    case 2:
      state = 0;
      if ($.geB(t1, $.get$length(t2))) return false;
      t1 = $.index(t2, this._nextValidIndex);
      t1 === $.CTC1 && this._advance$0();
      t1 = this._nextValidIndex;
    case 3:
      state = 0;
      return $.lt(t1, $.get$length(t2));
  }
 },
 HashSetIterator$1: function(set_) {
  this._advance$0();
 }
};

$$._DeletedKeySentinel = {"":
 [],
 super: "Object"
};

$$.StringBufferImpl = {"":
 ["_length", "_buffer"],
 super: "Object",
 toString$0: function() {
  var t1 = $.get$length(this._buffer);
  if (t1 === 0) return '';
  t1 = $.get$length(this._buffer);
  if (t1 === 1) {
    t1 = this._buffer;
    if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.toString$0$bailout(1, t1);
    var t2 = t1.length;
    if (0 >= t2) throw $.ioore(0);
    return t1[0];
  }
  var result = $.concatAll(this._buffer);
  $.clear(this._buffer);
  $.add$1(this._buffer, result);
  return result;
 },
 toString$0$bailout: function(state, env0) {
  switch (state) {
    case 1:
      t1 = env0;
      break;
  }
  switch (state) {
    case 0:
      var t1 = $.get$length(this._buffer);
      if (t1 === 0) return '';
      t1 = $.get$length(this._buffer);
    case 1:
      if (state == 1 || (state == 0 && t1 === 1)) {
        switch (state) {
          case 0:
            t1 = this._buffer;
          case 1:
            state = 0;
            return $.index(t1, 0);
        }
      }
      var result = $.concatAll(this._buffer);
      $.clear(this._buffer);
      $.add$1(this._buffer, result);
      return result;
  }
 },
 clear$0: function() {
  var t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'String'}));
  this._buffer = t1;
  this._length = 0;
  return this;
 },
 add$1: function(obj) {
  var str = $.toString(obj);
  if (str == null || $.isEmpty(str) === true) return this;
  $.add$1(this._buffer, str);
  var t1 = this._length;
  if (typeof t1 !== 'number') return this.add$1$bailout(1, str, t1);
  var t2 = $.get$length(str);
  if (typeof t2 !== 'number') return this.add$1$bailout(2, t1, t2);
  this._length = t1 + t2;
  return this;
 },
 add$1$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      str = env0;
      t1 = env1;
      break;
    case 2:
      t1 = env0;
      t2 = env1;
      break;
  }
  switch (state) {
    case 0:
      var str = $.toString(obj);
      if (str == null || $.isEmpty(str) === true) return this;
      $.add$1(this._buffer, str);
      var t1 = this._length;
    case 1:
      state = 0;
      var t2 = $.get$length(str);
    case 2:
      state = 0;
      this._length = $.add(t1, t2);
      return this;
  }
 },
 isEmpty$0: function() {
  var t1 = this._length;
  return t1 === 0;
 },
 get$length: function() {
  return this._length;
 },
 StringBufferImpl$1: function(content$) {
  this.clear$0();
  this.add$1(content$);
 }
};

$$.JSSyntaxRegExp = {"":
 ["ignoreCase?", "multiLine?", "pattern?"],
 super: "Object",
 allMatches$1: function(str) {
  $.checkString(str);
  return $._AllMatchesIterable$2(this, str);
 },
 hasMatch$1: function(str) {
  return $.regExpTest(this, $.checkString(str));
 },
 firstMatch$1: function(str) {
  var m = $.regExpExec(this, $.checkString(str));
  if (m == null) return;
  var matchStart = $.regExpMatchStart(m);
  var matchEnd = $.add(matchStart, $.get$length($.index(m, 0)));
  return $.MatchImplementation$5(this.pattern, str, matchStart, matchEnd, m);
 },
 JSSyntaxRegExp$_globalVersionOf$1: function(other) {
  $.regExpAttachGlobalNative(this);
 },
 is$JSSyntaxRegExp: true
};

$$.MatchImplementation = {"":
 ["_groups", "_end", "_start", "str", "pattern?"],
 super: "Object",
 operator$index$1: function(index) {
  return this.group$1(index);
 },
 group$1: function(index) {
  return $.index(this._groups, index);
 }
};

$$._AllMatchesIterable = {"":
 ["_str", "_re"],
 super: "Object",
 iterator$0: function() {
  return $._AllMatchesIterator$2(this._re, this._str);
 }
};

$$._AllMatchesIterator = {"":
 ["_done", "_next", "_str", "_re"],
 super: "Object",
 hasNext$0: function() {
  if (this._done === true) return false;
  if (!$.eqNullB(this._next)) return true;
  this._next = this._re.firstMatch$1(this._str);
  if ($.eqNullB(this._next)) {
    this._done = true;
    return false;
  }
  return true;
 },
 next$0: function() {
  if (this.hasNext$0() !== true) throw $.captureStackTrace($.CTC0);
  var next = this._next;
  this._next = null;
  return next;
 }
};

$$.DateImplementation = {"":
 ["isUtc?", "millisecondsSinceEpoch?"],
 super: "Object",
 _asJs$0: function() {
  return $.lazyAsJsDate(this);
 },
 add$1: function(duration) {
  return $.DateImplementation$fromMillisecondsSinceEpoch$2($.add(this.millisecondsSinceEpoch, duration.get$inMilliseconds()), this.isUtc);
 },
 toString$0: function() {
  var t1 = new $.Closure9();
  var t2 = new $.Closure10();
  var t3 = new $.Closure11();
  var y = t1.$call$1(this.get$year());
  var m = t3.$call$1(this.get$month());
  var d = t3.$call$1(this.get$day());
  var h = t3.$call$1(this.get$hour());
  var min = t3.$call$1(this.get$minute());
  var sec = t3.$call$1(this.get$second());
  var ms = t2.$call$1(this.get$millisecond());
  if (this.isUtc === true) return $.S(y) + '-' + $.S(m) + '-' + $.S(d) + ' ' + $.S(h) + ':' + $.S(min) + ':' + $.S(sec) + '.' + $.S(ms) + 'Z';
  return $.S(y) + '-' + $.S(m) + '-' + $.S(d) + ' ' + $.S(h) + ':' + $.S(min) + ':' + $.S(sec) + '.' + $.S(ms);
 },
 get$millisecond: function() {
  return $.getMilliseconds(this);
 },
 get$second: function() {
  return $.getSeconds(this);
 },
 get$minute: function() {
  return $.getMinutes(this);
 },
 get$hour: function() {
  return $.getHours(this);
 },
 get$day: function() {
  return $.getDay(this);
 },
 get$month: function() {
  return $.getMonth(this);
 },
 get$year: function() {
  return $.getYear(this);
 },
 hashCode$0: function() {
  return this.millisecondsSinceEpoch;
 },
 compareTo$1: function(other) {
  return $.compareTo(this.millisecondsSinceEpoch, other.get$millisecondsSinceEpoch());
 },
 operator$ge$1: function(other) {
  return $.ge(this.millisecondsSinceEpoch, other.get$millisecondsSinceEpoch());
 },
 operator$gt$1: function(other) {
  return $.gt(this.millisecondsSinceEpoch, other.get$millisecondsSinceEpoch());
 },
 operator$le$1: function(other) {
  return $.le(this.millisecondsSinceEpoch, other.get$millisecondsSinceEpoch());
 },
 operator$lt$1: function(other) {
  return $.lt(this.millisecondsSinceEpoch, other.get$millisecondsSinceEpoch());
 },
 operator$eq$1: function(other) {
  if (!((typeof other === 'object' && other !== null) && !!other.is$DateImplementation)) return false;
  return $.eq(this.millisecondsSinceEpoch, other.millisecondsSinceEpoch);
 },
 DateImplementation$fromMillisecondsSinceEpoch$2: function(millisecondsSinceEpoch, isUtc) {
  var t1 = this.millisecondsSinceEpoch;
  if ($.gtB($.abs(t1), 8640000000000000)) throw $.captureStackTrace($.IllegalArgumentException$1(t1));
 },
 DateImplementation$now$0: function() {
  this._asJs$0();
 },
 is$DateImplementation: true
};

$$.ListIterator = {"":
 ["list", "i"],
 super: "Object",
 next$0: function() {
  if (this.hasNext$0() !== true) throw $.captureStackTrace($.NoMoreElementsException$0());
  var value = (this.list[this.i]);
  var t1 = this.i;
  if (typeof t1 !== 'number') return this.next$0$bailout(1, t1, value);
  this.i = t1 + 1;
  return value;
 },
 next$0$bailout: function(state, t1, value) {
  this.i = $.add(t1, 1);
  return value;
 },
 hasNext$0: function() {
  var t1 = this.i;
  if (typeof t1 !== 'number') return this.hasNext$0$bailout(1, t1);
  return t1 < (this.list.length);
 },
 hasNext$0$bailout: function(state, t1) {
  return $.lt(t1, (this.list.length));
 }
};

$$.Closure26 = {"":
 [],
 super: "Object",
 toString$0: function() {
  return 'Closure';
 }
};

$$.MetaInfo = {"":
 ["set?", "tags", "tag?"],
 super: "Object"
};

$$.StringMatch = {"":
 ["pattern?", "str", "_lib1_start"],
 super: "Object",
 group$1: function(group_) {
  if (!$.eqB(group_, 0)) throw $.captureStackTrace($.IndexOutOfRangeException$1(group_));
  return this.pattern;
 },
 operator$index$1: function(g) {
  return this.group$1(g);
 }
};

$$.Object = {"":
 [],
 super: "",
 toString$0: function() {
  return $.objectToString(this);
 }
};

$$.IndexOutOfRangeException = {"":
 ["_index"],
 super: "Object",
 toString$0: function() {
  return 'IndexOutOfRangeException: ' + $.S(this._index);
 },
 is$Exception: true
};

$$.NoSuchMethodException = {"":
 ["_existingArgumentNames", "_arguments", "_functionName", "_receiver"],
 super: "Object",
 toString$0: function() {
  var sb = $.StringBufferImpl$1('');
  var t1 = this._arguments;
  if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.toString$0$bailout(1, sb, t1);
  var i = 0;
  for (; i < t1.length; ++i) {
    i > 0 && sb.add$1(', ');
    var t2 = t1.length;
    if (i < 0 || i >= t2) throw $.ioore(i);
    sb.add$1(t1[i]);
  }
  t1 = this._existingArgumentNames;
  if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.toString$0$bailout(2, t1, sb);
  var actualParameters = sb.toString$0();
  sb = $.StringBufferImpl$1('');
  for (i = 0; i < t1.length; ++i) {
    i > 0 && sb.add$1(', ');
    t2 = t1.length;
    if (i < 0 || i >= t2) throw $.ioore(i);
    sb.add$1(t1[i]);
  }
  var formalParameters = sb.toString$0();
  t1 = this._functionName;
  return 'NoSuchMethodException: incorrect number of arguments passed to method named \'' + $.S(t1) + '\'\nReceiver: ' + $.S(this._receiver) + '\n' + 'Tried calling: ' + $.S(t1) + '(' + $.S(actualParameters) + ')\n' + 'Found: ' + $.S(t1) + '(' + $.S(formalParameters) + ')';
 },
 toString$0$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      sb = env0;
      t1 = env1;
      break;
    case 2:
      t1 = env0;
      sb = env1;
      break;
  }
  switch (state) {
    case 0:
      var sb = $.StringBufferImpl$1('');
      var t1 = this._arguments;
    case 1:
      state = 0;
      var i = 0;
      for (; $.ltB(i, $.get$length(t1)); ++i) {
        i > 0 && sb.add$1(', ');
        sb.add$1($.index(t1, i));
      }
      t1 = this._existingArgumentNames;
    case 2:
      state = 0;
      if (t1 == null) return 'NoSuchMethodException : method not found: \'' + $.S(this._functionName) + '\'\n' + 'Receiver: ' + $.S(this._receiver) + '\n' + 'Arguments: [' + $.S(sb) + ']';
      var actualParameters = sb.toString$0();
      sb = $.StringBufferImpl$1('');
      for (i = 0; $.ltB(i, $.get$length(t1)); ++i) {
        i > 0 && sb.add$1(', ');
        sb.add$1($.index(t1, i));
      }
      var formalParameters = sb.toString$0();
      t1 = this._functionName;
      return 'NoSuchMethodException: incorrect number of arguments passed to method named \'' + $.S(t1) + '\'\nReceiver: ' + $.S(this._receiver) + '\n' + 'Tried calling: ' + $.S(t1) + '(' + $.S(actualParameters) + ')\n' + 'Found: ' + $.S(t1) + '(' + $.S(formalParameters) + ')';
  }
 },
 is$Exception: true
};

$$.ObjectNotClosureException = {"":
 [],
 super: "Object",
 toString$0: function() {
  return 'Object is not closure';
 },
 is$Exception: true
};

$$.IllegalArgumentException = {"":
 ["_arg"],
 super: "Object",
 toString$0: function() {
  return 'Illegal argument(s): ' + $.S(this._arg);
 },
 is$Exception: true
};

$$.StackOverflowException = {"":
 [],
 super: "Object",
 toString$0: function() {
  return 'Stack Overflow';
 },
 is$Exception: true
};

$$.BadNumberFormatException = {"":
 ["_s"],
 super: "Object",
 toString$0: function() {
  return 'BadNumberFormatException: \'' + $.S(this._s) + '\'';
 },
 is$Exception: true
};

$$.NullPointerException = {"":
 ["arguments", "functionName"],
 super: "Object",
 get$exceptionName: function() {
  return 'NullPointerException';
 },
 toString$0: function() {
  var t1 = this.functionName;
  if ($.eqNullB(t1)) return this.get$exceptionName();
  return $.S(this.get$exceptionName()) + ' : method: \'' + $.S(t1) + '\'\n' + 'Receiver: null\n' + 'Arguments: ' + $.S(this.arguments);
 },
 is$Exception: true
};

$$.NoMoreElementsException = {"":
 [],
 super: "Object",
 toString$0: function() {
  return 'NoMoreElementsException';
 },
 is$Exception: true
};

$$.UnsupportedOperationException = {"":
 ["_message"],
 super: "Object",
 toString$0: function() {
  return 'UnsupportedOperationException: ' + $.S(this._message);
 },
 is$Exception: true
};

$$.IllegalJSRegExpException = {"":
 ["_errmsg", "_pattern"],
 super: "Object",
 toString$0: function() {
  return 'IllegalJSRegExpException: \'' + $.S(this._pattern) + '\' \'' + $.S(this._errmsg) + '\'';
 },
 is$Exception: true
};

$$.FutureNotCompleteException = {"":
 [],
 super: "Object",
 toString$0: function() {
  return 'Exception: future has not been completed';
 },
 is$Exception: true
};

$$.FutureAlreadyCompleteException = {"":
 [],
 super: "Object",
 toString$0: function() {
  return 'Exception: future already completed';
 },
 is$Exception: true
};

$$._AbstractWorkerEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._AudioContextEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$complete: function() {
  return this.operator$index$1('complete');
 },
 complete$1: function(arg0) { return this.get$complete().$call$1(arg0); }
};

$$._BatteryManagerEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl"
};

$$._BodyElementEventsImpl = {"":
 ["_ptr"],
 super: "_ElementEventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 },
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$focus: function() {
  return this.operator$index$1('focus');
 },
 focus$0: function() { return this.get$focus().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._DOMApplicationCacheEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._DedicatedWorkerContextEventsImpl = {"":
 ["_ptr"],
 super: "_WorkerContextEventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 }
};

$$._DeprecatedPeerConnectionEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 }
};

$$._DocumentEventsImpl = {"":
 ["_ptr"],
 super: "_ElementEventsImpl",
 get$reset: function() {
  return this.operator$index$1('reset');
 },
 reset$0: function() { return this.get$reset().$call$0(); },
 get$mouseWheel: function() {
  return this.operator$index$1('mousewheel');
 },
 get$mouseUp: function() {
  return this.operator$index$1('mouseup');
 },
 get$mouseOut: function() {
  return this.operator$index$1('mouseout');
 },
 get$mouseMove: function() {
  return this.operator$index$1('mousemove');
 },
 get$mouseDown: function() {
  return this.operator$index$1('mousedown');
 },
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$keyUp: function() {
  return this.operator$index$1('keyup');
 },
 get$keyPress: function() {
  return this.operator$index$1('keypress');
 },
 get$keyDown: function() {
  return this.operator$index$1('keydown');
 },
 get$focus: function() {
  return this.operator$index$1('focus');
 },
 focus$0: function() { return this.get$focus().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$.EmptyElementRect = {"":
 ["clientRects", "bounding", "scroll", "offset?", "client"],
 super: "Object"
};

$$._SimpleClientRect = {"":
 ["height?", "width?", "top?", "left?"],
 super: "Object",
 toString$0: function() {
  return '(' + $.S(this.left) + ', ' + $.S(this.top) + ', ' + $.S(this.width) + ', ' + $.S(this.height) + ')';
 },
 operator$eq$1: function(other) {
  return !(other == null) && $.eqB(this.left, other.get$left()) && $.eqB(this.top, other.get$top()) && $.eqB(this.width, other.get$width()) && $.eqB(this.height, other.get$height());
 },
 get$bottom: function() {
  return $.add(this.top, this.height);
 },
 get$right: function() {
  return $.add(this.left, this.width);
 }
};

$$._ElementRectImpl = {"":
 ["_clientRects", "_boundingClientRect", "scroll", "offset?", "client"],
 super: "Object"
};

$$._ElementEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$reset: function() {
  return this.operator$index$1('reset');
 },
 reset$0: function() { return this.get$reset().$call$0(); },
 get$mouseWheel: function() {
  return this.operator$index$1('mousewheel');
 },
 get$mouseUp: function() {
  return this.operator$index$1('mouseup');
 },
 get$mouseOut: function() {
  return this.operator$index$1('mouseout');
 },
 get$mouseMove: function() {
  return this.operator$index$1('mousemove');
 },
 get$mouseDown: function() {
  return this.operator$index$1('mousedown');
 },
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$keyUp: function() {
  return this.operator$index$1('keyup');
 },
 get$keyPress: function() {
  return this.operator$index$1('keypress');
 },
 get$keyDown: function() {
  return this.operator$index$1('keydown');
 },
 get$focus: function() {
  return this.operator$index$1('focus');
 },
 focus$0: function() { return this.get$focus().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._EventSourceEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._EventsImpl = {"":
 ["_ptr"],
 super: "Object",
 operator$index$1: function(type) {
  return $._EventListenerListImpl$2(this._ptr, type);
 }
};

$$._EventListenerListImpl = {"":
 ["_lib_type", "_ptr"],
 super: "Object",
 _add$2: function(listener, useCapture) {
  this._ptr.$dom_addEventListener$3(this._lib_type, listener, useCapture);
 },
 add$2: function(listener, useCapture) {
  this._add$2(listener, useCapture);
  return this;
 },
 add$1: function(listener) {
  return this.add$2(listener,false)
}
};

$$._FileReaderEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._FileWriterEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._FrameSetElementEventsImpl = {"":
 ["_ptr"],
 super: "_ElementEventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 },
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$focus: function() {
  return this.operator$index$1('focus');
 },
 focus$0: function() { return this.get$focus().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._IDBDatabaseEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._IDBRequestEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._IDBTransactionEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 },
 get$complete: function() {
  return this.operator$index$1('complete');
 },
 complete$1: function(arg0) { return this.get$complete().$call$1(arg0); }
};

$$._IDBVersionChangeRequestEventsImpl = {"":
 ["_ptr"],
 super: "_IDBRequestEventsImpl"
};

$$._InputElementEventsImpl = {"":
 ["_ptr"],
 super: "_ElementEventsImpl"
};

$$._JavaScriptAudioNodeEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl"
};

$$._MediaElementEventsImpl = {"":
 ["_ptr"],
 super: "_ElementEventsImpl"
};

$$._MediaStreamEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl"
};

$$._MessagePortEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 }
};

$$._NotificationEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._PeerConnection00EventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl"
};

$$._SVGElementInstanceEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$reset: function() {
  return this.operator$index$1('reset');
 },
 reset$0: function() { return this.get$reset().$call$0(); },
 get$mouseWheel: function() {
  return this.operator$index$1('mousewheel');
 },
 get$mouseUp: function() {
  return this.operator$index$1('mouseup');
 },
 get$mouseOut: function() {
  return this.operator$index$1('mouseout');
 },
 get$mouseMove: function() {
  return this.operator$index$1('mousemove');
 },
 get$mouseDown: function() {
  return this.operator$index$1('mousedown');
 },
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$keyUp: function() {
  return this.operator$index$1('keyup');
 },
 get$keyPress: function() {
  return this.operator$index$1('keypress');
 },
 get$keyDown: function() {
  return this.operator$index$1('keydown');
 },
 get$focus: function() {
  return this.operator$index$1('focus');
 },
 focus$0: function() { return this.get$focus().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._SharedWorkerContextEventsImpl = {"":
 ["_ptr"],
 super: "_WorkerContextEventsImpl"
};

$$._SpeechRecognitionEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._TextTrackEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl"
};

$$._TextTrackCueEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl"
};

$$._TextTrackListEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl"
};

$$._WebSocketEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._WindowEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$reset: function() {
  return this.operator$index$1('reset');
 },
 reset$0: function() { return this.get$reset().$call$0(); },
 get$mouseWheel: function() {
  return this.operator$index$1('mousewheel');
 },
 get$mouseUp: function() {
  return this.operator$index$1('mouseup');
 },
 get$mouseOut: function() {
  return this.operator$index$1('mouseout');
 },
 get$mouseMove: function() {
  return this.operator$index$1('mousemove');
 },
 get$mouseDown: function() {
  return this.operator$index$1('mousedown');
 },
 get$message: function() {
  return this.operator$index$1('message');
 },
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$keyUp: function() {
  return this.operator$index$1('keyup');
 },
 get$keyPress: function() {
  return this.operator$index$1('keypress');
 },
 get$keyDown: function() {
  return this.operator$index$1('keydown');
 },
 get$focus: function() {
  return this.operator$index$1('focus');
 },
 focus$0: function() { return this.get$focus().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._WorkerEventsImpl = {"":
 ["_ptr"],
 super: "_AbstractWorkerEventsImpl",
 get$message: function() {
  return this.operator$index$1('message');
 }
};

$$._WorkerContextEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._XMLHttpRequestEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._XMLHttpRequestUploadEventsImpl = {"":
 ["_ptr"],
 super: "_EventsImpl",
 get$load: function() {
  return this.operator$index$1('load');
 },
 load$0: function() { return this.get$load().$call$0(); },
 get$error: function() {
  return this.operator$index$1('error');
 }
};

$$._MeasurementRequest = {"":
 ["exception=", "value=", "completer?", "computeValue"],
 super: "Object",
 computeValue$0: function() { return this.computeValue.$call$0(); }
};

$$._DOMWindowCrossFrameImpl = {"":
 ["_window"],
 super: "Object",
 postMessage$3: function(message, targetOrigin, messagePorts) {
  var t1 = $.eqNullB(messagePorts);
  var t2 = this._window;
  if (t1) $._postMessage2(t2, message, targetOrigin);
  else $._postMessage3(t2, message, targetOrigin, messagePorts);
 },
 postMessage$2: function(message,targetOrigin) {
  return this.postMessage$3(message,targetOrigin,null)
},
 focus$0: function() {
  return $._focus(this._window);
 },
 get$top: function() {
  return $._createSafe($._top(this._window));
 },
 get$parent: function() {
  return $._createSafe($._parent(this._window));
 }
};

$$._IDBOpenDBRequestEventsImpl = {"":
 ["_ptr"],
 super: "_IDBRequestEventsImpl"
};

$$._FixedSizeListIterator = {"":
 ["_lib_length", "_pos", "_array"],
 super: "_VariableSizeListIterator",
 hasNext$0: function() {
  var t1 = this._lib_length;
  if (typeof t1 !== 'number') return this.hasNext$0$bailout(1, t1, 0);
  var t2 = this._pos;
  if (typeof t2 !== 'number') return this.hasNext$0$bailout(2, t1, t2);
  return t1 > t2;
 },
 hasNext$0$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      t1 = env0;
      break;
    case 2:
      t1 = env0;
      t2 = env1;
      break;
  }
  switch (state) {
    case 0:
      var t1 = this._lib_length;
    case 1:
      state = 0;
      var t2 = this._pos;
    case 2:
      state = 0;
      return $.gt(t1, t2);
  }
 }
};

$$._VariableSizeListIterator = {"":
 [],
 super: "Object",
 next$0: function() {
  if (this.hasNext$0() !== true) throw $.captureStackTrace($.CTC0);
  var t1 = this._array;
  if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.next$0$bailout(1, t1, 0);
  var t2 = this._pos;
  if (typeof t2 !== 'number') return this.next$0$bailout(2, t1, t2);
  this._pos = t2 + 1;
  if (t2 !== (t2 | 0)) throw $.iae(t2);
  var t3 = t1.length;
  if (t2 < 0 || t2 >= t3) throw $.ioore(t2);
  return t1[t2];
 },
 next$0$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      t1 = env0;
      break;
    case 2:
      t1 = env0;
      t2 = env1;
      break;
  }
  switch (state) {
    case 0:
      if (this.hasNext$0() !== true) throw $.captureStackTrace($.CTC0);
      var t1 = this._array;
    case 1:
      state = 0;
      var t2 = this._pos;
    case 2:
      state = 0;
      this._pos = $.add(t2, 1);
      return $.index(t1, t2);
  }
 },
 hasNext$0: function() {
  var t1 = $.get$length(this._array);
  if (typeof t1 !== 'number') return this.hasNext$0$bailout(1, t1, 0);
  var t2 = this._pos;
  if (typeof t2 !== 'number') return this.hasNext$0$bailout(2, t2, t1);
  return t1 > t2;
 },
 hasNext$0$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      t1 = env0;
      break;
    case 2:
      t2 = env0;
      t1 = env1;
      break;
  }
  switch (state) {
    case 0:
      var t1 = $.get$length(this._array);
    case 1:
      state = 0;
      var t2 = this._pos;
    case 2:
      state = 0;
      return $.gt(t1, t2);
  }
 }
};

$$.Juggler = {"":
 ["_elapsedTime", "_animatablesCount", "_animatables"],
 super: "Object",
 advanceTime$1: function(time) {
  if (typeof time !== 'number') return this.advanceTime$1$bailout(1, time, 0, 0, 0, 0, 0);
  var t1 = this._elapsedTime;
  if (typeof t1 !== 'number') return this.advanceTime$1$bailout(2, time, t1, 0, 0, 0, 0);
  this._elapsedTime = t1 + time;
  var animatablesCount = this._animatablesCount;
  if (typeof animatablesCount !== 'number') return this.advanceTime$1$bailout(3, time, animatablesCount, 0, 0, 0, 0);
  for (var i = 0, c = 0; i < animatablesCount; ++i) {
    t1 = this._animatables;
    if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.advanceTime$1$bailout(4, time, t1, i, c, animatablesCount, 0);
    var t2 = t1.length;
    if (i < 0 || i >= t2) throw $.ioore(i);
    t1 = t1[i];
    if (!$.eqNullB(t1) && t1.advanceTime$1(time) === true) {
      if (!(c === i)) {
        t2 = this._animatables;
        if (typeof t2 !== 'object' || t2 === null || ((t2.constructor !== Array || !!t2.immutable$list) && !t2.is$JavaScriptIndexingBehavior())) return this.advanceTime$1$bailout(5, time, animatablesCount, t1, i, c, t2);
        var t3 = t2.length;
        if (c < 0 || c >= t3) throw $.ioore(c);
        t2[c] = t1;
      }
      ++c;
    }
  }
  i = animatablesCount;
  while (true) {
    t1 = this._animatablesCount;
    if (typeof t1 !== 'number') return this.advanceTime$1$bailout(6, c, t1, i, 0, 0, 0);
    if (!(i < t1)) break;
    t1 = this._animatables;
    if (typeof t1 !== 'object' || t1 === null || ((t1.constructor !== Array || !!t1.immutable$list) && !t1.is$JavaScriptIndexingBehavior())) return this.advanceTime$1$bailout(7, c, t1, i, 0, 0, 0);
    var c0 = c + 1;
    if (i !== (i | 0)) throw $.iae(i);
    t2 = t1.length;
    if (i < 0 || i >= t2) throw $.ioore(i);
    t3 = t1[i];
    if (c < 0 || c >= t2) throw $.ioore(c);
    t1[c] = t3;
    c = c0;
    ++i;
  }
  i = c;
  while (true) {
    t1 = this._animatablesCount;
    if (typeof t1 !== 'number') return this.advanceTime$1$bailout(8, i, c, t1, 0, 0, 0);
    if (!(i < t1)) break;
    t1 = this._animatables;
    if (typeof t1 !== 'object' || t1 === null || ((t1.constructor !== Array || !!t1.immutable$list) && !t1.is$JavaScriptIndexingBehavior())) return this.advanceTime$1$bailout(9, t1, c, i, 0, 0, 0);
    t2 = t1.length;
    if (i < 0 || i >= t2) throw $.ioore(i);
    t1[i] = null;
    ++i;
  }
  this._animatablesCount = c;
  return true;
 },
 advanceTime$1$bailout: function(state, env0, env1, env2, env3, env4, env5) {
  switch (state) {
    case 1:
      var time = env0;
      break;
    case 2:
      time = env0;
      t1 = env1;
      break;
    case 3:
      time = env0;
      animatablesCount = env1;
      break;
    case 4:
      time = env0;
      t1 = env1;
      i = env2;
      c = env3;
      animatablesCount = env4;
      break;
    case 5:
      time = env0;
      animatablesCount = env1;
      animatable = env2;
      i = env3;
      c = env4;
      t1 = env5;
      break;
    case 6:
      c = env0;
      t1 = env1;
      i = env2;
      break;
    case 7:
      c = env0;
      t1 = env1;
      i = env2;
      break;
    case 8:
      i = env0;
      c = env1;
      t1 = env2;
      break;
    case 9:
      t1 = env0;
      c = env1;
      i = env2;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
      var t1 = this._elapsedTime;
    case 2:
      state = 0;
      this._elapsedTime = $.add(t1, time);
      var animatablesCount = this._animatablesCount;
    case 3:
      state = 0;
      var i = 0;
      var c = 0;
    case 4:
    case 5:
      L0: while (true) {
        switch (state) {
          case 0:
            if (!$.ltB(i, animatablesCount)) break L0;
            t1 = this._animatables;
          case 4:
            state = 0;
            var animatable = $.index(t1, i);
          case 5:
            if (state == 5 || (state == 0 && (!$.eqNullB(animatable) && animatable.advanceTime$1(time) === true))) {
              switch (state) {
                case 0:
                case 5:
                  if (state == 5 || (state == 0 && !(c === i))) {
                    switch (state) {
                      case 0:
                        t1 = this._animatables;
                      case 5:
                        state = 0;
                        $.indexSet(t1, c, animatable);
                    }
                  }
                  ++c;
              }
            }
            ++i;
        }
      }
      i = animatablesCount;
    case 6:
    case 7:
      L1: while (true) {
        switch (state) {
          case 0:
            t1 = this._animatablesCount;
          case 6:
            state = 0;
            if (!$.ltB(i, t1)) break L1;
            t1 = this._animatables;
          case 7:
            state = 0;
            var c0 = c + 1;
            $.indexSet(t1, c, $.index(t1, i));
            c = c0;
            i = $.add(i, 1);
        }
      }
      i = c;
    case 8:
    case 9:
      L2: while (true) {
        switch (state) {
          case 0:
            t1 = this._animatablesCount;
          case 8:
            state = 0;
            if (!$.ltB(i, t1)) break L2;
            t1 = this._animatables;
          case 9:
            state = 0;
            $.indexSet(t1, i, null);
            ++i;
        }
      }
      this._animatablesCount = c;
      return true;
  }
 },
 add$1: function(animatable) {
  if ($.eqNullB(animatable)) return;
  var t1 = $.geB(this._animatablesCount, $.get$length(this._animatables));
  var t2 = this._animatables;
  if (t1) $.add$1(t2, animatable);
  else $.indexSet(t2, this._animatablesCount, animatable);
  this._animatablesCount = $.add(this._animatablesCount, 1);
 },
 Juggler$0: function() {
  this._elapsedTime = 0.0;
  var t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'IAnimatable'}));
  this._animatables = t1;
  this._animatablesCount = 0;
 }
};

$$._AnimateProperty = {"":
 ["targetValue?", "startValue=", "name?"],
 super: "Object"
};

$$.Tween = {"":
 ["_started", "_roundToInt", "_delay", "_currentTime", "_totalTime", "_onComplete", "_onUpdate", "_onStart", "_animateValues", "_animateProperties", "_transitionFunction", "_target!"],
 super: "Object",
 _getPropertyValue$2: function(object, name$) {
  switch (name$) {
    case 'x':
      return object.get$x();
    case 'y':
      return object.get$y();
    case 'pivotX':
      return object.get$pivotX();
    case 'pivotY':
      return object.get$pivotY();
    case 'scaleX':
      return object.get$scaleX();
    case 'scaleY':
      return object.get$scaleY();
    case 'rotation':
      return object.get$rotation();
    case 'alpha':
      return object.get$alpha();
    default:
      throw $.captureStackTrace($.ExceptionImplementation$1('Error #9003: The supplied property name (\'' + $.S(name$) + '\') is not supported at this time.'));
  }
 },
 _setPropertyValue$3: function(object, name$, value) {
  switch (name$) {
    case 'x':
      object.set$x(value);
      break;
    case 'y':
      object.set$y(value);
      break;
    case 'pivotX':
      object.set$pivotX(value);
      break;
    case 'pivotY':
      object.set$pivotY(value);
      break;
    case 'scaleX':
      object.set$scaleX(value);
      break;
    case 'scaleY':
      object.set$scaleY(value);
      break;
    case 'rotation':
      object.set$rotation(value);
      break;
    case 'alpha':
      object.set$alpha(value);
      break;
    default:
      throw $.captureStackTrace($.ExceptionImplementation$1('Error #9003: The supplied property name (\'' + $.S(name$) + '\') is not supported at this time.'));
  }
 },
 set$onComplete: function(value) {
  this._onComplete = value;
 },
 advanceTime$1: function(time) {
  if (typeof time !== 'number') return this.advanceTime$1$bailout(1, time, 0, 0, 0, 0, 0);
  var t1 = this._currentTime;
  if (typeof t1 !== 'number') return this.advanceTime$1$bailout(2, time, t1, 0, 0, 0, 0);
  var t2 = this._totalTime;
  if (typeof t2 !== 'number') return this.advanceTime$1$bailout(3, time, t1, t2, 0, 0, 0);
  if (!(t1 < t2)) {
    t2 = this._started;
    if (typeof t2 !== 'boolean') return this.advanceTime$1$bailout(4, time, t2, 0, 0, 0, 0);
    t2 = !t2;
  } else t2 = true;
  if (t2) {
    this._currentTime = t1 + time;
    t1 = this._currentTime;
    if (typeof t1 !== 'number') return this.advanceTime$1$bailout(6, t1, 0, 0, 0, 0, 0);
    t2 = this._totalTime;
    if (typeof t2 !== 'number') return this.advanceTime$1$bailout(7, t1, t2, 0, 0, 0, 0);
    if (t1 > t2) this._currentTime = t2;
    t1 = this._currentTime;
    if (typeof t1 !== 'number') return this.advanceTime$1$bailout(8, t1, 0, 0, 0, 0, 0);
    if (t1 >= 0.0) {
      t1 = this._started;
      if (typeof t1 !== 'boolean') return this.advanceTime$1$bailout(9, t1, 0, 0, 0, 0, 0);
      if (!t1) {
        this._started = true;
        var i = 0;
        while (true) {
          t1 = this._animateProperties.length;
          if (typeof t1 !== 'number') return this.advanceTime$1$bailout(10, i, t1, 0, 0, 0, 0);
          if (!(i < t1)) break;
          t1 = this._animateProperties;
          if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.advanceTime$1$bailout(11, i, t1, 0, 0, 0, 0);
          t2 = t1.length;
          if (i < 0 || i >= t2) throw $.ioore(i);
          t1 = t1[i];
          t1.set$startValue(this._getPropertyValue$2(this._target, t1.get$name()));
          ++i;
        }
        t1 = this._onStart;
        !(t1 == null) && this._onStart$0();
      }
      t1 = this._currentTime;
      if (typeof t1 !== 'number') return this.advanceTime$1$bailout(12, t1, 0, 0, 0, 0, 0);
      t2 = this._totalTime;
      if (typeof t2 !== 'number') return this.advanceTime$1$bailout(13, t1, t2, 0, 0, 0, 0);
      var transition = this._transitionFunction$1(t1 / t2);
      if (typeof transition !== 'number') return this.advanceTime$1$bailout(14, transition, 0, 0, 0, 0, 0);
      i = 0;
      while (true) {
        t1 = this._animateProperties.length;
        if (typeof t1 !== 'number') return this.advanceTime$1$bailout(15, i, transition, t1, 0, 0, 0);
        if (!(i < t1)) break;
        t1 = this._animateProperties;
        if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.advanceTime$1$bailout(16, t1, i, transition, 0, 0, 0);
        t2 = t1.length;
        if (i < 0 || i >= t2) throw $.ioore(i);
        t1 = t1[i];
        var t3 = t1.get$startValue();
        if (typeof t3 !== 'number') return this.advanceTime$1$bailout(17, t1, t3, i, transition, 0, 0);
        var t4 = t1.get$targetValue();
        if (typeof t4 !== 'number') return this.advanceTime$1$bailout(18, transition, t1, t3, t4, i, 0);
        var t5 = t1.get$startValue();
        if (typeof t5 !== 'number') return this.advanceTime$1$bailout(19, transition, t1, t3, t4, i, t5);
        var value = t3 + transition * (t4 - t5);
        t3 = this._target;
        t1 = t1.get$name();
        if (this._roundToInt === true) {
          t2 = $.round(value);
          if (typeof t2 !== 'number') return this.advanceTime$1$bailout(20, t2, t3, i, t1, transition, 0);
        } else t2 = value;
        this._setPropertyValue$3(t3, t1, t2);
        ++i;
      }
      i = 0;
      while (true) {
        t1 = this._animateValues.length;
        if (typeof t1 !== 'number') return this.advanceTime$1$bailout(21, i, transition, t1, 0, 0, 0);
        if (!(i < t1)) break;
        t1 = this._animateValues;
        if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.advanceTime$1$bailout(22, i, transition, t1, 0, 0, 0);
        t2 = t1.length;
        if (i < 0 || i >= t2) throw $.ioore(i);
        t1 = t1[i];
        t3 = t1.get$startValue();
        if (typeof t3 !== 'number') return this.advanceTime$1$bailout(23, t3, i, transition, t1, 0, 0);
        t4 = t1.get$targetValue();
        if (typeof t4 !== 'number') return this.advanceTime$1$bailout(24, transition, t1, t3, t4, i, 0);
        t5 = t1.get$startValue();
        if (typeof t5 !== 'number') return this.advanceTime$1$bailout(25, transition, t1, t3, t4, i, t5);
        value = t3 + transition * (t4 - t5);
        if (this._roundToInt === true) {
          t2 = $.round(value);
          if (typeof t2 !== 'number') return this.advanceTime$1$bailout(26, i, transition, t2, t1, 0, 0);
        } else t2 = value;
        t1.tweenFunction$1(t2);
        ++i;
      }
      t1 = this._onUpdate;
      !(t1 == null) && this._onUpdate$0();
      t1 = this._onComplete;
      if (!(t1 == null)) {
        t1 = this._currentTime;
        t2 = this._totalTime;
        t2 = t1 === t2;
        t1 = t2;
      } else t1 = false;
      t1 && this._onComplete$0();
    }
  }
  t1 = this._currentTime;
  if (typeof t1 !== 'number') return this.advanceTime$1$bailout(27, t1, 0, 0, 0, 0, 0);
  t2 = this._totalTime;
  if (typeof t2 !== 'number') return this.advanceTime$1$bailout(28, t1, t2, 0, 0, 0, 0);
  return t1 < t2;
 },
 advanceTime$1$bailout: function(state, env0, env1, env2, env3, env4, env5) {
  switch (state) {
    case 1:
      var time = env0;
      break;
    case 2:
      time = env0;
      t1 = env1;
      break;
    case 3:
      time = env0;
      t1 = env1;
      t2 = env2;
      break;
    case 4:
      time = env0;
      t1 = env1;
      break;
    case 5:
      time = env0;
      t1 = env1;
      break;
    case 6:
      t1 = env0;
      break;
    case 7:
      t1 = env0;
      t2 = env1;
      break;
    case 8:
      t1 = env0;
      break;
    case 9:
      t1 = env0;
      break;
    case 10:
      i = env0;
      t1 = env1;
      break;
    case 11:
      i = env0;
      t1 = env1;
      break;
    case 12:
      t1 = env0;
      break;
    case 13:
      t1 = env0;
      t2 = env1;
      break;
    case 14:
      transition = env0;
      break;
    case 15:
      i = env0;
      transition = env1;
      t1 = env2;
      break;
    case 16:
      t1 = env0;
      i = env1;
      transition = env2;
      break;
    case 17:
      ap = env0;
      t1 = env1;
      i = env2;
      transition = env3;
      break;
    case 18:
      transition = env0;
      ap = env1;
      t1 = env2;
      t2 = env3;
      i = env4;
      break;
    case 19:
      transition = env0;
      ap = env1;
      t1 = env2;
      t2 = env3;
      i = env4;
      t3 = env5;
      break;
    case 20:
      t2 = env0;
      t1 = env1;
      i = env2;
      t4 = env3;
      transition = env4;
      break;
    case 21:
      i = env0;
      transition = env1;
      t1 = env2;
      break;
    case 22:
      i = env0;
      transition = env1;
      t1 = env2;
      break;
    case 23:
      t1 = env0;
      i = env1;
      transition = env2;
      av = env3;
      break;
    case 24:
      transition = env0;
      av = env1;
      t1 = env2;
      t2 = env3;
      i = env4;
      break;
    case 25:
      transition = env0;
      av = env1;
      t1 = env2;
      t2 = env3;
      i = env4;
      t3 = env5;
      break;
    case 26:
      i = env0;
      transition = env1;
      t1 = env2;
      av = env3;
      break;
    case 27:
      t1 = env0;
      break;
    case 28:
      t1 = env0;
      t2 = env1;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
      var t1 = this._currentTime;
    case 2:
      state = 0;
      var t2 = this._totalTime;
    case 3:
      state = 0;
    case 4:
      if (state == 4 || (state == 0 && !$.ltB(t1, t2))) {
        switch (state) {
          case 0:
            t1 = this._started;
          case 4:
            state = 0;
            t1 = $.eqB(t1, false);
        }
      } else {
        t1 = true;
      }
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
    case 13:
    case 14:
    case 15:
    case 16:
    case 17:
    case 18:
    case 19:
    case 20:
    case 21:
    case 22:
    case 23:
    case 24:
    case 25:
    case 26:
      if (state == 5 || state == 6 || state == 7 || state == 8 || state == 9 || state == 10 || state == 11 || state == 12 || state == 13 || state == 14 || state == 15 || state == 16 || state == 17 || state == 18 || state == 19 || state == 20 || state == 21 || state == 22 || state == 23 || state == 24 || state == 25 || state == 26 || (state == 0 && t1)) {
        switch (state) {
          case 0:
            t1 = this._currentTime;
          case 5:
            state = 0;
            this._currentTime = $.add(t1, time);
            t1 = this._currentTime;
          case 6:
            state = 0;
            t2 = this._totalTime;
          case 7:
            state = 0;
            if ($.gtB(t1, t2)) this._currentTime = this._totalTime;
            t1 = this._currentTime;
          case 8:
            state = 0;
          case 9:
          case 10:
          case 11:
          case 12:
          case 13:
          case 14:
          case 15:
          case 16:
          case 17:
          case 18:
          case 19:
          case 20:
          case 21:
          case 22:
          case 23:
          case 24:
          case 25:
          case 26:
            if (state == 9 || state == 10 || state == 11 || state == 12 || state == 13 || state == 14 || state == 15 || state == 16 || state == 17 || state == 18 || state == 19 || state == 20 || state == 21 || state == 22 || state == 23 || state == 24 || state == 25 || state == 26 || (state == 0 && $.geB(t1, 0.0))) {
              switch (state) {
                case 0:
                  t1 = this._started;
                case 9:
                  state = 0;
                case 10:
                case 11:
                  if (state == 10 || state == 11 || (state == 0 && $.eqB(t1, false))) {
                    switch (state) {
                      case 0:
                        this._started = true;
                        var i = 0;
                      case 10:
                      case 11:
                        L0: while (true) {
                          switch (state) {
                            case 0:
                              t1 = $.get$length(this._animateProperties);
                            case 10:
                              state = 0;
                              if (!$.ltB(i, t1)) break L0;
                              t1 = this._animateProperties;
                            case 11:
                              state = 0;
                              var ap = $.index(t1, i);
                              ap.set$startValue(this._getPropertyValue$2(this._target, ap.get$name()));
                              ++i;
                          }
                        }
                        t1 = this._onStart;
                        !(t1 == null) && this._onStart$0();
                    }
                  }
                  t1 = this._currentTime;
                case 12:
                  state = 0;
                  t2 = this._totalTime;
                case 13:
                  state = 0;
                  var transition = this._transitionFunction$1($.div(t1, t2));
                case 14:
                  state = 0;
                  i = 0;
                case 15:
                case 16:
                case 17:
                case 18:
                case 19:
                case 20:
                  L1: while (true) {
                    switch (state) {
                      case 0:
                        t1 = $.get$length(this._animateProperties);
                      case 15:
                        state = 0;
                        if (!$.ltB(i, t1)) break L1;
                        t1 = this._animateProperties;
                      case 16:
                        state = 0;
                        ap = $.index(t1, i);
                        t1 = ap.get$startValue();
                      case 17:
                        state = 0;
                        t2 = ap.get$targetValue();
                      case 18:
                        state = 0;
                        var t3 = ap.get$startValue();
                      case 19:
                        state = 0;
                        var value = $.add(t1, $.mul(transition, $.sub(t2, t3)));
                        t1 = this._target;
                        var t4 = ap.get$name();
                      case 20:
                        if (state == 20 || (state == 0 && this._roundToInt === true)) {
                          switch (state) {
                            case 0:
                              t2 = $.round(value);
                            case 20:
                              state = 0;
                          }
                        } else {
                          t2 = value;
                        }
                        this._setPropertyValue$3(t1, t4, t2);
                        ++i;
                    }
                  }
                  i = 0;
                case 21:
                case 22:
                case 23:
                case 24:
                case 25:
                case 26:
                  L2: while (true) {
                    switch (state) {
                      case 0:
                        t1 = $.get$length(this._animateValues);
                      case 21:
                        state = 0;
                        if (!$.ltB(i, t1)) break L2;
                        t1 = this._animateValues;
                      case 22:
                        state = 0;
                        var av = $.index(t1, i);
                        t1 = av.get$startValue();
                      case 23:
                        state = 0;
                        t2 = av.get$targetValue();
                      case 24:
                        state = 0;
                        t3 = av.get$startValue();
                      case 25:
                        state = 0;
                        value = $.add(t1, $.mul(transition, $.sub(t2, t3)));
                      case 26:
                        if (state == 26 || (state == 0 && this._roundToInt === true)) {
                          switch (state) {
                            case 0:
                              t1 = $.round(value);
                            case 26:
                              state = 0;
                          }
                        } else {
                          t1 = value;
                        }
                        av.tweenFunction$1(t1);
                        ++i;
                    }
                  }
                  t1 = this._onUpdate;
                  !(t1 == null) && this._onUpdate$0();
                  !$.eqNullB(this._onComplete) && $.eqB(this._currentTime, this._totalTime) && this._onComplete$0();
              }
            }
        }
      }
      t1 = this._currentTime;
    case 27:
      state = 0;
      t2 = this._totalTime;
    case 28:
      state = 0;
      return $.lt(t1, t2);
  }
 },
 moveTo$2: function(x, y) {
  this.animate$2('x', x);
  this.animate$2('y', y);
 },
 animate$2: function(property, targetValue) {
  var t1 = this._target;
  if (!(t1 == null)) {
    t1 = this._started;
    if (typeof t1 !== 'boolean') return this.animate$2$bailout(1, property, targetValue, t1);
    t1 = !t1;
  } else t1 = false;
  t1 && this._animateProperties.push($._AnimateProperty$3(property, 0.0, targetValue));
 },
 animate$2$bailout: function(state, env0, env1, env2) {
  switch (state) {
    case 1:
      var property = env0;
      var targetValue = env1;
      t1 = env2;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      if (state == 1 || (state == 0 && !$.eqNullB(this._target))) {
        switch (state) {
          case 0:
            var t1 = this._started;
          case 1:
            state = 0;
            t1 = $.eqB(t1, false);
        }
      } else {
        t1 = false;
      }
      t1 && $.add$1(this._animateProperties, $._AnimateProperty$3(property, 0.0, targetValue));
  }
 },
 _onComplete$0: function() { return this._onComplete.$call$0(); },
 _onUpdate$0: function() { return this._onUpdate.$call$0(); },
 _onStart$0: function() { return this._onStart.$call$0(); },
 _transitionFunction$1: function(arg0) { return this._transitionFunction.$call$1(arg0); },
 Tween$3: function(target, time, transitionFunction) {
  this._target = target;
  this._transitionFunction = !$.eqNullB(transitionFunction) ? transitionFunction : $.linear;
  this._currentTime = 0.0;
  this._totalTime = $.max(0.0001, time);
  this._delay = 0.0;
  this._roundToInt = false;
  this._started = false;
  var t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: '_AnimateProperty'}));
  this._animateProperties = t1;
  t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: '_AnimateValue'}));
  this._animateValues = t1;
 }
};

$$.Point = {"":
 ["y=", "x="],
 super: "Object",
 offset$2: function(dx, dy) {
  this.x = $.add(this.x, dx);
  this.y = $.add(this.y, dy);
 },
 get$offset: function() { return new $.Closure30(this, 'offset$2'); },
 add$1: function(p) {
  return $.Point$2($.add(this.x, p.get$x()), $.add(this.y, p.get$y()));
 },
 get$length: function() {
  var t1 = this.x;
  t1 = $.mul(t1, t1);
  var t2 = this.y;
  return $.sqrt($.add(t1, $.mul(t2, t2)));
 }
};

$$.Rectangle = {"":
 ["height=", "width=", "y=", "x="],
 super: "Object",
 offset$2: function(dx, dy) {
  this.x = $.add(this.x, dx);
  this.y = $.add(this.y, dy);
 },
 get$offset: function() { return new $.Closure30(this, 'offset$2'); },
 get$isEmpty: function() {
  return $.eqB(this.width, 0) && $.eqB(this.height, 0);
 },
 isEmpty$0: function() { return this.get$isEmpty().$call$0(); },
 contains$2: function(px, py) {
  return $.leB(this.x, px) && $.leB(this.y, py) && $.geB(this.get$right(), px) && $.geB(this.get$bottom(), py);
 },
 get$size: function() {
  return $.Point$2(this.width, this.height);
 },
 get$bottom: function() {
  return $.add(this.y, this.height);
 },
 get$right: function() {
  return $.add(this.x, this.width);
 },
 get$top: function() {
  return this.y;
 },
 get$left: function() {
  return this.x;
 }
};

$$.Circle = {"":
 ["radius?", "y=", "x="],
 super: "Object"
};

$$.Matrix = {"":
 ["_det", "_ty", "_tx", "_d", "_c", "_b", "_a"],
 super: "Object",
 copyFromAndConcat$2: function(copyMatrix, concatMatrix) {
  var a1 = copyMatrix.get$a();
  if (typeof a1 !== 'number') return this.copyFromAndConcat$2$bailout(1, copyMatrix, concatMatrix, a1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  var b1 = copyMatrix.get$b();
  if (typeof b1 !== 'number') return this.copyFromAndConcat$2$bailout(2, copyMatrix, concatMatrix, a1, b1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  var c1 = copyMatrix.get$c();
  if (typeof c1 !== 'number') return this.copyFromAndConcat$2$bailout(3, copyMatrix, concatMatrix, a1, b1, c1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  var d1 = copyMatrix.get$d();
  if (typeof d1 !== 'number') return this.copyFromAndConcat$2$bailout(4, copyMatrix, concatMatrix, a1, b1, c1, d1, 0, 0, 0, 0, 0, 0, 0, 0);
  var tx1 = copyMatrix.get$tx();
  if (typeof tx1 !== 'number') return this.copyFromAndConcat$2$bailout(5, copyMatrix, concatMatrix, a1, b1, c1, d1, tx1, 0, 0, 0, 0, 0, 0, 0);
  var ty1 = copyMatrix.get$ty();
  if (typeof ty1 !== 'number') return this.copyFromAndConcat$2$bailout(6, copyMatrix, concatMatrix, a1, b1, c1, d1, tx1, ty1, 0, 0, 0, 0, 0, 0);
  var det1 = copyMatrix.get$det();
  if (typeof det1 !== 'number') return this.copyFromAndConcat$2$bailout(7, concatMatrix, a1, b1, c1, d1, tx1, ty1, det1, 0, 0, 0, 0, 0, 0);
  var a2 = concatMatrix.get$a();
  if (typeof a2 !== 'number') return this.copyFromAndConcat$2$bailout(8, concatMatrix, a1, b1, c1, d1, tx1, ty1, det1, a2, 0, 0, 0, 0, 0);
  var b2 = concatMatrix.get$b();
  if (typeof b2 !== 'number') return this.copyFromAndConcat$2$bailout(9, concatMatrix, a1, b1, c1, d1, tx1, ty1, det1, a2, b2, 0, 0, 0, 0);
  var c2 = concatMatrix.get$c();
  if (typeof c2 !== 'number') return this.copyFromAndConcat$2$bailout(10, concatMatrix, a1, b1, c1, d1, tx1, ty1, det1, a2, b2, c2, 0, 0, 0);
  var d2 = concatMatrix.get$d();
  if (typeof d2 !== 'number') return this.copyFromAndConcat$2$bailout(11, concatMatrix, a1, b1, c1, d1, tx1, ty1, det1, a2, b2, c2, d2, 0, 0);
  var tx2 = concatMatrix.get$tx();
  if (typeof tx2 !== 'number') return this.copyFromAndConcat$2$bailout(12, concatMatrix, a1, b1, c1, d1, tx1, ty1, det1, a2, b2, c2, d2, tx2, 0);
  var ty2 = concatMatrix.get$ty();
  if (typeof ty2 !== 'number') return this.copyFromAndConcat$2$bailout(13, concatMatrix, a1, b1, c1, d1, tx1, ty1, det1, a2, b2, c2, d2, tx2, ty2);
  var det2 = concatMatrix.get$det();
  if (typeof det2 !== 'number') return this.copyFromAndConcat$2$bailout(14, a1, b1, c1, d1, tx1, ty1, det1, a2, b2, c2, d2, tx2, ty2, det2);
  this._a = a1 * a2 + b1 * c2;
  this._b = a1 * b2 + b1 * d2;
  this._c = c1 * a2 + d1 * c2;
  this._d = c1 * b2 + d1 * d2;
  this._tx = tx1 * a2 + ty1 * c2 + tx2;
  this._ty = tx1 * b2 + ty1 * d2 + ty2;
  this._det = det1 * det2;
 },
 copyFromAndConcat$2$bailout: function(state, env0, env1, env2, env3, env4, env5, env6, env7, env8, env9, env10, env11, env12, env13) {
  switch (state) {
    case 1:
      var copyMatrix = env0;
      var concatMatrix = env1;
      a1 = env2;
      break;
    case 2:
      copyMatrix = env0;
      concatMatrix = env1;
      a1 = env2;
      b1 = env3;
      break;
    case 3:
      copyMatrix = env0;
      concatMatrix = env1;
      a1 = env2;
      b1 = env3;
      c1 = env4;
      break;
    case 4:
      copyMatrix = env0;
      concatMatrix = env1;
      a1 = env2;
      b1 = env3;
      c1 = env4;
      d1 = env5;
      break;
    case 5:
      copyMatrix = env0;
      concatMatrix = env1;
      a1 = env2;
      b1 = env3;
      c1 = env4;
      d1 = env5;
      tx1 = env6;
      break;
    case 6:
      copyMatrix = env0;
      concatMatrix = env1;
      a1 = env2;
      b1 = env3;
      c1 = env4;
      d1 = env5;
      tx1 = env6;
      ty1 = env7;
      break;
    case 7:
      concatMatrix = env0;
      a1 = env1;
      b1 = env2;
      c1 = env3;
      d1 = env4;
      tx1 = env5;
      ty1 = env6;
      det1 = env7;
      break;
    case 8:
      concatMatrix = env0;
      a1 = env1;
      b1 = env2;
      c1 = env3;
      d1 = env4;
      tx1 = env5;
      ty1 = env6;
      det1 = env7;
      a2 = env8;
      break;
    case 9:
      concatMatrix = env0;
      a1 = env1;
      b1 = env2;
      c1 = env3;
      d1 = env4;
      tx1 = env5;
      ty1 = env6;
      det1 = env7;
      a2 = env8;
      b2 = env9;
      break;
    case 10:
      concatMatrix = env0;
      a1 = env1;
      b1 = env2;
      c1 = env3;
      d1 = env4;
      tx1 = env5;
      ty1 = env6;
      det1 = env7;
      a2 = env8;
      b2 = env9;
      c2 = env10;
      break;
    case 11:
      concatMatrix = env0;
      a1 = env1;
      b1 = env2;
      c1 = env3;
      d1 = env4;
      tx1 = env5;
      ty1 = env6;
      det1 = env7;
      a2 = env8;
      b2 = env9;
      c2 = env10;
      d2 = env11;
      break;
    case 12:
      concatMatrix = env0;
      a1 = env1;
      b1 = env2;
      c1 = env3;
      d1 = env4;
      tx1 = env5;
      ty1 = env6;
      det1 = env7;
      a2 = env8;
      b2 = env9;
      c2 = env10;
      d2 = env11;
      tx2 = env12;
      break;
    case 13:
      concatMatrix = env0;
      a1 = env1;
      b1 = env2;
      c1 = env3;
      d1 = env4;
      tx1 = env5;
      ty1 = env6;
      det1 = env7;
      a2 = env8;
      b2 = env9;
      c2 = env10;
      d2 = env11;
      tx2 = env12;
      ty2 = env13;
      break;
    case 14:
      a1 = env0;
      b1 = env1;
      c1 = env2;
      d1 = env3;
      tx1 = env4;
      ty1 = env5;
      det1 = env6;
      a2 = env7;
      b2 = env8;
      c2 = env9;
      d2 = env10;
      tx2 = env11;
      ty2 = env12;
      det2 = env13;
      break;
  }
  switch (state) {
    case 0:
      var a1 = copyMatrix.get$a();
    case 1:
      state = 0;
      var b1 = copyMatrix.get$b();
    case 2:
      state = 0;
      var c1 = copyMatrix.get$c();
    case 3:
      state = 0;
      var d1 = copyMatrix.get$d();
    case 4:
      state = 0;
      var tx1 = copyMatrix.get$tx();
    case 5:
      state = 0;
      var ty1 = copyMatrix.get$ty();
    case 6:
      state = 0;
      var det1 = copyMatrix.get$det();
    case 7:
      state = 0;
      var a2 = concatMatrix.get$a();
    case 8:
      state = 0;
      var b2 = concatMatrix.get$b();
    case 9:
      state = 0;
      var c2 = concatMatrix.get$c();
    case 10:
      state = 0;
      var d2 = concatMatrix.get$d();
    case 11:
      state = 0;
      var tx2 = concatMatrix.get$tx();
    case 12:
      state = 0;
      var ty2 = concatMatrix.get$ty();
    case 13:
      state = 0;
      var det2 = concatMatrix.get$det();
    case 14:
      state = 0;
      this._a = $.add($.mul(a1, a2), $.mul(b1, c2));
      this._b = $.add($.mul(a1, b2), $.mul(b1, d2));
      this._c = $.add($.mul(c1, a2), $.mul(d1, c2));
      this._d = $.add($.mul(c1, b2), $.mul(d1, d2));
      this._tx = $.add($.add($.mul(tx1, a2), $.mul(ty1, c2)), tx2);
      this._ty = $.add($.add($.mul(tx1, b2), $.mul(ty1, d2)), ty2);
      this._det = $.mul(det1, det2);
  }
 },
 setTo$6: function(a, b, c, d, tx, ty) {
  this._a = a;
  this._b = b;
  this._c = c;
  this._d = d;
  this._tx = tx;
  this._ty = ty;
  this._det = $.sub($.mul(a, d), $.mul(b, c));
 },
 invert$0: function() {
  var a = this._a;
  var b = this._b;
  var c = this._c;
  var d = this._d;
  var tx = this._tx;
  var ty = this._ty;
  var det = this._det;
  this._a = $.div(d, det);
  this._b = $.neg($.div(b, det));
  this._c = $.neg($.div(c, det));
  this._d = $.div(a, det);
  this._tx = $.neg($.add($.mul(this._a, tx), $.mul(this._c, ty)));
  this._ty = $.neg($.add($.mul(this._b, tx), $.mul(this._d, ty)));
  if (typeof det !== 'number') throw $.iae(det);
  this._det = 1.0 / det;
 },
 identity$0: function() {
  this._a = 1.0;
  this._b = 0.0;
  this._c = 0.0;
  this._d = 1.0;
  this._tx = 0.0;
  this._ty = 0.0;
  this._det = 1.0;
 },
 concat$1: function(matrix) {
  var a1 = this._a;
  var b1 = this._b;
  var c1 = this._c;
  var d1 = this._d;
  var tx1 = this._tx;
  var ty1 = this._ty;
  var det1 = this._det;
  var a2 = matrix.get$a();
  var b2 = matrix.get$b();
  var c2 = matrix.get$c();
  var d2 = matrix.get$d();
  var tx2 = matrix.get$tx();
  var ty2 = matrix.get$ty();
  var det2 = matrix.get$det();
  this._a = $.add($.mul(a1, a2), $.mul(b1, c2));
  this._b = $.add($.mul(a1, b2), $.mul(b1, d2));
  this._c = $.add($.mul(c1, a2), $.mul(d1, c2));
  this._d = $.add($.mul(c1, b2), $.mul(d1, d2));
  this._tx = $.add($.add($.mul(tx1, a2), $.mul(ty1, c2)), tx2);
  this._ty = $.add($.add($.mul(tx1, b2), $.mul(ty1, d2)), ty2);
  this._det = $.mul(det1, det2);
 },
 transformPoint$1: function(p) {
  return $.Point$2($.add($.add($.mul(p.get$x(), this._a), $.mul(p.get$y(), this._c)), this._tx), $.add($.add($.mul(p.get$x(), this._b), $.mul(p.get$y(), this._d)), this._ty));
 },
 get$det: function() {
  return this._det;
 },
 get$ty: function() {
  return this._ty;
 },
 get$tx: function() {
  return this._tx;
 },
 get$d: function() {
  return this._d;
 },
 get$c: function() {
  return this._c;
 },
 get$b: function() {
  return this._b;
 },
 get$a: function() {
  return this._a;
 }
};

$$.RenderLoop = {"":
 ["_renderTime", "_stages", "_juggler"],
 super: "Object",
 addStage$1: function(stage) {
  $.add$1(this._stages, stage);
 },
 _onAnimationFrame$1: function(currentTime) {
  this._requestAnimationFrame$0();
  if ($.eqNullB(currentTime)) currentTime = $.DateImplementation$now$0().millisecondsSinceEpoch;
  if ($.isNaN(this._renderTime) === true) this._renderTime = currentTime;
  if ($.gtB(this._renderTime, currentTime)) this._renderTime = currentTime;
  var deltaTime = $.sub(currentTime, this._renderTime);
  var deltaTimeSec = $.div(deltaTime, 1000.0);
  if ($.geB(deltaTime, 1)) {
    this._renderTime = currentTime;
    $.dispatchEvent($.EnterFrameEvent$1(deltaTimeSec));
    this._juggler.advanceTime$1(deltaTimeSec);
    for (var i = 0; $.ltB(i, $.get$length(this._stages)); ++i) {
      $.index(this._stages, i).materialize$0();
    }
  }
  return true;
 },
 get$_onAnimationFrame: function() { return new $.Closure28(this, '_onAnimationFrame$1'); },
 _requestAnimationFrame$0: function() {
  try {
    $.window().requestAnimationFrame$1(this.get$_onAnimationFrame());
  } catch (exception) {
    var t1 = $.unwrapException(exception);
    if (t1 == null || typeof t1 === 'object' && t1 !== null && !!t1.is$Exception) $.window().setTimeout$2(new $.Closure8(this), 16);
    else throw exception;
  }
 },
 RenderLoop$0: function() {
  this._juggler = $.instance();
  var t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'Stage'}));
  this._stages = t1;
  this._requestAnimationFrame$0();
 }
};

$$.RenderState = {"":
 ["_depth", "_alphas", "_matrices", "_context?"],
 super: "Object",
 renderDisplayObject$1: function(displayObject) {
  var t1 = this._depth;
  if (typeof t1 !== 'number') return this.renderDisplayObject$1$bailout(1, displayObject, t1, 0, 0, 0);
  this._depth = t1 + 1;
  var t2 = this._matrices;
  if (typeof t2 !== 'string' && (typeof t2 !== 'object' || t2 === null || (t2.constructor !== Array && !t2.is$JavaScriptIndexingBehavior()))) return this.renderDisplayObject$1$bailout(2, displayObject, t2, 0, 0, 0);
  var t3 = this._depth;
  if (t3 !== (t3 | 0)) throw $.iae(t3);
  var t4 = t2.length;
  if (t3 < 0 || t3 >= t4) throw $.ioore(t3);
  t3 = t2[t3];
  t2 = displayObject.get$_transformationMatrix();
  var t5 = this._matrices;
  if (typeof t5 !== 'string' && (typeof t5 !== 'object' || t5 === null || (t5.constructor !== Array && !t5.is$JavaScriptIndexingBehavior()))) return this.renderDisplayObject$1$bailout(3, displayObject, t5, t3, t2, 0);
  var t6 = this._depth;
  if (typeof t6 !== 'number') return this.renderDisplayObject$1$bailout(4, displayObject, t5, t6, t3, t2);
  --t6;
  if (t6 !== (t6 | 0)) throw $.iae(t6);
  var t7 = t5.length;
  if (t6 < 0 || t6 >= t7) throw $.ioore(t6);
  t3.copyFromAndConcat$2(t2, t5[t6]);
  this._context.setTransform$6(t3.get$a(), t3.get$b(), t3.get$c(), t3.get$d(), t3.get$tx(), t3.get$ty());
  t2 = this._alphas;
  if (typeof t2 !== 'object' || t2 === null || ((t2.constructor !== Array || !!t2.immutable$list) && !t2.is$JavaScriptIndexingBehavior())) return this.renderDisplayObject$1$bailout(5, displayObject, t2, 0, 0, 0);
  var t8 = this._depth;
  if (typeof t8 !== 'number') return this.renderDisplayObject$1$bailout(6, displayObject, t2, t8, 0, 0);
  var t9 = t8 - 1;
  if (t9 !== (t9 | 0)) throw $.iae(t9);
  var t10 = t2.length;
  if (t9 < 0 || t9 >= t10) throw $.ioore(t9);
  t9 = t2[t9];
  if (typeof t9 !== 'number') return this.renderDisplayObject$1$bailout(7, displayObject, t2, t9, t8, 0);
  var t11 = displayObject.get$_alpha();
  if (typeof t11 !== 'number') return this.renderDisplayObject$1$bailout(8, displayObject, t2, t9, t11, t8);
  t11 *= t9;
  if (t8 !== (t8 | 0)) throw $.iae(t8);
  t9 = t2.length;
  if (t8 < 0 || t8 >= t9) throw $.ioore(t8);
  t2[t8] = t11;
  this._context.set$globalAlpha(t11);
  if ($.eqNullB(displayObject.get$mask())) displayObject.render$1(this);
  else {
    this._context.save$0();
    displayObject.get$mask().render$1(this);
    displayObject.render$1(this);
    this._context.restore$0();
  }
  t1 = this._depth;
  if (typeof t1 !== 'number') return this.renderDisplayObject$1$bailout(9, t1, 0, 0, 0, 0);
  this._depth = t1 - 1;
 },
 renderDisplayObject$1$bailout: function(state, env0, env1, env2, env3, env4) {
  switch (state) {
    case 1:
      var displayObject = env0;
      t1 = env1;
      break;
    case 2:
      displayObject = env0;
      t2 = env1;
      break;
    case 3:
      displayObject = env0;
      t3 = env1;
      matrix = env2;
      t2 = env3;
      break;
    case 4:
      displayObject = env0;
      t3 = env1;
      t4 = env2;
      matrix = env3;
      t2 = env4;
      break;
    case 5:
      displayObject = env0;
      t2 = env1;
      break;
    case 6:
      displayObject = env0;
      t2 = env1;
      t5 = env2;
      break;
    case 7:
      displayObject = env0;
      t2 = env1;
      t6 = env2;
      t5 = env3;
      break;
    case 8:
      displayObject = env0;
      t2 = env1;
      t6 = env2;
      t7 = env3;
      t5 = env4;
      break;
    case 9:
      t1 = env0;
      break;
  }
  switch (state) {
    case 0:
      var t1 = this._depth;
    case 1:
      state = 0;
      this._depth = $.add(t1, 1);
      var t2 = this._matrices;
    case 2:
      state = 0;
      var matrix = $.index(t2, this._depth);
      t2 = displayObject.get$_transformationMatrix();
      var t3 = this._matrices;
    case 3:
      state = 0;
      var t4 = this._depth;
    case 4:
      state = 0;
      matrix.copyFromAndConcat$2(t2, $.index(t3, $.sub(t4, 1)));
      this._context.setTransform$6(matrix.get$a(), matrix.get$b(), matrix.get$c(), matrix.get$d(), matrix.get$tx(), matrix.get$ty());
      t2 = this._alphas;
    case 5:
      state = 0;
      var t5 = this._depth;
    case 6:
      state = 0;
      var t6 = $.index(t2, $.sub(t5, 1));
    case 7:
      state = 0;
      var t7 = displayObject.get$_alpha();
    case 8:
      state = 0;
      t7 = $.mul(t6, t7);
      $.indexSet(t2, t5, t7);
      this._context.set$globalAlpha(t7);
      if ($.eqNullB(displayObject.get$mask())) displayObject.render$1(this);
      else {
        this._context.save$0();
        displayObject.get$mask().render$1(this);
        displayObject.render$1(this);
        this._context.restore$0();
      }
      t1 = this._depth;
    case 9:
      state = 0;
      this._depth = $.sub(t1, 1);
  }
 },
 reset$0: function() {
  this._context.setTransform$6(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
  this._context.set$globalAlpha(1);
  var t1 = this._context;
  t1.clearRect$4(0, 0, t1.get$canvas().get$width(), this._context.get$canvas().get$height());
  this._depth = 0;
 },
 get$context: function() {
  return this._context;
 },
 RenderState$fromCanvasRenderingContext2D$1: function(context) {
  this._context = context;
  var t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'Matrix'}));
  this._matrices = t1;
  t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'double'}));
  this._alphas = t1;
  this._depth = 0;
  for (var i = 0; i < 100; ++i) {
    $.add$1(this._matrices, $.Matrix$identity$0());
    $.add$1(this._alphas, 1.0);
  }
 }
};

$$.Event = {"":
 ["_stopsImmediatePropagation", "_stopsPropagation", "_currentTarget!", "_target!", "_eventPhase!", "_bubbles", "_type"],
 super: "Object",
 get$captures: function() {
  return true;
 },
 get$bubbles: function() {
  return this._bubbles;
 },
 get$type: function() {
  return this._type;
 },
 get$stopsImmediatePropagation: function() {
  return this._stopsImmediatePropagation;
 },
 get$stopsPropagation: function() {
  return this._stopsPropagation;
 },
 Event$2: function(type, bubbles) {
  this._type = type;
  this._bubbles = bubbles;
  this._eventPhase = 2;
 }
};

$$.EventDispatcher = {"":
 ["_eventListenersMap"],
 super: "Object",
 _invokeEventListeners$4: function(event$, target, currentTarget, eventPhase) {
  if (typeof eventPhase !== 'number') return this._invokeEventListeners$4$bailout(1, event$, target, currentTarget, eventPhase, 0, 0, 0);
  var t1 = this._eventListenersMap;
  if (!(t1 == null)) {
    t1 = this._eventListenersMap;
    if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this._invokeEventListeners$4$bailout(2, event$, target, currentTarget, eventPhase, t1, 0, 0);
    var t2 = event$.get$type();
    if (t2 !== (t2 | 0)) throw $.iae(t2);
    var t3 = t1.length;
    if (t2 < 0 || t2 >= t3) throw $.ioore(t2);
    t2 = t1[t2];
    if (!$.eqNullB(t2)) {
      for (t1 = $.iterator(t2), t2 = eventPhase === 1; t1.hasNext$0() === true; ) {
        t3 = t1.next$0();
        if (t2) {
          var t4 = t3.get$useCapture();
          if (typeof t4 !== 'boolean') return this._invokeEventListeners$4$bailout(3, event$, target, currentTarget, eventPhase, t4, t3, t1);
          t4 = !t4;
        } else t4 = false;
        if (t4) continue;
        event$.set$_target(target);
        event$.set$_currentTarget(currentTarget);
        event$.set$_eventPhase(eventPhase);
        t3.listener$1(event$);
        if (event$.get$stopsImmediatePropagation() === true) break;
      }
    }
  }
 },
 _invokeEventListeners$4$bailout: function(state, env0, env1, env2, env3, env4, env5, env6) {
  switch (state) {
    case 1:
      var event$ = env0;
      var target = env1;
      var currentTarget = env2;
      var eventPhase = env3;
      break;
    case 2:
      event$ = env0;
      target = env1;
      currentTarget = env2;
      eventPhase = env3;
      t1 = env4;
      break;
    case 3:
      event$ = env0;
      target = env1;
      currentTarget = env2;
      eventPhase = env3;
      t3 = env4;
      t2 = env5;
      t1 = env6;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 2:
    case 3:
      if (state == 2 || state == 3 || (state == 0 && !$.eqNullB(this._eventListenersMap))) {
        switch (state) {
          case 0:
            var t1 = this._eventListenersMap;
          case 2:
            state = 0;
            var eventListeners = $.index(t1, event$.get$type());
          case 3:
            if (state == 3 || (state == 0 && !$.eqNullB(eventListeners))) {
              switch (state) {
                case 0:
                  t1 = $.iterator(eventListeners);
                case 3:
                  L0: while (true) {
                    switch (state) {
                      case 0:
                        if (!(t1.hasNext$0() === true)) break L0;
                      case 3:
                        c$0:{
                          switch (state) {
                            case 0:
                              var t2 = t1.next$0();
                            case 3:
                              if (state == 3 || (state == 0 && $.eqB(eventPhase, 1))) {
                                switch (state) {
                                  case 0:
                                    var t3 = t2.get$useCapture();
                                  case 3:
                                    state = 0;
                                    t3 = $.eqB(t3, false);
                                }
                              } else {
                                t3 = false;
                              }
                              if (t3) break c$0;
                              event$.set$_target(target);
                              event$.set$_currentTarget(currentTarget);
                              event$.set$_eventPhase(eventPhase);
                              t2.listener$1(event$);
                              if (event$.get$stopsImmediatePropagation() === true) break L0;
                          }
                        }
                    }
                  }
              }
            }
        }
      }
  }
 },
 dispatchEvent$1: function(event$) {
  this._invokeEventListeners$4(event$, this, this, 2);
 },
 addEventListener$3: function(type, listener, useCapture) {
  var eventListener = $._EventListener$2(listener, useCapture);
  if ($.eqNullB(this._eventListenersMap)) this._eventListenersMap = $.HashMapImplementation$0();
  var eventListeners = $.index(this._eventListenersMap, type);
  if ($.eqNullB(eventListeners)) {
    eventListeners = $.List(null);
    $.setRuntimeTypeInfo(eventListeners, ({E: '_EventListener'}));
  } else {
    eventListeners = $.List$from(eventListeners);
    $.setRuntimeTypeInfo(eventListeners, ({E: '_EventListener'}));
  }
  $.add$1(eventListeners, eventListener);
  $.indexSet(this._eventListenersMap, type, eventListeners);
  $.addEventDispatcher(type, this);
 },
 addEventListener$2: function(type,listener) {
  return this.addEventListener$3(type,listener,false)
},
 hasEventListener$1: function(type) {
  return !$.eqNullB(this._eventListenersMap) && this._eventListenersMap.containsKey$1(type) === true;
 }
};

$$._EventListener = {"":
 ["useCapture?", "listener"],
 super: "Object",
 listener$1: function(arg0) { return this.listener.$call$1(arg0); }
};

$$.EnterFrameEvent = {"":
 ["_passedTime", "_stopsImmediatePropagation", "_stopsPropagation", "_currentTarget", "_target", "_eventPhase", "_bubbles", "_type"],
 super: "Event",
 get$captures: function() {
  return false;
 },
 EnterFrameEvent$1: function(passedTime) {
  this._passedTime = passedTime;
 }
};

$$.MouseEvent = {"":
 ["_relatedObject", "_isRelatedObjectInaccessible", "_delta", "_clickCount", "_shiftKey", "_ctrlKey", "_controlKey", "_altKey", "_buttonDown", "_stageY", "_stageX", "_localY", "_localX", "_stopsImmediatePropagation", "_stopsPropagation", "_currentTarget", "_target", "_eventPhase", "_bubbles", "_type"],
 super: "Event",
 get$shiftKey: function() {
  return this._shiftKey;
 },
 get$ctrlKey: function() {
  return this._ctrlKey;
 },
 get$altKey: function() {
  return this._altKey;
 },
 get$buttonDown: function() {
  return this._buttonDown;
 },
 get$localY: function() {
  return this._localY;
 },
 get$localX: function() {
  return this._localX;
 }
};

$$.KeyboardEvent = {"":
 ["_keyLocation", "_keyCode", "_charCode", "_controlKey", "_commandKey", "_shiftKey", "_ctrlKey", "_altKey", "_stopsImmediatePropagation", "_stopsPropagation", "_currentTarget", "_target", "_eventPhase", "_bubbles", "_type"],
 super: "Event",
 get$keyLocation: function() {
  return this._keyLocation;
 },
 get$keyCode: function() {
  return this._keyCode;
 },
 get$charCode: function() {
  return this._charCode;
 },
 get$shiftKey: function() {
  return this._shiftKey;
 },
 get$ctrlKey: function() {
  return this._ctrlKey;
 },
 get$altKey: function() {
  return this._altKey;
 }
};

$$.TextEvent = {"":
 ["_text", "_stopsImmediatePropagation", "_stopsPropagation", "_currentTarget", "_target", "_eventPhase", "_bubbles", "_type"],
 super: "Event"
};

$$.DisplayObject = {"":
 ["mask=", "_lib0_parent?", "_alpha?"],
 super: "EventDispatcher",
 render$1: function(renderState) {
 },
 _setParent$1: function(value) {
  for (var ancestor = value; !$.eqNullB(ancestor); ancestor = ancestor.get$_lib0_parent()) {
    if ($.eqB(ancestor, this)) throw $.captureStackTrace($.IllegalArgumentException$1('Error #2150: An object cannot be added as a child to one of it\'s children (or children\'s children, etc.).'));
  }
  this._lib0_parent = value;
 },
 dispatchEvent$1: function(event$) {
  if (event$.get$captures() === true || event$.get$bubbles() === true) {
    for (var ancestor = this._lib0_parent, ancestors = null; !$.eqNullB(ancestor); ancestor = ancestor.get$_lib0_parent()) {
      if (ancestor.hasEventListener$1(event$.get$type()) === true) {
        if ($.eqNullB(ancestors)) {
          ancestors = $.List(null);
          $.setRuntimeTypeInfo(ancestors, ({E: 'DisplayObject'}));
        }
        $.add$1(ancestors, ancestor);
      }
    }
  } else ancestors = null;
  if (event$.get$captures() === true && !$.eqNullB(ancestors)) {
    var t1 = $.get$length(ancestors);
    if (typeof t1 !== 'number') return this.dispatchEvent$1$bailout(1, event$, ancestors, t1, 0);
    var i = t1 - 1;
    for (; i >= 0; --i) {
      t1 = event$.get$stopsPropagation();
      if (typeof t1 !== 'boolean') return this.dispatchEvent$1$bailout(2, event$, ancestors, i, t1);
      !t1 && $.index(ancestors, i)._invokeEventListeners$4(event$, this, $.index(ancestors, i), 1);
    }
  }
  t1 = event$.get$stopsPropagation();
  if (typeof t1 !== 'boolean') return this.dispatchEvent$1$bailout(3, event$, ancestors, t1, 0);
  !t1 && this._invokeEventListeners$4(event$, this, this, 2);
  if (event$.get$bubbles() === true && !$.eqNullB(ancestors)) {
    i = 0;
    while (true) {
      t1 = $.get$length(ancestors);
      if (typeof t1 !== 'number') return this.dispatchEvent$1$bailout(4, event$, ancestors, i, t1);
      if (!(i < t1)) break;
      t1 = event$.get$stopsPropagation();
      if (typeof t1 !== 'boolean') return this.dispatchEvent$1$bailout(5, event$, ancestors, i, t1);
      !t1 && $.index(ancestors, i)._invokeEventListeners$4(event$, this, $.index(ancestors, i), 3);
      ++i;
    }
  }
 },
 dispatchEvent$1$bailout: function(state, env0, env1, env2, env3) {
  switch (state) {
    case 1:
      var event$ = env0;
      ancestors = env1;
      t1 = env2;
      break;
    case 2:
      event$ = env0;
      ancestors = env1;
      i = env2;
      t1 = env3;
      break;
    case 3:
      event$ = env0;
      ancestors = env1;
      t1 = env2;
      break;
    case 4:
      event$ = env0;
      ancestors = env1;
      i = env2;
      t1 = env3;
      break;
    case 5:
      event$ = env0;
      ancestors = env1;
      i = env2;
      t1 = env3;
      break;
  }
  switch (state) {
    case 0:
      if (event$.get$captures() === true || event$.get$bubbles() === true) {
        for (var ancestor = this._lib0_parent, ancestors = null; !$.eqNullB(ancestor); ancestor = ancestor.get$_lib0_parent()) {
          if (ancestor.hasEventListener$1(event$.get$type()) === true) {
            if ($.eqNullB(ancestors)) {
              ancestors = $.List(null);
              $.setRuntimeTypeInfo(ancestors, ({E: 'DisplayObject'}));
            }
            $.add$1(ancestors, ancestor);
          }
        }
      } else ancestors = null;
    case 1:
    case 2:
      if (state == 1 || state == 2 || (state == 0 && (event$.get$captures() === true && !$.eqNullB(ancestors)))) {
        switch (state) {
          case 0:
            var t1 = $.get$length(ancestors);
          case 1:
            state = 0;
            var i = $.sub(t1, 1);
          case 2:
            L0: while (true) {
              switch (state) {
                case 0:
                  if (!$.geB(i, 0)) break L0;
                  t1 = event$.get$stopsPropagation();
                case 2:
                  state = 0;
                  $.eqB(t1, false) && $.index(ancestors, i)._invokeEventListeners$4(event$, this, $.index(ancestors, i), 1);
                  i = $.sub(i, 1);
              }
            }
        }
      }
      t1 = event$.get$stopsPropagation();
    case 3:
      state = 0;
      $.eqB(t1, false) && this._invokeEventListeners$4(event$, this, this, 2);
    case 4:
    case 5:
      if (state == 4 || state == 5 || (state == 0 && (event$.get$bubbles() === true && !$.eqNullB(ancestors)))) {
        switch (state) {
          case 0:
            i = 0;
          case 4:
          case 5:
            L1: while (true) {
              switch (state) {
                case 0:
                  t1 = $.get$length(ancestors);
                case 4:
                  state = 0;
                  if (!$.ltB(i, t1)) break L1;
                  t1 = event$.get$stopsPropagation();
                case 5:
                  state = 0;
                  $.eqB(t1, false) && $.index(ancestors, i)._invokeEventListeners$4(event$, this, $.index(ancestors, i), 3);
                  ++i;
              }
            }
        }
      }
  }
 },
 globalToLocal$1: function(globalPoint) {
  this._tmpMatrix.identity$0();
  for (var displayObject = this; !$.eqNullB(displayObject); displayObject = displayObject.get$_lib0_parent()) {
    $.concat(this._tmpMatrix, displayObject.get$_transformationMatrix());
  }
  this._tmpMatrix.invert$0();
  return this._tmpMatrix.transformPoint$1(globalPoint);
 },
 hitTestInput$2: function(localX, localY) {
  if ($.contains$2(this.getBoundsTransformed$1(this._tmpMatrixIdentity), localX, localY) === true) return this;
  return;
 },
 getBoundsTransformed$2: function(matrix, returnRectangle) {
  if ($.eqNullB(returnRectangle)) returnRectangle = $.Rectangle$zero$0();
  returnRectangle.set$x(matrix.get$tx());
  returnRectangle.set$y(matrix.get$ty());
  returnRectangle.set$width(0);
  returnRectangle.set$height(0);
  return returnRectangle;
 },
 getBoundsTransformed$1: function(matrix) {
  return this.getBoundsTransformed$2(matrix,null)
},
 get$_transformationMatrix: function() {
  if (this._transformationMatrixRefresh === true) {
    this._transformationMatrixRefresh = false;
    if ($.eqB(this._rotation, 0.0)) {
      var t1 = this._transformationMatrixPrivate;
      var t2 = this._scaleX;
      t1.setTo$6(t2, 0.0, 0.0, this._scaleY, $.sub(this._x, $.mul(this._pivotX, t2)), $.sub(this._y, $.mul(this._pivotY, this._scaleY)));
    } else {
      var cos = $.cos(this._rotation);
      var sin = $.sin(this._rotation);
      var a = $.mul(this._scaleX, cos);
      var b = $.mul(this._scaleX, sin);
      var c = $.mul($.neg(this._scaleY), sin);
      var d = $.mul(this._scaleY, cos);
      var tx = $.sub($.sub(this._x, $.mul(this._pivotX, a)), $.mul(this._pivotY, c));
      var ty = $.sub($.sub(this._y, $.mul(this._pivotX, b)), $.mul(this._pivotY, d));
      this._transformationMatrixPrivate.setTo$6(a, b, c, d, tx, ty);
    }
  }
  return this._transformationMatrixPrivate;
 },
 removeFromParent$0: function() {
  !$.eqNullB(this._lib0_parent) && this._lib0_parent.removeChild$1(this);
 },
 set$height: function(value) {
  this.set$scaleY(1);
  var normalHeight = this.get$height();
  this.set$scaleY(!$.eqB(normalHeight, 0.0) ? $.div(value, normalHeight) : 1.0);
 },
 set$width: function(value) {
  this.set$scaleX(1);
  var normalWidth = this.get$width();
  this.set$scaleX(!$.eqB(normalWidth, 0.0) ? $.div(value, normalWidth) : 1.0);
 },
 get$height: function() {
  return this.getBoundsTransformed$1(this.get$_transformationMatrix()).get$height();
 },
 get$width: function() {
  return this.getBoundsTransformed$1(this.get$_transformationMatrix()).get$width();
 },
 set$alpha: function(value) {
  this._alpha = value;
  this._transformationMatrixRefresh = true;
 },
 set$rotation: function(value) {
  this._rotation = value;
  this._transformationMatrixRefresh = true;
 },
 set$scaleY: function(value) {
  this._scaleY = value;
  this._transformationMatrixRefresh = true;
 },
 set$scaleX: function(value) {
  this._scaleX = value;
  this._transformationMatrixRefresh = true;
 },
 set$pivotY: function(value) {
  this._pivotY = value;
  this._transformationMatrixRefresh = true;
 },
 set$pivotX: function(value) {
  this._pivotX = value;
  this._transformationMatrixRefresh = true;
 },
 set$y: function(value) {
  this._y = value;
  this._transformationMatrixRefresh = true;
 },
 set$x: function(value) {
  this._x = value;
  this._transformationMatrixRefresh = true;
 },
 get$stage: function() {
  var root = this.get$root();
  if (typeof root === 'object' && root !== null && !!root.is$Stage) return root;
  return;
 },
 get$root: function() {
  for (var currentObject = this; !$.eqNullB(currentObject.get$_lib0_parent()); ) {
    currentObject = currentObject.get$_lib0_parent();
  }
  return currentObject;
 },
 get$parent: function() {
  return this._lib0_parent;
 },
 get$name: function() {
  return this._name;
 },
 get$visible: function() {
  return this._visible;
 },
 get$alpha: function() {
  return this._alpha;
 },
 get$rotation: function() {
  return this._rotation;
 },
 get$scaleY: function() {
  return this._scaleY;
 },
 get$scaleX: function() {
  return this._scaleX;
 },
 get$pivotY: function() {
  return this._pivotY;
 },
 get$pivotX: function() {
  return this._pivotX;
 },
 get$y: function() {
  return this._y;
 },
 get$x: function() {
  return this._x;
 },
 DisplayObject$0: function() {
  this._transformationMatrixPrivate = $.Matrix$identity$0();
  this._transformationMatrixRefresh = true;
  this._tmpMatrix = $.Matrix$identity$0();
  this._tmpMatrixIdentity = $.Matrix$identity$0();
 }
};

$$.InteractiveObject = {"":
 ["doubleClickEnabled?"],
 super: "DisplayObject",
 is$InteractiveObject: true
};

$$.DisplayObjectContainer = {"":
 [],
 super: "InteractiveObject",
 _dispatchEventOnChildren$2: function(displayObject, event$) {
  displayObject.dispatchEvent$1(event$);
  if (typeof displayObject === 'object' && displayObject !== null && !!displayObject.is$DisplayObjectContainer) {
    var childrens = $.List$from(displayObject._childrens);
    $.setRuntimeTypeInfo(childrens, ({E: 'DisplayObject'}));
    var childrenLength = childrens.length;
    for (var i = 0; i < childrenLength; ++i) {
      var t1 = childrens.length;
      if (i < 0 || i >= t1) throw $.ioore(i);
      this._dispatchEventOnChildren$2(childrens[i], event$);
    }
  }
 },
 render$1: function(renderState) {
  var childrensLength = this._childrens.length;
  if (typeof childrensLength !== 'number') return this.render$1$bailout(1, renderState, childrensLength);
  for (var i = 0; i < childrensLength; ++i) {
    var child = this._childrens[i];
    child.get$visible() === true && renderState.renderDisplayObject$1(child);
  }
 },
 render$1$bailout: function(state, renderState, childrensLength) {
  for (var i = 0; $.ltB(i, childrensLength); ++i) {
    var child = $.index(this._childrens, i);
    child.get$visible() === true && renderState.renderDisplayObject$1(child);
  }
 },
 hitTestInput$2: function(localX, localY) {
  if (typeof localX !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  if (typeof localY !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  var t1 = this._childrens.length;
  if (typeof t1 !== 'number') return this.hitTestInput$2$bailout(2, localX, localY, t1, 0, 0, 0, 0, 0, 0, 0, 0);
  var i = t1 - 1;
  t1 = this._mouseChildren;
  var hit = null;
  for (; i >= 0; --i) {
    var t2 = this._childrens;
    if (typeof t2 !== 'string' && (typeof t2 !== 'object' || t2 === null || (t2.constructor !== Array && !t2.is$JavaScriptIndexingBehavior()))) return this.hitTestInput$2$bailout(3, t1, i, localY, localX, t2, hit, 0, 0, 0, 0, 0);
    if (i !== (i | 0)) throw $.iae(i);
    var t3 = t2.length;
    if (i < 0 || i >= t3) throw $.ioore(i);
    t2 = t2[i];
    if (t2.get$visible() === true) {
      var matrix = t2.get$_transformationMatrix();
      t3 = matrix.get$tx();
      if (typeof t3 !== 'number') return this.hitTestInput$2$bailout(4, t1, i, matrix, localX, localY, t3, t2, hit, 0, 0, 0);
      var deltaX = localX - t3;
      t3 = matrix.get$ty();
      if (typeof t3 !== 'number') return this.hitTestInput$2$bailout(5, t1, i, matrix, localX, deltaX, t3, localY, t2, hit, 0, 0);
      var deltaY = localY - t3;
      t3 = matrix.get$d();
      if (typeof t3 !== 'number') return this.hitTestInput$2$bailout(6, t1, i, matrix, localX, deltaX, deltaY, t3, localY, t2, hit, 0);
      t3 *= deltaX;
      var t4 = matrix.get$c();
      if (typeof t4 !== 'number') return this.hitTestInput$2$bailout(7, t1, i, matrix, localX, deltaX, localY, deltaY, t3, t4, t2, hit);
      t3 -= t4 * deltaY;
      var t5 = matrix.get$det();
      if (typeof t5 !== 'number') return this.hitTestInput$2$bailout(8, t1, i, matrix, t5, deltaX, t3, localX, deltaY, localY, t2, hit);
      var childX = t3 / t5;
      t5 = matrix.get$a();
      if (typeof t5 !== 'number') return this.hitTestInput$2$bailout(9, t1, i, childX, t5, matrix, deltaX, localX, deltaY, localY, t2, hit);
      t5 *= deltaY;
      t3 = matrix.get$b();
      if (typeof t3 !== 'number') return this.hitTestInput$2$bailout(10, t1, i, childX, localX, matrix, t5, t3, deltaX, localY, t2, hit);
      t5 -= t3 * deltaX;
      var t6 = matrix.get$det();
      if (typeof t6 !== 'number') return this.hitTestInput$2$bailout(11, t1, i, childX, localX, localY, t5, t6, t2, hit, 0, 0);
      var displayObject = t2.hitTestInput$2(childX, t5 / t6);
      if (!$.eqNullB(displayObject)) {
        if (typeof displayObject === 'object' && displayObject !== null && !!displayObject.is$InteractiveObject) {
          if (displayObject.mouseEnabled === true) {
            return t1 ? displayObject : this;
          }
        }
        hit = this;
      }
    }
  }
  return hit;
 },
 hitTestInput$2$bailout: function(state, env0, env1, env2, env3, env4, env5, env6, env7, env8, env9, env10) {
  switch (state) {
    case 1:
      var localX = env0;
      var localY = env1;
      break;
    case 1:
      localX = env0;
      localY = env1;
      break;
    case 2:
      localX = env0;
      localY = env1;
      t1 = env2;
      break;
    case 3:
      t1 = env0;
      i = env1;
      localY = env2;
      localX = env3;
      t2 = env4;
      hit = env5;
      break;
    case 4:
      t1 = env0;
      i = env1;
      matrix = env2;
      localX = env3;
      localY = env4;
      t2 = env5;
      children = env6;
      hit = env7;
      break;
    case 5:
      t1 = env0;
      i = env1;
      matrix = env2;
      localX = env3;
      deltaX = env4;
      t2 = env5;
      localY = env6;
      children = env7;
      hit = env8;
      break;
    case 6:
      t1 = env0;
      i = env1;
      matrix = env2;
      localX = env3;
      deltaX = env4;
      deltaY = env5;
      t2 = env6;
      localY = env7;
      children = env8;
      hit = env9;
      break;
    case 7:
      t1 = env0;
      i = env1;
      matrix = env2;
      localX = env3;
      deltaX = env4;
      localY = env5;
      deltaY = env6;
      t2 = env7;
      t3 = env8;
      children = env9;
      hit = env10;
      break;
    case 8:
      t1 = env0;
      i = env1;
      matrix = env2;
      t4 = env3;
      deltaX = env4;
      t2 = env5;
      localX = env6;
      deltaY = env7;
      localY = env8;
      children = env9;
      hit = env10;
      break;
    case 9:
      t1 = env0;
      i = env1;
      childX = env2;
      t4 = env3;
      matrix = env4;
      deltaX = env5;
      localX = env6;
      deltaY = env7;
      localY = env8;
      children = env9;
      hit = env10;
      break;
    case 10:
      t1 = env0;
      i = env1;
      childX = env2;
      localX = env3;
      matrix = env4;
      t4 = env5;
      t2 = env6;
      deltaX = env7;
      localY = env8;
      children = env9;
      hit = env10;
      break;
    case 11:
      t1 = env0;
      i = env1;
      childX = env2;
      localX = env3;
      localY = env4;
      t4 = env5;
      t5 = env6;
      children = env7;
      hit = env8;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 1:
      state = 0;
      var t1 = $.get$length(this._childrens);
    case 2:
      state = 0;
      var i = $.sub(t1, 1);
      t1 = this._mouseChildren === true;
      var hit = null;
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
      L0: while (true) {
        switch (state) {
          case 0:
            if (!$.geB(i, 0)) break L0;
            var t2 = this._childrens;
          case 3:
            state = 0;
            var children = $.index(t2, i);
          case 4:
          case 5:
          case 6:
          case 7:
          case 8:
          case 9:
          case 10:
          case 11:
            if (state == 4 || state == 5 || state == 6 || state == 7 || state == 8 || state == 9 || state == 10 || state == 11 || (state == 0 && children.get$visible() === true)) {
              switch (state) {
                case 0:
                  var matrix = children.get$_transformationMatrix();
                  t2 = matrix.get$tx();
                case 4:
                  state = 0;
                  var deltaX = $.sub(localX, t2);
                  t2 = matrix.get$ty();
                case 5:
                  state = 0;
                  var deltaY = $.sub(localY, t2);
                  t2 = matrix.get$d();
                case 6:
                  state = 0;
                  t2 = $.mul(t2, deltaX);
                  var t3 = matrix.get$c();
                case 7:
                  state = 0;
                  t2 = $.sub(t2, $.mul(t3, deltaY));
                  var t4 = matrix.get$det();
                case 8:
                  state = 0;
                  var childX = $.div(t2, t4);
                  t4 = matrix.get$a();
                case 9:
                  state = 0;
                  t4 = $.mul(t4, deltaY);
                  t2 = matrix.get$b();
                case 10:
                  state = 0;
                  t4 = $.sub(t4, $.mul(t2, deltaX));
                  var t5 = matrix.get$det();
                case 11:
                  state = 0;
                  var displayObject = children.hitTestInput$2(childX, $.div(t4, t5));
                  if (!$.eqNullB(displayObject)) {
                    if (typeof displayObject === 'object' && displayObject !== null && !!displayObject.is$InteractiveObject) {
                      if (displayObject.mouseEnabled === true) {
                        return t1 ? displayObject : this;
                      }
                    }
                    hit = this;
                  }
              }
            }
            i = $.sub(i, 1);
        }
      }
      return hit;
  }
 },
 getBoundsTransformed$2: function(matrix, returnRectangle) {
  if ($.eqNullB(returnRectangle)) returnRectangle = $.Rectangle$zero$0();
  var t1 = this._childrens.length;
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(1, matrix, t1, returnRectangle, 0, 0, 0, 0, 0, 0, 0);
  if (t1 === 0) return $.DisplayObject.prototype.getBoundsTransformed$2.call(this, matrix, returnRectangle);
  var childrensLength = this._childrens.length;
  if (typeof childrensLength !== 'number') return this.getBoundsTransformed$2$bailout(2, matrix, childrensLength, returnRectangle, 0, 0, 0, 0, 0, 0, 0);
  for (var left = (1/0), bottom = (-1/0), right = (-1/0), top$ = (1/0), i = 0; i < childrensLength; ++i) {
    t1 = this._tmpMatrix;
    var t2 = this._childrens;
    if (typeof t2 !== 'string' && (typeof t2 !== 'object' || t2 === null || (t2.constructor !== Array && !t2.is$JavaScriptIndexingBehavior()))) return this.getBoundsTransformed$2$bailout(3, matrix, childrensLength, left, bottom, t1, right, top$, i, t2, returnRectangle);
    var t3 = t2.length;
    if (i < 0 || i >= t3) throw $.ioore(i);
    t1.copyFromAndConcat$2(t2[i].get$_transformationMatrix(), matrix);
    t1 = this._childrens;
    if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.getBoundsTransformed$2$bailout(4, matrix, childrensLength, left, bottom, t1, right, top$, i, returnRectangle, 0);
    var t4 = t1.length;
    if (i < 0 || i >= t4) throw $.ioore(i);
    var rectangle = t1[i].getBoundsTransformed$2(this._tmpMatrix, returnRectangle);
    t1 = rectangle.get$left();
    if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(5, matrix, childrensLength, left, bottom, right, top$, i, rectangle, returnRectangle, t1);
    if (t1 < left) {
      left = rectangle.get$left();
      if (typeof left !== 'number') return this.getBoundsTransformed$2$bailout(6, matrix, childrensLength, left, bottom, right, top$, i, rectangle, returnRectangle, 0);
    }
    t1 = rectangle.get$top();
    if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(7, matrix, childrensLength, bottom, left, right, top$, i, t1, rectangle, returnRectangle);
    if (t1 < top$) {
      top$ = rectangle.get$top();
      if (typeof top$ !== 'number') return this.getBoundsTransformed$2$bailout(8, matrix, childrensLength, bottom, right, left, i, rectangle, top$, returnRectangle, 0);
    }
    t1 = rectangle.get$right();
    if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(9, matrix, top$, t1, bottom, childrensLength, right, left, i, rectangle, returnRectangle);
    if (t1 > right) {
      right = rectangle.get$right();
      if (typeof right !== 'number') return this.getBoundsTransformed$2$bailout(10, matrix, top$, childrensLength, bottom, left, right, i, rectangle, returnRectangle, 0);
    }
    t1 = rectangle.get$bottom();
    if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(11, matrix, top$, childrensLength, bottom, left, i, right, rectangle, t1, returnRectangle);
    if (t1 > bottom) {
      bottom = rectangle.get$bottom();
      if (typeof bottom !== 'number') return this.getBoundsTransformed$2$bailout(12, matrix, top$, bottom, childrensLength, left, i, right, returnRectangle, 0, 0);
    }
  }
  returnRectangle.set$x(left);
  returnRectangle.set$y(top$);
  returnRectangle.set$width(right - left);
  returnRectangle.set$height(bottom - top$);
  return returnRectangle;
 },
 getBoundsTransformed$2$bailout: function(state, env0, env1, env2, env3, env4, env5, env6, env7, env8, env9) {
  switch (state) {
    case 1:
      var matrix = env0;
      t1 = env1;
      returnRectangle = env2;
      break;
    case 2:
      matrix = env0;
      childrensLength = env1;
      returnRectangle = env2;
      break;
    case 3:
      matrix = env0;
      childrensLength = env1;
      left = env2;
      bottom = env3;
      t1 = env4;
      right = env5;
      top$ = env6;
      i = env7;
      t2 = env8;
      returnRectangle = env9;
      break;
    case 4:
      matrix = env0;
      childrensLength = env1;
      left = env2;
      bottom = env3;
      t1 = env4;
      right = env5;
      top$ = env6;
      i = env7;
      returnRectangle = env8;
      break;
    case 5:
      matrix = env0;
      childrensLength = env1;
      left = env2;
      bottom = env3;
      right = env4;
      top$ = env5;
      i = env6;
      rectangle = env7;
      returnRectangle = env8;
      t1 = env9;
      break;
    case 6:
      matrix = env0;
      childrensLength = env1;
      left = env2;
      bottom = env3;
      right = env4;
      top$ = env5;
      i = env6;
      rectangle = env7;
      returnRectangle = env8;
      break;
    case 7:
      matrix = env0;
      childrensLength = env1;
      bottom = env2;
      left = env3;
      right = env4;
      top$ = env5;
      i = env6;
      t1 = env7;
      rectangle = env8;
      returnRectangle = env9;
      break;
    case 8:
      matrix = env0;
      childrensLength = env1;
      bottom = env2;
      right = env3;
      left = env4;
      i = env5;
      rectangle = env6;
      top$ = env7;
      returnRectangle = env8;
      break;
    case 9:
      matrix = env0;
      top$ = env1;
      t1 = env2;
      bottom = env3;
      childrensLength = env4;
      right = env5;
      left = env6;
      i = env7;
      rectangle = env8;
      returnRectangle = env9;
      break;
    case 10:
      matrix = env0;
      top$ = env1;
      childrensLength = env2;
      bottom = env3;
      left = env4;
      right = env5;
      i = env6;
      rectangle = env7;
      returnRectangle = env8;
      break;
    case 11:
      matrix = env0;
      top$ = env1;
      childrensLength = env2;
      bottom = env3;
      left = env4;
      i = env5;
      right = env6;
      rectangle = env7;
      t1 = env8;
      returnRectangle = env9;
      break;
    case 12:
      matrix = env0;
      top$ = env1;
      bottom = env2;
      childrensLength = env3;
      left = env4;
      i = env5;
      right = env6;
      returnRectangle = env7;
      break;
  }
  switch (state) {
    case 0:
      if ($.eqNullB(returnRectangle)) var returnRectangle = $.Rectangle$zero$0();
      var t1 = $.get$length(this._childrens);
    case 1:
      state = 0;
      if ($.eqB(t1, 0)) return $.DisplayObject.prototype.getBoundsTransformed$2.call(this, matrix, returnRectangle);
      var childrensLength = $.get$length(this._childrens);
    case 2:
      state = 0;
      var left = (1/0);
      var bottom = (-1/0);
      var right = (-1/0);
      var top$ = (1/0);
      var i = 0;
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
      L0: while (true) {
        switch (state) {
          case 0:
            if (!$.ltB(i, childrensLength)) break L0;
            t1 = this._tmpMatrix;
            var t2 = this._childrens;
          case 3:
            state = 0;
            t1.copyFromAndConcat$2($.index(t2, i).get$_transformationMatrix(), matrix);
            t1 = this._childrens;
          case 4:
            state = 0;
            var rectangle = $.index(t1, i).getBoundsTransformed$2(this._tmpMatrix, returnRectangle);
            t1 = rectangle.get$left();
          case 5:
            state = 0;
          case 6:
            if (state == 6 || (state == 0 && $.ltB(t1, left))) {
              switch (state) {
                case 0:
                  left = rectangle.get$left();
                case 6:
                  state = 0;
              }
            }
            t1 = rectangle.get$top();
          case 7:
            state = 0;
          case 8:
            if (state == 8 || (state == 0 && $.ltB(t1, top$))) {
              switch (state) {
                case 0:
                  top$ = rectangle.get$top();
                case 8:
                  state = 0;
              }
            }
            t1 = rectangle.get$right();
          case 9:
            state = 0;
          case 10:
            if (state == 10 || (state == 0 && $.gtB(t1, right))) {
              switch (state) {
                case 0:
                  right = rectangle.get$right();
                case 10:
                  state = 0;
              }
            }
            t1 = rectangle.get$bottom();
          case 11:
            state = 0;
          case 12:
            if (state == 12 || (state == 0 && $.gtB(t1, bottom))) {
              switch (state) {
                case 0:
                  bottom = rectangle.get$bottom();
                case 12:
                  state = 0;
              }
            }
            ++i;
        }
      }
      returnRectangle.set$x(left);
      returnRectangle.set$y(top$);
      returnRectangle.set$width($.sub(right, left));
      returnRectangle.set$height($.sub(bottom, top$));
      return returnRectangle;
  }
 },
 getBoundsTransformed$1: function(matrix) {
  return this.getBoundsTransformed$2(matrix,null)
},
 contains$1: function(child) {
  for (; !$.eqNullB(child); child = child.get$_lib0_parent()) {
    if ($.eqB(child, this)) return true;
  }
  return false;
 },
 removeChildAt$1: function(index) {
  if ($.ltB(index, 0) && $.geB(index, $.get$length(this._childrens))) throw $.captureStackTrace($.IllegalArgumentException$1('Error #2006: The supplied index is out of bounds.'));
  var child = $.index(this._childrens, index);
  child.dispatchEvent$1($.Event$2('removed', true));
  !$.eqNullB(this.get$stage()) && this._dispatchEventOnChildren$2(child, $.Event$2('removedFromStage', false));
  child._setParent$1(null);
  $.removeRange(this._childrens, index, 1);
  return child;
 },
 removeChild$1: function(child) {
  var childIndex = $.indexOf$1(this._childrens, child);
  if ($.eqB(childIndex, -1)) throw $.captureStackTrace($.IllegalArgumentException$1('Error #2025: The supplied DisplayObject must be a child of the caller.'));
  return this.removeChildAt$1(childIndex);
 },
 addChildAt$2: function(child, index) {
  if ($.ltB(index, 0) && $.gtB(index, $.get$length(this._childrens))) throw $.captureStackTrace($.IllegalArgumentException$1('Error #2006: The supplied index is out of bounds.'));
  if ($.eqB(child, this)) throw $.captureStackTrace($.IllegalArgumentException$1('Error #2024: An object cannot be added as a child of itself.'));
  if ($.eqB(child.get$parent(), this)) {
    var currentIndex = $.indexOf$1(this._childrens, child);
    $.removeRange(this._childrens, currentIndex, 1);
    if ($.gtB(index, $.get$length(this._childrens))) index = $.sub(index, 1);
    $.insertRange$3(this._childrens, index, 1, child);
  } else {
    child.removeFromParent$0();
    child._setParent$1(this);
    $.insertRange$3(this._childrens, index, 1, child);
    child.dispatchEvent$1($.Event$2('added', true));
    !$.eqNullB(this.get$stage()) && this._dispatchEventOnChildren$2(child, $.Event$2('addedToStage', false));
  }
  return child;
 },
 addChild$1: function(child) {
  var t1 = $.eqB(child.get$parent(), this);
  var t2 = this._childrens;
  if (t1) {
    var index = $.indexOf$1(t2, child);
    $.removeRange(this._childrens, index, 1);
    $.add$1(this._childrens, child);
  } else this.addChildAt$2(child, $.get$length(t2));
  return child;
 },
 DisplayObjectContainer$0: function() {
  var t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'DisplayObject'}));
  this._childrens = t1;
 },
 is$DisplayObjectContainer: true
};

$$.Stage = {"":
 ["_mouseOverTarget", "_mouseDoubleClickEventTypes", "_mouseClickEventTypes", "_mouseUpEventTypes", "_mouseDownEventTypes", "_clickCount", "_clickTime", "_clickTarget", "_buttonState", "_canvasLocation!", "_mouseCursor", "_renderMode", "_renderState", "_focus", "_context?", "_canvas", "_tabChildren", "_mouseChildren", "_childrens", "tabIndex", "tabEnabled", "mouseEnabled", "doubleClickEnabled", "_tmpMatrixIdentity", "_tmpMatrix", "mask", "_lib0_parent", "_name", "_visible", "_alpha", "_transformationMatrixRefresh", "_transformationMatrixPrivate", "_rotation", "_scaleY", "_scaleX", "_pivotY", "_pivotX", "_y", "_x", "_eventListenersMap"],
 super: "DisplayObjectContainer",
 _calculateElementLocation$1: function(element) {
  var t1 = ({});
  t1.element_3 = element;
  var completer = $.CompleterImpl$0();
  $.setRuntimeTypeInfo(completer, ({T: 'Point'}));
  t1.completer_4 = completer;
  t1.element_3.get$rect().then$1(new $.Closure16(this, t1));
  return t1.completer_4.get$future();
 },
 _onTextEvent$1: function(event$) {
  var charCode = !$.eqB(event$.get$charCode(), 0) ? event$.get$charCode() : event$.get$keyCode();
  var textEvent = $.TextEvent$2('textInput', true);
  textEvent._text = $.String$fromCharCodes([charCode]);
  var t1 = this._focus;
  !(t1 == null) && t1.dispatchEvent$1(textEvent);
 },
 get$_onTextEvent: function() { return new $.Closure28(this, '_onTextEvent$1'); },
 _onKeyEvent$1: function(event$) {
  var keyboardEventType = $.eqB(event$.get$type(), 'keyup') ? 'keyUp' : null;
  if ($.eqB(event$.get$type(), 'keydown')) keyboardEventType = 'keyDown';
  var keyboardEvent = $.KeyboardEvent$2(keyboardEventType, true);
  keyboardEvent._altKey = event$.get$altKey();
  keyboardEvent._ctrlKey = event$.get$ctrlKey();
  keyboardEvent._shiftKey = event$.get$shiftKey();
  keyboardEvent._charCode = event$.get$charCode();
  keyboardEvent._keyCode = event$.get$keyCode();
  keyboardEvent._keyLocation = 0;
  if ($.eqB(event$.get$keyLocation(), 1)) keyboardEvent._keyLocation = 1;
  if ($.eqB(event$.get$keyLocation(), 2)) keyboardEvent._keyLocation = 2;
  if ($.eqB(event$.get$keyLocation(), 3)) keyboardEvent._keyLocation = 3;
  if ($.eqB(event$.get$keyLocation(), 5)) keyboardEvent._keyLocation = 4;
  if ($.eqB(event$.get$keyLocation(), 4)) keyboardEvent._keyLocation = 4;
  var t1 = this._focus;
  !(t1 == null) && t1.dispatchEvent$1(keyboardEvent);
 },
 get$_onKeyEvent: function() { return new $.Closure28(this, '_onKeyEvent$1'); },
 _onMouseWheel$1: function(event$) {
  var mouseX = event$.get$offsetX();
  var mouseY = event$.get$offsetY();
  if (($.eqNullB(mouseX) || $.eqNullB(mouseY)) && !$.eqNullB(this._canvasLocation)) {
    mouseX = $.sub(event$.get$pageX(), this._canvasLocation.get$x());
    mouseY = $.sub(event$.get$pageY(), this._canvasLocation.get$y());
  }
  var target = this.hitTestInput$2(mouseX, mouseY);
  if (!$.eqNullB(target)) {
    var stagePoint = $.Point$2(event$.get$offsetX(), event$.get$offsetY());
    var localPoint = target.globalToLocal$1(stagePoint);
    var mouseEvent = $.MouseEvent$2('mouseWheel', true);
    mouseEvent._localX = localPoint.get$x();
    mouseEvent._localY = localPoint.get$y();
    mouseEvent._stageX = stagePoint.x;
    mouseEvent._stageY = stagePoint.y;
    mouseEvent._delta = event$.get$wheelDelta();
    target.dispatchEvent$1(mouseEvent);
  }
 },
 get$_onMouseWheel: function() { return new $.Closure28(this, '_onMouseWheel$1'); },
 _onMouseEvent$1: function(event$) {
  var time = $.DateImplementation$now$0().millisecondsSinceEpoch;
  var button = event$.get$button();
  if ($.eqNullB(this._canvasLocation) || $.ltB(button, 0) || $.gtB(button, 2)) return;
  var mouseX = event$.get$offsetX();
  var mouseY = event$.get$offsetY();
  if ($.eqNullB(mouseX) || $.eqNullB(mouseY)) {
    mouseX = $.sub(event$.get$pageX(), this._canvasLocation.get$x());
    mouseY = $.sub(event$.get$pageY(), this._canvasLocation.get$y());
  }
  var stagePoint = $.Point$2(mouseX, mouseY);
  var target = !$.eqB(event$.get$type(), 'mouseout') ? this.hitTestInput$2(stagePoint.x, stagePoint.y) : null;
  if (typeof target === 'object' && target !== null && !!target.is$Sprite) {
    var mouseCursor = target.useHandCursor === true ? 'button' : 'arrow';
  } else mouseCursor = 'arrow';
  if (typeof target === 'object' && target !== null && !!target.is$SimpleButton) {
    if (target.useHandCursor === true) mouseCursor = 'button';
  }
  if (!$.eqB(this._mouseCursor, mouseCursor)) {
    this._mouseCursor = mouseCursor;
    var t1 = $._getCssStyle(mouseCursor);
    this._canvas.get$style().set$cursor(t1);
  }
  if (!$.eqNullB(this._mouseOverTarget) && !$.eqB(this._mouseOverTarget, target)) {
    var localPoint = !$.eqNullB(this._mouseOverTarget.get$stage()) ? this._mouseOverTarget.globalToLocal$1(stagePoint) : $.Point$zero$0();
    var mouseEvent = $.MouseEvent$2('mouseOut', true);
    mouseEvent._localX = localPoint.get$x();
    mouseEvent._localY = localPoint.get$y();
    mouseEvent._stageX = stagePoint.x;
    mouseEvent._stageY = stagePoint.y;
    mouseEvent._buttonDown = $.index(this._buttonState, button);
    this._mouseOverTarget.dispatchEvent$1(mouseEvent);
    this._mouseOverTarget = null;
  }
  if (!$.eqNullB(target) && !$.eqB(target, this._mouseOverTarget)) {
    localPoint = target.globalToLocal$1(stagePoint);
    mouseEvent = $.MouseEvent$2('mouseOver', true);
    mouseEvent._localX = localPoint.get$x();
    mouseEvent._localY = localPoint.get$y();
    mouseEvent._stageX = stagePoint.x;
    mouseEvent._stageY = stagePoint.y;
    mouseEvent._buttonDown = $.index(this._buttonState, button);
    this._mouseOverTarget = target;
    this._mouseOverTarget.dispatchEvent$1(mouseEvent);
  }
  var clickCount = $.index(this._clickCount, button);
  if ($.eqB(event$.get$type(), 'mousedown')) {
    var mouseEventType = $.index(this._mouseDownEventTypes, button);
    $.indexSet(this._buttonState, button, true);
    if (!$.eqB(target, $.index(this._clickTarget, button)) || $.gtB(time, $.add($.index(this._clickTime, button), 500))) clickCount = 0;
    $.indexSet(this._clickTarget, button, target);
    $.indexSet(this._clickTime, button, time);
    t1 = this._clickCount;
    clickCount = $.add(clickCount, 1);
    $.indexSet(t1, button, clickCount);
  } else mouseEventType = null;
  if ($.eqB(event$.get$type(), 'mouseup')) {
    mouseEventType = $.index(this._mouseUpEventTypes, button);
    $.indexSet(this._buttonState, button, false);
    var isClick = $.eq($.index(this._clickTarget, button), target);
    var isDoubleClick = isClick === true && $.isEven($.index(this._clickCount, button)) === true && $.ltB(time, $.add($.index(this._clickTime, button), 500));
  } else {
    isDoubleClick = false;
    isClick = false;
  }
  if ($.eqB(event$.get$type(), 'mousemove')) {
    clickCount = 0;
    mouseEventType = 'mouseMove';
  }
  if (!$.eqNullB(mouseEventType) && !$.eqNullB(target)) {
    localPoint = target.globalToLocal$1(stagePoint);
    mouseEvent = $.MouseEvent$2(mouseEventType, true);
    mouseEvent._localX = localPoint.get$x();
    mouseEvent._localY = localPoint.get$y();
    mouseEvent._stageX = stagePoint.x;
    mouseEvent._stageY = stagePoint.y;
    mouseEvent._buttonDown = $.index(this._buttonState, button);
    mouseEvent._clickCount = clickCount;
    target.dispatchEvent$1(mouseEvent);
    if (isClick === true) {
      isDoubleClick = isDoubleClick && target.get$doubleClickEnabled() === true;
      mouseEvent = $.MouseEvent$2(isDoubleClick ? $.index(this._mouseDoubleClickEventTypes, button) : $.index(this._mouseClickEventTypes, button), true);
      mouseEvent._localX = localPoint.get$x();
      mouseEvent._localY = localPoint.get$y();
      mouseEvent._stageX = stagePoint.x;
      mouseEvent._stageY = stagePoint.y;
      mouseEvent._buttonDown = $.index(this._buttonState, button);
      target.dispatchEvent$1(mouseEvent);
    }
  }
 },
 get$_onMouseEvent: function() { return new $.Closure28(this, '_onMouseEvent$1'); },
 _onMouseCursorChanged$1: function(event$) {
  var t1 = $._getCssStyle(this._mouseCursor);
  this._canvas.get$style().set$cursor(t1);
 },
 get$_onMouseCursorChanged: function() { return new $.Closure28(this, '_onMouseCursorChanged$1'); },
 materialize$0: function() {
  var t1 = this._renderMode;
  if (typeof t1 !== 'string') return this.materialize$0$bailout(1, t1);
  if (t1 === 'auto' || t1 === 'once') {
    this._renderState.reset$0();
    this.render$1(this._renderState);
    t1 = this._renderMode;
    if (typeof t1 !== 'string') return this.materialize$0$bailout(3, t1);
    if (t1 === 'once') this._renderMode = 'stop';
  }
 },
 materialize$0$bailout: function(state, env0) {
  switch (state) {
    case 1:
      t1 = env0;
      break;
    case 2:
      t1 = env0;
      break;
    case 3:
      t1 = env0;
      break;
  }
  switch (state) {
    case 0:
      var t1 = this._renderMode;
    case 1:
      state = 0;
    case 2:
      if (state == 2 || (state == 0 && !$.eqB(t1, 'auto'))) {
        switch (state) {
          case 0:
            t1 = this._renderMode;
          case 2:
            state = 0;
            t1 = $.eqB(t1, 'once');
        }
      } else {
        t1 = true;
      }
    case 3:
      if (state == 3 || (state == 0 && t1)) {
        switch (state) {
          case 0:
            this._renderState.reset$0();
            this.render$1(this._renderState);
            t1 = this._renderMode;
          case 3:
            state = 0;
            if ($.eqB(t1, 'once')) this._renderMode = 'stop';
        }
      }
  }
 },
 set$height: function(value) {
  this._throwStageException$0();
 },
 set$width: function(value) {
  this._throwStageException$0();
 },
 set$alpha: function(value) {
  this._throwStageException$0();
 },
 set$rotation: function(value) {
  this._throwStageException$0();
 },
 set$scaleY: function(value) {
  this._throwStageException$0();
 },
 set$scaleX: function(value) {
  this._throwStageException$0();
 },
 set$pivotY: function(value) {
  this._throwStageException$0();
 },
 set$pivotX: function(value) {
  this._throwStageException$0();
 },
 set$y: function(value) {
  this._throwStageException$0();
 },
 set$x: function(value) {
  this._throwStageException$0();
 },
 _throwStageException$0: function() {
  throw $.captureStackTrace($.ExceptionImplementation$1('Error #2071: The Stage class does not implement this property or method.'));
 },
 get$focus: function() {
  return this._focus;
 },
 focus$0: function() { return this.get$focus().$call$0(); },
 Stage$2: function(name$, canvas) {
  this._name = name$;
  this._canvas = canvas;
  this._canvas.get$style().set$outline('none');
  this._canvas.focus$0();
  this._context = canvas.get$context2d();
  this._canvasLocation = null;
  this._calculateElementLocation$1(this._canvas).then$1(new $.Closure12(this));
  this._renderState = $.RenderState$fromCanvasRenderingContext2D$1(this._context);
  this._renderMode = 'auto';
  this._mouseCursor = 'arrow';
  this._buttonState = [false, false, false];
  this._clickTarget = [null, null, null];
  this._clickTime = [0, 0, 0];
  this._clickCount = [0, 0, 0];
  this._mouseDownEventTypes = ['mouseDown', 'middleMouseDown', 'rightMouseDown'];
  this._mouseUpEventTypes = ['mouseUp', 'middleMouseUp', 'rightMouseUp'];
  this._mouseClickEventTypes = ['click', 'middleClick', 'rightClick'];
  this._mouseDoubleClickEventTypes = ['doubleClick', 'middleClick', 'rightClick'];
  this._mouseOverTarget = null;
  $.add$1(this._canvas.get$on().get$mouseDown(), this.get$_onMouseEvent());
  $.add$1(this._canvas.get$on().get$mouseUp(), this.get$_onMouseEvent());
  $.add$1(this._canvas.get$on().get$mouseMove(), this.get$_onMouseEvent());
  $.add$1(this._canvas.get$on().get$mouseOut(), this.get$_onMouseEvent());
  $.add$1(this._canvas.get$on().get$mouseWheel(), this.get$_onMouseWheel());
  $.add$1(this._canvas.get$on().get$keyDown(), this.get$_onKeyEvent());
  $.add$1(this._canvas.get$on().get$keyUp(), this.get$_onKeyEvent());
  $.add$1(this._canvas.get$on().get$keyPress(), this.get$_onTextEvent());
  $._eventDispatcher().addEventListener$2('mouseCursorChanged', this.get$_onMouseCursorChanged());
 },
 is$Stage: true
};

$$.Sprite = {"":
 ["useHandCursor", "buttonMode", "_tabChildren", "_mouseChildren", "_childrens", "tabIndex", "tabEnabled", "mouseEnabled", "doubleClickEnabled", "_tmpMatrixIdentity", "_tmpMatrix", "mask", "_lib0_parent", "_name", "_visible", "_alpha", "_transformationMatrixRefresh", "_transformationMatrixPrivate", "_rotation", "_scaleY", "_scaleX", "_pivotY", "_pivotX", "_y", "_x", "_eventListenersMap"],
 super: "DisplayObjectContainer",
 is$Sprite: true
};

$$.Bitmap = {"":
 ["clipRectangle", "smoothing", "pixelSnapping", "bitmapData", "_tmpMatrixIdentity", "_tmpMatrix", "mask", "_lib0_parent", "_name", "_visible", "_alpha", "_transformationMatrixRefresh", "_transformationMatrixPrivate", "_rotation", "_scaleY", "_scaleX", "_pivotY", "_pivotX", "_y", "_x", "_eventListenersMap"],
 super: "DisplayObject",
 render$1: function(renderState) {
  var t1 = this.bitmapData;
  if (!$.eqNullB(t1)) {
    if ($.eqNullB(this.clipRectangle)) t1.render$1(renderState);
    else t1.renderClipped$2(renderState, this.clipRectangle);
  }
 },
 hitTestInput$2: function(localX, localY) {
  if (typeof localX !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0, 0);
  if (typeof localY !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0, 0);
  var t1 = this.bitmapData;
  if (!$.eqNullB(t1) && localX >= 0 && localY >= 0) {
    var t2 = t1.get$width();
    if (typeof t2 !== 'number') return this.hitTestInput$2$bailout(2, localX, localY, t1, t2);
    t2 = localX < t2;
  } else t2 = false;
  if (t2) {
    t1 = t1.get$height();
    if (typeof t1 !== 'number') return this.hitTestInput$2$bailout(3, localY, t1, 0, 0);
    t1 = localY < t1;
  } else t1 = false;
  if (t1) return this;
  return;
 },
 hitTestInput$2$bailout: function(state, env0, env1, env2, env3) {
  switch (state) {
    case 1:
      var localX = env0;
      var localY = env1;
      break;
    case 1:
      localX = env0;
      localY = env1;
      break;
    case 2:
      localX = env0;
      localY = env1;
      t1 = env2;
      t2 = env3;
      break;
    case 3:
      localY = env0;
      t1 = env1;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 1:
      state = 0;
      var t1 = this.bitmapData;
    case 2:
      if (state == 2 || (state == 0 && (!$.eqNullB(t1) && $.geB(localX, 0) && $.geB(localY, 0)))) {
        switch (state) {
          case 0:
            var t2 = t1.get$width();
          case 2:
            state = 0;
            t2 = $.ltB(localX, t2);
        }
      } else {
        t2 = false;
      }
    case 3:
      if (state == 3 || (state == 0 && t2)) {
        switch (state) {
          case 0:
            t1 = t1.get$height();
          case 3:
            state = 0;
            t1 = $.ltB(localY, t1);
        }
      } else {
        t1 = false;
      }
      if (t1) return this;
      return;
  }
 },
 getBoundsTransformed$2: function(matrix, returnRectangle) {
  var t1 = this.bitmapData;
  if (!$.eqNullB(t1)) {
    var t2 = t1.get$width();
    if (typeof t2 !== 'number') return this.getBoundsTransformed$2$bailout(1, matrix, returnRectangle, t1, t2, 0, 0, 0, 0, 0, 0, 0);
    var width = t2;
  } else width = 0;
  if (!$.eqNullB(t1)) {
    t1 = t1.get$height();
    if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(2, matrix, returnRectangle, width, t1, 0, 0, 0, 0, 0, 0, 0);
    var height = t1;
  } else height = 0;
  var x1 = matrix.get$tx();
  if (typeof x1 !== 'number') return this.getBoundsTransformed$2$bailout(3, x1, returnRectangle, width, matrix, height, 0, 0, 0, 0, 0, 0);
  var y1 = matrix.get$ty();
  if (typeof y1 !== 'number') return this.getBoundsTransformed$2$bailout(4, x1, returnRectangle, y1, matrix, width, height, 0, 0, 0, 0, 0);
  t1 = matrix.get$a();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(5, x1, returnRectangle, y1, matrix, t1, width, height, 0, 0, 0, 0);
  t1 *= width;
  t2 = matrix.get$tx();
  if (typeof t2 !== 'number') return this.getBoundsTransformed$2$bailout(6, x1, returnRectangle, y1, matrix, t1, t2, width, height, 0, 0, 0);
  var x2 = t1 + t2;
  t2 = matrix.get$b();
  if (typeof t2 !== 'number') return this.getBoundsTransformed$2$bailout(7, x1, returnRectangle, y1, matrix, width, x2, t2, height, 0, 0, 0);
  t2 *= width;
  t1 = matrix.get$ty();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(8, x1, returnRectangle, y1, matrix, width, x2, t2, t1, height, 0, 0);
  var y2 = t2 + t1;
  t1 = matrix.get$a();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(9, x1, returnRectangle, y1, matrix, width, x2, y2, t1, height, 0, 0);
  t1 *= width;
  t2 = matrix.get$c();
  if (typeof t2 !== 'number') return this.getBoundsTransformed$2$bailout(10, x1, returnRectangle, y1, matrix, t2, width, t1, x2, y2, height, 0);
  t1 += height * t2;
  var t3 = matrix.get$tx();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(11, x1, returnRectangle, y1, matrix, width, t1, x2, t3, y2, height, 0);
  var x3 = t1 + t3;
  t3 = matrix.get$b();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(12, x1, returnRectangle, y1, matrix, width, x2, x3, t3, y2, height, 0);
  t3 *= width;
  t1 = matrix.get$d();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(13, x1, returnRectangle, y1, matrix, x2, x3, t3, t1, y2, height, 0);
  t3 += height * t1;
  var t4 = matrix.get$ty();
  if (typeof t4 !== 'number') return this.getBoundsTransformed$2$bailout(14, x1, returnRectangle, y1, t3, t4, matrix, x2, x3, y2, height, 0);
  var y3 = t3 + t4;
  t4 = matrix.get$c();
  if (typeof t4 !== 'number') return this.getBoundsTransformed$2$bailout(15, x1, returnRectangle, y1, y3, t4, matrix, x2, x3, y2, height, 0);
  t4 *= height;
  t3 = matrix.get$tx();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(16, x1, returnRectangle, y1, y3, matrix, x2, t3, t4, x3, y2, height);
  var x4 = t4 + t3;
  t3 = matrix.get$d();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(17, x1, returnRectangle, y1, y3, matrix, x2, x3, x4, t3, y2, height);
  t3 *= height;
  t4 = matrix.get$ty();
  if (typeof t4 !== 'number') return this.getBoundsTransformed$2$bailout(18, x1, returnRectangle, y1, y3, x2, x3, x4, t3, y2, t4, 0);
  var y4 = t3 + t4;
  if (x1 > x2) var left = x2;
  else left = x1;
  if (left > x3) left = x3;
  if (left > x4) left = x4;
  if (y1 > y2) var top$ = y2;
  else top$ = y1;
  if (top$ > y3) top$ = y3;
  if (top$ > y4) top$ = y4;
  if (x1 < x2) var right = x2;
  else right = x1;
  if (right < x3) right = x3;
  if (right < x4) right = x4;
  if (y1 < y2) var bottom = y2;
  else bottom = y1;
  if (bottom < y3) bottom = y3;
  if (bottom < y4) bottom = y4;
  if ($.eqNullB(returnRectangle)) returnRectangle = $.Rectangle$zero$0();
  returnRectangle.set$x(left);
  returnRectangle.set$y(top$);
  returnRectangle.set$width(right - left);
  returnRectangle.set$height(bottom - top$);
  return returnRectangle;
 },
 getBoundsTransformed$2$bailout: function(state, env0, env1, env2, env3, env4, env5, env6, env7, env8, env9, env10) {
  switch (state) {
    case 1:
      var matrix = env0;
      var returnRectangle = env1;
      t1 = env2;
      t2 = env3;
      break;
    case 2:
      matrix = env0;
      returnRectangle = env1;
      width = env2;
      t1 = env3;
      break;
    case 3:
      x1 = env0;
      returnRectangle = env1;
      width = env2;
      matrix = env3;
      height = env4;
      break;
    case 4:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      width = env4;
      height = env5;
      break;
    case 5:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      t1 = env4;
      width = env5;
      height = env6;
      break;
    case 6:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      t1 = env4;
      t2 = env5;
      width = env6;
      height = env7;
      break;
    case 7:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      width = env4;
      x2 = env5;
      t2 = env6;
      height = env7;
      break;
    case 8:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      width = env4;
      x2 = env5;
      t2 = env6;
      t1 = env7;
      height = env8;
      break;
    case 9:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      width = env4;
      x2 = env5;
      y2 = env6;
      t1 = env7;
      height = env8;
      break;
    case 10:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      t2 = env4;
      width = env5;
      t1 = env6;
      x2 = env7;
      y2 = env8;
      height = env9;
      break;
    case 11:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      width = env4;
      t1 = env5;
      x2 = env6;
      t3 = env7;
      y2 = env8;
      height = env9;
      break;
    case 12:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      width = env4;
      x2 = env5;
      x3 = env6;
      t3 = env7;
      y2 = env8;
      height = env9;
      break;
    case 13:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      matrix = env3;
      x2 = env4;
      x3 = env5;
      t3 = env6;
      t1 = env7;
      y2 = env8;
      height = env9;
      break;
    case 14:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      t3 = env3;
      t4 = env4;
      matrix = env5;
      x2 = env6;
      x3 = env7;
      y2 = env8;
      height = env9;
      break;
    case 15:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      y3 = env3;
      t4 = env4;
      matrix = env5;
      x2 = env6;
      x3 = env7;
      y2 = env8;
      height = env9;
      break;
    case 16:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      y3 = env3;
      matrix = env4;
      x2 = env5;
      t3 = env6;
      t4 = env7;
      x3 = env8;
      y2 = env9;
      height = env10;
      break;
    case 17:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      y3 = env3;
      matrix = env4;
      x2 = env5;
      x3 = env6;
      x4 = env7;
      t3 = env8;
      y2 = env9;
      height = env10;
      break;
    case 18:
      x1 = env0;
      returnRectangle = env1;
      y1 = env2;
      y3 = env3;
      x2 = env4;
      x3 = env5;
      x4 = env6;
      t3 = env7;
      y2 = env8;
      t4 = env9;
      break;
  }
  switch (state) {
    case 0:
      var t1 = this.bitmapData;
    case 1:
      if (state == 1 || (state == 0 && !$.eqNullB(t1))) {
        switch (state) {
          case 0:
            var t2 = t1.get$width();
          case 1:
            state = 0;
            var width = t2;
        }
      } else {
        width = 0;
      }
    case 2:
      if (state == 2 || (state == 0 && !$.eqNullB(t1))) {
        switch (state) {
          case 0:
            t1 = t1.get$height();
          case 2:
            state = 0;
            var height = t1;
        }
      } else {
        height = 0;
      }
      var x1 = matrix.get$tx();
    case 3:
      state = 0;
      var y1 = matrix.get$ty();
    case 4:
      state = 0;
      t1 = matrix.get$a();
    case 5:
      state = 0;
      t1 = $.mul(width, t1);
      t2 = matrix.get$tx();
    case 6:
      state = 0;
      var x2 = $.add(t1, t2);
      t2 = matrix.get$b();
    case 7:
      state = 0;
      t2 = $.mul(width, t2);
      t1 = matrix.get$ty();
    case 8:
      state = 0;
      var y2 = $.add(t2, t1);
      t1 = matrix.get$a();
    case 9:
      state = 0;
      t1 = $.mul(width, t1);
      t2 = matrix.get$c();
    case 10:
      state = 0;
      t1 = $.add(t1, $.mul(height, t2));
      var t3 = matrix.get$tx();
    case 11:
      state = 0;
      var x3 = $.add(t1, t3);
      t3 = matrix.get$b();
    case 12:
      state = 0;
      t3 = $.mul(width, t3);
      t1 = matrix.get$d();
    case 13:
      state = 0;
      t3 = $.add(t3, $.mul(height, t1));
      var t4 = matrix.get$ty();
    case 14:
      state = 0;
      var y3 = $.add(t3, t4);
      t4 = matrix.get$c();
    case 15:
      state = 0;
      t4 = $.mul(height, t4);
      t3 = matrix.get$tx();
    case 16:
      state = 0;
      var x4 = $.add(t4, t3);
      t3 = matrix.get$d();
    case 17:
      state = 0;
      t3 = $.mul(height, t3);
      t4 = matrix.get$ty();
    case 18:
      state = 0;
      var y4 = $.add(t3, t4);
      var left = $.gtB(x1, x2) ? x2 : x1;
      if ($.gtB(left, x3)) left = x3;
      if ($.gtB(left, x4)) left = x4;
      var top$ = $.gtB(y1, y2) ? y2 : y1;
      if ($.gtB(top$, y3)) top$ = y3;
      if ($.gtB(top$, y4)) top$ = y4;
      var right = $.ltB(x1, x2) ? x2 : x1;
      if ($.ltB(right, x3)) right = x3;
      if ($.ltB(right, x4)) right = x4;
      var bottom = $.ltB(y1, y2) ? y2 : y1;
      if ($.ltB(bottom, y3)) bottom = y3;
      if ($.ltB(bottom, y4)) bottom = y4;
      if ($.eqNullB(returnRectangle)) returnRectangle = $.Rectangle$zero$0();
      returnRectangle.set$x(left);
      returnRectangle.set$y(top$);
      returnRectangle.set$width($.sub(right, left));
      returnRectangle.set$height($.sub(bottom, top$));
      return returnRectangle;
  }
 },
 getBoundsTransformed$1: function(matrix) {
  return this.getBoundsTransformed$2(matrix,null)
},
 Bitmap$3: function(bitmapData, pixelSnapping, smoothing) {
  this.clipRectangle = null;
 }
};

$$.BitmapData = {"":
 ["_frameHeight", "_frameWidth", "_frameY", "_frameX", "_frameOffsetY", "_frameOffsetX", "_frameMode", "_context?", "_htmlElement", "_transparent", "_height", "_width"],
 super: "Object",
 renderClipped$2: function(renderState, clipRectangle) {
  if ($.leB(clipRectangle.get$width(), 0.0) || $.leB(clipRectangle.get$height(), 0.0)) return;
  switch (this._frameMode) {
    case 0:
      renderState.get$context().drawImage$9(this._htmlElement, clipRectangle.get$x(), clipRectangle.get$y(), clipRectangle.get$width(), clipRectangle.get$height(), clipRectangle.get$x(), clipRectangle.get$y(), clipRectangle.get$width(), clipRectangle.get$height());
      break;
    case 1:
      var fLeft = this._frameX;
      var fTop = this._frameY;
      var fRight = $.add(fLeft, this._frameWidth);
      var fBottom = $.add(fTop, this._frameHeight);
      var t1 = this._frameOffsetX;
      var cLeft = $.add($.sub(fLeft, t1), clipRectangle.get$x());
      var t2 = this._frameOffsetY;
      var cTop = $.add($.sub(fTop, t2), clipRectangle.get$y());
      var cRight = $.add(cLeft, clipRectangle.get$width());
      var cBottom = $.add(cTop, clipRectangle.get$height());
      var iLeft = $.gtB(fLeft, cLeft) ? fLeft : cLeft;
      var iTop = $.gtB(fTop, cTop) ? fTop : cTop;
      var iRight = $.ltB(fRight, cRight) ? fRight : cRight;
      var iBottom = $.ltB(fBottom, cBottom) ? fBottom : cBottom;
      var iOffsetX = $.add($.sub(t1, fLeft), iLeft);
      var iOffsetY = $.add($.sub(t2, fTop), iTop);
      var iWidth = $.sub(iRight, iLeft);
      var iHeight = $.sub(iBottom, iTop);
      $.gtB(iWidth, 0.0) && $.gtB(iHeight, 0.0) && renderState.get$context().drawImage$9(this._htmlElement, iLeft, iTop, iWidth, iHeight, iOffsetX, iOffsetY, iWidth, iHeight);
      break;
    case 2:
      fLeft = this._frameX;
      fTop = this._frameY;
      t1 = this._frameHeight;
      fRight = $.add(fLeft, t1);
      fBottom = $.add(fTop, this._frameWidth);
      t2 = this._frameOffsetY;
      cLeft = $.sub($.add($.sub($.add(fLeft, t2), clipRectangle.get$y()), t1), clipRectangle.get$height());
      var t3 = this._frameOffsetX;
      cTop = $.add($.sub(fTop, t3), clipRectangle.get$x());
      cRight = $.add(cLeft, clipRectangle.get$height());
      cBottom = $.add(cTop, clipRectangle.get$width());
      iLeft = $.gtB(fLeft, cLeft) ? fLeft : cLeft;
      iTop = $.gtB(fTop, cTop) ? fTop : cTop;
      iRight = $.ltB(fRight, cRight) ? fRight : cRight;
      iBottom = $.ltB(fBottom, cBottom) ? fBottom : cBottom;
      iOffsetX = $.add($.sub(t3, fTop), iTop);
      iOffsetY = $.sub($.add(t2, fRight), iRight);
      iWidth = $.sub(iBottom, iTop);
      iHeight = $.sub(iRight, iLeft);
      if ($.gtB(iWidth, 0.0) && $.gtB(iHeight, 0.0)) {
        renderState.get$context().transform$6(0.0, -1.0, 1.0, 0.0, iOffsetX, $.add(iOffsetY, iHeight));
        renderState.get$context().drawImage$9(this._htmlElement, iLeft, iTop, iHeight, iWidth, 0.0, 0.0, iHeight, iWidth);
      }
      break;
  }
 },
 render$1: function(renderState) {
  switch (this._frameMode) {
    case 0:
      renderState.get$context().drawImage$3(this._htmlElement, 0.0, 0.0);
      break;
    case 1:
      var t1 = renderState.get$context();
      var t2 = this._htmlElement;
      var t3 = this._frameX;
      var t4 = this._frameY;
      var t5 = this._frameWidth;
      var t6 = this._frameHeight;
      t1.drawImage$9(t2, t3, t4, t5, t6, this._frameOffsetX, this._frameOffsetY, t5, t6);
      break;
    case 2:
      t1 = renderState.get$context();
      t2 = this._frameOffsetX;
      t3 = this._frameOffsetY;
      t4 = this._frameHeight;
      t1.transform$6(0.0, -1.0, 1.0, 0.0, t2, $.add(t3, t4));
      t2 = renderState.get$context();
      t1 = this._htmlElement;
      t5 = this._frameX;
      t6 = this._frameY;
      var t7 = this._frameWidth;
      t2.drawImage$9(t1, t5, t6, t4, t7, 0.0, 0.0, t4, t7);
      break;
  }
 },
 get$height: function() {
  return this._height;
 },
 get$width: function() {
  return this._width;
 },
 BitmapData$fromImageElement$1: function(imageElement) {
  this._width = imageElement.get$naturalWidth();
  this._height = imageElement.get$naturalHeight();
  this._transparent = true;
  this._htmlElement = imageElement;
  this._frameMode = 0;
 }
};

$$.SimpleButton = {"":
 ["_currentState", "enabled", "useHandCursor", "hitTestState", "downState", "overState", "upState", "tabIndex", "tabEnabled", "mouseEnabled", "doubleClickEnabled", "_tmpMatrixIdentity", "_tmpMatrix", "mask", "_lib0_parent", "_name", "_visible", "_alpha", "_transformationMatrixRefresh", "_transformationMatrixPrivate", "_rotation", "_scaleY", "_scaleX", "_pivotY", "_pivotX", "_y", "_x", "_eventListenersMap"],
 super: "InteractiveObject",
 _onMouseEvent$1: function(mouseEvent) {
  var over = $.eqB(this.hitTestInput$2(mouseEvent.get$localX(), mouseEvent.get$localY()), this) && !$.eqB(mouseEvent.get$type(), 'mouseOut');
  var down = mouseEvent.get$buttonDown();
  this._currentState = this.upState;
  if (over && down === true) this._currentState = this.downState;
  if (over && down !== true) this._currentState = this.overState;
 },
 get$_onMouseEvent: function() { return new $.Closure28(this, '_onMouseEvent$1'); },
 render$1: function(renderState) {
  !$.eqNullB(this._currentState) && renderState.renderDisplayObject$1(this._currentState);
 },
 hitTestInput$2: function(localX, localY) {
  if (typeof localX !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0, 0, 0, 0);
  if (typeof localY !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0, 0, 0, 0);
  var t1 = this.hitTestState;
  if (!$.eqNullB(t1)) {
    var matrix = t1.get$_transformationMatrix();
    var t2 = matrix.get$tx();
    if (typeof t2 !== 'number') return this.hitTestInput$2$bailout(2, localX, localY, matrix, t1, t2, 0);
    var deltaX = localX - t2;
    t2 = matrix.get$ty();
    if (typeof t2 !== 'number') return this.hitTestInput$2$bailout(3, deltaX, localY, t2, t1, matrix, 0);
    var deltaY = localY - t2;
    t2 = matrix.get$d();
    if (typeof t2 !== 'number') return this.hitTestInput$2$bailout(4, deltaX, deltaY, t2, t1, matrix, 0);
    t2 *= deltaX;
    var t3 = matrix.get$c();
    if (typeof t3 !== 'number') return this.hitTestInput$2$bailout(5, deltaX, deltaY, t2, t3, t1, matrix);
    t2 -= t3 * deltaY;
    var t4 = matrix.get$det();
    if (typeof t4 !== 'number') return this.hitTestInput$2$bailout(6, deltaX, deltaY, t2, t4, t1, matrix);
    var childX = t2 / t4;
    t4 = matrix.get$a();
    if (typeof t4 !== 'number') return this.hitTestInput$2$bailout(7, t4, deltaX, childX, deltaY, t1, matrix);
    t4 *= deltaY;
    t2 = matrix.get$b();
    if (typeof t2 !== 'number') return this.hitTestInput$2$bailout(8, childX, deltaX, t4, t2, t1, matrix);
    t4 -= t2 * deltaX;
    var t5 = matrix.get$det();
    if (typeof t5 !== 'number') return this.hitTestInput$2$bailout(9, t5, childX, t1, t4, 0, 0);
    if (!$.eqNullB(t1.hitTestInput$2(childX, t4 / t5))) return this;
  }
  return;
 },
 hitTestInput$2$bailout: function(state, env0, env1, env2, env3, env4, env5) {
  switch (state) {
    case 1:
      var localX = env0;
      var localY = env1;
      break;
    case 1:
      localX = env0;
      localY = env1;
      break;
    case 2:
      localX = env0;
      localY = env1;
      matrix = env2;
      t1 = env3;
      t2 = env4;
      break;
    case 3:
      deltaX = env0;
      localY = env1;
      t2 = env2;
      t1 = env3;
      matrix = env4;
      break;
    case 4:
      deltaX = env0;
      deltaY = env1;
      t2 = env2;
      t1 = env3;
      matrix = env4;
      break;
    case 5:
      deltaX = env0;
      deltaY = env1;
      t2 = env2;
      t3 = env3;
      t1 = env4;
      matrix = env5;
      break;
    case 6:
      deltaX = env0;
      deltaY = env1;
      t2 = env2;
      t4 = env3;
      t1 = env4;
      matrix = env5;
      break;
    case 7:
      t4 = env0;
      deltaX = env1;
      childX = env2;
      deltaY = env3;
      t1 = env4;
      matrix = env5;
      break;
    case 8:
      childX = env0;
      deltaX = env1;
      t4 = env2;
      t2 = env3;
      t1 = env4;
      matrix = env5;
      break;
    case 9:
      t5 = env0;
      childX = env1;
      t1 = env2;
      t4 = env3;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 1:
      state = 0;
      var t1 = this.hitTestState;
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
      if (state == 2 || state == 3 || state == 4 || state == 5 || state == 6 || state == 7 || state == 8 || state == 9 || (state == 0 && !$.eqNullB(t1))) {
        switch (state) {
          case 0:
            var matrix = t1.get$_transformationMatrix();
            var t2 = matrix.get$tx();
          case 2:
            state = 0;
            var deltaX = $.sub(localX, t2);
            t2 = matrix.get$ty();
          case 3:
            state = 0;
            var deltaY = $.sub(localY, t2);
            t2 = matrix.get$d();
          case 4:
            state = 0;
            t2 = $.mul(t2, deltaX);
            var t3 = matrix.get$c();
          case 5:
            state = 0;
            t2 = $.sub(t2, $.mul(t3, deltaY));
            var t4 = matrix.get$det();
          case 6:
            state = 0;
            var childX = $.div(t2, t4);
            t4 = matrix.get$a();
          case 7:
            state = 0;
            t4 = $.mul(t4, deltaY);
            t2 = matrix.get$b();
          case 8:
            state = 0;
            t4 = $.sub(t4, $.mul(t2, deltaX));
            var t5 = matrix.get$det();
          case 9:
            state = 0;
            if (!$.eqNullB(t1.hitTestInput$2(childX, $.div(t4, t5)))) return this;
        }
      }
      return;
  }
 },
 getBoundsTransformed$2: function(matrix, returnRectangle) {
  if (!$.eqNullB(this._currentState)) {
    this._tmpMatrix.copyFromAndConcat$2(this._currentState.get$_transformationMatrix(), matrix);
    return this._currentState.getBoundsTransformed$2(this._tmpMatrix, returnRectangle);
  }
  return $.DisplayObject.prototype.getBoundsTransformed$2.call(this, matrix, returnRectangle);
 },
 getBoundsTransformed$1: function(matrix) {
  return this.getBoundsTransformed$2(matrix,null)
},
 SimpleButton$4: function(upState, overState, downState, hitTestState) {
  this.addEventListener$2('mouseOver', this.get$_onMouseEvent());
  this.addEventListener$2('mouseOut', this.get$_onMouseEvent());
  this.addEventListener$2('mouseDown', this.get$_onMouseEvent());
  this.addEventListener$2('mouseUp', this.get$_onMouseEvent());
  this._currentState = this.upState;
 },
 is$SimpleButton: true
};

$$.Mask = {"":
 ["_points", "_circle", "_rectangle", "_type"],
 super: "Object",
 render$1: function(renderState) {
  var context = renderState.get$context();
  context.beginPath$0();
  switch (this._type) {
    case 0:
      context.rect$4(this._rectangle.get$x(), this._rectangle.get$y(), this._rectangle.get$width(), this._rectangle.get$height());
      break;
    case 1:
      context.arc$6(this._circle.get$x(), this._circle.get$y(), this._circle.get$radius(), 0, 6.283185307179586, false);
      break;
    case 2:
      context.moveTo$2($.index(this._points, 0).get$x(), $.index(this._points, 0).get$y());
      for (var i = 1; $.ltB(i, $.get$length(this._points)); ++i) {
        context.lineTo$2($.index(this._points, i).get$x(), $.index(this._points, i).get$y());
      }
      break;
  }
  context.clip$0();
 },
 Mask$rectangle$4: function(x, y, width, height) {
  this._type = 0;
  this._rectangle = $.Rectangle$4(x, y, width, height);
 },
 Mask$circle$3: function(x, y, radius) {
  this._type = 1;
  this._circle = $.Circle$3(x, y, radius);
 },
 Mask$custom$1: function(points) {
  this._type = 2;
  this._points = points;
  if ($.ltB($.get$length(this._points), 3)) throw $.captureStackTrace($.IllegalArgumentException$1('A custom mask needs at least 3 points.'));
 }
};

$$.TextField = {"":
 ["_context?", "_canvas", "_canvasHeight", "_canvasWidth", "_canvasRefreshPending", "_linesMetrics", "_linesText", "_textHeight", "_textWidth", "_borderColor", "_border", "_backgroundColor", "_background", "_wordWrap", "_type", "_gridFitType", "_autoSize", "_defaultTextFormat", "_textColor", "_text", "tabIndex", "tabEnabled", "mouseEnabled", "doubleClickEnabled", "_tmpMatrixIdentity", "_tmpMatrix", "mask", "_lib0_parent", "_name", "_visible", "_alpha", "_transformationMatrixRefresh", "_transformationMatrixPrivate", "_rotation", "_scaleY", "_scaleX", "_pivotY", "_pivotX", "_y", "_x", "_eventListenersMap"],
 super: "InteractiveObject",
 _canvasRefresh$0: function() {
  if (this._canvasRefreshPending === true) {
    this._canvasRefreshPending = false;
    var canvasWidthInt = $.toInt($.ceil(this._canvasWidth));
    var canvasHeightInt = $.toInt($.ceil(this._canvasHeight));
    if ($.eqNullB(this._canvas)) {
      this._canvas = $.CanvasElement(canvasWidthInt, canvasHeightInt);
      this._context = this._canvas.get$context2d();
    }
    !$.eqB(this._canvas.get$width(), canvasWidthInt) && this._canvas.set$width(canvasWidthInt);
    !$.eqB(this._canvas.get$height(), canvasHeightInt) && this._canvas.set$height(canvasHeightInt);
    var fontStyle = $.StringBufferImpl$1('');
    fontStyle.add$1(this._defaultTextFormat.get$italic() === true ? 'italic ' : 'normal ');
    fontStyle.add$1('normal ');
    fontStyle.add$1(this._defaultTextFormat.get$bold() === true ? 'bold ' : 'normal ');
    fontStyle.add$1($.S(this._defaultTextFormat.get$size()) + 'px ');
    fontStyle.add$1($.S(this._defaultTextFormat.get$font()) + ',sans-serif');
    var t1 = fontStyle.toString$0();
    this._context.set$font(t1);
    this._context.set$textAlign('start');
    this._context.set$textBaseline('top');
    t1 = $._color2rgb(this._textColor);
    this._context.set$fillStyle(t1);
    this._processTextLines$0();
    if (this._background === true) {
      t1 = $._color2rgb(this._backgroundColor);
      this._context.set$fillStyle(t1);
      this._context.fillRect$4(0, 0, this._canvasWidth, this._canvasHeight);
    } else this._context.clearRect$4(0, 0, this._canvasWidth, this._canvasHeight);
    for (var offsetY = 0, i = 0; $.ltB(i, $.get$length(this._linesText)); ++i) {
      var metrics = $.index(this._linesMetrics, i);
      t1 = $._color2rgb(this._textColor);
      this._context.set$fillStyle(t1);
      this._context.fillText$3($.index(this._linesText, i), metrics.get$x(), offsetY);
      t1 = metrics.get$height();
      if (typeof t1 !== 'number') throw $.iae(t1);
      offsetY += t1;
    }
    if (this._border === true) {
      t1 = $._color2rgb(this._borderColor);
      this._context.set$strokeStyle(t1);
      this._context.set$lineWidth(1);
      this._context.strokeRect$4(0, 0, this._canvasWidth, this._canvasHeight);
    }
  }
 },
 _processTextLines$0: function() {
  $.clear(this._linesText);
  $.clear(this._linesMetrics);
  var t1 = this._wordWrap;
  if (t1 === false) $.add$1(this._linesText, this._text);
  else {
    var lineBuffer = $.StringBufferImpl$1('');
    for (t1 = $.iterator($.split(this._text, ' ')), line = null, previousLength = null; t1.hasNext$0() === true; ) {
      var word = t1.next$0();
      previousLength = $.get$length(lineBuffer);
      lineBuffer.add$1($.gtB(previousLength, 0) ? ' ' + $.S(word) : word);
      line = lineBuffer.toString$0();
      if ($.gtB(this._context.measureText$1(line).get$width(), this._canvasWidth)) {
        if ($.gtB(previousLength, 0)) line = $.substring$2(line, 0, previousLength);
        else word = '';
        $.add$1(this._linesText, line);
        lineBuffer.clear$0();
        lineBuffer.add$1(word);
      }
    }
    $.eqB(lineBuffer.isEmpty$0(), false) && $.add$1(this._linesText, lineBuffer.toString$0());
  }
  this._textWidth = 0;
  this._textHeight = 0;
  for (t1 = $.iterator(this._linesText); t1.hasNext$0() === true; ) {
    var t2 = t1.next$0();
    var metrics = this._context.measureText$1(t2);
    var offsetX = $.eqB(this._defaultTextFormat.get$align(), 'center') || $.eqB(this._defaultTextFormat.get$align(), 'justify') ? $.div($.sub(this._canvasWidth, metrics.get$width()), 2) : 0;
    if ($.eqB(this._defaultTextFormat.get$align(), 'right') || $.eqB(this._defaultTextFormat.get$align(), 'end')) offsetX = $.sub(this._canvasWidth, metrics.get$width());
    var textLineMetrics = $.TextLineMetrics$6(offsetX, metrics.get$width(), this._defaultTextFormat.get$size(), 0, 0, 0);
    $.add$1(this._linesMetrics, textLineMetrics);
    this._textWidth = $.max(this._textWidth, textLineMetrics.width);
    this._textHeight = $.add(this._textHeight, textLineMetrics.height);
  }
  var previousLength, line;
 },
 render$1: function(renderState) {
  this._canvasRefresh$0();
  renderState.get$_context().drawImage$3(this._canvas, 0.0, 0.0);
 },
 hitTestInput$2: function(localX, localY) {
  if (typeof localX !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0);
  if (typeof localY !== 'number') return this.hitTestInput$2$bailout(1, localX, localY, 0);
  if (localX >= 0 && localY >= 0) {
    var t1 = this._canvasWidth;
    if (typeof t1 !== 'number') return this.hitTestInput$2$bailout(2, localX, localY, t1);
    t1 = localX < t1;
  } else t1 = false;
  if (t1) {
    t1 = this._canvasHeight;
    if (typeof t1 !== 'number') return this.hitTestInput$2$bailout(3, localY, t1, 0);
    t1 = localY < t1;
  } else t1 = false;
  if (t1) return this;
  return;
 },
 hitTestInput$2$bailout: function(state, env0, env1, env2) {
  switch (state) {
    case 1:
      var localX = env0;
      var localY = env1;
      break;
    case 1:
      localX = env0;
      localY = env1;
      break;
    case 2:
      localX = env0;
      localY = env1;
      t1 = env2;
      break;
    case 3:
      localY = env0;
      t1 = env1;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 1:
      state = 0;
    case 2:
      if (state == 2 || (state == 0 && ($.geB(localX, 0) && $.geB(localY, 0)))) {
        switch (state) {
          case 0:
            var t1 = this._canvasWidth;
          case 2:
            state = 0;
            t1 = $.ltB(localX, t1);
        }
      } else {
        t1 = false;
      }
    case 3:
      if (state == 3 || (state == 0 && t1)) {
        switch (state) {
          case 0:
            t1 = this._canvasHeight;
          case 3:
            state = 0;
            t1 = $.ltB(localY, t1);
        }
      } else {
        t1 = false;
      }
      if (t1) return this;
      return;
  }
 },
 getBoundsTransformed$2: function(matrix, returnRectangle) {
  var width = this._canvasWidth;
  if (typeof width !== 'number') return this.getBoundsTransformed$2$bailout(1, matrix, returnRectangle, width, 0, 0, 0, 0, 0, 0, 0, 0);
  var height = this._canvasHeight;
  if (typeof height !== 'number') return this.getBoundsTransformed$2$bailout(2, matrix, returnRectangle, width, height, 0, 0, 0, 0, 0, 0, 0);
  var x1 = matrix.get$tx();
  if (typeof x1 !== 'number') return this.getBoundsTransformed$2$bailout(3, matrix, returnRectangle, width, height, x1, 0, 0, 0, 0, 0, 0);
  var y1 = matrix.get$ty();
  if (typeof y1 !== 'number') return this.getBoundsTransformed$2$bailout(4, matrix, returnRectangle, x1, y1, width, height, 0, 0, 0, 0, 0);
  var t1 = matrix.get$a();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(5, matrix, returnRectangle, x1, y1, t1, width, height, 0, 0, 0, 0);
  t1 *= width;
  var t2 = matrix.get$tx();
  if (typeof t2 !== 'number') return this.getBoundsTransformed$2$bailout(6, matrix, returnRectangle, x1, y1, width, t1, t2, height, 0, 0, 0);
  var x2 = t1 + t2;
  t2 = matrix.get$b();
  if (typeof t2 !== 'number') return this.getBoundsTransformed$2$bailout(7, matrix, returnRectangle, x1, y1, width, height, x2, t2, 0, 0, 0);
  t2 *= width;
  t1 = matrix.get$ty();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(8, matrix, returnRectangle, t1, t2, x1, y1, width, height, x2, 0, 0);
  var y2 = t2 + t1;
  t1 = matrix.get$a();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(9, matrix, returnRectangle, y2, t1, x1, y1, width, height, x2, 0, 0);
  t1 *= width;
  t2 = matrix.get$c();
  if (typeof t2 !== 'number') return this.getBoundsTransformed$2$bailout(10, matrix, returnRectangle, y2, x1, y1, t2, t1, width, height, x2, 0);
  t1 += height * t2;
  var t3 = matrix.get$tx();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(11, matrix, returnRectangle, y2, x1, y1, width, height, t1, t3, x2, 0);
  var x3 = t1 + t3;
  t3 = matrix.get$b();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(12, matrix, returnRectangle, y2, x1, y1, width, height, x2, x3, t3, 0);
  t3 *= width;
  t1 = matrix.get$d();
  if (typeof t1 !== 'number') return this.getBoundsTransformed$2$bailout(13, matrix, returnRectangle, t3, t1, y2, x1, y1, height, x2, x3, 0);
  t3 += height * t1;
  var t4 = matrix.get$ty();
  if (typeof t4 !== 'number') return this.getBoundsTransformed$2$bailout(14, matrix, returnRectangle, y2, x1, t4, y1, t3, height, x2, x3, 0);
  var y3 = t3 + t4;
  t4 = matrix.get$c();
  if (typeof t4 !== 'number') return this.getBoundsTransformed$2$bailout(15, matrix, returnRectangle, y2, x1, y1, y3, t4, height, x2, x3, 0);
  t4 *= height;
  t3 = matrix.get$tx();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(16, matrix, returnRectangle, y2, x1, y1, y3, height, t4, x2, t3, x3);
  var x4 = t4 + t3;
  t3 = matrix.get$d();
  if (typeof t3 !== 'number') return this.getBoundsTransformed$2$bailout(17, matrix, returnRectangle, t3, y2, x1, y1, y3, height, x2, x3, x4);
  t3 *= height;
  t4 = matrix.get$ty();
  if (typeof t4 !== 'number') return this.getBoundsTransformed$2$bailout(18, returnRectangle, t3, y2, t4, x1, y1, y3, x2, x3, x4, 0);
  var y4 = t3 + t4;
  if (x1 > x2) var left = x2;
  else left = x1;
  if (left > x3) left = x3;
  if (left > x4) left = x4;
  if (y1 > y2) var top$ = y2;
  else top$ = y1;
  if (top$ > y3) top$ = y3;
  if (top$ > y4) top$ = y4;
  if (x1 < x2) var right = x2;
  else right = x1;
  if (right < x3) right = x3;
  if (right < x4) right = x4;
  if (y1 < y2) var bottom = y2;
  else bottom = y1;
  if (bottom < y3) bottom = y3;
  if (bottom < y4) bottom = y4;
  if ($.eqNullB(returnRectangle)) returnRectangle = $.Rectangle$zero$0();
  returnRectangle.set$x(left);
  returnRectangle.set$y(top$);
  returnRectangle.set$width(right - left);
  returnRectangle.set$height(bottom - top$);
  return returnRectangle;
 },
 getBoundsTransformed$2$bailout: function(state, env0, env1, env2, env3, env4, env5, env6, env7, env8, env9, env10) {
  switch (state) {
    case 1:
      var matrix = env0;
      var returnRectangle = env1;
      width = env2;
      break;
    case 2:
      matrix = env0;
      returnRectangle = env1;
      width = env2;
      height = env3;
      break;
    case 3:
      matrix = env0;
      returnRectangle = env1;
      width = env2;
      height = env3;
      x1 = env4;
      break;
    case 4:
      matrix = env0;
      returnRectangle = env1;
      x1 = env2;
      y1 = env3;
      width = env4;
      height = env5;
      break;
    case 5:
      matrix = env0;
      returnRectangle = env1;
      x1 = env2;
      y1 = env3;
      t1 = env4;
      width = env5;
      height = env6;
      break;
    case 6:
      matrix = env0;
      returnRectangle = env1;
      x1 = env2;
      y1 = env3;
      width = env4;
      t1 = env5;
      t2 = env6;
      height = env7;
      break;
    case 7:
      matrix = env0;
      returnRectangle = env1;
      x1 = env2;
      y1 = env3;
      width = env4;
      height = env5;
      x2 = env6;
      t2 = env7;
      break;
    case 8:
      matrix = env0;
      returnRectangle = env1;
      t1 = env2;
      t2 = env3;
      x1 = env4;
      y1 = env5;
      width = env6;
      height = env7;
      x2 = env8;
      break;
    case 9:
      matrix = env0;
      returnRectangle = env1;
      y2 = env2;
      t1 = env3;
      x1 = env4;
      y1 = env5;
      width = env6;
      height = env7;
      x2 = env8;
      break;
    case 10:
      matrix = env0;
      returnRectangle = env1;
      y2 = env2;
      x1 = env3;
      y1 = env4;
      t2 = env5;
      t1 = env6;
      width = env7;
      height = env8;
      x2 = env9;
      break;
    case 11:
      matrix = env0;
      returnRectangle = env1;
      y2 = env2;
      x1 = env3;
      y1 = env4;
      width = env5;
      height = env6;
      t1 = env7;
      t3 = env8;
      x2 = env9;
      break;
    case 12:
      matrix = env0;
      returnRectangle = env1;
      y2 = env2;
      x1 = env3;
      y1 = env4;
      width = env5;
      height = env6;
      x2 = env7;
      x3 = env8;
      t3 = env9;
      break;
    case 13:
      matrix = env0;
      returnRectangle = env1;
      t3 = env2;
      t1 = env3;
      y2 = env4;
      x1 = env5;
      y1 = env6;
      height = env7;
      x2 = env8;
      x3 = env9;
      break;
    case 14:
      matrix = env0;
      returnRectangle = env1;
      y2 = env2;
      x1 = env3;
      t4 = env4;
      y1 = env5;
      t3 = env6;
      height = env7;
      x2 = env8;
      x3 = env9;
      break;
    case 15:
      matrix = env0;
      returnRectangle = env1;
      y2 = env2;
      x1 = env3;
      y1 = env4;
      y3 = env5;
      t4 = env6;
      height = env7;
      x2 = env8;
      x3 = env9;
      break;
    case 16:
      matrix = env0;
      returnRectangle = env1;
      y2 = env2;
      x1 = env3;
      y1 = env4;
      y3 = env5;
      height = env6;
      t4 = env7;
      x2 = env8;
      t3 = env9;
      x3 = env10;
      break;
    case 17:
      matrix = env0;
      returnRectangle = env1;
      t3 = env2;
      y2 = env3;
      x1 = env4;
      y1 = env5;
      y3 = env6;
      height = env7;
      x2 = env8;
      x3 = env9;
      x4 = env10;
      break;
    case 18:
      returnRectangle = env0;
      t3 = env1;
      y2 = env2;
      t4 = env3;
      x1 = env4;
      y1 = env5;
      y3 = env6;
      x2 = env7;
      x3 = env8;
      x4 = env9;
      break;
  }
  switch (state) {
    case 0:
      var width = this._canvasWidth;
    case 1:
      state = 0;
      var height = this._canvasHeight;
    case 2:
      state = 0;
      var x1 = matrix.get$tx();
    case 3:
      state = 0;
      var y1 = matrix.get$ty();
    case 4:
      state = 0;
      var t1 = matrix.get$a();
    case 5:
      state = 0;
      t1 = $.mul(width, t1);
      var t2 = matrix.get$tx();
    case 6:
      state = 0;
      var x2 = $.add(t1, t2);
      t2 = matrix.get$b();
    case 7:
      state = 0;
      t2 = $.mul(width, t2);
      t1 = matrix.get$ty();
    case 8:
      state = 0;
      var y2 = $.add(t2, t1);
      t1 = matrix.get$a();
    case 9:
      state = 0;
      t1 = $.mul(width, t1);
      t2 = matrix.get$c();
    case 10:
      state = 0;
      t1 = $.add(t1, $.mul(height, t2));
      var t3 = matrix.get$tx();
    case 11:
      state = 0;
      var x3 = $.add(t1, t3);
      t3 = matrix.get$b();
    case 12:
      state = 0;
      t3 = $.mul(width, t3);
      t1 = matrix.get$d();
    case 13:
      state = 0;
      t3 = $.add(t3, $.mul(height, t1));
      var t4 = matrix.get$ty();
    case 14:
      state = 0;
      var y3 = $.add(t3, t4);
      t4 = matrix.get$c();
    case 15:
      state = 0;
      t4 = $.mul(height, t4);
      t3 = matrix.get$tx();
    case 16:
      state = 0;
      var x4 = $.add(t4, t3);
      t3 = matrix.get$d();
    case 17:
      state = 0;
      t3 = $.mul(height, t3);
      t4 = matrix.get$ty();
    case 18:
      state = 0;
      var y4 = $.add(t3, t4);
      var left = $.gtB(x1, x2) ? x2 : x1;
      if ($.gtB(left, x3)) left = x3;
      if ($.gtB(left, x4)) left = x4;
      var top$ = $.gtB(y1, y2) ? y2 : y1;
      if ($.gtB(top$, y3)) top$ = y3;
      if ($.gtB(top$, y4)) top$ = y4;
      var right = $.ltB(x1, x2) ? x2 : x1;
      if ($.ltB(right, x3)) right = x3;
      if ($.ltB(right, x4)) right = x4;
      var bottom = $.ltB(y1, y2) ? y2 : y1;
      if ($.ltB(bottom, y3)) bottom = y3;
      if ($.ltB(bottom, y4)) bottom = y4;
      if ($.eqNullB(returnRectangle)) returnRectangle = $.Rectangle$zero$0();
      returnRectangle.set$x(left);
      returnRectangle.set$y(top$);
      returnRectangle.set$width($.sub(right, left));
      returnRectangle.set$height($.sub(bottom, top$));
      return returnRectangle;
  }
 },
 getBoundsTransformed$1: function(matrix) {
  return this.getBoundsTransformed$2(matrix,null)
},
 set$height: function(value) {
  this._canvasHeight = value;
  this._canvasRefreshPending = true;
 },
 set$width: function(value) {
  this._canvasWidth = value;
  this._canvasRefreshPending = true;
 },
 set$defaultTextFormat: function(value) {
  this._defaultTextFormat = value;
  this._textColor = this._defaultTextFormat.get$color();
  this._canvasRefreshPending = true;
 },
 set$text: function(value) {
  this._text = value;
  this._canvasRefreshPending = true;
 },
 get$height: function() {
  return this._canvasHeight;
 },
 get$width: function() {
  return this._canvasWidth;
 },
 get$type: function() {
  return this._type;
 },
 TextField$0: function() {
  this._defaultTextFormat = $.TextFormat$13(null, 12, 0, false, false, false, null, null, 'left', 0, 0, 0, 0);
  var t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'String'}));
  this._linesText = t1;
  t1 = $.List(null);
  $.setRuntimeTypeInfo(t1, ({E: 'TextLineMetrics'}));
  this._linesMetrics = t1;
 }
};

$$.TextFormat = {"":
 ["kerning", "bullet", "blockIndent", "letterSpacing", "leading", "indent", "rightMargin", "leftMargin", "align?", "target", "url", "underline", "italic?", "bold?", "color?", "size?", "font="],
 super: "Object"
};

$$.TextLineMetrics = {"":
 ["x=", "width=", "leading", "height=", "descent", "ascent"],
 super: "Object"
};

$$.Resource = {"":
 ["_loaderErrorCount=", "_loaderPendingCount=", "_loader", "_texts", "_textureAtlases", "_sounds", "_images?"],
 super: "Object",
 _loaderCheck$0: function() {
  if (!$.eqNullB(this._loader) && $.eqB(this._loaderPendingCount, 0)) {
    var t1 = $.eqB(this._loaderErrorCount, 0);
    var t2 = this._loader;
    if (t1) t2.complete$1(this);
    else t2.completeException$1(this);
  }
 },
 getBitmapData$1: function(name$) {
  var t1 = this._images.containsKey$1(name$);
  if (typeof t1 !== 'boolean') return this.getBitmapData$1$bailout(1, name$, t1);
  if (!t1) throw $.captureStackTrace('Resource not found: \'' + $.S(name$) + '\'');
  t1 = this._images;
  if (typeof t1 !== 'string' && (typeof t1 !== 'object' || t1 === null || (t1.constructor !== Array && !t1.is$JavaScriptIndexingBehavior()))) return this.getBitmapData$1$bailout(2, t1, name$);
  if (name$ !== (name$ | 0)) throw $.iae(name$);
  var t2 = t1.length;
  if (name$ < 0 || name$ >= t2) throw $.ioore(name$);
  return t1[name$];
 },
 getBitmapData$1$bailout: function(state, env0, env1) {
  switch (state) {
    case 1:
      var name$ = env0;
      t1 = env1;
      break;
    case 2:
      t1 = env0;
      name$ = env1;
      break;
  }
  switch (state) {
    case 0:
      var t1 = this._images.containsKey$1(name$);
    case 1:
      state = 0;
      if ($.eqB(t1, false)) throw $.captureStackTrace('Resource not found: \'' + $.S(name$) + '\'');
      t1 = this._images;
    case 2:
      state = 0;
      return $.index(t1, name$);
  }
 },
 load$0: function() {
  var t1 = $.CompleterImpl$0();
  $.setRuntimeTypeInfo(t1, ({T: 'Resource'}));
  this._loader = t1;
  this._loaderCheck$0();
  return this._loader.get$future();
 },
 get$load: function() { return new $.Closure29(this, 'load$0'); },
 addImage$2: function(name$, url) {
  var t1 = ({});
  t1.name_1 = name$;
  var future = $.loadImage(url);
  this._loaderPendingCount = $.add(this._loaderPendingCount, 1);
  future.then$1(new $.Closure1(this, t1));
  future.handleException$1(new $.Closure2(this));
 },
 Resource$0: function() {
  this._images = $.HashMapImplementation$0();
  this._sounds = $.HashMapImplementation$0();
  this._textureAtlases = $.HashMapImplementation$0();
  this._texts = $.HashMapImplementation$0();
  this._loader = null;
  this._loaderPendingCount = 0;
  this._loaderErrorCount = 0;
 }
};

$$.Closure = {"":
 ["box_2"],
 super: "Closure26",
 $call$1: function(result) {
  var t1 = ({});
  t1.animation_1 = $.getAnimation();
  t1.animation_1.set$pivotX(400);
  t1.animation_1.set$pivotY(350);
  t1.animation_1.set$x(400);
  t1.animation_1.set$y(350);
  this.box_2.stage_3.addChild$1(t1.animation_1);
  var buttons = [$.getButton('None', new $.Closure18(t1)), $.getButton('Rectangle', new $.Closure19(t1, this.box_2)), $.getButton('Circle', new $.Closure20(t1, this.box_2)), $.getButton('Custom', new $.Closure21(t1, this.box_2)), $.getButton('spin', new $.Closure22(t1))];
  for (var b = 0; t1 = buttons.length, b < t1; ++b) {
    if (b < 0 || b >= t1) throw $.ioore(b);
    var t2 = buttons[b];
    this.box_2.stage_3.addChild$1(t2);
    t2.set$x(b < 4 ? 10 + b * 130 : 645);
    t2.set$y(10);
    t2.set$scaleX(0.5);
    t2.set$scaleY(0.5);
  }
 }
};

$$.Closure18 = {"":
 ["box_0"],
 super: "Closure26",
 $call$0: function() {
  this.box_0.animation_1.set$mask(null);
  return;
 }
};

$$.Closure19 = {"":
 ["box_0", "box_2"],
 super: "Closure26",
 $call$0: function() {
  var t1 = this.box_2.rectangleMask_4;
  this.box_0.animation_1.set$mask(t1);
  return t1;
 }
};

$$.Closure20 = {"":
 ["box_0", "box_2"],
 super: "Closure26",
 $call$0: function() {
  var t1 = this.box_2.circleMask_5;
  this.box_0.animation_1.set$mask(t1);
  return t1;
 }
};

$$.Closure21 = {"":
 ["box_0", "box_2"],
 super: "Closure26",
 $call$0: function() {
  var t1 = this.box_2.customMask_6;
  this.box_0.animation_1.set$mask(t1);
  return t1;
 }
};

$$.Closure22 = {"":
 ["box_0"],
 super: "Closure26",
 $call$0: function() {
  var rotate = $.Tween$3(this.box_0.animation_1, 2.0, $.easeInOutBack);
  rotate.animate$2('rotation', 12.566370614359172);
  rotate.set$onComplete(new $.Closure24(this.box_0));
  $.add$1($.instance(), rotate);
 }
};

$$.Closure24 = {"":
 ["box_0"],
 super: "Closure26",
 $call$0: function() {
  this.box_0.animation_1.set$rotation(0.0);
  return 0.0;
 }
};

$$.Closure0 = {"":
 ["box_0"],
 super: "Closure26",
 $call$2: function(k, v) {
  var t1 = this.box_0;
  t1.first_3 !== true && $.add$1(t1.result_1, ', ');
  this.box_0.first_3 = false;
  t1 = this.box_0;
  $._emitObject(k, t1.result_1, t1.visiting_2);
  $.add$1(this.box_0.result_1, ': ');
  var t2 = this.box_0;
  $._emitObject(v, t2.result_1, t2.visiting_2);
 }
};

$$.Closure1 = {"":
 ["this_2", "box_0"],
 super: "Closure26",
 $call$1: function(bitmapData) {
  $.indexSet(this.this_2.get$_images(), this.box_0.name_1, bitmapData);
  var t1 = this.this_2;
  t1.set$_loaderPendingCount($.sub(t1.get$_loaderPendingCount(), 1));
  this.this_2._loaderCheck$0();
 }
};

$$.Closure2 = {"":
 ["this_3"],
 super: "Closure26",
 $call$1: function(e) {
  var t1 = this.this_3;
  t1.set$_loaderErrorCount($.add(t1.get$_loaderErrorCount(), 1));
  t1 = this.this_3;
  t1.set$_loaderPendingCount($.sub(t1.get$_loaderPendingCount(), 1));
  this.this_3._loaderCheck$0();
 }
};

$$.Closure3 = {"":
 ["box_0"],
 super: "Closure26",
 $call$1: function(event$) {
  var t1 = this.box_0;
  return t1.completer_1.complete$1($.BitmapData$fromImageElement$1(t1.image_2));
 }
};

$$.Closure4 = {"":
 ["box_0"],
 super: "Closure26",
 $call$1: function(event$) {
  return this.box_0.completer_1.completeException$1('Failed to load image.');
 }
};

$$.Closure5 = {"":
 ["box_0"],
 super: "Closure26",
 $call$0: function() {
  return this.box_0.closure_1.$call$0();
 }
};

$$.Closure6 = {"":
 ["box_0"],
 super: "Closure26",
 $call$0: function() {
  var t1 = this.box_0;
  return t1.closure_1.$call$1(t1.arg1_2);
 }
};

$$.Closure7 = {"":
 ["box_0"],
 super: "Closure26",
 $call$0: function() {
  var t1 = this.box_0;
  return t1.closure_1.$call$2(t1.arg1_2, t1.arg2_3);
 }
};

$$.Closure8 = {"":
 ["this_0"],
 super: "Closure26",
 $call$0: function() {
  this.this_0._onAnimationFrame$1(null);
 }
};

$$.Closure9 = {"":
 [],
 super: "Closure26",
 $call$1: function(n) {
  var absN = $.abs(n);
  var sign = $.ltB(n, 0) ? '-' : '';
  if ($.geB(absN, 1000)) return $.S(n);
  if ($.geB(absN, 100)) return sign + '0' + $.S(absN);
  if ($.geB(absN, 10)) return sign + '00' + $.S(absN);
  if ($.geB(absN, 1)) return sign + '000' + $.S(absN);
  throw $.captureStackTrace($.IllegalArgumentException$1(n));
 }
};

$$.Closure10 = {"":
 [],
 super: "Closure26",
 $call$1: function(n) {
  if ($.geB(n, 100)) return $.S(n);
  if ($.geB(n, 10)) return '0' + $.S(n);
  return '00' + $.S(n);
 }
};

$$.Closure11 = {"":
 [],
 super: "Closure26",
 $call$1: function(n) {
  if ($.geB(n, 10)) return $.S(n);
  return '0' + $.S(n);
 }
};

$$.Closure12 = {"":
 ["this_0"],
 super: "Closure26",
 $call$1: function(point) {
  this.this_0.set$_canvasLocation(point);
  return point;
 }
};

$$.Closure13 = {"":
 ["this_0"],
 super: "Closure26",
 $call$0: function() {
  return $._ElementRectImpl$1(this.this_0);
 }
};

$$.Closure14 = {"":
 [],
 super: "Closure26",
 $call$1: function(e) {
  return $._completeMeasurementFutures();
 }
};

$$.Closure15 = {"":
 [],
 super: "Closure26",
 $call$0: function() {
  return $.CTC4;
 }
};

$$.Closure16 = {"":
 ["this_5", "box_2"],
 super: "Closure26",
 $call$1: function(rect) {
  var t1 = ({});
  t1.point_1 = $.Point$2(rect.get$offset().get$left(), rect.get$offset().get$top());
  var t2 = !$.eqNullB(this.box_2.element_3.get$offsetParent());
  var t3 = this.box_2;
  if (t2) this.this_5._calculateElementLocation$1(t3.element_3.get$offsetParent()).then$1(new $.Closure17(t1, this.box_2));
  else t3.completer_4.complete$1(t1.point_1);
 }
};

$$.Closure17 = {"":
 ["box_0", "box_2"],
 super: "Closure26",
 $call$1: function(p) {
  return this.box_2.completer_4.complete$1($.add$1(this.box_0.point_1, p));
 }
};

$$.Closure23 = {"":
 ["box_0"],
 super: "Closure26",
 $call$1: function(me) {
  return this.box_0.clickHandler_1.$call$0();
 }
};

$$.Closure25 = {"":
 ["box_0"],
 super: "Closure26",
 $call$2: function(key, value) {
  this.box_0.f_1.$call$1(key);
 }
};

$$.Closure26 = {"":
 [],
 super: "Object",
 toString$0: function() {
  return 'Closure';
 }
};

Isolate.$defineClass('Closure27', 'Closure26', ['self', 'target'], {
$call$4: function(p0, p1, p2, p3) { return this.self[this.target](p0, p1, p2, p3); }
});
Isolate.$defineClass('Closure28', 'Closure26', ['self', 'target'], {
$call$1: function(p0) { return this.self[this.target](p0); }
});
Isolate.$defineClass('Closure29', 'Closure26', ['self', 'target'], {
$call$0: function() { return this.self[this.target](); }
});
Isolate.$defineClass('Closure30', 'Closure26', ['self', 'target'], {
$call$2: function(p0, p1) { return this.self[this.target](p0, p1); }
});
$.mul$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a * b;
  return a.operator$mul$1(b);
};

$._AudioContextEventsImpl$1 = function(_ptr) {
  return new $._AudioContextEventsImpl(_ptr);
};

$.floor = function(receiver) {
  if (!(typeof receiver === 'number')) return receiver.floor$0();
  return Math.floor(receiver);
};

$.eqB = function(a, b) {
  if (a == null) return b == null;
  if (typeof a === "object") {
    if (!!a.operator$eq$1) {
      var t1 = a.operator$eq$1(b);
      return t1 === true;
    }
    return a === b;
  }
  return a === b;
};

$._completeMeasurementFutures = function() {
  if ($.eqB($._nextMeasurementFrameScheduled, false)) return;
  $._nextMeasurementFrameScheduled = false;
  var t1 = $._pendingRequests;
  if (!(t1 == null)) {
    for (t1 = $.iterator($._pendingRequests); t1.hasNext$0() === true; ) {
      var request = t1.next$0();
      try {
        var t2 = request.computeValue$0();
        request.set$value(t2);
      } catch (exception) {
        t2 = $.unwrapException(exception);
        var e = t2;
        t2 = e;
        request.set$value(t2);
        request.set$exception(true);
      }
    }
  }
  var completedRequests = $._pendingRequests;
  var readyMeasurementFrameCallbacks = $._pendingMeasurementFrameCallbacks;
  $._pendingRequests = null;
  $._pendingMeasurementFrameCallbacks = null;
  if (!(completedRequests == null)) {
    for (t1 = $.iterator(completedRequests); t1.hasNext$0() === true; ) {
      t2 = t1.next$0();
      if (t2.get$exception() === true) t2.get$completer().completeException$1(t2.get$value());
      else t2.get$completer().complete$1(t2.get$value());
    }
  }
  if (!(readyMeasurementFrameCallbacks == null)) {
    for (t1 = $.iterator(readyMeasurementFrameCallbacks); t1.hasNext$0() === true; ) {
      t1.next$0().$call$0();
    }
  }
};

$._containsRef = function(c, ref) {
  for (var t1 = $.iterator(c); t1.hasNext$0() === true; ) {
    var t2 = t1.next$0();
    if (t2 == null ? ref == null : t2 === ref) return true;
  }
  return false;
};

$.Rectangle$zero$0 = function() {
  return new $.Rectangle(0, 0, 0, 0);
};

$.isJsArray = function(value) {
  return !(value == null) && (value.constructor === Array);
};

$.indexSet$slow = function(a, index, value) {
  if ($.isJsArray(a) === true) {
    if (!((typeof index === 'number') && (index === (index | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(index));
    if (index < 0 || $.geB(index, $.get$length(a))) throw $.captureStackTrace($.IndexOutOfRangeException$1(index));
    $.checkMutable(a, 'indexed set');
    a[index] = value;
    return;
  }
  a.operator$indexSet$2(index, value);
};

$._nextProbe = function(currentProbe, numberOfProbes, length$) {
  return $.and($.add(currentProbe, numberOfProbes), $.sub(length$, 1));
};

$.allMatches = function(receiver, str) {
  if (!(typeof receiver === 'string')) return receiver.allMatches$1(str);
  $.checkString(str);
  return $.allMatchesInStringUnchecked(receiver, str);
};

$.CanvasElement = function(width, height) {
  var _e = $._document().$dom_createElement$1('canvas');
  !$.eqNullB(width) && _e.set$width(width);
  !$.eqNullB(height) && _e.set$height(height);
  return _e;
};

$.substringUnchecked = function(receiver, startIndex, endIndex) {
  return receiver.substring(startIndex, endIndex);
};

$.TextLineMetrics$6 = function(x, width, height, ascent, descent, leading) {
  return new $.TextLineMetrics(x, width, leading, height, descent, ascent);
};

$.DateImplementation$now$0 = function() {
  var t1 = new $.DateImplementation(false, $.dateNow());
  t1.DateImplementation$now$0();
  return t1;
};

$.get$length = function(receiver) {
  if (typeof receiver === 'string' || $.isJsArray(receiver) === true) return receiver.length;
  return receiver.get$length();
};

$.ge$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a >= b;
  return a.operator$ge$1(b);
};

$.Matrix$identity$0 = function() {
  return new $.Matrix(1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0);
};

$.IllegalJSRegExpException$2 = function(_pattern, _errmsg) {
  return new $.IllegalJSRegExpException(_errmsg, _pattern);
};

$._EventListener$2 = function(listener, useCapture) {
  return new $._EventListener(useCapture, listener);
};

$._IDBOpenDBRequestEventsImpl$1 = function(_ptr) {
  return new $._IDBOpenDBRequestEventsImpl(_ptr);
};

$.Point$zero$0 = function() {
  return new $.Point(0, 0);
};

$.TextFormat$13 = function(font, size, color, bold, italic, underline, url, target, align, leftMargin, rightMargin, indent, leading) {
  return new $.TextFormat(false, false, 0, 0, leading, indent, rightMargin, leftMargin, align, target, url, underline, italic, bold, color, size, font);
};

$.constructorNameFallback = function(obj) {
  var constructor$ = (obj.constructor);
  var t1 = (typeof(constructor$));
  if (t1 === 'function') {
    var name$ = (constructor$.name);
    t1 = (typeof(name$));
    if (t1 === 'string' && $.isEmpty(name$) !== true && !(name$ === 'Object')) return name$;
  }
  var string = (Object.prototype.toString.call(obj));
  return $.substring$2(string, 8, string.length - 1);
};

$.regExpMatchStart = function(m) {
  return m.index;
};

$.clear = function(receiver) {
  if ($.isJsArray(receiver) !== true) return receiver.clear$0();
  $.set$length(receiver, 0);
};

$.NullPointerException$2 = function(functionName, arguments$) {
  return new $.NullPointerException(arguments$, functionName);
};

$.max = function(a, b) {
  return $.ltB($.compareTo(a, b), 0) ? b : a;
};

$.tdiv = function(a, b) {
  if ($.checkNumbers(a, b) === true) return $.truncate((a) / (b));
  return a.operator$tdiv$1(b);
};

$.JSSyntaxRegExp$_globalVersionOf$1 = function(other) {
  var t1 = other.get$pattern();
  var t2 = other.get$multiLine();
  t1 = new $.JSSyntaxRegExp(other.get$ignoreCase(), t2, t1);
  t1.JSSyntaxRegExp$_globalVersionOf$1(other);
  return t1;
};

$.typeNameInIE = function(obj) {
  var name$ = $.constructorNameFallback(obj);
  if ($.eqB(name$, 'Window')) return 'DOMWindow';
  if ($.eqB(name$, 'Document')) {
    if (!!obj.xmlVersion) return 'Document';
    return 'HTMLDocument';
  }
  if ($.eqB(name$, 'HTMLTableDataCellElement')) return 'HTMLTableCellElement';
  if ($.eqB(name$, 'HTMLTableHeaderCellElement')) return 'HTMLTableCellElement';
  if ($.eqB(name$, 'MSStyleCSSProperties')) return 'CSSStyleDeclaration';
  if ($.eqB(name$, 'CanvasPixelArray')) return 'Uint8ClampedArray';
  if ($.eqB(name$, 'HTMLPhraseElement')) return 'HTMLElement';
  if ($.eqB(name$, 'MouseWheelEvent')) return 'WheelEvent';
  return name$;
};

$.removeRange = function(receiver, start, length$) {
  if ($.isJsArray(receiver) !== true) return receiver.removeRange$2(start, length$);
  $.checkGrowable(receiver, 'removeRange');
  if ($.eqB(length$, 0)) return;
  $.checkNull(start);
  $.checkNull(length$);
  if (!((typeof start === 'number') && (start === (start | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(start));
  if (!((typeof length$ === 'number') && (length$ === (length$ | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(length$));
  if (length$ < 0) throw $.captureStackTrace($.IllegalArgumentException$1(length$));
  var receiverLength = (receiver.length);
  if (start < 0 || start >= receiverLength) throw $.captureStackTrace($.IndexOutOfRangeException$1(start));
  var t1 = start + length$;
  if (t1 > receiverLength) throw $.captureStackTrace($.IndexOutOfRangeException$1(t1));
  t1 = $.add(start, length$);
  if (typeof length$ !== 'number') throw $.iae(length$);
  var t2 = receiverLength - length$;
  if (typeof start !== 'number') throw $.iae(start);
  $.copy(receiver, t1, receiver, start, t2 - start);
  $.set$length(receiver, t2);
};

$._eventDispatcher = function() {
  if ($.eqNullB($.__eventDispatcher)) $.__eventDispatcher = $.EventDispatcher$0();
  return $.__eventDispatcher;
};

$.MouseEvent$2 = function(type, bubbles) {
  var t1 = new $.MouseEvent(null, false, 0, 0, false, false, false, false, false, 0, 0, 0, 0, false, false, null, null, null, null, null);
  t1.Event$2(type, bubbles);
  return t1;
};

$.typeNameInChrome = function(obj) {
  var name$ = (obj.constructor.name);
  if (name$ === 'Window') return 'DOMWindow';
  if (name$ === 'CanvasPixelArray') return 'Uint8ClampedArray';
  return name$;
};

$.sqrt = function(x) {
  return $.sqrt0(x);
};

$.sqrt0 = function(value) {
  return Math.sqrt($.checkNum(value));
};

$.BitmapData$fromImageElement$1 = function(imageElement) {
  var t1 = new $.BitmapData(null, null, null, null, null, null, null, null, null, null, null, null);
  t1.BitmapData$fromImageElement$1(imageElement);
  return t1;
};

$.shr = function(a, b) {
  if ($.checkNumbers(a, b) === true) {
    a = (a);
    b = (b);
    if (b < 0) throw $.captureStackTrace($.IllegalArgumentException$1(b));
    if (a > 0) {
      if (b > 31) return 0;
      return a >>> b;
    }
    if (b > 31) b = 31;
    return (a >> b) >>> 0;
  }
  return a.operator$shr$1(b);
};

$.eqNull = function(a) {
  if (a == null) return true;
  if (typeof a === "object") {
    if (!!a.operator$eq$1) return a.operator$eq$1(null);
  }
  return false;
};

$.and = function(a, b) {
  if ($.checkNumbers(a, b) === true) return (a & b) >>> 0;
  return a.operator$and$1(b);
};

$.substring$2 = function(receiver, startIndex, endIndex) {
  if (!(typeof receiver === 'string')) return receiver.substring$2(startIndex, endIndex);
  $.checkNum(startIndex);
  var length$ = receiver.length;
  if (endIndex == null) endIndex = length$;
  $.checkNum(endIndex);
  if ($.ltB(startIndex, 0)) throw $.captureStackTrace($.IndexOutOfRangeException$1(startIndex));
  if ($.gtB(startIndex, endIndex)) throw $.captureStackTrace($.IndexOutOfRangeException$1(startIndex));
  if ($.gtB(endIndex, length$)) throw $.captureStackTrace($.IndexOutOfRangeException$1(endIndex));
  return $.substringUnchecked(receiver, startIndex, endIndex);
};

$.Point$2 = function(x, y) {
  return new $.Point(y, x);
};

$.indexSet = function(a, index, value) {
  if (a.constructor === Array && !a.immutable$list) {
    var key = (index >>> 0);
    if (key === index && key < (a.length)) {
      a[key] = value;
      return;
    }
  }
  $.indexSet$slow(a, index, value);
};

$._DOMApplicationCacheEventsImpl$1 = function(_ptr) {
  return new $._DOMApplicationCacheEventsImpl(_ptr);
};

$.StringMatch$3 = function(_start, str, pattern) {
  return new $.StringMatch(pattern, str, _start);
};

$.ExceptionImplementation$1 = function(msg) {
  return new $.ExceptionImplementation(msg);
};

$.Rectangle$4 = function(x, y, width, height) {
  return new $.Rectangle(height, width, y, x);
};

$.invokeClosure = function(closure, isolate, numberOfArguments, arg1, arg2) {
  var t1 = ({});
  t1.arg2_3 = arg2;
  t1.arg1_2 = arg1;
  t1.closure_1 = closure;
  if ($.eqB(numberOfArguments, 0)) return new $.Closure5(t1).$call$0();
  if ($.eqB(numberOfArguments, 1)) return new $.Closure6(t1).$call$0();
  if ($.eqB(numberOfArguments, 2)) return new $.Closure7(t1).$call$0();
  throw $.captureStackTrace($.ExceptionImplementation$1('Unsupported number of arguments for wrapped closure'));
};

$.stringJoinUnchecked = function(array, separator) {
  return array.join(separator);
};

$.gt = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a > b) : $.gt$slow(a, b);
};

$.String$fromCharCodes = function(charCodes) {
  return $.createFromCharCodes(charCodes);
};

$._createMeasurementFuture = function(computeValue, completer) {
  var t1 = $._pendingRequests;
  if (t1 == null) {
    $._pendingRequests = [];
    $._maybeScheduleMeasurementFrame();
  }
  $.add$1($._pendingRequests, $._MeasurementRequest$2(computeValue, completer));
  return completer.get$future();
};

$._postMessage2 = function(win, message, targetOrigin) {
      win.postMessage(message, targetOrigin);
;
};

$._maybeScheduleMeasurementFrame = function() {
  if ($._nextMeasurementFrameScheduled === true) return;
  $._nextMeasurementFrameScheduled = true;
  if ($._firstMeasurementRequest === true) {
    $.add$1($.window().get$on().get$message(), new $.Closure14());
    $._firstMeasurementRequest = false;
  }
  $.window().postMessage$2('DART-MEASURE', '*');
};

$.buildDynamicMetadata = function(inputTable) {
  if (typeof inputTable !== 'string' && (typeof inputTable !== 'object' || inputTable === null || (inputTable.constructor !== Array && !inputTable.is$JavaScriptIndexingBehavior()))) return $.buildDynamicMetadata$bailout(1, inputTable, 0, 0, 0, 0, 0, 0);
  var result = [];
  for (var i = 0; t1 = inputTable.length, i < t1; ++i) {
    if (i < 0 || i >= t1) throw $.ioore(i);
    var tag = $.index(inputTable[i], 0);
    var t2 = inputTable.length;
    if (i < 0 || i >= t2) throw $.ioore(i);
    var tags = $.index(inputTable[i], 1);
    var set = $.HashSetImplementation$0();
    $.setRuntimeTypeInfo(set, ({E: 'String'}));
    var tagNames = $.split(tags, '|');
    if (typeof tagNames !== 'string' && (typeof tagNames !== 'object' || tagNames === null || (tagNames.constructor !== Array && !tagNames.is$JavaScriptIndexingBehavior()))) return $.buildDynamicMetadata$bailout(2, inputTable, result, tagNames, tag, i, tags, set);
    for (var j = 0; t1 = tagNames.length, j < t1; ++j) {
      if (j < 0 || j >= t1) throw $.ioore(j);
      set.add$1(tagNames[j]);
    }
    $.add$1(result, $.MetaInfo$3(tag, tags, set));
  }
  return result;
  var t1;
};

$.contains$1 = function(receiver, other) {
  if (!(typeof receiver === 'string')) return receiver.contains$1(other);
  return $.contains$2(receiver, other, 0);
};

$._EventSourceEventsImpl$1 = function(_ptr) {
  return new $._EventSourceEventsImpl(_ptr);
};

$.mul = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a * b) : $.mul$slow(a, b);
};

$._NotificationEventsImpl$1 = function(_ptr) {
  return new $._NotificationEventsImpl(_ptr);
};

$._browserPrefix = function() {
  var t1 = $._cachedBrowserPrefix;
  if (t1 == null) {
    if ($.isFirefox() === true) $._cachedBrowserPrefix = '-moz-';
    else $._cachedBrowserPrefix = '-webkit-';
  }
  return $._cachedBrowserPrefix;
};

$.neg = function(a) {
  if (typeof a === "number") return -a;
  return a.operator$negate$0();
};

$._emitCollection = function(c, result, visiting) {
  $.add$1(visiting, c);
  var isList = typeof c === 'object' && c !== null && (c.constructor === Array || c.is$List0());
  $.add$1(result, isList ? '[' : '{');
  for (var t1 = $.iterator(c), first = true; t1.hasNext$0() === true; ) {
    var t2 = t1.next$0();
    !first && $.add$1(result, ', ');
    $._emitObject(t2, result, visiting);
    first = false;
  }
  $.add$1(result, isList ? ']' : '}');
  $.removeLast(visiting);
};

$.checkMutable = function(list, reason) {
  if (!!(list.immutable$list)) throw $.captureStackTrace($.UnsupportedOperationException$1(reason));
};

$.addEventDispatcher = function(eventType, eventDispatcher) {
  if (!$.eqB(eventType, 'enterFrame')) return;
  if ($.eqNullB($._eventDispatcherMap)) $._eventDispatcherMap = $.HashMapImplementation$0();
  var eventDispatchers = $.index($._eventDispatcherMap, eventType);
  if ($.eqNullB(eventDispatchers)) {
    var t1 = $._eventDispatcherMap;
    eventDispatchers = $.List(null);
    $.setRuntimeTypeInfo(eventDispatchers, ({E: 'EventDispatcher'}));
    $.indexSet(t1, eventType, eventDispatchers);
  }
  $.add$1(eventDispatchers, eventDispatcher);
};

$.sub$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a - b;
  return a.operator$sub$1(b);
};

$.toStringWrapper = function() {
  return $.toString((this.dartException));
};

$._PeerConnection00EventsImpl$1 = function(_ptr) {
  return new $._PeerConnection00EventsImpl(_ptr);
};

$.Mask$custom$1 = function(points) {
  var t1 = new $.Mask(null, null, null, null);
  t1.Mask$custom$1(points);
  return t1;
};

$._WorkerContextEventsImpl$1 = function(_ptr) {
  return new $._WorkerContextEventsImpl(_ptr);
};

$._DocumentEventsImpl$1 = function(_ptr) {
  return new $._DocumentEventsImpl(_ptr);
};

$.regExpTest = function(regExp, str) {
  return $.regExpGetNative(regExp).test(str);
};

$.getDay = function(receiver) {
  return receiver.get$isUtc() === true ? ($.lazyAsJsDate(receiver).getUTCDate()) : ($.lazyAsJsDate(receiver).getDate());
};

$._EventsImpl$1 = function(_ptr) {
  return new $._EventsImpl(_ptr);
};

$.Tween$3 = function(target, time, transitionFunction) {
  var t1 = new $.Tween(null, null, null, null, null, null, null, null, null, null, null, null);
  t1.Tween$3(target, time, transitionFunction);
  return t1;
};

$.Sprite$0 = function() {
  var t1 = new $.Sprite(false, false, true, true, null, 0, true, true, false, null, null, null, null, '', true, 1.0, null, null, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, null);
  t1.DisplayObject$0();
  t1.DisplayObjectContainer$0();
  return t1;
};

$._IDBRequestEventsImpl$1 = function(_ptr) {
  return new $._IDBRequestEventsImpl(_ptr);
};

$.HashSetImplementation$0 = function() {
  var t1 = new $.HashSetImplementation(null);
  t1.HashSetImplementation$0();
  return t1;
};

$.stringSplitUnchecked = function(receiver, pattern) {
  if (typeof pattern === 'string') return receiver.split(pattern);
  if (typeof pattern === 'object' && pattern !== null && !!pattern.is$JSSyntaxRegExp) return receiver.split($.regExpGetNative(pattern));
  throw $.captureStackTrace('StringImplementation.split(Pattern) UNIMPLEMENTED');
};

$.isEmpty = function(receiver) {
  if (typeof receiver === 'string' || $.isJsArray(receiver) === true) return receiver.length === 0;
  return receiver.isEmpty$0();
};

$.checkGrowable = function(list, reason) {
  if (!!(list.fixed$length)) throw $.captureStackTrace($.UnsupportedOperationException$1(reason));
};

$._SpeechRecognitionEventsImpl$1 = function(_ptr) {
  return new $._SpeechRecognitionEventsImpl(_ptr);
};

$._SVGElementInstanceEventsImpl$1 = function(_ptr) {
  return new $._SVGElementInstanceEventsImpl(_ptr);
};

$.add$1 = function(receiver, value) {
  if ($.isJsArray(receiver) === true) {
    $.checkGrowable(receiver, 'add');
    receiver.push(value);
    return;
  }
  return receiver.add$1(value);
};

$.regExpExec = function(regExp, str) {
  var result = ($.regExpGetNative(regExp).exec(str));
  if (result === null) return;
  return result;
};

$.getButton = function(text, clickHandler) {
  var t1 = ({});
  t1.clickHandler_1 = clickHandler;
  var button = $.Sprite$0();
  var buttonUp = $.Bitmap$3($.resource.getBitmapData$1('buttonUp'), 'auto', false);
  var buttonOver = $.Bitmap$3($.resource.getBitmapData$1('buttonOver'), 'auto', false);
  var simpleButton = $.SimpleButton$4(buttonUp, buttonOver, $.Bitmap$3($.resource.getBitmapData$1('buttonDown'), 'auto', false), buttonOver);
  simpleButton.set$x(20);
  simpleButton.set$y(20);
  var textFormat = $.TextFormat$13('Verdana', 30, 4294967295, false, false, false, null, null, 'left', 0, 0, 0, 0);
  textFormat.align = 'center';
  var textField = $.TextField$0();
  textField.set$defaultTextFormat(textFormat);
  textField.set$width(simpleButton.get$width());
  textField.set$height(40);
  textField.set$text(text);
  textField.set$x(simpleButton.get$x());
  textField.set$y($.add(simpleButton.get$y(), 10));
  textField.mouseEnabled = false;
  button.addChild$1(simpleButton);
  button.addChild$1(textField);
  simpleButton.addEventListener$2('click', new $.Closure23(t1));
  return button;
};

$.geB = function(a, b) {
  if (typeof a === 'number' && typeof b === 'number') var t1 = (a >= b);
  else {
    t1 = $.ge$slow(a, b);
    t1 = t1 === true;
  }
  return t1;
};

$.getMinutes = function(receiver) {
  return receiver.get$isUtc() === true ? ($.lazyAsJsDate(receiver).getUTCMinutes()) : ($.lazyAsJsDate(receiver).getMinutes());
};

$.getMonth = function(receiver) {
  return receiver.get$isUtc() === true ? ($.lazyAsJsDate(receiver).getUTCMonth()) + 1 : ($.lazyAsJsDate(receiver).getMonth()) + 1;
};

$.stringContainsUnchecked = function(receiver, other, startIndex) {
  if (typeof other === 'string') {
    var t1 = $.indexOf$2(receiver, other, startIndex);
    return !(t1 === -1);
  }
  if (typeof other === 'object' && other !== null && !!other.is$JSSyntaxRegExp) return other.hasMatch$1($.substring$1(receiver, startIndex));
  return $.iterator($.allMatches(other, $.substring$1(receiver, startIndex))).hasNext$0();
};

$.easeInOutBack = function(ratio) {
  ratio = $.mul(ratio, 2.0);
  if ($.ltB(ratio, 1.0)) {
    var t1 = $.easeInBack(ratio);
    if (typeof t1 !== 'number') throw $.iae(t1);
    t1 *= 0.5;
  } else {
    t1 = $.easeOutBack($.sub(ratio, 1.0));
    if (typeof t1 !== 'number') throw $.iae(t1);
    var t2 = 0.5 * t1 + 0.5;
    t1 = t2;
  }
  return t1;
};

$.ObjectNotClosureException$0 = function() {
  return new $.ObjectNotClosureException();
};

$.window = function() {
  return window;;
};

$._getCssStyle = function(mouseCursor) {
  var cursor = !$.eqB($._customCursor, 'auto') ? $._customCursor : mouseCursor;
  var style = 'auto';
  switch (cursor) {
    case 'auto':
      style = 'auto';
      break;
    case 'arrow':
      style = 'default';
      break;
    case 'button':
      style = 'pointer';
      break;
    case 'hand':
      style = 'move';
      break;
    case 'ibeam':
      style = 'text';
      break;
    case 'wait':
      style = 'wait';
      break;
  }
  return $._isCursorHidden === true ? 'none' : style;
};

$.abs = function(receiver) {
  if (!(typeof receiver === 'number')) return receiver.abs$0();
  return Math.abs(receiver);
};

$.add = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a + b) : $.add$slow(a, b);
};

$.iterator = function(receiver) {
  if ($.isJsArray(receiver) === true) return $.ListIterator$1(receiver);
  return receiver.iterator$0();
};

$.objectTypeName = function(object) {
  var name$ = $.constructorNameFallback(object);
  if ($.eqB(name$, 'Object')) {
    var decompiled = (String(object.constructor).match(/^\s*function\s*(\S*)\s*\(/)[1]);
    if (typeof decompiled === 'string') name$ = decompiled;
  }
  var t1 = $.charCodeAt(name$, 0);
  return t1 === 36 ? $.substring$1(name$, 1) : name$;
};

$.regExpAttachGlobalNative = function(regExp) {
  regExp._re = $.regExpMakeNative(regExp, true);
};

$.leB = function(a, b) {
  if (typeof a === 'number' && typeof b === 'number') var t1 = (a <= b);
  else {
    t1 = $.le$slow(a, b);
    t1 = t1 === true;
  }
  return t1;
};

$.isNegative = function(receiver) {
  if (typeof receiver === 'number') {
    return receiver === 0 ? 1 / receiver < 0 : receiver < 0;
  }
  return receiver.isNegative$0();
};

$._DOMWindowCrossFrameImpl$1 = function(_window) {
  return new $._DOMWindowCrossFrameImpl(_window);
};

$.regExpMakeNative = function(regExp, global) {
  var pattern = regExp.get$pattern();
  var multiLine = regExp.get$multiLine();
  var ignoreCase = regExp.get$ignoreCase();
  $.checkString(pattern);
  var sb = $.StringBufferImpl$1('');
  multiLine === true && $.add$1(sb, 'm');
  ignoreCase === true && $.add$1(sb, 'i');
  global === true && $.add$1(sb, 'g');
  try {
    return new RegExp(pattern, $.toString(sb));
  } catch (exception) {
    var t1 = $.unwrapException(exception);
    var e = t1;
    throw $.captureStackTrace($.IllegalJSRegExpException$2(pattern, (String(e))));
  }
};

$.BadNumberFormatException$1 = function(_s) {
  return new $.BadNumberFormatException(_s);
};

$.mapToString = function(m) {
  var result = $.StringBufferImpl$1('');
  $._emitMap(m, result, $.List(null));
  return result.toString$0();
};

$.lazyAsJsDate = function(receiver) {
  (receiver.date === (void 0)) && (receiver.date = new Date(receiver.get$millisecondsSinceEpoch()));
  return receiver.date;
};

$._XMLHttpRequestEventsImpl$1 = function(_ptr) {
  return new $._XMLHttpRequestEventsImpl(_ptr);
};

$._JavaScriptAudioNodeEventsImpl$1 = function(_ptr) {
  return new $._JavaScriptAudioNodeEventsImpl(_ptr);
};

$._emitObject = function(o, result, visiting) {
  if (typeof o === 'object' && o !== null && (o.constructor === Array || o.is$Collection())) {
    if ($._containsRef(visiting, o) === true) {
      $.add$1(result, typeof o === 'object' && o !== null && (o.constructor === Array || o.is$List0()) ? '[...]' : '{...}');
    } else $._emitCollection(o, result, visiting);
  } else {
    if (typeof o === 'object' && o !== null && o.is$Map()) {
      if ($._containsRef(visiting, o) === true) $.add$1(result, '{...}');
      else $._emitMap(o, result, visiting);
    } else {
      $.add$1(result, $.eqNullB(o) ? 'null' : o);
    }
  }
};

$._emitMap = function(m, result, visiting) {
  var t1 = ({});
  t1.visiting_2 = visiting;
  t1.result_1 = result;
  $.add$1(t1.visiting_2, m);
  $.add$1(t1.result_1, '{');
  t1.first_3 = true;
  $.forEach(m, new $.Closure0(t1));
  $.add$1(t1.result_1, '}');
  $.removeLast(t1.visiting_2);
};

$._IDBDatabaseEventsImpl$1 = function(_ptr) {
  return new $._IDBDatabaseEventsImpl(_ptr);
};

$.isFirefox = function() {
  return $.contains$2($.userAgent(), 'Firefox', 0);
};

$.EnterFrameEvent$1 = function(passedTime) {
  var t1 = new $.EnterFrameEvent(null, false, false, null, null, null, null, null);
  t1.Event$2('enterFrame', false);
  t1.EnterFrameEvent$1(passedTime);
  return t1;
};

$.compareTo = function(a, b) {
  if ($.checkNumbers(a, b) === true) {
    if ($.ltB(a, b)) return -1;
    if ($.gtB(a, b)) return 1;
    if ($.eqB(a, b)) {
      if ($.eqB(a, 0)) {
        var aIsNegative = $.isNegative(a);
        if ($.eqB(aIsNegative, $.isNegative(b))) return 0;
        if (aIsNegative === true) return -1;
        return 1;
      }
      return 0;
    }
    if ($.isNaN(a) === true) {
      if ($.isNaN(b) === true) return 0;
      return 1;
    }
    return -1;
  }
  if (typeof a === 'string') {
    if (!(typeof b === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(b));
    if (a == b) var t1 = 0;
    else {
      t1 = (a < b) ? -1 : 1;
    }
    return t1;
  }
  return a.compareTo$1(b);
};

$.ge = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a >= b) : $.ge$slow(a, b);
};

$._MeasurementRequest$2 = function(computeValue, completer) {
  return new $._MeasurementRequest(false, null, completer, computeValue);
};

$._TextTrackCueEventsImpl$1 = function(_ptr) {
  return new $._TextTrackCueEventsImpl(_ptr);
};

$.MatchImplementation$5 = function(pattern, str, _start, _end, _groups) {
  return new $.MatchImplementation(_groups, _end, _start, str, pattern);
};

$._SimpleClientRect$4 = function(left, top$, width, height) {
  return new $._SimpleClientRect(height, width, top$, left);
};

$.UnsupportedOperationException$1 = function(_message) {
  return new $.UnsupportedOperationException(_message);
};

$.indexOf$2 = function(receiver, element, start) {
  if ($.isJsArray(receiver) === true) {
    if (!((typeof start === 'number') && (start === (start | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(start));
    return $.indexOf(receiver, element, start, (receiver.length));
  }
  if (typeof receiver === 'string') {
    $.checkNull(element);
    if (!((typeof start === 'number') && (start === (start | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(start));
    if (!(typeof element === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(element));
    if (start < 0) return -1;
    return receiver.indexOf(element, start);
  }
  return receiver.indexOf$2(element, start);
};

$._DedicatedWorkerContextEventsImpl$1 = function(_ptr) {
  return new $._DedicatedWorkerContextEventsImpl(_ptr);
};

$._FileReaderEventsImpl$1 = function(_ptr) {
  return new $._FileReaderEventsImpl(_ptr);
};

$.concat = function(receiver, other) {
  if (!(typeof receiver === 'string')) return receiver.concat$1(other);
  if (!(typeof other === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(other));
  return receiver + other;
};

$.NoMoreElementsException$0 = function() {
  return new $.NoMoreElementsException();
};

$.getYear = function(receiver) {
  return receiver.get$isUtc() === true ? ($.lazyAsJsDate(receiver).getUTCFullYear()) : ($.lazyAsJsDate(receiver).getFullYear());
};

$.eqNullB = function(a) {
  if (a == null) return true;
  if (typeof a === "object") {
    if (!!a.operator$eq$1) {
      var t1 = a.operator$eq$1(null);
      return t1 === true;
    }
  }
  return false;
};

$.Element$tag = function(tag) {
  return document.createElement(tag);
};

$._FrameSetElementEventsImpl$1 = function(_ptr) {
  return new $._FrameSetElementEventsImpl(_ptr);
};

$.add$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a + b;
  return a.operator$add$1(b);
};

$.List$from = function(other) {
  var result = $.List(null);
  $.setRuntimeTypeInfo(result, ({E: 'E'}));
  var iterator = $.iterator(other);
  for (; iterator.hasNext$0() === true; ) {
    result.push(iterator.next$0());
  }
  return result;
};

$.newList = function(length$) {
  if (length$ == null) return new Array();
  if (!((typeof length$ === 'number') && (length$ === (length$ | 0))) || length$ < 0) throw $.captureStackTrace($.IllegalArgumentException$1(length$));
  var result = (new Array(length$));
  result.fixed$length = true;
  return result;
};

$.main = function() {
  var t1 = ({});
  t1.stage_3 = $.Stage$2('myStage', $.document().query$1('#stage'));
  $.RenderLoop$0().addStage$1(t1.stage_3);
  $.resource = $.Resource$0();
  $.resource.addImage$2('buttonUp', '../images/ButtonUp.png');
  $.resource.addImage$2('buttonOver', '../images/ButtonOver.png');
  $.resource.addImage$2('buttonDown', '../images/ButtonDown.png');
  $.resource.addImage$2('flower1', '../images/Flower1.png');
  $.resource.addImage$2('flower2', '../images/Flower2.png');
  $.resource.addImage$2('flower3', '../images/Flower3.png');
  var starPath = $.List(null);
  $.setRuntimeTypeInfo(starPath, ({E: 'Point'}));
  for (var i = 0; i < 6; ++i) {
    var t2 = i * 60.0;
    var a1 = 3.141592653589793 * t2 / 180.0;
    var a2 = 3.141592653589793 * (t2 + 30.0) / 180.0;
    var t3 = $.cos(a1);
    if (typeof t3 !== 'number') throw $.iae(t3);
    var t4 = 400.0 + 200.0 * t3;
    var t5 = $.sin(a1);
    if (typeof t5 !== 'number') throw $.iae(t5);
    starPath.push($.Point$2(t4, 350.0 + 200.0 * t5));
    var t6 = $.cos(a2);
    if (typeof t6 !== 'number') throw $.iae(t6);
    var t7 = 400.0 + 100.0 * t6;
    var t8 = $.sin(a2);
    if (typeof t8 !== 'number') throw $.iae(t8);
    starPath.push($.Point$2(t7, 350.0 + 100.0 * t8));
  }
  t1.rectangleMask_4 = $.Mask$rectangle$4(100.0, 200.0, 600.0, 300.0);
  t1.circleMask_5 = $.Mask$circle$3(400.0, 350.0, 200.0);
  t1.customMask_6 = $.Mask$custom$1(starPath);
  $.resource.load$0().then$1(new $.Closure(t1));
};

$._AbstractWorkerEventsImpl$1 = function(_ptr) {
  return new $._AbstractWorkerEventsImpl(_ptr);
};

$.dateNow = function() {
  return Date.now();
};

$._computeLoadLimit = function(capacity) {
  return $.tdiv($.mul(capacity, 3), 4);
};

$.HashSetIterator$1 = function(set_) {
  var t1 = new $.HashSetIterator(-1, set_.get$_backingMap().get$_keys());
  t1.HashSetIterator$1(set_);
  return t1;
};

$.getAnimation = function() {
  var sprite = $.Sprite$0();
  for (var i = 0; i < 150; ++i) {
    var t1 = $.toInt($.mul($.random(), 3.0));
    if (typeof t1 !== 'number') throw $.iae(t1);
    var f = 1 + t1;
    var bitmap = $.Bitmap$3($.resource.getBitmapData$1('flower' + $.S(f)), 'auto', false);
    bitmap.set$pivotX(64);
    bitmap.set$pivotY(64);
    t1 = $.mul($.random(), 672.0);
    if (typeof t1 !== 'number') throw $.iae(t1);
    bitmap.set$x(64.0 + t1);
    var t2 = $.mul($.random(), 372.0);
    if (typeof t2 !== 'number') throw $.iae(t2);
    bitmap.set$y(164.0 + t2);
    sprite.addChild$1(bitmap);
    var tween = $.Tween$3(bitmap, 180.0, $.linear);
    tween.animate$2('rotation', 62.83185307179586);
    $.add$1($.instance(), tween);
  }
  return sprite;
};

$.TextEvent$2 = function(type, bubbles) {
  var t1 = new $.TextEvent('', false, false, null, null, null, null, null);
  t1.Event$2(type, bubbles);
  return t1;
};

$.IllegalArgumentException$1 = function(arg) {
  return new $.IllegalArgumentException(arg);
};

$._MediaElementEventsImpl$1 = function(_ptr) {
  return new $._MediaElementEventsImpl(_ptr);
};

$._IDBTransactionEventsImpl$1 = function(_ptr) {
  return new $._IDBTransactionEventsImpl(_ptr);
};

$._BodyElementEventsImpl$1 = function(_ptr) {
  return new $._BodyElementEventsImpl(_ptr);
};

$._AllMatchesIterator$2 = function(re, _str) {
  return new $._AllMatchesIterator(false, null, _str, $.JSSyntaxRegExp$_globalVersionOf$1(re));
};

$.FutureImpl$0 = function() {
  var t1 = [];
  var t2 = [];
  return new $.FutureImpl([], t2, t1, false, null, null, null, false);
};

$.iae = function(argument) {
  throw $.captureStackTrace($.IllegalArgumentException$1(argument));
};

$.truncate = function(receiver) {
  if (!(typeof receiver === 'number')) return receiver.truncate$0();
  return receiver < 0 ? $.ceil(receiver) : $.floor(receiver);
};

$.isNaN = function(receiver) {
  if (typeof receiver === 'number') return isNaN(receiver);
  return receiver.isNaN$0();
};

$.isInfinite = function(receiver) {
  if (!(typeof receiver === 'number')) return receiver.isInfinite$0();
  return (receiver == Infinity) || (receiver == -Infinity);
};

$._AnimateProperty$3 = function(name$, startValue, targetValue) {
  return new $._AnimateProperty(targetValue, startValue, name$);
};

$.Resource$0 = function() {
  var t1 = new $.Resource(null, null, null, null, null, null, null);
  t1.Resource$0();
  return t1;
};

$.round = function(receiver) {
  if (!(typeof receiver === 'number')) return receiver.round$0();
  if (receiver < 0) return -Math.round(-receiver);
  return Math.round(receiver);
};

$.allMatchesInStringUnchecked = function(needle, haystack) {
  var result = $.List(null);
  $.setRuntimeTypeInfo(result, ({E: 'Match'}));
  var length$ = $.get$length(haystack);
  var patternLength = $.get$length(needle);
  if (patternLength !== (patternLength | 0)) return $.allMatchesInStringUnchecked$bailout(1, needle, haystack, length$, patternLength, result);
  for (var startIndex = 0; true; ) {
    var position = $.indexOf$2(haystack, needle, startIndex);
    if ($.eqB(position, -1)) break;
    result.push($.StringMatch$3(position, haystack, needle));
    var endIndex = $.add(position, patternLength);
    if ($.eqB(endIndex, length$)) break;
    else {
      startIndex = $.eqB(position, endIndex) ? $.add(startIndex, 1) : endIndex;
    }
  }
  return result;
};

$.le$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a <= b;
  return a.operator$le$1(b);
};

$._AllMatchesIterable$2 = function(_re, _str) {
  return new $._AllMatchesIterable(_str, _re);
};

$.copy = function(src, srcStart, dst, dstStart, count) {
  if (typeof src !== 'string' && (typeof src !== 'object' || src === null || (src.constructor !== Array && !src.is$JavaScriptIndexingBehavior()))) return $.copy$bailout(1, src, srcStart, dst, dstStart, count);
  if (typeof dst !== 'object' || dst === null || ((dst.constructor !== Array || !!dst.immutable$list) && !dst.is$JavaScriptIndexingBehavior())) return $.copy$bailout(1, src, srcStart, dst, dstStart, count);
  if (typeof count !== 'number') return $.copy$bailout(1, src, srcStart, dst, dstStart, count);
  if (srcStart == null) srcStart = 0;
  if (typeof srcStart !== 'number') return $.copy$bailout(2, src, dst, dstStart, count, srcStart);
  if (dstStart == null) dstStart = 0;
  if (typeof dstStart !== 'number') return $.copy$bailout(3, src, dst, count, srcStart, dstStart);
  if (srcStart < dstStart) {
    for (var i = srcStart + count - 1, j = dstStart + count - 1; i >= srcStart; --i, --j) {
      if (i !== (i | 0)) throw $.iae(i);
      var t1 = src.length;
      if (i < 0 || i >= t1) throw $.ioore(i);
      var t2 = src[i];
      if (j !== (j | 0)) throw $.iae(j);
      var t3 = dst.length;
      if (j < 0 || j >= t3) throw $.ioore(j);
      dst[j] = t2;
    }
  } else {
    for (t1 = srcStart + count, i = srcStart, j = dstStart; i < t1; ++i, ++j) {
      if (i !== (i | 0)) throw $.iae(i);
      t2 = src.length;
      if (i < 0 || i >= t2) throw $.ioore(i);
      t3 = src[i];
      if (j !== (j | 0)) throw $.iae(j);
      var t4 = dst.length;
      if (j < 0 || j >= t4) throw $.ioore(j);
      dst[j] = t3;
    }
  }
};

$.dynamicSetMetadata = function(inputTable) {
  var t1 = $.buildDynamicMetadata(inputTable);
  $._dynamicMetadata(t1);
};

$.endsWith = function(receiver, other) {
  if (!(typeof receiver === 'string')) return receiver.endsWith$1(other);
  $.checkString(other);
  var receiverLength = receiver.length;
  var otherLength = $.get$length(other);
  if ($.gtB(otherLength, receiverLength)) return false;
  if (typeof otherLength !== 'number') throw $.iae(otherLength);
  return $.eq(other, $.substring$1(receiver, receiverLength - otherLength));
};

$.getMilliseconds = function(receiver) {
  return receiver.get$isUtc() === true ? ($.lazyAsJsDate(receiver).getUTCMilliseconds()) : ($.lazyAsJsDate(receiver).getMilliseconds());
};

$.ListIterator$1 = function(list) {
  return new $.ListIterator(list, 0);
};

$._top = function(win) {
  return win.top;;
};

$.checkNum = function(value) {
  if (!(typeof value === 'number')) {
    $.checkNull(value);
    throw $.captureStackTrace($.IllegalArgumentException$1(value));
  }
  return value;
};

$.easeOutBack = function(ratio) {
  ratio = $.sub(ratio, 1.0);
  var t1 = $.mul(ratio, ratio);
  if (typeof ratio !== 'number') throw $.iae(ratio);
  return $.add($.mul(t1, 2.70158 * ratio + 1.70158), 1.0);
};

$.FutureAlreadyCompleteException$0 = function() {
  return new $.FutureAlreadyCompleteException();
};

$._WorkerEventsImpl$1 = function(_ptr) {
  return new $._WorkerEventsImpl(_ptr);
};

$.EventDispatcher$0 = function() {
  return new $.EventDispatcher(null);
};

$.ltB = function(a, b) {
  if (typeof a === 'number' && typeof b === 'number') var t1 = (a < b);
  else {
    t1 = $.lt$slow(a, b);
    t1 = t1 === true;
  }
  return t1;
};

$.convertDartClosureToJS = function(closure, arity) {
  if (closure == null) return;
  var function$ = (closure.$identity);
  if (!!function$) return function$;
  function$ = (function() {
    return $.invokeClosure.$call$5(closure, $, arity, arguments[0], arguments[1]);
  });
  closure.$identity = function$;
  return function$;
};

$._FixedSizeListIterator$1 = function(array) {
  return new $._FixedSizeListIterator($.get$length(array), 0, array);
};

$.Mask$circle$3 = function(x, y, radius) {
  var t1 = new $.Mask(null, null, null, null);
  t1.Mask$circle$3(x, y, radius);
  return t1;
};

$.split = function(receiver, pattern) {
  if (!(typeof receiver === 'string')) return receiver.split$1(pattern);
  $.checkNull(pattern);
  return $.stringSplitUnchecked(receiver, pattern);
};

$.concatAll = function(strings) {
  return $.stringJoinUnchecked($._toJsStringArray(strings), '');
};

$.userAgent = function() {
  return $.window().get$navigator().get$userAgent();
};

$._InputElementEventsImpl$1 = function(_ptr) {
  return new $._InputElementEventsImpl(_ptr);
};

$.Juggler$0 = function() {
  var t1 = new $.Juggler(null, null, null);
  t1.Juggler$0();
  return t1;
};

$.S = function(value) {
  var res = $.toString(value);
  if (!(typeof res === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(value));
  return res;
};

$._TextTrackListEventsImpl$1 = function(_ptr) {
  return new $._TextTrackListEventsImpl(_ptr);
};

$._dynamicMetadata = function(table) {
  $dynamicMetadata = table;
};

$._dynamicMetadata0 = function() {
  var t1 = (typeof($dynamicMetadata));
  if (t1 === 'undefined') {
    t1 = [];
    $._dynamicMetadata(t1);
  }
  return $dynamicMetadata;
};

$._DeprecatedPeerConnectionEventsImpl$1 = function(_ptr) {
  return new $._DeprecatedPeerConnectionEventsImpl(_ptr);
};

$.Circle$3 = function(x, y, radius) {
  return new $.Circle(radius, y, x);
};

$.regExpGetNative = function(regExp) {
  var r = (regExp._re);
  return r == null ? (regExp._re = $.regExpMakeNative(regExp, false)) : r;
};

$.throwNoSuchMethod = function(obj, name$, arguments$) {
  throw $.captureStackTrace($.NoSuchMethodException$4(obj, name$, arguments$, null));
};

$.checkNull = function(object) {
  if (object == null) throw $.captureStackTrace($.NullPointerException$2(null, $.CTC));
  return object;
};

$.CompleterImpl$0 = function() {
  return new $.CompleterImpl($.FutureImpl$0());
};

$._EventListenerListImpl$2 = function(_ptr, _type) {
  return new $._EventListenerListImpl(_type, _ptr);
};

$._focus = function(win) {
  win.focus();
};

$.getSeconds = function(receiver) {
  return receiver.get$isUtc() === true ? ($.lazyAsJsDate(receiver).getUTCSeconds()) : ($.lazyAsJsDate(receiver).getSeconds());
};

$.dispatchEvent = function(event$) {
  if (!$.eqNullB($._eventDispatcherMap)) {
    var eventDispatchers = $.index($._eventDispatcherMap, event$.get$type());
    if (typeof eventDispatchers !== 'object' || eventDispatchers === null || ((eventDispatchers.constructor !== Array || !!eventDispatchers.immutable$list) && !eventDispatchers.is$JavaScriptIndexingBehavior())) return $.dispatchEvent$bailout(1, event$, eventDispatchers);
    var eventDispatchersLength = eventDispatchers.length;
    for (var c = 0, i = 0; i < eventDispatchersLength; ++i) {
      var t1 = eventDispatchers.length;
      if (i < 0 || i >= t1) throw $.ioore(i);
      var t2 = eventDispatchers[i];
      if (!$.eqNullB(t2)) {
        t2.dispatchEvent$1(event$);
        if (!(c === i)) {
          t1 = eventDispatchers.length;
          if (c < 0 || c >= t1) throw $.ioore(c);
          eventDispatchers[c] = t2;
        }
        ++c;
      }
    }
    for (i = eventDispatchersLength; t1 = eventDispatchers.length, i < t1; ++i) {
      var c0 = c + 1;
      if (i < 0 || i >= t1) throw $.ioore(i);
      t2 = eventDispatchers[i];
      if (c < 0 || c >= t1) throw $.ioore(c);
      eventDispatchers[c] = t2;
      c = c0;
    }
    $.set$length(eventDispatchers, c);
  }
};

$._WindowEventsImpl$1 = function(_ptr) {
  return new $._WindowEventsImpl(_ptr);
};

$.checkNumbers = function(a, b) {
  if (typeof a === 'number') {
    if (typeof b === 'number') return true;
    $.checkNull(b);
    throw $.captureStackTrace($.IllegalArgumentException$1(b));
  }
  return false;
};

$.random = function() {
  return $.random0();
};

$.random0 = function() {
  return Math.random();
};

$.getHours = function(receiver) {
  return receiver.get$isUtc() === true ? ($.lazyAsJsDate(receiver).getUTCHours()) : ($.lazyAsJsDate(receiver).getHours());
};

$.Stage$2 = function(name$, canvas) {
  var t1 = new $.Stage(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, true, true, null, 0, true, true, false, null, null, null, null, '', true, 1.0, null, null, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, null);
  t1.DisplayObject$0();
  t1.DisplayObjectContainer$0();
  t1.Stage$2(name$, canvas);
  return t1;
};

$.lt$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a < b;
  return a.operator$lt$1(b);
};

$.index$slow = function(a, index) {
  if (typeof a === 'string' || $.isJsArray(a) === true) {
    if (!((typeof index === 'number') && (index === (index | 0)))) {
      if (!(typeof index === 'number')) throw $.captureStackTrace($.IllegalArgumentException$1(index));
      var t1 = $.truncate(index);
      if (!(t1 === index)) throw $.captureStackTrace($.IllegalArgumentException$1(index));
    }
    if ($.ltB(index, 0) || $.geB(index, $.get$length(a))) throw $.captureStackTrace($.IndexOutOfRangeException$1(index));
    return a[index];
  }
  return a.operator$index$1(index);
};

$.loadImage = function(url) {
  var t1 = ({});
  var completer = $.CompleterImpl$0();
  $.setRuntimeTypeInfo(completer, ({T: 'BitmapData'}));
  t1.completer_1 = completer;
  t1.image_2 = $.ImageElement(url, null, null);
  $.add$1(t1.image_2.get$on().get$load(), new $.Closure3(t1));
  $.add$1(t1.image_2.get$on().get$error(), new $.Closure4(t1));
  return t1.completer_1.get$future();
};

$.linear = function(ratio) {
  return ratio;
};

$.RenderState$fromCanvasRenderingContext2D$1 = function(context) {
  var t1 = new $.RenderState(null, null, null, null);
  t1.RenderState$fromCanvasRenderingContext2D$1(context);
  return t1;
};

$.isEven = function(receiver) {
  if (!((typeof receiver === 'number') && (receiver === (receiver | 0)))) return receiver.isEven$0();
  var t1 = receiver & 1;
  return t1 === 0;
};

$.toString = function(value) {
  if (typeof value == "object" && value !== null) {
    if ($.isJsArray(value) === true) return $.collectionToString(value);
    return value.toString$0();
  }
  if (value === 0 && (1 / value) < 0) return '-0.0';
  if (value == null) return 'null';
  if (typeof value == "function") return 'Closure';
  return String(value);
};

$._postMessage3 = function(win, message, targetOrigin, messagePorts) {
      win.postMessage(message, targetOrigin, messagePorts);
;
};

$.contains$2 = function(receiver, other, startIndex) {
  if (!(typeof receiver === 'string')) return receiver.contains$2(other, startIndex);
  $.checkNull(other);
  return $.stringContainsUnchecked(receiver, other, startIndex);
};

$.listInsertRange = function(receiver, start, length$, initialValue) {
  if (typeof receiver !== 'object' || receiver === null || ((receiver.constructor !== Array || !!receiver.immutable$list) && !receiver.is$JavaScriptIndexingBehavior())) return $.listInsertRange$bailout(1, receiver, start, length$, initialValue);
  if (typeof start !== 'number') return $.listInsertRange$bailout(1, receiver, start, length$, initialValue);
  if (typeof length$ !== 'number') return $.listInsertRange$bailout(1, receiver, start, length$, initialValue);
  if (length$ === 0) return;
  $.checkNull(start);
  $.checkNull(length$);
  if (!((typeof length$ === 'number') && (length$ === (length$ | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(length$));
  if (length$ < 0) throw $.captureStackTrace($.IllegalArgumentException$1(length$));
  if (!((typeof start === 'number') && (start === (start | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(start));
  var receiverLength = (receiver.length);
  if (start < 0 || start > receiverLength) throw $.captureStackTrace($.IndexOutOfRangeException$1(start));
  var t1 = receiverLength + length$;
  $.set$length(receiver, t1);
  $.copy(receiver, start, receiver, start + length$, receiverLength - start);
  if (!(initialValue == null)) {
    for (var t2 = start + length$, i = start; i < t2; ++i) {
      if (i !== (i | 0)) throw $.iae(i);
      var t3 = receiver.length;
      if (i < 0 || i >= t3) throw $.ioore(i);
      receiver[i] = initialValue;
    }
  }
  $.set$length(receiver, t1);
};

$.ImageElement = function(src, width, height) {
  var _e = $._document().$dom_createElement$1('img');
  !$.eqNullB(src) && _e.set$src(src);
  !$.eqNullB(width) && _e.set$width(width);
  !$.eqNullB(height) && _e.set$height(height);
  return _e;
};

$._toJsStringArray = function(strings) {
  if (typeof strings !== 'object' || strings === null || ((strings.constructor !== Array || !!strings.immutable$list) && !strings.is$JavaScriptIndexingBehavior())) return $._toJsStringArray$bailout(1, strings);
  $.checkNull(strings);
  var length$ = strings.length;
  if ($.isJsArray(strings) === true) {
    for (var i = 0; i < length$; ++i) {
      var t1 = strings.length;
      if (i < 0 || i >= t1) throw $.ioore(i);
      var t2 = strings[i];
      $.checkNull(t2);
      if (!(typeof t2 === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(t2));
    }
    var array = strings;
  } else {
    array = $.List(length$);
    for (i = 0; i < length$; ++i) {
      t1 = strings.length;
      if (i < 0 || i >= t1) throw $.ioore(i);
      t2 = strings[i];
      $.checkNull(t2);
      if (!(typeof t2 === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(t2));
      t1 = array.length;
      if (i < 0 || i >= t1) throw $.ioore(i);
      array[i] = t2;
    }
  }
  return array;
};

$.IndexOutOfRangeException$1 = function(_index) {
  return new $.IndexOutOfRangeException(_index);
};

$._TextTrackEventsImpl$1 = function(_ptr) {
  return new $._TextTrackEventsImpl(_ptr);
};

$.charCodeAt = function(receiver, index) {
  if (typeof receiver === 'string') {
    if (!(typeof index === 'number')) throw $.captureStackTrace($.IllegalArgumentException$1(index));
    if (index < 0) throw $.captureStackTrace($.IndexOutOfRangeException$1(index));
    if (index >= receiver.length) throw $.captureStackTrace($.IndexOutOfRangeException$1(index));
    return receiver.charCodeAt(index);
  }
  return receiver.charCodeAt$1(index);
};

$._BatteryManagerEventsImpl$1 = function(_ptr) {
  return new $._BatteryManagerEventsImpl(_ptr);
};

$._ElementRectImpl$1 = function(element) {
  var t1 = $._SimpleClientRect$4(element.get$$$dom_clientLeft(), element.get$$$dom_clientTop(), element.get$$$dom_clientWidth(), element.get$$$dom_clientHeight());
  var t2 = $._SimpleClientRect$4(element.get$$$dom_offsetLeft(), element.get$$$dom_offsetTop(), element.get$$$dom_offsetWidth(), element.get$$$dom_offsetHeight());
  var t3 = $._SimpleClientRect$4(element.get$$$dom_scrollLeft(), element.get$$$dom_scrollTop(), element.get$$$dom_scrollWidth(), element.get$$$dom_scrollHeight());
  var t4 = element.$dom_getBoundingClientRect$0();
  return new $._ElementRectImpl(element.$dom_getClientRects$0(), t4, t3, t2, t1);
};

$.toInt = function(receiver) {
  if (!(typeof receiver === 'number')) return receiver.toInt$0();
  if ($.isNaN(receiver) === true) throw $.captureStackTrace($.BadNumberFormatException$1('NaN'));
  if ($.isInfinite(receiver) === true) throw $.captureStackTrace($.BadNumberFormatException$1('Infinity'));
  var truncated = $.truncate(receiver);
  return (truncated == -0.0) ? 0 : truncated;
};

$.Mask$rectangle$4 = function(x, y, width, height) {
  var t1 = new $.Mask(null, null, null, null);
  t1.Mask$rectangle$4(x, y, width, height);
  return t1;
};

$._WebSocketEventsImpl$1 = function(_ptr) {
  return new $._WebSocketEventsImpl(_ptr);
};

$.collectionToString = function(c) {
  var result = $.StringBufferImpl$1('');
  $._emitCollection(c, result, $.List(null));
  return result.toString$0();
};

$.MetaInfo$3 = function(tag, tags, set) {
  return new $.MetaInfo(set, tags, tag);
};

$._MediaStreamEventsImpl$1 = function(_ptr) {
  return new $._MediaStreamEventsImpl(_ptr);
};

$.defineProperty = function(obj, property, value) {
  Object.defineProperty(obj, property,
      {value: value, enumerable: false, writable: true, configurable: true});
};

$.dynamicFunction = function(name$) {
  var f = (Object.prototype[name$]);
  if (!(f == null) && (!!f.methods)) return f.methods;
  var methods = ({});
  var dartMethod = (Object.getPrototypeOf($.CTC6)[name$]);
  !(dartMethod == null) && (methods['Object'] = dartMethod);
  var bind = (function() {return $.dynamicBind.$call$4(this, name$, methods, Array.prototype.slice.call(arguments));});
  bind.methods = methods;
  $.defineProperty((Object.prototype), name$, bind);
  return methods;
};

$.checkString = function(value) {
  if (!(typeof value === 'string')) {
    $.checkNull(value);
    throw $.captureStackTrace($.IllegalArgumentException$1(value));
  }
  return value;
};

$.div = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a / b) : $.div$slow(a, b);
};

$.stringFromCharCodes = function(charCodes) {
  for (var t1 = $.iterator(charCodes); t1.hasNext$0() === true; ) {
    var t2 = t1.next$0();
    if (!((typeof t2 === 'number') && (t2 === (t2 | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(t2));
  }
  return String.fromCharCode.apply(null, charCodes);
};

$.DateImplementation$fromMillisecondsSinceEpoch$2 = function(millisecondsSinceEpoch, isUtc) {
  var t1 = new $.DateImplementation($.checkNull(isUtc), millisecondsSinceEpoch);
  t1.DateImplementation$fromMillisecondsSinceEpoch$2(millisecondsSinceEpoch, isUtc);
  return t1;
};

$.objectToString = function(object) {
  return 'Instance of \'' + $.S($.objectTypeName(object)) + '\'';
};

$.indexOf0 = function(a, element, startIndex, endIndex) {
  if (typeof a !== 'string' && (typeof a !== 'object' || a === null || (a.constructor !== Array && !a.is$JavaScriptIndexingBehavior()))) return $.indexOf0$bailout(1, a, element, startIndex, endIndex);
  if (typeof endIndex !== 'number') return $.indexOf0$bailout(1, a, element, startIndex, endIndex);
  if ($.geB(startIndex, a.length)) return -1;
  if ($.ltB(startIndex, 0)) startIndex = 0;
  if (typeof startIndex !== 'number') return $.indexOf0$bailout(2, a, element, startIndex, endIndex);
  for (var i = startIndex; i < endIndex; ++i) {
    if (i !== (i | 0)) throw $.iae(i);
    var t1 = a.length;
    if (i < 0 || i >= t1) throw $.ioore(i);
    if ($.eqB(a[i], element)) return i;
  }
  return -1;
};

$._firstProbe = function(hashCode, length$) {
  return $.and(hashCode, $.sub(length$, 1));
};

$.set$length = function(receiver, newLength) {
  if ($.isJsArray(receiver) === true) {
    $.checkNull(newLength);
    if (!((typeof newLength === 'number') && (newLength === (newLength | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(newLength));
    if (newLength < 0) throw $.captureStackTrace($.IndexOutOfRangeException$1(newLength));
    $.checkGrowable(receiver, 'set length');
    receiver.length = newLength;
  } else receiver.set$length(newLength);
  return newLength;
};

$.ioore = function(index) {
  throw $.captureStackTrace($.IndexOutOfRangeException$1(index));
};

$.gt$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a > b;
  return a.operator$gt$1(b);
};

$.forEach = function(receiver, f) {
  if ($.isJsArray(receiver) !== true) return receiver.forEach$1(f);
  return $.forEach0(receiver, f);
};

$.Bitmap$3 = function(bitmapData, pixelSnapping, smoothing) {
  var t1 = new $.Bitmap(null, smoothing, pixelSnapping, bitmapData, null, null, null, null, '', true, 1.0, null, null, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, null);
  t1.DisplayObject$0();
  t1.Bitmap$3(bitmapData, pixelSnapping, smoothing);
  return t1;
};

$.forEach0 = function(iterable, f) {
  for (var t1 = $.iterator(iterable); t1.hasNext$0() === true; ) {
    f.$call$1(t1.next$0());
  }
};

$.typeNameInFirefox = function(obj) {
  var name$ = $.constructorNameFallback(obj);
  if ($.eqB(name$, 'Window')) return 'DOMWindow';
  if ($.eqB(name$, 'Document')) return 'HTMLDocument';
  if ($.eqB(name$, 'XMLDocument')) return 'Document';
  if ($.eqB(name$, 'WorkerMessageEvent')) return 'MessageEvent';
  return name$;
};

$._color2rgb = function(color) {
  var r = $.and($.shr(color, 16), 255);
  var g = $.and($.shr(color, 8), 255);
  var b = $.and($.shr(color, 0), 255);
  return 'rgb(' + $.S(r) + ',' + $.S(g) + ',' + $.S(b) + ')';
};

$._parent = function(win) {
  return win.parent;;
};

$.forEach1 = function(iterable, f) {
  for (var t1 = $.iterator(iterable); t1.hasNext$0() === true; ) {
    f.$call$1(t1.next$0());
  }
};

$.hashCode = function(receiver) {
  if (typeof receiver === 'number') return receiver & 0x1FFFFFFF;
  if (!(typeof receiver === 'string')) return receiver.hashCode$0();
  var length$ = (receiver.length);
  for (var hash = 0, i = 0; i < length$; ++i) {
    var hash0 = 536870911 & hash + (receiver.charCodeAt(i));
    var hash1 = 536870911 & hash0 + (524287 & hash0 << 10);
    hash1 = (hash1 ^ $.shr(hash1, 6)) >>> 0;
    hash = hash1;
  }
  hash0 = 536870911 & hash + (67108863 & hash << 3);
  hash0 = (hash0 ^ $.shr(hash0, 11)) >>> 0;
  return 536870911 & hash0 + (16383 & hash0 << 15);
};

$.createFromCharCodes = function(charCodes) {
  $.checkNull(charCodes);
  if ($.isJsArray(charCodes) !== true) {
    if (!((typeof charCodes === 'object' && charCodes !== null) && (((charCodes.constructor === Array) || charCodes.is$List0())))) throw $.captureStackTrace($.IllegalArgumentException$1(charCodes));
    var charCodes0 = $.List$from(charCodes);
    charCodes = charCodes0;
  }
  return $.stringFromCharCodes(charCodes);
};

$.startsWith = function(receiver, other) {
  if (!(typeof receiver === 'string')) return receiver.startsWith$1(other);
  $.checkString(other);
  var length$ = $.get$length(other);
  if ($.gtB(length$, receiver.length)) return false;
  return other == receiver.substring(0, length$);
};

$.le = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a <= b) : $.le$slow(a, b);
};

$.toStringForNativeObject = function(obj) {
  return 'Instance of ' + $.S($.getTypeNameOf(obj));
};

$.removeLast = function(receiver) {
  if ($.isJsArray(receiver) === true) {
    $.checkGrowable(receiver, 'removeLast');
    var t1 = $.get$length(receiver);
    if (t1 === 0) throw $.captureStackTrace($.IndexOutOfRangeException$1(-1));
    return receiver.pop();
  }
  return receiver.removeLast$0();
};

$.dynamicBind = function(obj, name$, methods, arguments$) {
  var tag = $.getTypeNameOf(obj);
  var method = (methods[tag]);
  if (method == null) {
    var t1 = $._dynamicMetadata0();
    var t2 = !(t1 == null);
    t1 = t2;
  } else t1 = false;
  if (t1) {
    for (var i = 0; $.ltB(i, $.get$length($._dynamicMetadata0())); ++i) {
      var entry = $.index($._dynamicMetadata0(), i);
      if ($.contains$1(entry.get$set(), tag) === true) {
        method = (methods[entry.get$tag()]);
        if (!(method == null)) break;
      }
    }
  }
  if (method == null) method = (methods['Object']);
  var proto = (Object.getPrototypeOf(obj));
  if (method == null) method = (function () {if (Object.getPrototypeOf(this) === proto) {$.throwNoSuchMethod.$call$3(this, name$, Array.prototype.slice.call(arguments));} else {return Object.prototype[name$].apply(this, arguments);}});
  (!proto.hasOwnProperty(name$)) && $.defineProperty(proto, name$, method);
  return method.apply(obj, arguments$);
};

$._MessagePortEventsImpl$1 = function(_ptr) {
  return new $._MessagePortEventsImpl(_ptr);
};

$._document = function() {
  return document;;
};

$.getFunctionForTypeNameOf = function() {
  var t1 = (typeof(navigator));
  if (!(t1 === 'object')) return $.typeNameInChrome;
  var userAgent = (navigator.userAgent);
  if ($.contains$1(userAgent, $.CTC5) === true) return $.typeNameInChrome;
  if ($.contains$1(userAgent, 'Firefox') === true) return $.typeNameInFirefox;
  if ($.contains$1(userAgent, 'MSIE') === true) return $.typeNameInIE;
  return $.constructorNameFallback;
};

$.index = function(a, index) {
  if (typeof a == "string" || a.constructor === Array) {
    var key = (index >>> 0);
    if (key === index && key < (a.length)) return a[key];
  }
  return $.index$slow(a, index);
};

$._ElementEventsImpl$1 = function(_ptr) {
  return new $._ElementEventsImpl(_ptr);
};

$.instance = function() {
  if ($.eqNullB($._instance)) $._instance = $.Juggler$0();
  return $._instance;
};

$.TextField$0 = function() {
  var t1 = new $.TextField(null, null, 100, 100, true, null, null, 0, 0, 0, false, 0, false, false, 'dynamic', 'pixel', 'none', null, 0, '', 0, true, true, false, null, null, null, null, '', true, 1.0, null, null, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, null);
  t1.DisplayObject$0();
  t1.TextField$0();
  return t1;
};

$.sin = function(x) {
  return $.sin0(x);
};

$.sin0 = function(value) {
  return Math.sin($.checkNum(value));
};

$.List = function(length$) {
  return $.newList(length$);
};

$._createSafe = function(w) {
  var t1 = $.window();
  if (w == null ? t1 == null : w === t1) return w;
  return $._DOMWindowCrossFrameImpl$1(w);
};

$.SimpleButton$4 = function(upState, overState, downState, hitTestState) {
  var t1 = new $.SimpleButton(null, true, true, hitTestState, downState, overState, upState, 0, true, true, false, null, null, null, null, '', true, 1.0, null, null, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, null);
  t1.DisplayObject$0();
  t1.SimpleButton$4(upState, overState, downState, hitTestState);
  return t1;
};

$._XMLHttpRequestUploadEventsImpl$1 = function(_ptr) {
  return new $._XMLHttpRequestUploadEventsImpl(_ptr);
};

$.insertRange$3 = function(receiver, start, length$, initialValue) {
  if ($.isJsArray(receiver) !== true) return receiver.insertRange$3(start, length$, initialValue);
  return $.listInsertRange(receiver, start, length$, initialValue);
};

$.Event$2 = function(type, bubbles) {
  var t1 = new $.Event(false, false, null, null, null, null, null);
  t1.Event$2(type, bubbles);
  return t1;
};

$.captureStackTrace = function(ex) {
  var jsError = (new Error());
  jsError.dartException = ex;
  jsError.toString = $.toStringWrapper.$call$0;
  return jsError;
};

$.indexOf = function(a, element, startIndex, endIndex) {
  if (typeof a !== 'string' && (typeof a !== 'object' || a === null || (a.constructor !== Array && !a.is$JavaScriptIndexingBehavior()))) return $.indexOf$bailout(1, a, element, startIndex, endIndex);
  if (typeof endIndex !== 'number') return $.indexOf$bailout(1, a, element, startIndex, endIndex);
  if ($.geB(startIndex, a.length)) return -1;
  if ($.ltB(startIndex, 0)) startIndex = 0;
  if (typeof startIndex !== 'number') return $.indexOf$bailout(2, a, element, startIndex, endIndex);
  for (var i = startIndex; i < endIndex; ++i) {
    if (i !== (i | 0)) throw $.iae(i);
    var t1 = a.length;
    if (i < 0 || i >= t1) throw $.ioore(i);
    if ($.eqB(a[i], element)) return i;
  }
  return -1;
};

$.indexOf$1 = function(receiver, element) {
  if ($.isJsArray(receiver) === true) return $.indexOf(receiver, element, 0, (receiver.length));
  if (typeof receiver === 'string') {
    $.checkNull(element);
    if (!(typeof element === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(element));
    return receiver.indexOf(element);
  }
  return receiver.indexOf$1(element);
};

$.RenderLoop$0 = function() {
  var t1 = new $.RenderLoop((0/0), null, null);
  t1.RenderLoop$0();
  return t1;
};

$.StackOverflowException$0 = function() {
  return new $.StackOverflowException();
};

$.eq = function(a, b) {
  if (a == null) return b == null;
  if (typeof a === "object") {
    if (!!a.operator$eq$1) return a.operator$eq$1(b);
    return a === b;
  }
  return a === b;
};

$.StringBufferImpl$1 = function(content$) {
  var t1 = new $.StringBufferImpl(null, null);
  t1.StringBufferImpl$1(content$);
  return t1;
};

$.HashMapImplementation$0 = function() {
  var t1 = new $.HashMapImplementation(null, null, null, null, null);
  t1.HashMapImplementation$0();
  return t1;
};

$.substring$1 = function(receiver, startIndex) {
  if (!(typeof receiver === 'string')) return receiver.substring$1(startIndex);
  return $.substring$2(receiver, startIndex, null);
};

$.div$slow = function(a, b) {
  if ($.checkNumbers(a, b) === true) return a / b;
  return a.operator$div$1(b);
};

$.KeyboardEvent$2 = function(type, bubbles) {
  var t1 = new $.KeyboardEvent(0, 0, 0, false, false, false, false, false, false, false, null, null, null, null, null);
  t1.Event$2(type, bubbles);
  return t1;
};

$._SharedWorkerContextEventsImpl$1 = function(_ptr) {
  return new $._SharedWorkerContextEventsImpl(_ptr);
};

$._IDBVersionChangeRequestEventsImpl$1 = function(_ptr) {
  return new $._IDBVersionChangeRequestEventsImpl(_ptr);
};

$.easeInBack = function(ratio) {
  var t1 = $.mul(ratio, ratio);
  if (typeof ratio !== 'number') throw $.iae(ratio);
  return $.mul(t1, 2.70158 * ratio - 1.70158);
};

$.gtB = function(a, b) {
  if (typeof a === 'number' && typeof b === 'number') var t1 = (a > b);
  else {
    t1 = $.gt$slow(a, b);
    t1 = t1 === true;
  }
  return t1;
};

$.setRuntimeTypeInfo = function(target, typeInfo) {
  !(target == null) && (target.builtin$typeInfo = typeInfo);
};

$.document = function() {
  return document;;
};

$._FileWriterEventsImpl$1 = function(_ptr) {
  return new $._FileWriterEventsImpl(_ptr);
};

$.FutureNotCompleteException$0 = function() {
  return new $.FutureNotCompleteException();
};

$.NoSuchMethodException$4 = function(_receiver, _functionName, _arguments, existingArgumentNames) {
  return new $.NoSuchMethodException(existingArgumentNames, _arguments, _functionName, _receiver);
};

$.lt = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a < b) : $.lt$slow(a, b);
};

$.unwrapException = function(ex) {
  if ("dartException" in ex) return ex.dartException;
  var message = (ex.message);
  if (ex instanceof TypeError) {
    var type = (ex.type);
    var name$ = (ex.arguments ? ex.arguments[0] : "");
    if ($.eqB(type, 'property_not_function') || $.eqB(type, 'called_non_callable') || $.eqB(type, 'non_object_property_call') || $.eqB(type, 'non_object_property_load')) {
      if (typeof name$ === 'string' && $.startsWith(name$, '$call$') === true) return $.ObjectNotClosureException$0();
      return $.NullPointerException$2(null, $.CTC);
    }
    if ($.eqB(type, 'undefined_method')) {
      if (typeof name$ === 'string' && $.startsWith(name$, '$call$') === true) return $.ObjectNotClosureException$0();
      return $.NoSuchMethodException$4('', name$, [], null);
    }
    if (typeof message === 'string') {
      if ($.endsWith(message, 'is null') === true || $.endsWith(message, 'is undefined') === true || $.endsWith(message, 'is null or undefined') === true) return $.NullPointerException$2(null, $.CTC);
      if ($.endsWith(message, 'is not a function') === true) return $.NoSuchMethodException$4('', '<unknown>', [], null);
    }
    return $.ExceptionImplementation$1(typeof message === 'string' ? message : '');
  }
  if (ex instanceof RangeError) {
    if (typeof message === 'string' && $.contains$1(message, 'call stack') === true) return $.StackOverflowException$0();
    return $.IllegalArgumentException$1('');
  }
  if (typeof InternalError == 'function' && ex instanceof InternalError) {
    if (typeof message === 'string' && message === 'too much recursion') return $.StackOverflowException$0();
  }
  return ex;
};

$.ceil = function(receiver) {
  if (!(typeof receiver === 'number')) return receiver.ceil$0();
  return Math.ceil(receiver);
};

$.getTypeNameOf = function(obj) {
  var t1 = $._getTypeNameOf;
  if (t1 == null) $._getTypeNameOf = $.getFunctionForTypeNameOf();
  return $._getTypeNameOf.$call$1(obj);
};

$.cos = function(x) {
  return $.cos0(x);
};

$.cos0 = function(value) {
  return Math.cos($.checkNum(value));
};

$.sub = function(a, b) {
  return typeof a === 'number' && typeof b === 'number' ? (a - b) : $.sub$slow(a, b);
};

$._toJsStringArray$bailout = function(state, strings) {
  $.checkNull(strings);
  var length$ = $.get$length(strings);
  if ($.isJsArray(strings) === true) {
    for (var i = 0; $.ltB(i, length$); ++i) {
      var string = $.index(strings, i);
      $.checkNull(string);
      if (!(typeof string === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(string));
    }
    var array = strings;
  } else {
    array = $.List(length$);
    for (i = 0; $.ltB(i, length$); ++i) {
      string = $.index(strings, i);
      $.checkNull(string);
      if (!(typeof string === 'string')) throw $.captureStackTrace($.IllegalArgumentException$1(string));
      var t1 = array.length;
      if (i < 0 || i >= t1) throw $.ioore(i);
      array[i] = string;
    }
  }
  return array;
};

$.dispatchEvent$bailout = function(state, env0, env1) {
  switch (state) {
    case 1:
      var event$ = env0;
      eventDispatchers = env1;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      if (state == 1 || (state == 0 && !$.eqNullB($._eventDispatcherMap))) {
        switch (state) {
          case 0:
            var eventDispatchers = $.index($._eventDispatcherMap, event$.get$type());
          case 1:
            state = 0;
            if (!$.eqNullB(eventDispatchers)) {
              var eventDispatchersLength = $.get$length(eventDispatchers);
              for (var c = 0, i = 0; $.ltB(i, eventDispatchersLength); ++i) {
                var eventDispatcher = $.index(eventDispatchers, i);
                if (!$.eqNullB(eventDispatcher)) {
                  eventDispatcher.dispatchEvent$1(event$);
                  if (!(c === i)) $.indexSet(eventDispatchers, c, eventDispatcher);
                  ++c;
                }
              }
              for (i = eventDispatchersLength; $.ltB(i, $.get$length(eventDispatchers)); i = $.add(i, 1)) {
                var c0 = c + 1;
                $.indexSet(eventDispatchers, c, $.index(eventDispatchers, i));
                c = c0;
              }
              $.set$length(eventDispatchers, c);
            }
        }
      }
  }
};

$.copy$bailout = function(state, env0, env1, env2, env3, env4) {
  switch (state) {
    case 1:
      var src = env0;
      var srcStart = env1;
      var dst = env2;
      var dstStart = env3;
      var count = env4;
      break;
    case 1:
      src = env0;
      srcStart = env1;
      dst = env2;
      dstStart = env3;
      count = env4;
      break;
    case 1:
      src = env0;
      srcStart = env1;
      dst = env2;
      dstStart = env3;
      count = env4;
      break;
    case 2:
      src = env0;
      dst = env1;
      dstStart = env2;
      count = env3;
      srcStart = env4;
      break;
    case 3:
      src = env0;
      dst = env1;
      count = env2;
      srcStart = env3;
      dstStart = env4;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 1:
      state = 0;
    case 1:
      state = 0;
      if (srcStart == null) srcStart = 0;
    case 2:
      state = 0;
      if (dstStart == null) dstStart = 0;
    case 3:
      state = 0;
      if ($.ltB(srcStart, dstStart)) {
        for (var i = $.sub($.add(srcStart, count), 1), j = $.sub($.add(dstStart, count), 1); $.geB(i, srcStart); i = $.sub(i, 1), j = $.sub(j, 1)) {
          $.indexSet(dst, j, $.index(src, i));
        }
      } else {
        for (i = srcStart, j = dstStart; $.ltB(i, $.add(srcStart, count)); i = $.add(i, 1), j = $.add(j, 1)) {
          $.indexSet(dst, j, $.index(src, i));
        }
      }
  }
};

$.indexOf0$bailout = function(state, env0, env1, env2, env3) {
  switch (state) {
    case 1:
      var a = env0;
      var element = env1;
      var startIndex = env2;
      var endIndex = env3;
      break;
    case 1:
      a = env0;
      element = env1;
      startIndex = env2;
      endIndex = env3;
      break;
    case 2:
      a = env0;
      element = env1;
      startIndex = env2;
      endIndex = env3;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 1:
      state = 0;
      if ($.geB(startIndex, $.get$length(a))) return -1;
      if ($.ltB(startIndex, 0)) startIndex = 0;
    case 2:
      state = 0;
      for (var i = startIndex; $.ltB(i, endIndex); i = $.add(i, 1)) {
        if ($.eqB($.index(a, i), element)) return i;
      }
      return -1;
  }
};

$.indexOf$bailout = function(state, env0, env1, env2, env3) {
  switch (state) {
    case 1:
      var a = env0;
      var element = env1;
      var startIndex = env2;
      var endIndex = env3;
      break;
    case 1:
      a = env0;
      element = env1;
      startIndex = env2;
      endIndex = env3;
      break;
    case 2:
      a = env0;
      element = env1;
      startIndex = env2;
      endIndex = env3;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
    case 1:
      state = 0;
      if ($.geB(startIndex, $.get$length(a))) return -1;
      if ($.ltB(startIndex, 0)) startIndex = 0;
    case 2:
      state = 0;
      for (var i = startIndex; $.ltB(i, endIndex); i = $.add(i, 1)) {
        if ($.eqB($.index(a, i), element)) return i;
      }
      return -1;
  }
};

$.buildDynamicMetadata$bailout = function(state, env0, env1, env2, env3, env4, env5, env6) {
  switch (state) {
    case 1:
      var inputTable = env0;
      break;
    case 2:
      inputTable = env0;
      result = env1;
      tagNames = env2;
      tag = env3;
      i = env4;
      tags = env5;
      set = env6;
      break;
  }
  switch (state) {
    case 0:
    case 1:
      state = 0;
      var result = [];
      var i = 0;
    case 2:
      L0: while (true) {
        switch (state) {
          case 0:
            if (!$.ltB(i, $.get$length(inputTable))) break L0;
            var tag = $.index($.index(inputTable, i), 0);
            var tags = $.index($.index(inputTable, i), 1);
            var set = $.HashSetImplementation$0();
            $.setRuntimeTypeInfo(set, ({E: 'String'}));
            var tagNames = $.split(tags, '|');
          case 2:
            state = 0;
            for (var j = 0; $.ltB(j, $.get$length(tagNames)); ++j) {
              set.add$1($.index(tagNames, j));
            }
            $.add$1(result, $.MetaInfo$3(tag, tags, set));
            ++i;
        }
      }
      return result;
  }
};

$.listInsertRange$bailout = function(state, receiver, start, length$, initialValue) {
  if (length$ === 0) return;
  $.checkNull(start);
  $.checkNull(length$);
  if (!((typeof length$ === 'number') && (length$ === (length$ | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(length$));
  if (length$ < 0) throw $.captureStackTrace($.IllegalArgumentException$1(length$));
  if (!((typeof start === 'number') && (start === (start | 0)))) throw $.captureStackTrace($.IllegalArgumentException$1(start));
  var receiverLength = (receiver.length);
  if (start < 0 || start > receiverLength) throw $.captureStackTrace($.IndexOutOfRangeException$1(start));
  $.set$length(receiver, receiverLength + length$);
  $.copy(receiver, start, receiver, start + length$, receiverLength - start);
  if (!(initialValue == null)) {
    for (var i = start; $.ltB(i, $.add(start, length$)); i = $.add(i, 1)) {
      $.indexSet(receiver, i, initialValue);
    }
  }
  if (typeof length$ !== 'number') throw $.iae(length$);
  $.set$length(receiver, receiverLength + length$);
};

$.allMatchesInStringUnchecked$bailout = function(state, needle, haystack, length$, patternLength, result) {
  for (var startIndex = 0; true; ) {
    var position = $.indexOf$2(haystack, needle, startIndex);
    if ($.eqB(position, -1)) break;
    result.push($.StringMatch$3(position, haystack, needle));
    var endIndex = $.add(position, patternLength);
    if ($.eqB(endIndex, length$)) break;
    else {
      startIndex = $.eqB(position, endIndex) ? $.add(startIndex, 1) : endIndex;
    }
  }
  return result;
};

$.dynamicBind.$call$4 = $.dynamicBind;
$.dynamicBind.$name = "dynamicBind";
$.linear.$call$1 = $.linear;
$.linear.$name = "linear";
$.throwNoSuchMethod.$call$3 = $.throwNoSuchMethod;
$.throwNoSuchMethod.$name = "throwNoSuchMethod";
$.invokeClosure.$call$5 = $.invokeClosure;
$.invokeClosure.$name = "invokeClosure";
$.typeNameInChrome.$call$1 = $.typeNameInChrome;
$.typeNameInChrome.$name = "typeNameInChrome";
$.toStringWrapper.$call$0 = $.toStringWrapper;
$.toStringWrapper.$name = "toStringWrapper";
$.typeNameInIE.$call$1 = $.typeNameInIE;
$.typeNameInIE.$name = "typeNameInIE";
$.easeInOutBack.$call$1 = $.easeInOutBack;
$.easeInOutBack.$name = "easeInOutBack";
$.typeNameInFirefox.$call$1 = $.typeNameInFirefox;
$.typeNameInFirefox.$name = "typeNameInFirefox";
$.constructorNameFallback.$call$1 = $.constructorNameFallback;
$.constructorNameFallback.$name = "constructorNameFallback";
Isolate.$finishClasses($$);
$$ = {};
Isolate.makeConstantList = function(list) {
  list.immutable$list = true;
  list.fixed$length = true;
  return list;
};
$.CTC = Isolate.makeConstantList([]);
$.CTC3 = new Isolate.$isolateProperties._SimpleClientRect(0, 0, 0, 0);
$.CTC4 = new Isolate.$isolateProperties.EmptyElementRect(Isolate.$isolateProperties.CTC, Isolate.$isolateProperties.CTC3, Isolate.$isolateProperties.CTC3, Isolate.$isolateProperties.CTC3, Isolate.$isolateProperties.CTC3);
$.CTC2 = new Isolate.$isolateProperties.JSSyntaxRegExp(false, false, '^#[_a-zA-Z]\\w*$');
$.CTC1 = new Isolate.$isolateProperties._DeletedKeySentinel();
$.CTC5 = new Isolate.$isolateProperties.JSSyntaxRegExp(false, false, 'Chrome|DumpRenderTree');
$.CTC6 = new Isolate.$isolateProperties.Object();
$.CTC0 = new Isolate.$isolateProperties.NoMoreElementsException();
$._pendingRequests = null;
$.resource = null;
$.__eventDispatcher = null;
$._isCursorHidden = false;
$._getTypeNameOf = null;
$._customCursor = 'auto';
$._cachedBrowserPrefix = null;
$._nextMeasurementFrameScheduled = false;
$._firstMeasurementRequest = true;
$._pendingMeasurementFrameCallbacks = null;
$._eventDispatcherMap = null;
$._instance = null;
var $ = null;
Isolate.$finishClasses($$);
$$ = {};
Isolate = Isolate.$finishIsolateConstructor(Isolate);
var $ = new Isolate();
$.$defineNativeClass = function(cls, fields, methods) {
  var generateGetterSetter = function(field, prototype) {
  var len = field.length;
  var lastChar = field[len - 1];
  var needsGetter = lastChar == '?' || lastChar == '=';
  var needsSetter = lastChar == '!' || lastChar == '=';
  if (needsGetter || needsSetter) field = field.substring(0, len - 1);
  if (needsGetter) {
    var getterString = "return this." + field + ";";
    prototype["get$" + field] = new Function(getterString);
  }
  if (needsSetter) {
    var setterString = "this." + field + " = v;";
    prototype["set$" + field] = new Function("v", setterString);
  }
  return field;
};
  for (var i = 0; i < fields.length; i++) {
    generateGetterSetter(fields[i], methods);
  }
  for (var method in methods) {
    $.dynamicFunction(method)[cls] = methods[method];
  }
};
$.defineProperty(Object.prototype, 'is$JavaScriptIndexingBehavior', function() { return false; });
$.defineProperty(Object.prototype, 'is$Collection', function() { return false; });
$.defineProperty(Object.prototype, 'is$List0', function() { return false; });
$.defineProperty(Object.prototype, 'is$Map', function() { return false; });
$.defineProperty(Object.prototype, 'toString$0', function() { return $.toStringForNativeObject(this); });
$.$defineNativeClass('AbstractWorker', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  if (Object.getPrototypeOf(this).hasOwnProperty('get$on')) {
    return $._AbstractWorkerEventsImpl$1(this);
  } else {
    return Object.prototype.get$on.call(this);
  }
 }
});

$.$defineNativeClass('HTMLAnchorElement', ["type?", "name?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('WebKitAnimation', ["name?"], {
});

$.$defineNativeClass('WebKitAnimationList', ["length?"], {
});

$.$defineNativeClass('HTMLAppletElement', ["width=", "name?", "height=", "align?"], {
});

$.$defineNativeClass('Attr', ["value=", "name?"], {
});

$.$defineNativeClass('AudioBuffer', ["length?"], {
});

$.$defineNativeClass('AudioContext', [], {
 listener$1: function(arg0) { return this.listener.$call$1(arg0); },
 get$on: function() {
  return $._AudioContextEventsImpl$1(this);
 }
});

$.$defineNativeClass('AudioNode', ["context?"], {
});

$.$defineNativeClass('AudioParam', ["value=", "name?"], {
});

$.$defineNativeClass('HTMLBRElement', [], {
 clear$0: function() { return this.clear.$call$0(); }
});

$.$defineNativeClass('BarInfo', ["visible?"], {
});

$.$defineNativeClass('HTMLBaseFontElement', ["size?", "color?"], {
});

$.$defineNativeClass('BatteryManager', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._BatteryManagerEventsImpl$1(this);
 }
});

$.$defineNativeClass('BiquadFilterNode', ["type?"], {
});

$.$defineNativeClass('Blob', ["type?", "size?"], {
});

$.$defineNativeClass('HTMLBodyElement', [], {
 get$on: function() {
  return $._BodyElementEventsImpl$1(this);
 }
});

$.$defineNativeClass('HTMLButtonElement', ["value=", "type?", "name?"], {
});

$.$defineNativeClass('CSSFontFaceRule', ["style?"], {
});

$.$defineNativeClass('WebKitCSSKeyframeRule', ["style?"], {
});

$.$defineNativeClass('WebKitCSSKeyframesRule', ["name?"], {
});

$.$defineNativeClass('WebKitCSSMatrix', ["d?", "c?", "b?", "a?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('CSSPageRule', ["style?"], {
});

$.$defineNativeClass('CSSRule', ["type?"], {
});

$.$defineNativeClass('CSSRuleList', ["length?"], {
});

$.$defineNativeClass('CSSStyleDeclaration', ["length?"], {
 set$width: function(value) {
  this.setProperty$3('width', value, '');
 },
 get$width: function() {
  return this.getPropertyValue$1('width');
 },
 get$transform: function() {
  return this.getPropertyValue$1($.S($._browserPrefix()) + 'transform');
 },
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.get$transform().$call$6(arg0, arg1, arg2, arg3, arg4, arg5); },
 get$top: function() {
  return this.getPropertyValue$1('top');
 },
 set$textAlign: function(value) {
  this.setProperty$3('text-align', value, '');
 },
 set$src: function(value) {
  this.setProperty$3('src', value, '');
 },
 get$size: function() {
  return this.getPropertyValue$1('size');
 },
 get$right: function() {
  return this.getPropertyValue$1('right');
 },
 set$outline: function(value) {
  this.setProperty$3('outline', value, '');
 },
 set$mask: function(value) {
  this.setProperty$3($.S($._browserPrefix()) + 'mask', value, '');
 },
 get$mask: function() {
  return this.getPropertyValue$1($.S($._browserPrefix()) + 'mask');
 },
 get$left: function() {
  return this.getPropertyValue$1('left');
 },
 set$height: function(value) {
  this.setProperty$3('height', value, '');
 },
 get$height: function() {
  return this.getPropertyValue$1('height');
 },
 set$font: function(value) {
  this.setProperty$3('font', value, '');
 },
 get$font: function() {
  return this.getPropertyValue$1('font');
 },
 set$cursor: function(value) {
  this.setProperty$3('cursor', value, '');
 },
 get$color: function() {
  return this.getPropertyValue$1('color');
 },
 get$clip: function() {
  return this.getPropertyValue$1('clip');
 },
 clip$0: function() { return this.get$clip().$call$0(); },
 get$clear: function() {
  return this.getPropertyValue$1('clear');
 },
 clear$0: function() { return this.get$clear().$call$0(); },
 get$bottom: function() {
  return this.getPropertyValue$1('bottom');
 },
 setProperty$3: function(propertyName, value, priority) {
  return this.setProperty(propertyName,value,priority);
 },
 getPropertyValue$1: function(propertyName) {
  return this.getPropertyValue(propertyName);
 }
});

$.$defineNativeClass('CSSStyleRule', ["style?"], {
});

$.$defineNativeClass('CSSValueList', ["length?"], {
});

$.$defineNativeClass('HTMLCanvasElement', ["width=", "height="], {
 get$context2d: function() {
  return this.getContext$1('2d');
 },
 getContext$1: function(contextId) {
  return this.getContext(contextId);
 }
});

$.$defineNativeClass('CanvasRenderingContext', ["canvas?"], {
});

$.$defineNativeClass('CanvasRenderingContext2D', ["textBaseline!", "textAlign!", "strokeStyle!", "lineWidth!", "globalAlpha!", "font=", "fillStyle!"], {
 transform$6: function(m11, m12, m21, m22, dx, dy) {
  return this.transform(m11,m12,m21,m22,dx,dy);
 },
 strokeRect$5: function(x, y, width, height, lineWidth) {
  return this.strokeRect(x,y,width,height,lineWidth);
 },
 strokeRect$4: function(x,y,width,height) {
  return this.strokeRect(x,y,width,height);
},
 setTransform$6: function(m11, m12, m21, m22, dx, dy) {
  return this.setTransform(m11,m12,m21,m22,dx,dy);
 },
 save$0: function() {
  return this.save();
 },
 restore$0: function() {
  return this.restore();
 },
 rect$4: function(x, y, width, height) {
  return this.rect(x,y,width,height);
 },
 get$rect: function() { return new $.Closure27(this, 'rect$4'); },
 moveTo$2: function(x, y) {
  return this.moveTo(x,y);
 },
 measureText$1: function(text) {
  return this.measureText(text);
 },
 lineTo$2: function(x, y) {
  return this.lineTo(x,y);
 },
 fillText$4: function(text, x, y, maxWidth) {
  return this.fillText(text,x,y,maxWidth);
 },
 fillText$3: function(text,x,y) {
  return this.fillText(text,x,y);
},
 fillRect$4: function(x, y, width, height) {
  return this.fillRect(x,y,width,height);
 },
 drawImage$9: function(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh, dx, dy, dw, dh) {
  return this.drawImage(canvas_OR_image_OR_video,sx_OR_x,sy_OR_y,sw_OR_width,height_OR_sh,dx,dy,dw,dh);
 },
 drawImage$3: function(canvas_OR_image_OR_video,sx_OR_x,sy_OR_y) {
  return this.drawImage(canvas_OR_image_OR_video,sx_OR_x,sy_OR_y);
},
 clip$0: function() {
  return this.clip();
 },
 clearRect$4: function(x, y, width, height) {
  return this.clearRect(x,y,width,height);
 },
 beginPath$0: function() {
  return this.beginPath();
 },
 arc$6: function(x, y, radius, startAngle, endAngle, anticlockwise) {
  return this.arc(x,y,radius,startAngle,endAngle,anticlockwise);
 }
});

$.$defineNativeClass('CharacterData', ["length?"], {
});

$.$defineNativeClass('ClientRect', ["width?", "top?", "right?", "left?", "height?", "bottom?"], {
});

$.$defineNativeClass('ClientRectList', ["length?"], {
});

_ConsoleImpl = (typeof console == 'undefined' ? {} : console);
_ConsoleImpl.error$1 = function(arg) {
  return this.error(arg);
 };
_ConsoleImpl.get$error = function() { return new $.Closure28(this, 'error$1'); };
$.$defineNativeClass('DOMApplicationCache', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._DOMApplicationCacheEventsImpl$1(this);
 }
});

$.$defineNativeClass('DOMError', ["name?"], {
});

$.$defineNativeClass('DOMException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('DOMFileSystem', ["name?"], {
});

$.$defineNativeClass('DOMFileSystemSync', ["name?"], {
});

$.$defineNativeClass('DOMMimeType', ["type?"], {
});

$.$defineNativeClass('DOMMimeTypeArray', ["length?"], {
});

$.$defineNativeClass('DOMPlugin', ["name?", "length?"], {
});

$.$defineNativeClass('DOMPluginArray', ["length?"], {
});

$.$defineNativeClass('DOMSelection', ["type?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('DOMSettableTokenList', ["value="], {
});

$.$defineNativeClass('DOMStringList', ["length?"], {
 contains$1: function(string) {
  return this.contains(string);
 },
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'String'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot assign element of immutable List.'));
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('DOMTokenList', ["length?"], {
 toString$0: function() {
  return this.toString();
 },
 contains$1: function(token) {
  return this.contains(token);
 },
 add$1: function(token) {
  return this.add(token);
 }
});

$.$defineNativeClass('DataTransferItem', ["type?"], {
});

$.$defineNativeClass('DataTransferItemList', ["length?"], {
 clear$0: function() {
  return this.clear();
 },
 add$2: function(data_OR_file, type) {
  return this.add(data_OR_file,type);
 },
 add$1: function(data_OR_file) {
  return this.add(data_OR_file);
}
});

$.$defineNativeClass('DedicatedWorkerContext', [], {
 postMessage$2: function(message, messagePorts) {
  return this.postMessage(message,messagePorts);
 },
 get$on: function() {
  return $._DedicatedWorkerContextEventsImpl$1(this);
 }
});

$.$defineNativeClass('DeprecatedPeerConnection', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._DeprecatedPeerConnectionEventsImpl$1(this);
 }
});

$.$defineNativeClass('DeviceOrientationEvent', ["alpha?"], {
});

$.$defineNativeClass('HTMLDivElement', ["align?"], {
});

$.$defineNativeClass('HTMLDocument', [], {
 query$1: function(selectors) {
  if ($.CTC2.hasMatch$1(selectors) === true) return this.$dom_getElementById$1($.substring$1(selectors, 1));
  return this.$dom_querySelector$1(selectors);
 },
 $dom_querySelector$1: function(selectors) {
  return this.querySelector(selectors);
 },
 $dom_getElementById$1: function(elementId) {
  return this.getElementById(elementId);
 },
 $dom_createElement$1: function(tagName) {
  return this.createElement(tagName);
 },
 get$on: function() {
  return $._DocumentEventsImpl$1(this);
 }
});

$.$defineNativeClass('DocumentFragment', [], {
 $dom_querySelector$1: function(selectors) {
  return this.querySelector(selectors);
 },
 get$on: function() {
  return $._ElementEventsImpl$1(this);
 },
 focus$0: function() {
 },
 get$style: function() {
  return $.Element$tag('div').get$style();
 },
 get$parent: function() {
  return;
 },
 get$offsetParent: function() {
  return;
 },
 get$rect: function() {
  var t1 = new $.Closure15();
  var t2 = $.CompleterImpl$0();
  $.setRuntimeTypeInfo(t2, ({T: 'ElementRect'}));
  return $._createMeasurementFuture(t1, t2);
 },
 rect$4: function(arg0, arg1, arg2, arg3) { return this.get$rect().$call$4(arg0, arg1, arg2, arg3); },
 query$1: function(selectors) {
  return this.$dom_querySelector$1(selectors);
 }
});

$.$defineNativeClass('DocumentType', ["name?"], {
});

$.$defineNativeClass('Element', ["style?", "offsetParent?"], {
 $dom_querySelector$1: function(selectors) {
  return this.querySelector(selectors);
 },
 $dom_getClientRects$0: function() {
  return this.getClientRects();
 },
 $dom_getBoundingClientRect$0: function() {
  return this.getBoundingClientRect();
 },
 focus$0: function() {
  return this.focus();
 },
 get$$$dom_scrollWidth: function() {
  return this.scrollWidth;;
 },
 get$$$dom_scrollTop: function() {
  return this.scrollTop;;
 },
 get$$$dom_scrollLeft: function() {
  return this.scrollLeft;;
 },
 get$$$dom_scrollHeight: function() {
  return this.scrollHeight;;
 },
 get$$$dom_offsetWidth: function() {
  return this.offsetWidth;;
 },
 get$$$dom_offsetTop: function() {
  return this.offsetTop;;
 },
 get$$$dom_offsetLeft: function() {
  return this.offsetLeft;;
 },
 get$$$dom_offsetHeight: function() {
  return this.offsetHeight;;
 },
 get$$$dom_clientWidth: function() {
  return this.clientWidth;;
 },
 get$$$dom_clientTop: function() {
  return this.clientTop;;
 },
 get$$$dom_clientLeft: function() {
  return this.clientLeft;;
 },
 get$$$dom_clientHeight: function() {
  return this.clientHeight;;
 },
 get$on: function() {
  if (Object.getPrototypeOf(this).hasOwnProperty('get$on')) {
    return $._ElementEventsImpl$1(this);
  } else {
    return Object.prototype.get$on.call(this);
  }
 },
 get$rect: function() {
  var t1 = new $.Closure13(this);
  var t2 = $.CompleterImpl$0();
  $.setRuntimeTypeInfo(t2, ({T: 'ElementRect'}));
  return $._createMeasurementFuture(t1, t2);
 },
 rect$4: function(arg0, arg1, arg2, arg3) { return this.get$rect().$call$4(arg0, arg1, arg2, arg3); },
 query$1: function(selectors) {
  return this.$dom_querySelector$1(selectors);
 }
});

$.$defineNativeClass('HTMLEmbedElement', ["width=", "type?", "src!", "name?", "height=", "align?"], {
});

$.$defineNativeClass('Entry', ["name?"], {
 moveTo$4: function(parent, name, successCallback, errorCallback) {
  return this.moveTo(parent,name,$.convertDartClosureToJS(successCallback, 1),$.convertDartClosureToJS(errorCallback, 1));
 },
 moveTo$2: function(parent$,name$) {
  return this.moveTo(parent$,name$);
}
});

$.$defineNativeClass('EntryArray', ["length?"], {
});

$.$defineNativeClass('EntryArraySync', ["length?"], {
});

$.$defineNativeClass('EntrySync', ["name?"], {
 moveTo$2: function(parent, name) {
  return this.moveTo(parent,name);
 }
});

$.$defineNativeClass('ErrorEvent', ["message?"], {
});

$.$defineNativeClass('Event', ["type?", "bubbles?"], {
});

$.$defineNativeClass('EventException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('EventSource', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._EventSourceEventsImpl$1(this);
 }
});

$.$defineNativeClass('EventTarget', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  if (Object.getPrototypeOf(this).hasOwnProperty('$dom_addEventListener$3')) {
    return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
  } else {
    return Object.prototype.$dom_addEventListener$3.call(this, type, listener, useCapture);
  }
 },
 get$on: function() {
  if (Object.getPrototypeOf(this).hasOwnProperty('get$on')) {
    return $._EventsImpl$1(this);
  } else {
    return Object.prototype.get$on.call(this);
  }
 }
});

$.$defineNativeClass('HTMLFieldSetElement', ["type?", "name?"], {
 get$elements: function() {
  return this.lib$_FieldSetElementImpl$elements;
 },
 set$elements: function(x) {
  this.lib$_FieldSetElementImpl$elements = x;
 }
});

$.$defineNativeClass('File', ["name?"], {
});

$.$defineNativeClass('FileException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('FileList', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'File'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot assign element of immutable List.'));
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('FileReader', ["error?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._FileReaderEventsImpl$1(this);
 }
});

$.$defineNativeClass('FileWriter', ["length?", "error?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._FileWriterEventsImpl$1(this);
 }
});

$.$defineNativeClass('FileWriterSync', ["length?"], {
});

$.$defineNativeClass('Float32Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'num'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Float64Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'num'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('HTMLFontElement', ["size?", "color?"], {
});

$.$defineNativeClass('HTMLFormElement', ["name?", "length?"], {
 reset$0: function() {
  return this.reset();
 }
});

$.$defineNativeClass('HTMLFrameElement', ["width?", "src!", "name?", "height?"], {
});

$.$defineNativeClass('HTMLFrameSetElement', [], {
 get$on: function() {
  return $._FrameSetElementEventsImpl$1(this);
 }
});

$.$defineNativeClass('HTMLHRElement', ["width=", "size?", "align?"], {
});

$.$defineNativeClass('HTMLAllCollection', ["length?"], {
});

$.$defineNativeClass('HTMLCollection', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'Node'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot assign element of immutable List.'));
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('HTMLOptionsCollection', [], {
 set$length: function(value) {
  this.length = value;;
 },
 get$length: function() {
  return this.length;;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('HTMLHeadingElement', ["align?"], {
});

$.$defineNativeClass('History', ["length?"], {
});

$.$defineNativeClass('IDBCursorWithValue', ["value?"], {
});

$.$defineNativeClass('IDBDatabase', ["name?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._IDBDatabaseEventsImpl$1(this);
 }
});

$.$defineNativeClass('IDBDatabaseException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('IDBIndex', ["name?"], {
});

$.$defineNativeClass('IDBObjectStore', ["name?"], {
 clear$0: function() {
  return this.clear();
 },
 add$2: function(value, key) {
  return this.add(value,key);
 },
 add$1: function(value) {
  return this.add(value);
}
});

$.$defineNativeClass('IDBRequest', ["error?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  if (Object.getPrototypeOf(this).hasOwnProperty('$dom_addEventListener$3')) {
    return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
  } else {
    return Object.prototype.$dom_addEventListener$3.call(this, type, listener, useCapture);
  }
 },
 get$on: function() {
  if (Object.getPrototypeOf(this).hasOwnProperty('get$on')) {
    return $._IDBRequestEventsImpl$1(this);
  } else {
    return Object.prototype.get$on.call(this);
  }
 }
});

$.$defineNativeClass('IDBTransaction', ["error?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._IDBTransactionEventsImpl$1(this);
 }
});

$.$defineNativeClass('IDBVersionChangeRequest', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._IDBVersionChangeRequestEventsImpl$1(this);
 }
});

$.$defineNativeClass('HTMLIFrameElement', ["width=", "src!", "name?", "height=", "align?"], {
});

$.$defineNativeClass('ImageData', ["width?", "height?"], {
});

$.$defineNativeClass('HTMLImageElement', ["y?", "x?", "width=", "src!", "naturalWidth?", "naturalHeight?", "name?", "height=", "align?"], {
 complete$1: function(arg0) { return this.complete.$call$1(arg0); }
});

$.$defineNativeClass('HTMLInputElement', ["width=", "value=", "type?", "src!", "size?", "pattern?", "name?", "height=", "align?"], {
 get$on: function() {
  return $._InputElementEventsImpl$1(this);
 }
});

$.$defineNativeClass('Int16Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'int'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Int32Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'int'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Int8Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'int'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('JavaScriptAudioNode', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._JavaScriptAudioNodeEventsImpl$1(this);
 }
});

$.$defineNativeClass('JavaScriptCallFrame', ["type?"], {
});

$.$defineNativeClass('KeyboardEvent', ["shiftKey?", "keyLocation?", "ctrlKey?", "altKey?"], {
});

$.$defineNativeClass('HTMLKeygenElement', ["type?", "name?"], {
});

$.$defineNativeClass('HTMLLIElement', ["value=", "type?"], {
});

$.$defineNativeClass('HTMLLegendElement', ["align?"], {
});

$.$defineNativeClass('HTMLLinkElement', ["type?"], {
});

$.$defineNativeClass('LocalMediaStream', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 }
});

$.$defineNativeClass('Location', [], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('HTMLMapElement', ["name?"], {
});

$.$defineNativeClass('HTMLMarqueeElement', ["width=", "height="], {
});

$.$defineNativeClass('MediaController', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 }
});

$.$defineNativeClass('HTMLMediaElement', ["src!", "error?"], {
 load$0: function() {
  return this.load();
 },
 get$load: function() { return new $.Closure29(this, 'load$0'); },
 get$on: function() {
  return $._MediaElementEventsImpl$1(this);
 }
});

$.$defineNativeClass('MediaKeyEvent', ["message?"], {
});

$.$defineNativeClass('MediaList', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'String'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot assign element of immutable List.'));
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('MediaStream', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  if (Object.getPrototypeOf(this).hasOwnProperty('$dom_addEventListener$3')) {
    return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
  } else {
    return Object.prototype.$dom_addEventListener$3.call(this, type, listener, useCapture);
  }
 },
 get$on: function() {
  return $._MediaStreamEventsImpl$1(this);
 }
});

$.$defineNativeClass('MediaStreamList', ["length?"], {
});

$.$defineNativeClass('MediaStreamTrackList', ["length?"], {
});

$.$defineNativeClass('MessagePort', [], {
 postMessage$2: function(message, messagePorts) {
  return this.postMessage(message,messagePorts);
 },
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._MessagePortEventsImpl$1(this);
 }
});

$.$defineNativeClass('HTMLMetaElement', ["name?"], {
});

$.$defineNativeClass('Metadata', ["size?"], {
});

$.$defineNativeClass('HTMLMeterElement', ["value="], {
});

$.$defineNativeClass('MouseEvent', ["y?", "x?", "shiftKey?", "offsetY?", "offsetX?", "ctrlKey?", "button?", "altKey?"], {
});

$.$defineNativeClass('MutationRecord', ["type?"], {
});

$.$defineNativeClass('NamedNodeMap', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'Node'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot assign element of immutable List.'));
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Navigator', ["userAgent?"], {
});

$.$defineNativeClass('Node', [], {
 $dom_replaceChild$2: function(newChild, oldChild) {
  return this.replaceChild(newChild,oldChild);
 },
 $dom_removeChild$1: function(oldChild) {
  return this.removeChild(oldChild);
 },
 contains$1: function(other) {
  return this.contains(other);
 },
 $dom_appendChild$1: function(newChild) {
  return this.appendChild(newChild);
 },
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 set$text: function(value) {
  this.textContent = value;;
 },
 get$parent: function() {
  if (Object.getPrototypeOf(this).hasOwnProperty('get$parent')) {
    return this.parentNode;;
  } else {
    return Object.prototype.get$parent.call(this);
  }
 }
});

$.$defineNativeClass('NodeList', ["length?", "_parent?"], {
 operator$index$1: function(index) {
  return this[index];;
 },
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 last$0: function() {
  return this.operator$index$1($.sub($.get$length(this), 1));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 operator$indexSet$2: function(index, value) {
  this._parent.$dom_replaceChild$2(value, this.operator$index$1(index));
 },
 clear$0: function() {
  this._parent.set$text('');
 },
 removeLast$0: function() {
  var result = this.last$0();
  !$.eqNullB(result) && this._parent.$dom_removeChild$1(result);
  return result;
 },
 add$1: function(value) {
  this._parent.$dom_appendChild$1(value);
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'Node'}));
  return t1;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Notification', ["tag?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._NotificationEventsImpl$1(this);
 }
});

$.$defineNativeClass('HTMLOListElement', ["type?"], {
});

$.$defineNativeClass('HTMLObjectElement', ["width=", "type?", "name?", "height=", "align?"], {
});

$.$defineNativeClass('HTMLOptionElement', ["value="], {
});

$.$defineNativeClass('Oscillator', ["type?"], {
});

$.$defineNativeClass('HTMLOutputElement', ["value=", "type?", "name?"], {
});

$.$defineNativeClass('HTMLParagraphElement', ["align?"], {
});

$.$defineNativeClass('HTMLParamElement', ["value=", "type?", "name?"], {
});

$.$defineNativeClass('PeerConnection00', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._PeerConnection00EventsImpl$1(this);
 }
});

$.$defineNativeClass('PerformanceNavigation', ["type?"], {
});

$.$defineNativeClass('WebKitPoint', ["y=", "x="], {
});

$.$defineNativeClass('PositionError', ["message?"], {
});

$.$defineNativeClass('HTMLPreElement', ["width="], {
});

$.$defineNativeClass('HTMLProgressElement', ["value="], {
});

$.$defineNativeClass('RadioNodeList', ["value="], {
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Range', [], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('RangeException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('Rect', ["top?", "right?", "left?", "bottom?"], {
});

$.$defineNativeClass('SQLError', ["message?"], {
});

$.$defineNativeClass('SQLException', ["message?"], {
});

$.$defineNativeClass('SQLResultSetRowList', ["length?"], {
});

$.$defineNativeClass('SVGAElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGAngle', ["value="], {
});

$.$defineNativeClass('SVGCircleElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGClipPathElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGComponentTransferFunctionElement', ["type?", "offset?"], {
});

$.$defineNativeClass('SVGCursorElement', ["y?", "x?"], {
});

$.$defineNativeClass('SVGDefsElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGElementInstance', [], {
 dispatchEvent$1: function(event) {
  return this.dispatchEvent(event);
 },
 addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 addEventListener$2: function(type,listener) {
  listener = $.convertDartClosureToJS(listener, 1);
  return this.addEventListener(type,listener);
},
 get$on: function() {
  return $._SVGElementInstanceEventsImpl$1(this);
 }
});

$.$defineNativeClass('SVGElementInstanceList', ["length?"], {
});

$.$defineNativeClass('SVGEllipseElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('SVGFEBlendElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEColorMatrixElement', ["y?", "x?", "width?", "height?", "type?"], {
});

$.$defineNativeClass('SVGFEComponentTransferElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFECompositeElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEConvolveMatrixElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEDiffuseLightingElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEDisplacementMapElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEDropShadowElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEFloodElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEGaussianBlurElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEImageElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEMergeElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEMorphologyElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEOffsetElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFEPointLightElement', ["y?", "x?"], {
});

$.$defineNativeClass('SVGFESpecularLightingElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFESpotLightElement', ["y?", "x?"], {
});

$.$defineNativeClass('SVGFETileElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGFETurbulenceElement', ["y?", "x?", "width?", "height?", "type?"], {
});

$.$defineNativeClass('SVGFilterElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGForeignObjectElement', ["y?", "x?", "width?", "height?"], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGGElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGGlyphRefElement', ["y=", "x="], {
});

$.$defineNativeClass('SVGImageElement', ["y?", "x?", "width?", "height?"], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGLength', ["value="], {
});

$.$defineNativeClass('SVGLengthList', [], {
 clear$0: function() {
  return this.clear();
 }
});

$.$defineNativeClass('SVGLineElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGMaskElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGMatrix', ["d?", "c?", "b?", "a?"], {
});

$.$defineNativeClass('SVGNumber', ["value="], {
});

$.$defineNativeClass('SVGNumberList', [], {
 clear$0: function() {
  return this.clear();
 }
});

$.$defineNativeClass('SVGPathElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGPathSegArcAbs', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegArcRel', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoCubicAbs', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoCubicRel', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoCubicSmoothAbs', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoCubicSmoothRel', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoQuadraticAbs', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoQuadraticRel', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoQuadraticSmoothAbs', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegCurvetoQuadraticSmoothRel', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegLinetoAbs', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegLinetoHorizontalAbs', ["x="], {
});

$.$defineNativeClass('SVGPathSegLinetoHorizontalRel', ["x="], {
});

$.$defineNativeClass('SVGPathSegLinetoRel', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegLinetoVerticalAbs', ["y="], {
});

$.$defineNativeClass('SVGPathSegLinetoVerticalRel', ["y="], {
});

$.$defineNativeClass('SVGPathSegList', [], {
 clear$0: function() {
  return this.clear();
 }
});

$.$defineNativeClass('SVGPathSegMovetoAbs', ["y=", "x="], {
});

$.$defineNativeClass('SVGPathSegMovetoRel', ["y=", "x="], {
});

$.$defineNativeClass('SVGPatternElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGPoint', ["y=", "x="], {
});

$.$defineNativeClass('SVGPointList', [], {
 clear$0: function() {
  return this.clear();
 }
});

$.$defineNativeClass('SVGPolygonElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGPolylineElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGPreserveAspectRatio', ["align?"], {
});

$.$defineNativeClass('SVGRect', ["y=", "x=", "width=", "height="], {
});

$.$defineNativeClass('SVGRectElement', ["y?", "x?", "width?", "height?"], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGSVGElement', ["y?", "x?", "width?", "height?"], {
});

$.$defineNativeClass('SVGScriptElement', ["type?"], {
});

$.$defineNativeClass('SVGStopElement', ["offset?"], {
});

$.$defineNativeClass('SVGStringList', [], {
 clear$0: function() {
  return this.clear();
 }
});

$.$defineNativeClass('SVGStyleElement', ["type?"], {
});

$.$defineNativeClass('SVGSwitchElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGTextElement', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGTextPositioningElement', ["y?", "x?"], {
});

$.$defineNativeClass('SVGTransform', ["type?"], {
});

$.$defineNativeClass('SVGTransformList', [], {
 clear$0: function() {
  return this.clear();
 }
});

$.$defineNativeClass('SVGUseElement', ["y?", "x?", "width?", "height?"], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('SVGViewSpec', [], {
 transform$6: function(arg0, arg1, arg2, arg3, arg4, arg5) { return this.transform.$call$6(arg0, arg1, arg2, arg3, arg4, arg5); }
});

$.$defineNativeClass('Screen', ["width?", "height?"], {
});

$.$defineNativeClass('HTMLScriptElement', ["type?", "src!"], {
});

$.$defineNativeClass('ScriptProfileNode', ["visible?"], {
});

$.$defineNativeClass('HTMLSelectElement', ["value=", "type?", "size?", "name?", "length="], {
});

$.$defineNativeClass('ShadowRoot', [], {
 get$innerHTML: function() {
  return this.lib$_ShadowRootImpl$innerHTML;
 },
 set$innerHTML: function(x) {
  this.lib$_ShadowRootImpl$innerHTML = x;
 }
});

$.$defineNativeClass('SharedWorkerContext', ["name?"], {
 get$on: function() {
  return $._SharedWorkerContextEventsImpl$1(this);
 }
});

$.$defineNativeClass('HTMLSourceElement', ["type?", "src!"], {
});

$.$defineNativeClass('SpeechGrammar', ["src!"], {
});

$.$defineNativeClass('SpeechGrammarList', ["length?"], {
});

$.$defineNativeClass('SpeechInputResultList', ["length?"], {
});

$.$defineNativeClass('SpeechRecognition', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._SpeechRecognitionEventsImpl$1(this);
 }
});

$.$defineNativeClass('SpeechRecognitionError', ["message?"], {
});

$.$defineNativeClass('SpeechRecognitionResult', ["length?"], {
});

$.$defineNativeClass('SpeechRecognitionResultList', ["length?"], {
});

$.$defineNativeClass('Storage', [], {
 $dom_setItem$2: function(key, data) {
  return this.setItem(key,data);
 },
 $dom_key$1: function(index) {
  return this.key(index);
 },
 $dom_getItem$1: function(key) {
  return this.getItem(key);
 },
 $dom_clear$0: function() {
  return this.clear();
 },
 get$$$dom_length: function() {
  return this.length;;
 },
 isEmpty$0: function() {
  return $.eqNull(this.$dom_key$1(0));
 },
 get$length: function() {
  return this.get$$$dom_length();
 },
 forEach$1: function(f) {
  for (var i = 0; true; ++i) {
    var key = this.$dom_key$1(i);
    if ($.eqNullB(key)) return;
    f.$call$2(key, this.operator$index$1(key));
  }
 },
 clear$0: function() {
  return this.$dom_clear$0();
 },
 operator$indexSet$2: function(key, value) {
  return this.$dom_setItem$2(key, value);
 },
 operator$index$1: function(key) {
  return this.$dom_getItem$1(key);
 },
 containsKey$1: function(key) {
  return !$.eqNullB(this.$dom_getItem$1(key));
 },
 is$Map: function() { return true; }
});

$.$defineNativeClass('HTMLStyleElement', ["type?"], {
});

$.$defineNativeClass('StyleMedia', ["type?"], {
});

$.$defineNativeClass('StyleSheet', ["type?"], {
});

$.$defineNativeClass('StyleSheetList', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'StyleSheet'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot assign element of immutable List.'));
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('HTMLTableCaptionElement', ["align?"], {
});

$.$defineNativeClass('HTMLTableCellElement', ["width=", "height=", "align?"], {
});

$.$defineNativeClass('HTMLTableColElement', ["width=", "align?"], {
});

$.$defineNativeClass('HTMLTableElement', ["width=", "align?"], {
});

$.$defineNativeClass('HTMLTableRowElement', ["align?"], {
});

$.$defineNativeClass('HTMLTableSectionElement', ["align?"], {
});

$.$defineNativeClass('HTMLTextAreaElement', ["value=", "type?", "name?"], {
});

$.$defineNativeClass('TextMetrics', ["width?"], {
});

$.$defineNativeClass('TextTrack', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._TextTrackEventsImpl$1(this);
 }
});

$.$defineNativeClass('TextTrackCue', ["text!", "size?", "align?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._TextTrackCueEventsImpl$1(this);
 }
});

$.$defineNativeClass('TextTrackCueList', ["length?"], {
});

$.$defineNativeClass('TextTrackList', ["length?"], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._TextTrackListEventsImpl$1(this);
 }
});

$.$defineNativeClass('TimeRanges', ["length?"], {
});

$.$defineNativeClass('Touch', ["pageY?", "pageX?"], {
});

$.$defineNativeClass('TouchEvent', ["shiftKey?", "ctrlKey?", "altKey?"], {
});

$.$defineNativeClass('TouchList', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'Touch'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot assign element of immutable List.'));
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('HTMLTrackElement', ["src!"], {
});

$.$defineNativeClass('UIEvent', ["pageY?", "pageX?", "keyCode?", "charCode?"], {
});

$.$defineNativeClass('HTMLUListElement', ["type?"], {
});

$.$defineNativeClass('Uint16Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'int'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Uint32Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'int'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Uint8Array', ["length?"], {
 insertRange$3: function(start, rangeLength, initialValue) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot insertRange on immutable List.'));
 },
 removeRange$2: function(start, rangeLength) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeRange on immutable List.'));
 },
 removeLast$0: function() {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot removeLast on immutable List.'));
 },
 indexOf$2: function(element, start) {
  return $.indexOf0(this, element, start, $.get$length(this));
 },
 indexOf$1: function(element) {
  return this.indexOf$2(element,0)
},
 isEmpty$0: function() {
  return $.eq($.get$length(this), 0);
 },
 forEach$1: function(f) {
  return $.forEach1(this, f);
 },
 add$1: function(value) {
  throw $.captureStackTrace($.UnsupportedOperationException$1('Cannot add to immutable List.'));
 },
 iterator$0: function() {
  var t1 = $._FixedSizeListIterator$1(this);
  $.setRuntimeTypeInfo(t1, ({T: 'int'}));
  return t1;
 },
 operator$indexSet$2: function(index, value) {
  this[index] = value;
 },
 operator$index$1: function(index) {
  return this[index];;
 },
 is$JavaScriptIndexingBehavior: function() { return true; },
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('Uint8ClampedArray', [], {
 is$List0: function() { return true; },
 is$Collection: function() { return true; }
});

$.$defineNativeClass('HTMLVideoElement', ["width=", "height="], {
});

$.$defineNativeClass('WebGLActiveInfo', ["type?", "size?", "name?"], {
});

$.$defineNativeClass('WebGLContextAttributes', ["alpha="], {
});

$.$defineNativeClass('WebGLRenderingContext', [], {
 lineWidth$1: function(width) {
  return this.lineWidth(width);
 }
});

$.$defineNativeClass('WebKitNamedFlow', ["name?"], {
});

$.$defineNativeClass('WebSocket', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._WebSocketEventsImpl$1(this);
 }
});

$.$defineNativeClass('WheelEvent', ["y?", "x?", "wheelDelta?", "shiftKey?", "offsetY?", "offsetX?", "ctrlKey?", "altKey?"], {
});

$.$defineNativeClass('DOMWindow', ["parent?", "navigator?", "name?", "length?"], {
 setTimeout$2: function(handler, timeout) {
  return this.setTimeout($.convertDartClosureToJS(handler, 0),timeout);
 },
 postMessage$3: function(message, targetOrigin, messagePorts) {
  return this.postMessage(message,targetOrigin,messagePorts);
 },
 postMessage$2: function(message,targetOrigin) {
  return this.postMessage(message,targetOrigin);
},
 moveTo$2: function(x, y) {
  return this.moveTo(x,y);
 },
 focus$0: function() {
  return this.focus();
 },
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._WindowEventsImpl$1(this);
 },
 _ensureRequestAnimationFrame$0: function() {
     if (this.requestAnimationFrame && this.cancelAnimationFrame) return;
   var vendors = ['ms', 'moz', 'webkit', 'o'];
   for (var i = 0; i < vendors.length && !this.requestAnimationFrame; ++i) {
     this.requestAnimationFrame = this[vendors[i] + 'RequestAnimationFrame'];
     this.cancelAnimationFrame =
         this[vendors[i]+'CancelAnimationFrame'] ||
         this[vendors[i]+'CancelRequestAnimationFrame'];
   }
   if (this.requestAnimationFrame && this.cancelAnimationFrame) return;
   this.requestAnimationFrame = function(callback) {
       return window.setTimeout(callback, 16 /* 16ms ~= 60fps */);
   };
   this.cancelAnimationFrame = function(id) { clearTimeout(id); }
;
 },
 _lib_requestAnimationFrame$1: function(callback) {
  return this.requestAnimationFrame($.convertDartClosureToJS(callback, 1));
 },
 requestAnimationFrame$1: function(callback) {
  this._ensureRequestAnimationFrame$0();
  return this._lib_requestAnimationFrame$1(callback);
 },
 get$top: function() {
  return $._createSafe(this.get$_top());
 },
 get$_top: function() {
  return this.top;;
 }
});

$.$defineNativeClass('Worker', [], {
 postMessage$2: function(message, messagePorts) {
  return this.postMessage(message,messagePorts);
 },
 get$on: function() {
  return $._WorkerEventsImpl$1(this);
 }
});

$.$defineNativeClass('WorkerContext', ["navigator?"], {
 setTimeout$2: function(handler, timeout) {
  return this.setTimeout($.convertDartClosureToJS(handler, 0),timeout);
 },
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  if (Object.getPrototypeOf(this).hasOwnProperty('get$on')) {
    return $._WorkerContextEventsImpl$1(this);
  } else {
    return Object.prototype.get$on.call(this);
  }
 }
});

$.$defineNativeClass('WorkerLocation', [], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('WorkerNavigator', ["userAgent?"], {
});

$.$defineNativeClass('XMLHttpRequest', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._XMLHttpRequestEventsImpl$1(this);
 }
});

$.$defineNativeClass('XMLHttpRequestException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('XMLHttpRequestUpload', [], {
 $dom_addEventListener$3: function(type, listener, useCapture) {
  return this.addEventListener(type,$.convertDartClosureToJS(listener, 1),useCapture);
 },
 get$on: function() {
  return $._XMLHttpRequestUploadEventsImpl$1(this);
 }
});

$.$defineNativeClass('XPathException', ["name?", "message?"], {
 toString$0: function() {
  return this.toString();
 }
});

$.$defineNativeClass('XSLTProcessor', [], {
 reset$0: function() {
  return this.reset();
 }
});

$.$defineNativeClass('IDBOpenDBRequest', [], {
 get$on: function() {
  return $._IDBOpenDBRequestEventsImpl$1(this);
 }
});

// 292 dynamic classes.
// 411 classes
// 35 !leaf
(function(){
  var v0/*class(_SVGTextPositioningElementImpl)*/ = 'SVGTextPositioningElement|SVGTextElement|SVGTSpanElement|SVGTRefElement|SVGAltGlyphElement|SVGTextElement|SVGTSpanElement|SVGTRefElement|SVGAltGlyphElement';
  var v1/*class(_SVGComponentTransferFunctionElementImpl)*/ = 'SVGComponentTransferFunctionElement|SVGFEFuncRElement|SVGFEFuncGElement|SVGFEFuncBElement|SVGFEFuncAElement|SVGFEFuncRElement|SVGFEFuncGElement|SVGFEFuncBElement|SVGFEFuncAElement';
  var v2/*class(_MediaElementImpl)*/ = 'HTMLMediaElement|HTMLVideoElement|HTMLAudioElement|HTMLVideoElement|HTMLAudioElement';
  var v3/*class(_UIEventImpl)*/ = 'UIEvent|WheelEvent|TouchEvent|TextEvent|SVGZoomEvent|MouseEvent|KeyboardEvent|CompositionEvent|WheelEvent|TouchEvent|TextEvent|SVGZoomEvent|MouseEvent|KeyboardEvent|CompositionEvent';
  var v4/*class(_ElementImpl)*/ = [v0/*class(_SVGTextPositioningElementImpl)*/,v0/*class(_SVGTextPositioningElementImpl)*/,v1/*class(_SVGComponentTransferFunctionElementImpl)*/,v0/*class(_SVGTextPositioningElementImpl)*/,v0/*class(_SVGTextPositioningElementImpl)*/,v1/*class(_SVGComponentTransferFunctionElementImpl)*/,v2/*class(_MediaElementImpl)*/,v0/*class(_SVGTextPositioningElementImpl)*/,v0/*class(_SVGTextPositioningElementImpl)*/,v1/*class(_SVGComponentTransferFunctionElementImpl)*/,v0/*class(_SVGTextPositioningElementImpl)*/,v0/*class(_SVGTextPositioningElementImpl)*/,v1/*class(_SVGComponentTransferFunctionElementImpl)*/,v2/*class(_MediaElementImpl)*/,'Element|HTMLUnknownElement|HTMLUListElement|HTMLTrackElement|HTMLTitleElement|HTMLTextAreaElement|HTMLTableSectionElement|HTMLTableRowElement|HTMLTableElement|HTMLTableColElement|HTMLTableCellElement|HTMLTableCaptionElement|HTMLStyleElement|HTMLSpanElement|HTMLSourceElement|HTMLShadowElement|HTMLSelectElement|HTMLScriptElement|SVGElement|SVGViewElement|SVGVKernElement|SVGUseElement|SVGTitleElement|SVGTextContentElement|SVGTextPathElement|SVGTextPathElement|SVGSymbolElement|SVGSwitchElement|SVGStyleElement|SVGStopElement|SVGScriptElement|SVGSVGElement|SVGRectElement|SVGPolylineElement|SVGPolygonElement|SVGPatternElement|SVGPathElement|SVGMissingGlyphElement|SVGMetadataElement|SVGMaskElement|SVGMarkerElement|SVGMPathElement|SVGLineElement|SVGImageElement|SVGHKernElement|SVGGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGGlyphRefElement|SVGGlyphElement|SVGGElement|SVGForeignObjectElement|SVGFontFaceUriElement|SVGFontFaceSrcElement|SVGFontFaceNameElement|SVGFontFaceFormatElement|SVGFontFaceElement|SVGFontElement|SVGFilterElement|SVGFETurbulenceElement|SVGFETileElement|SVGFESpotLightElement|SVGFESpecularLightingElement|SVGFEPointLightElement|SVGFEOffsetElement|SVGFEMorphologyElement|SVGFEMergeNodeElement|SVGFEMergeElement|SVGFEImageElement|SVGFEGaussianBlurElement|SVGFEFloodElement|SVGFEDropShadowElement|SVGFEDistantLightElement|SVGFEDisplacementMapElement|SVGFEDiffuseLightingElement|SVGFEConvolveMatrixElement|SVGFECompositeElement|SVGFEComponentTransferElement|SVGFEColorMatrixElement|SVGFEBlendElement|SVGEllipseElement|SVGDescElement|SVGDefsElement|SVGCursorElement|SVGClipPathElement|SVGCircleElement|SVGAnimationElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGAltGlyphItemElement|SVGAltGlyphDefElement|SVGAElement|SVGViewElement|SVGVKernElement|SVGUseElement|SVGTitleElement|SVGTextContentElement|SVGTextPathElement|SVGTextPathElement|SVGSymbolElement|SVGSwitchElement|SVGStyleElement|SVGStopElement|SVGScriptElement|SVGSVGElement|SVGRectElement|SVGPolylineElement|SVGPolygonElement|SVGPatternElement|SVGPathElement|SVGMissingGlyphElement|SVGMetadataElement|SVGMaskElement|SVGMarkerElement|SVGMPathElement|SVGLineElement|SVGImageElement|SVGHKernElement|SVGGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGGlyphRefElement|SVGGlyphElement|SVGGElement|SVGForeignObjectElement|SVGFontFaceUriElement|SVGFontFaceSrcElement|SVGFontFaceNameElement|SVGFontFaceFormatElement|SVGFontFaceElement|SVGFontElement|SVGFilterElement|SVGFETurbulenceElement|SVGFETileElement|SVGFESpotLightElement|SVGFESpecularLightingElement|SVGFEPointLightElement|SVGFEOffsetElement|SVGFEMorphologyElement|SVGFEMergeNodeElement|SVGFEMergeElement|SVGFEImageElement|SVGFEGaussianBlurElement|SVGFEFloodElement|SVGFEDropShadowElement|SVGFEDistantLightElement|SVGFEDisplacementMapElement|SVGFEDiffuseLightingElement|SVGFEConvolveMatrixElement|SVGFECompositeElement|SVGFEComponentTransferElement|SVGFEColorMatrixElement|SVGFEBlendElement|SVGEllipseElement|SVGDescElement|SVGDefsElement|SVGCursorElement|SVGClipPathElement|SVGCircleElement|SVGAnimationElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGAltGlyphItemElement|SVGAltGlyphDefElement|SVGAElement|HTMLQuoteElement|HTMLProgressElement|HTMLPreElement|HTMLParamElement|HTMLParagraphElement|HTMLOutputElement|HTMLOptionElement|HTMLOptGroupElement|HTMLObjectElement|HTMLOListElement|HTMLModElement|HTMLMeterElement|HTMLMetaElement|HTMLMenuElement|HTMLMarqueeElement|HTMLMapElement|HTMLLinkElement|HTMLLegendElement|HTMLLabelElement|HTMLLIElement|HTMLKeygenElement|HTMLInputElement|HTMLImageElement|HTMLIFrameElement|HTMLHtmlElement|HTMLHeadingElement|HTMLHeadElement|HTMLHRElement|HTMLFrameSetElement|HTMLFrameElement|HTMLFormElement|HTMLFontElement|HTMLFieldSetElement|HTMLEmbedElement|HTMLDivElement|HTMLDirectoryElement|HTMLDetailsElement|HTMLDListElement|HTMLContentElement|HTMLCanvasElement|HTMLButtonElement|HTMLBodyElement|HTMLBaseFontElement|HTMLBaseElement|HTMLBRElement|HTMLAreaElement|HTMLAppletElement|HTMLAnchorElement|HTMLElement|HTMLUnknownElement|HTMLUListElement|HTMLTrackElement|HTMLTitleElement|HTMLTextAreaElement|HTMLTableSectionElement|HTMLTableRowElement|HTMLTableElement|HTMLTableColElement|HTMLTableCellElement|HTMLTableCaptionElement|HTMLStyleElement|HTMLSpanElement|HTMLSourceElement|HTMLShadowElement|HTMLSelectElement|HTMLScriptElement|SVGElement|SVGViewElement|SVGVKernElement|SVGUseElement|SVGTitleElement|SVGTextContentElement|SVGTextPathElement|SVGTextPathElement|SVGSymbolElement|SVGSwitchElement|SVGStyleElement|SVGStopElement|SVGScriptElement|SVGSVGElement|SVGRectElement|SVGPolylineElement|SVGPolygonElement|SVGPatternElement|SVGPathElement|SVGMissingGlyphElement|SVGMetadataElement|SVGMaskElement|SVGMarkerElement|SVGMPathElement|SVGLineElement|SVGImageElement|SVGHKernElement|SVGGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGGlyphRefElement|SVGGlyphElement|SVGGElement|SVGForeignObjectElement|SVGFontFaceUriElement|SVGFontFaceSrcElement|SVGFontFaceNameElement|SVGFontFaceFormatElement|SVGFontFaceElement|SVGFontElement|SVGFilterElement|SVGFETurbulenceElement|SVGFETileElement|SVGFESpotLightElement|SVGFESpecularLightingElement|SVGFEPointLightElement|SVGFEOffsetElement|SVGFEMorphologyElement|SVGFEMergeNodeElement|SVGFEMergeElement|SVGFEImageElement|SVGFEGaussianBlurElement|SVGFEFloodElement|SVGFEDropShadowElement|SVGFEDistantLightElement|SVGFEDisplacementMapElement|SVGFEDiffuseLightingElement|SVGFEConvolveMatrixElement|SVGFECompositeElement|SVGFEComponentTransferElement|SVGFEColorMatrixElement|SVGFEBlendElement|SVGEllipseElement|SVGDescElement|SVGDefsElement|SVGCursorElement|SVGClipPathElement|SVGCircleElement|SVGAnimationElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGAltGlyphItemElement|SVGAltGlyphDefElement|SVGAElement|SVGViewElement|SVGVKernElement|SVGUseElement|SVGTitleElement|SVGTextContentElement|SVGTextPathElement|SVGTextPathElement|SVGSymbolElement|SVGSwitchElement|SVGStyleElement|SVGStopElement|SVGScriptElement|SVGSVGElement|SVGRectElement|SVGPolylineElement|SVGPolygonElement|SVGPatternElement|SVGPathElement|SVGMissingGlyphElement|SVGMetadataElement|SVGMaskElement|SVGMarkerElement|SVGMPathElement|SVGLineElement|SVGImageElement|SVGHKernElement|SVGGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGRadialGradientElement|SVGLinearGradientElement|SVGGlyphRefElement|SVGGlyphElement|SVGGElement|SVGForeignObjectElement|SVGFontFaceUriElement|SVGFontFaceSrcElement|SVGFontFaceNameElement|SVGFontFaceFormatElement|SVGFontFaceElement|SVGFontElement|SVGFilterElement|SVGFETurbulenceElement|SVGFETileElement|SVGFESpotLightElement|SVGFESpecularLightingElement|SVGFEPointLightElement|SVGFEOffsetElement|SVGFEMorphologyElement|SVGFEMergeNodeElement|SVGFEMergeElement|SVGFEImageElement|SVGFEGaussianBlurElement|SVGFEFloodElement|SVGFEDropShadowElement|SVGFEDistantLightElement|SVGFEDisplacementMapElement|SVGFEDiffuseLightingElement|SVGFEConvolveMatrixElement|SVGFECompositeElement|SVGFEComponentTransferElement|SVGFEColorMatrixElement|SVGFEBlendElement|SVGEllipseElement|SVGDescElement|SVGDefsElement|SVGCursorElement|SVGClipPathElement|SVGCircleElement|SVGAnimationElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGSetElement|SVGAnimateTransformElement|SVGAnimateMotionElement|SVGAnimateElement|SVGAnimateColorElement|SVGAltGlyphItemElement|SVGAltGlyphDefElement|SVGAElement|HTMLQuoteElement|HTMLProgressElement|HTMLPreElement|HTMLParamElement|HTMLParagraphElement|HTMLOutputElement|HTMLOptionElement|HTMLOptGroupElement|HTMLObjectElement|HTMLOListElement|HTMLModElement|HTMLMeterElement|HTMLMetaElement|HTMLMenuElement|HTMLMarqueeElement|HTMLMapElement|HTMLLinkElement|HTMLLegendElement|HTMLLabelElement|HTMLLIElement|HTMLKeygenElement|HTMLInputElement|HTMLImageElement|HTMLIFrameElement|HTMLHtmlElement|HTMLHeadingElement|HTMLHeadElement|HTMLHRElement|HTMLFrameSetElement|HTMLFrameElement|HTMLFormElement|HTMLFontElement|HTMLFieldSetElement|HTMLEmbedElement|HTMLDivElement|HTMLDirectoryElement|HTMLDetailsElement|HTMLDListElement|HTMLContentElement|HTMLCanvasElement|HTMLButtonElement|HTMLBodyElement|HTMLBaseFontElement|HTMLBaseElement|HTMLBRElement|HTMLAreaElement|HTMLAppletElement|HTMLAnchorElement|HTMLElement'].join('|');
  var v5/*class(_DocumentFragmentImpl)*/ = 'DocumentFragment|ShadowRoot|ShadowRoot';
  var v6/*class(_DocumentImpl)*/ = 'HTMLDocument|SVGDocument|SVGDocument';
  var v7/*class(_CharacterDataImpl)*/ = 'CharacterData|Text|CDATASection|CDATASection|Comment|Text|CDATASection|CDATASection|Comment';
  var v8/*class(_WorkerContextImpl)*/ = 'WorkerContext|SharedWorkerContext|DedicatedWorkerContext|SharedWorkerContext|DedicatedWorkerContext';
  var v9/*class(_NodeImpl)*/ = [v4/*class(_ElementImpl)*/,v5/*class(_DocumentFragmentImpl)*/,v6/*class(_DocumentImpl)*/,v7/*class(_CharacterDataImpl)*/,v4/*class(_ElementImpl)*/,v5/*class(_DocumentFragmentImpl)*/,v6/*class(_DocumentImpl)*/,v7/*class(_CharacterDataImpl)*/,'Node|ProcessingInstruction|Notation|EntityReference|Entity|DocumentType|Attr|ProcessingInstruction|Notation|EntityReference|Entity|DocumentType|Attr'].join('|');
  var v10/*class(_MediaStreamImpl)*/ = 'MediaStream|LocalMediaStream|LocalMediaStream';
  var v11/*class(_IDBRequestImpl)*/ = 'IDBRequest|IDBOpenDBRequest|IDBVersionChangeRequest|IDBOpenDBRequest|IDBVersionChangeRequest';
  var v12/*class(_AbstractWorkerImpl)*/ = 'AbstractWorker|Worker|SharedWorker|Worker|SharedWorker';
  var table = [
    // [dynamic-dispatch-tag, tags of classes implementing dynamic-dispatch-tag]
    ['SVGTextPositioningElement', v0/*class(_SVGTextPositioningElementImpl)*/],
    ['StyleSheet', 'StyleSheet|CSSStyleSheet|CSSStyleSheet'],
    ['UIEvent', v3/*class(_UIEventImpl)*/],
    ['Uint8Array', 'Uint8Array|Uint8ClampedArray|Uint8ClampedArray'],
    ['AbstractWorker', v12/*class(_AbstractWorkerImpl)*/],
    ['AudioNode', 'AudioNode|WaveShaperNode|RealtimeAnalyserNode|JavaScriptAudioNode|DynamicsCompressorNode|DelayNode|ConvolverNode|BiquadFilterNode|AudioSourceNode|Oscillator|MediaElementAudioSourceNode|AudioBufferSourceNode|Oscillator|MediaElementAudioSourceNode|AudioBufferSourceNode|AudioPannerNode|AudioGainNode|AudioDestinationNode|AudioChannelSplitter|AudioChannelMerger|WaveShaperNode|RealtimeAnalyserNode|JavaScriptAudioNode|DynamicsCompressorNode|DelayNode|ConvolverNode|BiquadFilterNode|AudioSourceNode|Oscillator|MediaElementAudioSourceNode|AudioBufferSourceNode|Oscillator|MediaElementAudioSourceNode|AudioBufferSourceNode|AudioPannerNode|AudioGainNode|AudioDestinationNode|AudioChannelSplitter|AudioChannelMerger'],
    ['AudioParam', 'AudioParam|AudioGain|AudioGain'],
    ['WorkerContext', v8/*class(_WorkerContextImpl)*/],
    ['Blob', 'Blob|File|File'],
    ['CSSRule', 'CSSRule|CSSUnknownRule|CSSStyleRule|CSSPageRule|CSSMediaRule|WebKitCSSKeyframesRule|WebKitCSSKeyframeRule|CSSImportRule|CSSFontFaceRule|CSSCharsetRule|CSSUnknownRule|CSSStyleRule|CSSPageRule|CSSMediaRule|WebKitCSSKeyframesRule|WebKitCSSKeyframeRule|CSSImportRule|CSSFontFaceRule|CSSCharsetRule'],
    ['CSSValueList', 'CSSValueList|WebKitCSSFilterValue|WebKitCSSTransformValue|WebKitCSSFilterValue|WebKitCSSTransformValue'],
    ['CanvasRenderingContext', 'CanvasRenderingContext|WebGLRenderingContext|CanvasRenderingContext2D|WebGLRenderingContext|CanvasRenderingContext2D'],
    ['CharacterData', v7/*class(_CharacterDataImpl)*/],
    ['DOMTokenList', 'DOMTokenList|DOMSettableTokenList|DOMSettableTokenList'],
    ['HTMLDocument', v6/*class(_DocumentImpl)*/],
    ['DocumentFragment', v5/*class(_DocumentFragmentImpl)*/],
    ['SVGComponentTransferFunctionElement', v1/*class(_SVGComponentTransferFunctionElementImpl)*/],
    ['HTMLMediaElement', v2/*class(_MediaElementImpl)*/],
    ['Element', v4/*class(_ElementImpl)*/],
    ['Entry', 'Entry|FileEntry|DirectoryEntry|FileEntry|DirectoryEntry'],
    ['EntrySync', 'EntrySync|FileEntrySync|DirectoryEntrySync|FileEntrySync|DirectoryEntrySync'],
    ['Event', [v3/*class(_UIEventImpl)*/,v3/*class(_UIEventImpl)*/,'Event|WebGLContextEvent|WebKitTransitionEvent|TrackEvent|StorageEvent|SpeechRecognitionEvent|SpeechRecognitionError|SpeechInputEvent|ProgressEvent|XMLHttpRequestProgressEvent|XMLHttpRequestProgressEvent|PopStateEvent|PageTransitionEvent|OverflowEvent|OfflineAudioCompletionEvent|MutationEvent|MessageEvent|MediaStreamEvent|MediaKeyEvent|IDBVersionChangeEvent|HashChangeEvent|ErrorEvent|DeviceOrientationEvent|DeviceMotionEvent|CustomEvent|CloseEvent|BeforeLoadEvent|AudioProcessingEvent|WebKitAnimationEvent|WebGLContextEvent|WebKitTransitionEvent|TrackEvent|StorageEvent|SpeechRecognitionEvent|SpeechRecognitionError|SpeechInputEvent|ProgressEvent|XMLHttpRequestProgressEvent|XMLHttpRequestProgressEvent|PopStateEvent|PageTransitionEvent|OverflowEvent|OfflineAudioCompletionEvent|MutationEvent|MessageEvent|MediaStreamEvent|MediaKeyEvent|IDBVersionChangeEvent|HashChangeEvent|ErrorEvent|DeviceOrientationEvent|DeviceMotionEvent|CustomEvent|CloseEvent|BeforeLoadEvent|AudioProcessingEvent|WebKitAnimationEvent'].join('|')],
    ['Node', v9/*class(_NodeImpl)*/],
    ['MediaStream', v10/*class(_MediaStreamImpl)*/],
    ['IDBRequest', v11/*class(_IDBRequestImpl)*/],
    ['EventTarget', [v8/*class(_WorkerContextImpl)*/,v9/*class(_NodeImpl)*/,v10/*class(_MediaStreamImpl)*/,v11/*class(_IDBRequestImpl)*/,v12/*class(_AbstractWorkerImpl)*/,v8/*class(_WorkerContextImpl)*/,v9/*class(_NodeImpl)*/,v10/*class(_MediaStreamImpl)*/,v11/*class(_IDBRequestImpl)*/,v12/*class(_AbstractWorkerImpl)*/,'EventTarget|XMLHttpRequestUpload|XMLHttpRequest|DOMWindow|WebSocket|TextTrackList|TextTrackCue|TextTrack|SpeechRecognition|PeerConnection00|Notification|MessagePort|MediaController|IDBTransaction|IDBDatabase|FileWriter|FileReader|EventSource|DeprecatedPeerConnection|DOMApplicationCache|BatteryManager|AudioContext|XMLHttpRequestUpload|XMLHttpRequest|DOMWindow|WebSocket|TextTrackList|TextTrackCue|TextTrack|SpeechRecognition|PeerConnection00|Notification|MessagePort|MediaController|IDBTransaction|IDBDatabase|FileWriter|FileReader|EventSource|DeprecatedPeerConnection|DOMApplicationCache|BatteryManager|AudioContext'].join('|')],
    ['HTMLCollection', 'HTMLCollection|HTMLOptionsCollection|HTMLOptionsCollection'],
    ['NodeList', 'NodeList|RadioNodeList|RadioNodeList']];
$.dynamicSetMetadata(table);
})();

if (typeof window != 'undefined' && typeof document != 'undefined' &&
    window.addEventListener && document.readyState == 'loading') {
  window.addEventListener('DOMContentLoaded', function(e) {
    $.main();
  });
} else {
  $.main();
}
function init() {
  Isolate.$isolateProperties = {};
Isolate.$defineClass = function(cls, superclass, fields, prototype) {
  var generateGetterSetter = function(field, prototype) {
  var len = field.length;
  var lastChar = field[len - 1];
  var needsGetter = lastChar == '?' || lastChar == '=';
  var needsSetter = lastChar == '!' || lastChar == '=';
  if (needsGetter || needsSetter) field = field.substring(0, len - 1);
  if (needsGetter) {
    var getterString = "return this." + field + ";";
    prototype["get$" + field] = new Function(getterString);
  }
  if (needsSetter) {
    var setterString = "this." + field + " = v;";
    prototype["set$" + field] = new Function("v", setterString);
  }
  return field;
};
  var constructor;
  if (typeof fields == 'function') {
    constructor = fields;
  } else {
    var str = "function " + cls + "(";
    var body = "";
    for (var i = 0; i < fields.length; i++) {
      if (i != 0) str += ", ";
      var field = fields[i];
      field = generateGetterSetter(field, prototype);
      str += field;
      body += "this." + field + " = " + field + ";\n";
    }
    str += ") {" + body + "}\n";
    str += "return " + cls + ";";
    constructor = new Function(str)();
  }
  Isolate.$isolateProperties[cls] = constructor;
  constructor.prototype = prototype;
  if (superclass !== "") {
    Isolate.$pendingClasses[cls] = superclass;
  }
};
Isolate.$pendingClasses = {};
Isolate.$finishClasses = function(collectedClasses) {
  for (var collected in collectedClasses) {
    if (Object.prototype.hasOwnProperty.call(collectedClasses, collected)) {
      var desc = collectedClasses[collected];
      Isolate.$defineClass(collected, desc.super, desc[''], desc);
    }
  }
  var pendingClasses = Isolate.$pendingClasses;
  Isolate.$pendingClasses = {};
  var finishedClasses = {};
  function finishClass(cls) {
    if (finishedClasses[cls]) return;
    finishedClasses[cls] = true;
    var superclass = pendingClasses[cls];
    if (!superclass) return;
    finishClass(superclass);
    var constructor = Isolate.$isolateProperties[cls];
    var superConstructor = Isolate.$isolateProperties[superclass];
    var prototype = constructor.prototype;
    if (prototype.__proto__) {
      prototype.__proto__ = superConstructor.prototype;
      prototype.constructor = constructor;
    } else {
      function tmp() {};
      tmp.prototype = superConstructor.prototype;
      var newPrototype = new tmp();
      constructor.prototype = newPrototype;
      newPrototype.constructor = constructor;
      var hasOwnProperty = Object.prototype.hasOwnProperty;
      for (var member in prototype) {
        if (member == '' || member == 'super') continue;
        if (hasOwnProperty.call(prototype, member)) {
          newPrototype[member] = prototype[member];
        }
      }
    }
  }
  for (var cls in pendingClasses) finishClass(cls);
};
Isolate.$finishIsolateConstructor = function(oldIsolate) {
  var isolateProperties = oldIsolate.$isolateProperties;
  var isolatePrototype = oldIsolate.prototype;
  var str = "{\n";
  str += "var properties = Isolate.$isolateProperties;\n";
  for (var staticName in isolateProperties) {
    if (Object.prototype.hasOwnProperty.call(isolateProperties, staticName)) {
      str += "this." + staticName + "= properties." + staticName + ";\n";
    }
  }
  str += "}\n";
  var newIsolate = new Function(str);
  newIsolate.prototype = isolatePrototype;
  isolatePrototype.constructor = newIsolate;
  newIsolate.$isolateProperties = isolateProperties;
  return newIsolate;
};
}

//@ sourceMappingURL=.map