library game_connect_client.src.game_connect_client_component;

import 'dart:html';
import 'dart:collection';
import 'package:client/src/game_connect_client_models.dart';
import 'package:react/react.dart' as react;
import 'package:w_flux/w_flux.dart' as flux;

import 'game_connect_actions.dart';
import 'game_connect_stores.dart';
import 'api.dart';

part 'components/main_content_component.dart';
part 'components/pairing_screen_component.dart';
part 'components/level_select_screen_component.dart';

var gameConnectClientComponent =
  react.registerComponent(() => new _GameConnectClientComponent());

class _GameConnectClientComponent extends react.Component {

  static GameConnectClientActions _actions = new GameConnectClientActions();
  static GameConnectClientApi _api = new GameConnectClientApi(_actions);
  GameConnectClientStores _stores =  new GameConnectClientStores(_actions, _api);

  render() => react.div({'className': ''}, mainContentComponent({'actions': _actions, 'store': _stores}));
}