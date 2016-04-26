library game_connect_client.src.actions;

import 'package:w_flux/w_flux.dart';
import 'package:client/src/game_connect_stores.dart';
import 'game_connect_client_models.dart';

class GameConnectClientActions {


  Action onSocketConnect = new Action();
  Action onQuit = new Action();
  Action requestGroupCode = new Action();
  Action<String> groupingCodeReceived = new Action<String>();
  Action<String> setCurrentComponent = new Action<String>();
  Action<ControllerSnapshot> controllerSnapshotReceived = new Action<ControllerSnapshot>();
  Action<String> setActiveGame = new Action<String>();
  Action<RegisterClientPayload> registerClient = new Action<RegisterClientPayload>();
  Action<String> disconnectPlayer = new Action<String>();

}