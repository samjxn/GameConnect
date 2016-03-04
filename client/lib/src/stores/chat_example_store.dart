part of game_connect_client.src.stores;

class ChatExampleStore extends flux.Store {

  GameConnectClientActions _actions;

  List<String> _chatMessages = [];

  List<String> get chatMessages => _chatMessages;

  ChatExampleStore(GameConnectClientActions this._actions) {
    _actions.onChatMessageReceived.listen(_onMessageReceived);
  }

  void _onMessageReceived(String message) {
    _chatMessages.add(message);
  }

}