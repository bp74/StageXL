library events_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {
  EventDispatcher dispatcher;
  const String eventType = "TEST_EVENT_TYPE";

  setUp(() {
    dispatcher = new EventDispatcher();
  });

  tearDown(() {
    dispatcher = null;
  });

  //----------

  test("event_dispatcher_add_event_listener", () {
    dispatcher.addEventListener(eventType, (Event event) => null);
    expect(dispatcher.hasEventListener(eventType), isTrue);
  });

  test("event_dispatcher_remove_event_listeners", () {
    dispatcher.addEventListener(eventType, (Event event) => null);
    dispatcher.addEventListener(eventType, (Event event) => null);
    dispatcher.removeEventListeners(eventType);
    expect(dispatcher.hasEventListener(eventType), isFalse);
  });

  test("event_dispatcher_remove_listener_verification", () {
    List actual = new List();
    List expected = ["listener1", "listener3"];

    void listener1(Event event) => actual.add("listener1");
    void listener2(Event event) => actual.add("listener2");

    dispatcher.addEventListener(eventType, listener1);
    dispatcher.addEventListener(eventType, listener2);
    dispatcher.addEventListener(eventType, (Event event) => actual.add("listener3"));
    dispatcher.removeEventListener(eventType, listener2);

    dispatcher.dispatchEvent(new Event(eventType));
    expect(actual, equals(expected));
  });

  //----------

  test("event_stream_listen", () {
    dispatcher.on(eventType).listen((Event event) => null);
    expect(dispatcher.hasEventListener(eventType), isTrue);
  });

  test("event_stream_subscription_cancel", () {
    var subscription = dispatcher.on(eventType).listen((Event event) => null);
    subscription.cancel();
    expect(dispatcher.hasEventListener(eventType), isFalse);
  });

  test("event_stream_subscription_cancel_verification", () {
    List actual = new List();
    List expected = ["listener1", "listener3"];

    void listener1(Event event) => actual.add("listener1");
    void listener2(Event event) => actual.add("listener2");

    var sub1 = dispatcher.on(eventType).listen(listener1);
    var sub2 = dispatcher.on(eventType).listen(listener2);
    var sub3 = dispatcher.on(eventType).listen((Event event) => actual.add("listener3"));

    sub2.cancel();

    dispatcher.dispatchEvent(new Event(eventType));
    expect(actual, equals(expected));
  });

  //----------

  /*
  test("addEventListener_with_priorities_dispatch_fires_in_correct_order", () {
    List actual = new List();
    List expected = [1, 2, 3, 4];

    void listener1(Event event) => actual.add(4);
    void listener2(Event event) => actual.add(3);
    void listener3(Event event) => actual.add(2);
    void listener4(Event event) => actual.add(1);

    dispatcher.addEventListener(eventType, listener1, priority: -100);
    dispatcher.addEventListener(eventType, listener2, priority: 0);
    dispatcher.addEventListener(eventType, listener3, priority: 50);
    dispatcher.addEventListener(eventType, listener4, priority: 100);
    dispatcher.dispatchEvent(new Event(eventType));
    expect(actual, equals(expected));
  });
  */
}