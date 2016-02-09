import 'dart:html';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:hello_world/hello_world.dart';

main() {
  reactClient.setClientConfiguration();

  render(helloWorldComponent({}), querySelector('#greeting'));
}