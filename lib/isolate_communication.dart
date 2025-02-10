import 'dart:isolate';
import 'dart:async';
import 'package:async/async.dart';


class IsolateChatService {
  late ReceivePort mainReceivePort;
  late SendPort isolateSendPort;
  late Isolate isolate;
  StreamSubscription? subscription;
  StreamQueue<String>? messageQueue;
  bool isPaused = false;

  final Completer<bool> _isolateReady = Completer<bool>();

  IsolateChatService() {
    mainReceivePort = ReceivePort();
    var broadcastStream = mainReceivePort.asBroadcastStream();
    messageQueue = StreamQueue(
      broadcastStream.where((msg) => msg is String).cast<String>(),
    );

    subscription = broadcastStream.listen((message) {
      if (message is SendPort) {
        isolateSendPort = message;
        _isolateReady.complete(true);
        print("✅ Chat Initialized! Start typing...");
      } else if (message is String) {
        print("📩 Received from Isolate: $message");
      }
    });
  }

  Future<void> start() async {
    isolate = await Isolate.spawn(_isolateFunction, mainReceivePort.sendPort);
    await _isolateReady.future;
  }

  Future<void> sendMessageToIsolate(String message) async {
    if (isPaused) {
      print("⚠️ Cannot send messages while paused.");
      return;
    }

    if (await _isolateReady.future) {
      isolateSendPort.send(message);
      print("📤 Sent to Isolate: $message");
      try {
        await messageQueue?.next.timeout(
          Duration(seconds: 5),
          onTimeout: () {
            return "⚠️ Timeout: No response from isolate.";
          },
        );
      } catch (e) {
        print("⚠️ Error while waiting for response: $e");
      }
    }
  }

  static void _isolateFunction(SendPort mainSendPort) {
    ReceivePort isolateReceivePort = ReceivePort();
    mainSendPort.send(isolateReceivePort.sendPort);

    isolateReceivePort.listen((message) {
      print("💬 Isolate received: $message");

      Future.delayed(Duration(seconds: 1), () {
        mainSendPort.send("Isolate says: $message (Got it!)");
      });
    });
  }

  void pause() {
    if (subscription != null) {
      subscription?.pause();
      isPaused = true;
      print("⏸️ Subscription paused.");
    } else {
      print("⚠️ No active subscription to pause.");
    }
  }

  void resume() {
    if (isPaused) {
      subscription?.resume();
      isPaused = false;
      print("▶️ Subscription resumed.");
    } else {
      print("⚠️ Subscription is already running.");
    }
  }

  void dispose() {
    isolate.kill(priority: Isolate.immediate);
    mainReceivePort.close();
    subscription?.cancel();
    messageQueue?.cancel();
    print("🚫 Chat closed.");
  }
}


