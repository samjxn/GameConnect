import 'package:w_flux/w_flux.dart';

class HelloWorldActions {

  Action<String> updateDisplayText = new Action<String>();
  Action<String> chatRoomMessageReceived = new Action<String>();
  Action<String> sendChatMessage = new Action<String>();
  Action connectionButtonPressed = new Action();


}