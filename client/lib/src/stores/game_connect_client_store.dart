part of game_connect_client.src.stores;

class GameConnectClientStore extends flux.Store {

  GameConnectClientActions _actions;

  //TODO:  Don't represent components via strings
  String _currentComponent;
  GameConnectClientApi _api;

  get currentComponent => _currentComponent;


  GameConnectClientStore(this._actions, this._api) {
    _actions.setCurrentComponent.listen(_onSetComponent);
    _actions.onQuit.listen(_onUserQuit);
  }

  _onSetComponent(String component) {
    _currentComponent = component;
    trigger();
  }

  _onUserQuit(_){
    _onSetComponent('pairingScreenComponent');
  }
}