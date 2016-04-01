part of game_connect_client.src.stores;

class GameDisplayStore extends flux.Store {

  GameConnectClientActions _actions;
  GameConnectClientApi _api;

  String _activeGameId;

  String get activeGameId => _activeGameId;

  GameDisplayStore(GameConnectClientActions this._actions, GameConnectClientApi this._api) {
    _activeGameId = null;
    _actions.setActiveGame.listen(_onSetActiveGame);
  }

  _onSetActiveGame(String gameId) {
    _activeGameId = gameId;
    trigger();
  }
}
