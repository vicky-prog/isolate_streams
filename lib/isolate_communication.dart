import 'dart:isolate';
import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';

class IsolateChatService {
  late ReceivePort mainReceivePort;
  late SendPort isolateSendPort;
  late Isolate isolate;
  final Completer<bool> _isolateReady = Completer<bool>(); // ✅ Ensures we wait until ready
  StreamQueue<String>? messageQueue; //  Handles multiple messages

  IsolateChatService() {
    mainReceivePort = ReceivePort();
    var broadcastStream = mainReceivePort.asBroadcastStream(); // ✅ Convert to Broadcast Stream
    messageQueue = StreamQueue(broadcastStream.where((msg) => msg is String).cast<String>()); // ✅ Only listen to String messages

    broadcastStream.listen((message) {
      if (message is SendPort) {
        isolateSendPort = message;
        _isolateReady.complete(true); // ✅ Mark chat as ready
        print("✅ Chat Initialized! Start typing...");
      } else if (message is String) {
        print("📩 Received from Isolate: $message");
      }
    });
  }

  Future<void> start() async {
    isolate = await Isolate.spawn(_isolateFunction, mainReceivePort.sendPort);
    await _isolateReady.future; // ✅ Wait until chat is ready
  }

  Future<void> sendMessageToIsolate(String message) async {
    if (await _isolateReady.future) { // ✅ Ensures chat is ready
      isolateSendPort.send(message);
      print("📤 Sent to Isolate: $message");
      await messageQueue?.next; // ✅ Wait for response
    }
  }

  static void _isolateFunction(SendPort mainSendPort) {
    ReceivePort isolateReceivePort = ReceivePort();
    mainSendPort.send(isolateReceivePort.sendPort); // ✅ Send back the SendPort

    isolateReceivePort.listen((message) {
      print("💬 Isolate received: $message");

      // Simulate typing delay before responding
      Future.delayed(Duration(seconds: 1), () {
        mainSendPort.send("Isolate says: $message (Got it!)");
      });
    });
  }

  void dispose() {
    isolate.kill(priority: Isolate.immediate);
    mainReceivePort.close();
    messageQueue?.cancel(); // ✅ Proper cleanup
    print("🚫 Chat closed.");
  }
}
