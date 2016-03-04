part of game_connect_client.src.game_connect_client_component;


var chatExampleComponent = react.registerComponent(()=> new _ChatExampleComponent());

class _ChatExampleComponent extends flux.FluxComponent<GameConnectClientActions, GameConnectClientStores>{

  redrawOn() => [store.chatExampleStore];

  _getMessageDivs() {
    List<String> messages = store.chatExampleStore.chatMessages;

    List _messageDivs = [];

    messages.forEach((String message){
      _messageDivs.add(react.div({'className':'chat-example-message'}, message));
    });

    return _messageDivs;
  }

  render() {
    return react.div({'className': 'chat-example-screen'}, [
      react.div({'className':'chat-screen-header'}, "Chat Example"),
      react.div({'className':'chat-content'}, _getMessageDivs()),
    ]);
  }
}
