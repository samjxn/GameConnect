part of game_connect_client.src.stores;

class GameConnectClientStore extends flux.Store {

  GameConnectClientActions _actions;

  String _currentComponent;
  GameConnectClientApi _api;

  Map<String, String> _clientDisplayNames;

  get currentComponent => _currentComponent;
  Map<String, String> get clientDisplayNames => _clientDisplayNames;

  GameConnectClientStore(this._actions, this._api) {
    _clientDisplayNames = {};
    _actions.setCurrentComponent.listen(_onSetComponent);
    _actions.onQuit.listen(_onUserQuit);
    _actions.registerClient.listen(_onRegisterClient);
  }

  _onRegisterClient(RegisterClientPayload p) {
    _clientDisplayNames[p.clientId] = p.displayName;
    trigger();
  }

  _onSetComponent(String component) {
    _currentComponent = component;
    trigger();
  }

  _onUserQuit(_){
    _onSetComponent('groupingScreenComponent');
  }
}