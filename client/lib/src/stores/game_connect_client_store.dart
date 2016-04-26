part of game_connect_client.src.stores;

class GameConnectClientStore extends flux.Store {

  GameConnectClientActions _actions;

  String _currentComponent;
  GameConnectClientApi _api;

  Map<String, Player> _groupMembers;

  get currentComponent => _currentComponent;
  List<Player> get players => _groupMembers.values;

  GameConnectClientStore(this._actions, this._api) {
    _groupMembers = {};
    _actions.setCurrentComponent.listen(_onSetComponent);
    _actions.onQuit.listen(_onUserQuit);
    _actions.registerClient.listen(_onRegisterClient);
    _actions.disconnectPlayer.listen(_deRegisterClient);
  }

  _onRegisterClient(RegisterClientPayload p) {
    _groupMembers[p.clientId] = new Player(p.clientId, p.displayName);
    trigger();
  }

  _onSetComponent(String componentName) {
    _currentComponent = componentName;
    trigger();
  }

  _onUserQuit(_){
    _groupMembers = {};
    _onSetComponent(Screens.GROUPING_SCREEN);
  }

  _deRegisterClient(String clientId) {
    _groupMembers.remove(clientId);
    trigger();
  }
}