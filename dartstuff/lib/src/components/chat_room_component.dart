part of hello_world;

var chatRoomComponent = registerComponent(() => new ChatRoomComponent());


class ChatRoomComponent extends FluxComponent<HelloWorldActions, ChatRoomStore> {

  ChatRoomStore get store => props['store'];
  HelloWorldActions get actions => props['actions'];

  redrawOn() => [store];

  _buildChatRoom(){

    List message_divs = [];
    store.messages.forEach((String msg){
      message_divs.add(div({'className': 'chat-message'}, msg));
      message_divs.add(br({}));
    });

    return div({'className':'chat-room'}, message_divs);
  }

  render() {
    bool shouldDisplay = store.isConnected;

    List toRender = [];
    if (shouldDisplay) {
      toRender.add(input({'className':'chatroom-input', 'onKeyUp': (SyntheticKeyboardEvent e) {
        if (e.keyCode == 13) {
          actions.sendChatMessage.call(e.target.value);
        }
      }}));
      toRender.add(_buildChatRoom());
    }

    else {
      toRender.add("Chat room disconnected.");
    }
    var domElement = div({'className': 'chat-room-wrapper'}, toRender);
    return domElement;
  }
}