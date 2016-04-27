part of game_connect_client.src.game_connect_client_component;

var gameDisplayComponent =
    react.registerComponent(() => new _GameDisplayComponent());

class _GameDisplayComponent extends flux
    .FluxComponent<GameConnectClientActions, GameConnectClientStores> {
  redrawOn() => [store.gameConnectClientStore, store.gameDisplayStore];

  var canvas;
  var _game;

  void componentDidMount(rootNode) {
    switch (store.gameDisplayStore.activeGameId) {
      case GameIds.SNAKE:
        _game = new SnakeGame();
        break;
      case GameIds.LITE_BIKE:
        _game = new LightBikeGame();
        break;
    }
    store.gameDisplayStore.forwarder.registerListener(_game);
    _game.onDidMount(store.gameConnectClientStore.players,
        store.gameDisplayStore.api, actions);
    _game.run();
  }

  render() {
    // don't remake the canvas
    canvas ??= react.canvas({
      'id': "game-canvas",
      "height": "${window.innerHeight * .9}",
      "width": "${window.innerHeight}"
    }, []);

    return react.div({
      'className': 'game-display-area'
    }, [
      react.div({'className': 'game-content'}, [canvas]),
    ]);
  }
}
