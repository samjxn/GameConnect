library game_connect_client.src.stores;

import 'package:w_flux/w_flux.dart' as flux;
import 'package:client/src/game_connect_actions.dart';
import 'package:client/src/api.dart';
import 'package:client/src/game_connect_client_models.dart';
import 'dart:async';

// Parts
part 'stores/grouping_screen_store.dart';
part 'stores/game_connect_client_store.dart';
part 'stores/level_select_store.dart';
part 'stores/chat_example_store.dart';

class GameConnectClientStores {
  GroupingScreenStore groupingScreenStore;
  GameConnectClientStore gameConnectClientStore;
  ChatExampleStore chatExampleStore;
  LevelSelectStore levelSelectStore;

  GameConnectClientStores(
      GameConnectClientActions actions, GameConnectClientApi api) {
    groupingScreenStore = new GroupingScreenStore(actions, api);
    gameConnectClientStore = new GameConnectClientStore(actions, api);
    levelSelectStore = new LevelSelectStore();
    chatExampleStore = new ChatExampleStore(actions);

  }
}
