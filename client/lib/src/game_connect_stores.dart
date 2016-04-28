library game_connect_client.src.stores;

import 'package:w_flux/w_flux.dart' as flux;
import 'package:client/src/game_connect_actions.dart';
import 'package:client/src/api.dart';
import 'package:client/src/game_connect_client_models.dart';
import 'dart:html';

// Parts
part 'stores/grouping_screen_store.dart';
part 'stores/game_connect_client_store.dart';
part 'stores/level_select_store.dart';
part 'stores/game_display_store.dart';
part 'stores/chat_demo_store.dart';

class GameConnectClientStores {
  GroupingScreenStore groupingScreenStore;
  GameConnectClientStore gameConnectClientStore;
  LevelSelectStore levelSelectStore;
  GameDisplayStore gameDisplayStore;
  ChatDemoStore chatDemoStore;

  GameConnectClientStores(
      GameConnectClientActions actions, GameConnectClientApi api) {
    groupingScreenStore = new GroupingScreenStore(actions, api);
    gameConnectClientStore = new GameConnectClientStore(actions, api);
    levelSelectStore = new LevelSelectStore();
    gameDisplayStore = new GameDisplayStore(actions, api);
    chatDemoStore = new ChatDemoStore(actions, this);
  }
}
