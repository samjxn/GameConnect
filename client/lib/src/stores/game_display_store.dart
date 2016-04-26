part of game_connect_client.src.stores;

class GameDisplayStore extends flux.Store {

  GameConnectClientActions _actions;
  GameConnectClientApi api;

  String _activeGameId;

  String get activeGameId => _activeGameId;

  ControllerSnapshot _snapshot;
  ControllerSnapshot get lastSnapshot => _snapshot;

  ControlForwarder _forwarder;
  ControlForwarder get forwarder => _forwarder;

  GameDisplayStore(GameConnectClientActions this._actions, GameConnectClientApi this.api) {
    _forwarder = new ControlForwarder();
    _activeGameId = null;

    _actions.setActiveGame.listen(_onSetActiveGame);
    _actions.controllerSnapshotReceived.listen(_onSnapshotReceived);
  }

  _onSetActiveGame(String gameId) {
    _activeGameId = gameId;
    trigger();
  }

  _onSnapshotReceived(ControllerSnapshot snapshot) {
    this._snapshot = snapshot;
    _forwarder.sendSnapshot(snapshot);
    trigger();
  }
}
