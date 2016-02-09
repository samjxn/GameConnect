part of hello_world;

var inputComponent = registerComponent(() => new InputComponent());



class InputComponent extends Component {

  GreetingDisplayStore get store => props['store'];
  HelloWorldActions get actions => props['actions'];

  void onInputChange(SyntheticFormEvent e) {
    actions.updateDisplayText.call(e.target.value);
  }

  render () {
    var user_input = div(
        {'className': 'user-input-form',
          'onChange': onInputChange
        }, input({"ref":"input"}));
    return user_input;
  }
}