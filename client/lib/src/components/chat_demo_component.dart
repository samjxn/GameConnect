part of game_connect_client.src.game_connect_client_component;

var chatComponent = react.registerComponent(() => new _ChatComponent());

class _ChatComponent  extends flux
    .FluxComponent<GameConnectClientActions, GameConnectClientStores> {
  List<flux.Store> redrawOn() =>
      [store.chatDemoStore];


  _buildChatList() {

    List messageDivs = [];

    store.chatDemoStore.messages.forEach((ChatMessage message){

      var nameDisplay = "";

      if (message.displayName != null) {
       nameDisplay = message.displayName + ":  ";
      }

      messageDivs.add(react.div({'className':'chat-message'}, nameDisplay + message.message));
    });

    return messageDivs;
  }

  render() => react.div({'className':'chat-wrapper'}, _buildChatList());
}