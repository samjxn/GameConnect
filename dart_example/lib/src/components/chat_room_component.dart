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

  _onInputKeyUp(SyntheticKeyboardEvent e) {
    // KeyCode 13 is 'return'
    if (e.keyCode == 13) {
      actions.sendChatMessage.call(e.target.value);
    }
  }

  _onClearMessages(SytheticMouseEvent e){
    actions.clearChatMessages.call();
  }

  render() {
    bool shouldDisplay = store.isConnected;

    List toRender = [];

    if (shouldDisplay) {
      toRender.add(
          div({},[
            input({
                'className':'chatroom-input',
                'onKeyUp': _onInputKeyUp
              }),
            button({
              'className':'chatroom-clear-messages-button',
              'onClick': _onClearMessages
            },("Clear Messages")),
            ]
          )
      );
      toRender.add(_buildChatRoom());
    }

    var domElement = div({'className': 'chat-room-wrapper'}, toRender);
    return domElement;
  }
}