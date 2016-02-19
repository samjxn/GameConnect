part of game_connect_client.src.stores;

class GameConnectClientStore extends flux.Store {

  GameConnectClientActions _actions;

  //TODO:  Don't represent current component with a string.
  var _currentComponent = 'pairingScreenComponent';

  get currentComponent => _currentComponent;


  GameConnectClientStore(this._actions) {
    _actions.setCurrentComponent.listen(_onSetComponent);
  }

  _onSetComponent(String component) {
    _currentComponent = component;
    trigger();
  }

}