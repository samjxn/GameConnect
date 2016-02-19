library game_connect_client.src.actions;

import 'package:w_flux/w_flux.dart';
import 'package:client/src/game_connect_stores.dart';

class GameConnectClientActions {


  Action onSocketConnect = new Action();
  Action<String> pairCodeReceived = new Action<String>();
  Action<String> setCurrentComponent = new Action<String>();

}