@TestOn('browser')
library events_test;

import 'package:stagexl/stagexl.dart';
import 'package:test/test.dart';

void main() {
  late EventDispatcher dispatcher;
  const eventType = 'TEST_EVENT_TYPE';

  setUp(() {
    dispatcher = EventDispatcher();
  });

  //----------

  test('EventDispatcher.addEventListener', () {
    expect(dispatcher.hasEventListener(eventType), isFalse);
    dispatcher.addEventListener(eventType, (event) => Never);
    expect(dispatcher.hasEventListener(eventType), isTrue);
  });

  test('EventDispatcher.removeEventListeners', () {
    dispatcher.addEventListener(eventType, (event) => Never);
    dispatcher.addEventListener(eventType, (event) => Never);
    expect(dispatcher.hasEventListener(eventType), isTrue);
    dispatcher.removeEventListeners(eventType);
    expect(dispatcher.hasEventListener(eventType), isFalse);
  });

  test('EventDispatcher.removeListener - test correct removal', () {
    final actual = <String>[];
    final expected = ['listener1', 'listener3'];

    void listener1(Event event) => actual.add('listener1');
    void listener2(Event event) => actual.add('listener2');

    dispatcher.addEventListener(eventType, listener1);
    dispatcher.addEventListener(eventType, listener2);
    dispatcher.addEventListener(eventType, (event) => actual.add('listener3'));
    dispatcher.removeEventListener(eventType, listener2);

    dispatcher.dispatchEvent(Event(eventType));
    expect(actual, equals(expected));
  });

  test(
      'EventDispatcher.addEventListener - test with priorities and correct fire order',
      () {
    final actual = <int>[];
    final expected = [1, 2, 3, 4];

    void listener1(Event event) => actual.add(4);
    void listener2(Event event) => actual.add(3);
    void listener3(Event event) => actual.add(2);
    void listener4(Event event) => actual.add(1);

    dispatcher.addEventListener(eventType, listener1, priority: -100);
    dispatcher.addEventListener(eventType, listener3, priority: 50);
    dispatcher.addEventListener(eventType, listener2, priority: 0);
    dispatcher.addEventListener(eventType, listener4, priority: 100);
    dispatcher.dispatchEvent(Event(eventType));
    expect(actual, equals(expected));
  });

  //----------

  test('EventStream.listen', () {
    dispatcher.on(eventType).listen((event) => Never);
    expect(dispatcher.hasEventListener(eventType), isTrue);
  });

  test('EventStreamSubscription.cancel', () {
    final subscription = dispatcher.on(eventType).listen((event) => Never);
    subscription.cancel();
    expect(dispatcher.hasEventListener(eventType), isFalse);
  });

  test('EventStreamSubscription.cancel - test correct removal', () {
    final actual = <String>[];
    final expected = ['listener1', 'listener3'];

    void listener1(Event event) => actual.add('listener1');
    void listener2(Event event) => actual.add('listener2');

    final sub1 = dispatcher.on(eventType).listen(listener1);
    final sub2 = dispatcher.on(eventType).listen(listener2);
    final sub3 =
        dispatcher.on(eventType).listen((event) => actual.add('listener3'));

    sub2.cancel();
    dispatcher.dispatchEvent(Event(eventType));

    expect(sub1.isCanceled, equals(false));
    expect(sub2.isCanceled, equals(true));
    expect(sub3.isCanceled, equals(false));
    expect(actual, equals(expected));
  });

  test('EventStream.listen - test with priorities and correct fire order', () {
    final actual = <int>[];
    final expected = [1, 2, 3, 4];

    void listener1(Event event) => actual.add(4);
    void listener2(Event event) => actual.add(3);
    void listener3(Event event) => actual.add(2);
    void listener4(Event event) => actual.add(1);

    dispatcher.on(eventType).listen(listener1, priority: -100);
    dispatcher.on(eventType).listen(listener3, priority: 50);
    dispatcher.on(eventType).listen(listener2, priority: 0);
    dispatcher.on(eventType).listen(listener4, priority: 100);
    dispatcher.dispatchEvent(Event(eventType));
    expect(actual, equals(expected));
  });

  //----------

  test('EventStream - test first future', () {
    dispatcher.on(eventType).first.then(expectAsync1((e) {
      // test will hang and fail if this function is not called
    }));
    expect(dispatcher.hasEventListener(eventType), isTrue);
    dispatcher.dispatchEvent(Event(eventType));
    expect(dispatcher.hasEventListener(eventType), isFalse);
  });
}
