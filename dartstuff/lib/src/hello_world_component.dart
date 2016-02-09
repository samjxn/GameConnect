import 'package:react/react.dart';
import 'greeting_component.dart';
import 'input_component.dart';
import 'dart:html';

var helloWorldComponent = registerComponent(() => new HelloWorldComponent());

class HelloWorldComponent extends Component {

  render() => div({'className':'content-area'}, [greetingComponent({}), inputComponent({})]);

//  componentDidMount(root) {
//    var inputRef = ref("input");
//    InputElement input = findDOMNode(inputRef);
//
//    _DartCompo
//  }
}