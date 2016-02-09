import 'package:react/react.dart';

var inputComponent = registerComponent(() => new InputComponent());

class InputComponent extends Component {

  render () => div({},
    input({"ref":"input"})
  );
}