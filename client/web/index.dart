import 'dart:html';
import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:client/game_connect_client.dart';


main() {
  reactClient.setClientConfiguration();

  if (Uri.base.queryParameters['debug'] == true){
    // Todo:  add debug state
  } else {

  }

  final Element container = querySelector('#content-container');
  react.render(gameConnectClientComponent({}), container);

}