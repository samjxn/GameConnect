import 'package:w_flux/w_flux.dart';
import 'package:hello_world/src/hello_world_actions.dart';

class GreetingDisplayStore extends Store {

  HelloWorldActions _actions;

  String _displayText = "Hello, world!";
  String get greeting {
    return _displayText;
  }

  GreetingDisplayStore(this._actions) {
    _actions.updateDisplayText.listen(_onUpdateDisplayText);
  }

  void _onUpdateDisplayText(String text) {
    if (text.isNotEmpty) {
      _displayText = "Hello, ${text}!";
    } else {
      _displayText = "Hello, world!";
    }
    trigger();
  }

}