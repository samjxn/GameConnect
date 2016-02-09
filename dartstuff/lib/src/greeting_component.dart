import 'package:react/react.dart';

var greetingComponent = registerComponent(() => new GreetingComponent());

class GreetingComponent extends Component {

  render() => div({'className':'greeting'}, "Hello World!");
}