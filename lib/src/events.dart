/// The event classes are built on top of streams from the dart:async
/// library. The display list supports event capturing and bubbling of
/// events through the hierarchy of the display list.
///
/// All display objects extend the [EventDispatcher] class which is used
/// to listen to events as well as dispatching new events.
///
library stagexl.events;

import 'dart:async';

part 'events/broadcast_event.dart';
part 'events/event.dart';
part 'events/event_dispatcher.dart';
part 'events/event_phase.dart';
part 'events/event_stream.dart';
part 'events/event_stream_provider.dart';
part 'events/event_stream_subscription.dart';
part 'events/keyboard_event.dart';
part 'events/key_location.dart';
part 'events/mouse_event.dart';
part 'events/text_event.dart';
part 'events/touch_event.dart';