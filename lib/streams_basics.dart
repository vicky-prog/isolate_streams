part of 'isolate_communication.dart';

class StreamExample {
  StreamExample() {
    streamQueue = StreamQueue<int>(stream);
  }
  final stream = Stream.fromIterable([
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
  ]);

  late StreamQueue<int>? streamQueue;

  start() {
    stream.listen((event) => print(event), onDone: () {
      print("Stream Completed");
    });

// Transformations in Streams
    // Stream transformations let you manipulate or filter the data flowing through a stream.
    // You can apply transformations like map, where, expand, and asyncMap to modify, filter, or flatten the data.
    // 1. map

    stream.map((event) => event.isEven).listen(
      (event) {
        print(event); // Output: 2, 4, 6, 8, 10
      },
    );

    // 2. where

    stream.where((event) => event.isEven).listen((event) {
      print(event);
    });

    // 3. expand
    // Converts a single event into multiple events by expanding it into an iterable.

    stream.expand((event) => [event, event * 2]).listen((event) {
      print(event);
      // Output:
      // 1, 10
      // 2, 20
      // 3, 30
    });

    // 4. asyncMap
    //Transforms each event asynchronously, such as fetching data from an API.

    stream.asyncMap((event) async {
      return event * 3; // Simulates an async operation
    }).listen((event) {
      print(event);
    });
  }
}
