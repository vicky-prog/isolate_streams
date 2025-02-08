import 'dart:io';

import 'package:isolate_streams/isolate_communication.dart';

int calculate() {
  return 6 * 7;
}


void startChart() async{
 final chatService = IsolateChatService();  
  await chatService.start(); // ✅ Waits until the chat is ready before continuing

  while (true) {
    stdout.write("You: ");
    String input = stdin.readLineSync()!;
    if (input.toLowerCase() == "exit") {
      chatService.dispose();
      break;
    }
    await chatService.sendMessageToIsolate(input); // ✅ Waits for a response before next input
  }
}
