import 'dart:async';

import 'package:gcloud/pubsub.dart';

import 'pubsub.dart';

class Command {
  String id;

  Command(this.id);
}

Command transformToCommand(String text) {
  return Command(text);
}

class CommandController {
  final _streamController = StreamController<Command>();

  Subscription _subscription;

  Stream<Command> get stream {
    return _streamController.stream;
  }

  Sink<Command> get sink {
    return _streamController.sink;
  }

  CommandController() {
    getPubSub().then((pubsub) {
      return pubsub.lookupSubscription('videogator');
    }).then((subscription) {
      _subscription = subscription;
      pull(_subscription, _streamController);
    });
  }
}

void pull(Subscription sub, StreamController<Command> streamController) async {
  sub.pull(wait: false).then((pullEvent) {
    if (pullEvent == null) {
      print('pullEvent = null');
      pull(sub, streamController);
      return;
    }
    print('pullEventt = ${pullEvent.message.asString}');
    streamController.add(Command(pullEvent.message.asString));
    pullEvent.acknowledge();
    print('[ACK] pullEventt = ${pullEvent.message.asString}');
    pull(sub, streamController);
  });
}
