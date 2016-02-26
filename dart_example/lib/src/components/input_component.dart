part of hello_world;

var inputComponent = registerComponent(() => new InputComponent());



class InputComponent extends Component {

  GreetingDisplayStore get store => props['store'];
  HelloWorldActions get actions => props['actions'];

  void onInputChange(SyntheticFormEvent e) {
    actions.updateDisplayText.call(e.target.value);
  }

  void onButtonClick(SyntheticMouseEvent e){
    actions.connectionButtonPressed.call();
  }

  render () {
    var user_input = div({'className':'user-input-form-wrapper'},
        [
          input({'className': 'user-input-form', 'onChange': onInputChange}),
          button({'className': 'button-open-websocket', 'onClick': onButtonClick}, "Chat Room")
        ]);
    return user_input;
  }
}