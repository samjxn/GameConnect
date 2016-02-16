import 'package:w_flux/w_flux.dart';
import 'package:hello_world/src/hello_world_actions.dart';
import 'package:hello_world/src/api.dart';

class ChatRoomStore extends Store {

  HelloWorldActions _actions;
  HelloWorldApi _api;
  bool _isConnected = false;

  List<String> _messages = ['hello', 'world'];


  bool get isConnected => _isConnected;
  List<String> get messages => _messages;

  ChatRoomStore(this._actions, this._api) {
    _actions.connectionButtonPressed.listen(_onConnectButtonPress);
    _actions.chatRoomMessageReceived.listen(_onMessageReceived);
    _actions.sendChatMessage.listen(_onSendChatMessage);
  }

  _onConnectButtonPress(dynamic) {
    _isConnected = !_isConnected;
    if (_isConnected) {
      _api.initWebSocket();
    } else {
      _api.closeSocket();
    }
    trigger();
  }

  _onMessageReceived(String msg) {
    _messages.add(msg);
    trigger();
  }

  _onSendChatMessage(String msg) {
    _api.sendMessage(msg);
    trigger();
  }

}
