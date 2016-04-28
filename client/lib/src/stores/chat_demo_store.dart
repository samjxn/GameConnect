part of game_connect_client.src.stores;

class ChatDemoStore extends flux.Store {


  GameConnectClientActions _actions;
  GameConnectClientStores _stores;

  List<ChatMessage> messages;

  ChatDemoStore(this._actions, this._stores) {
    messages = [];
    _actions.onChatMessageReceived.listen(_displayChatMessage);
  }


  _displayChatMessage(ChatPayload payload){

    String senderName = _stores.gameConnectClientStore._groupMembers[payload.clientId]?.displayName;
    String message = payload.message;

    messages.add(new ChatMessage(senderName, message));
    trigger();
  }
}