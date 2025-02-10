import 'dart:io';

import 'package:isolate_streams/isolate_communication.dart';

int calculate() {
  return 6 * 7;
}



void startChat() async {
  final chatService = IsolateChatService();
  await chatService.start();

  while (true) {
    stdout.write("You: ");
    String input = stdin.readLineSync()?.trim() ?? "";
    if (input.toLowerCase() == "exit") {
      chatService.dispose();
      break;
    } else if (input.toLowerCase() == "pause") {
      chatService.pause();
    } else if (input.toLowerCase() == "resume") {
      chatService.resume();
    } else {
      await chatService.sendMessageToIsolate(input);
    }
  }
}
