part of game_connect_client.src.game_connect_client_component;

var gameDisplayComponent =
    react.registerComponent(() => new _GameDisplayComponent());

class _GameDisplayComponent extends flux
    .FluxComponent<GameConnectClientActions, GameConnectClientStores> {
  redrawOn() => [store.gameConnectClientStore, store.gameDisplayStore];

  var bottomCanvas;
  var middleCanvas;
  var topCanvas;
  var _game;

  void componentDidMount(rootNode) {
    _initGame(){
      store.gameDisplayStore.forwarder.registerListener(_game);
      _game.onDidMount(store.gameConnectClientStore.players,
          store.gameDisplayStore.api, actions);
      _game.run();
    }

    switch (store.gameDisplayStore.activeGameId) {
      case GameIds.SNAKE:
        _game = new SnakeGame();
        _initGame();
        break;
      case GameIds.LITE_BIKE:
        _game = new LightBikeGame();
        _initGame();
        break;
      case GameIds.COINS:
        break;
      case GameIds.CHAT:
        break;
    }

  }

  _gameContent() {
    var content;
    switch(store.gameDisplayStore.activeGameId) {
      case GameIds.SNAKE:
        content = [bottomCanvas];
        break;
      case GameIds.LITE_BIKE:
        content = [bottomCanvas];
        break;
      case GameIds.COINS:
        content = [bottomCanvas, middleCanvas, topCanvas];
        break;
      case GameIds.CHAT:
        content = [chatComponent({'actions':actions,'store':store})];
        break;
    }

    return content;
  }

  render() {



    // don't remake the canvas
    bottomCanvas ??= react.canvas({
      'id': "game-canvas",
      'className': 'game-display-canvas',
      "height": "${window.innerHeight * .9}",
      "width": "${window.innerHeight}"
    }, []);

    middleCanvas ??= react.canvas({
      'id': "middle-canvas",
      'className': 'game-display-canvas',
      "height": "${window.innerHeight * .9}",
      "width": "${window.innerHeight}"
    }, []);

    topCanvas ??= react.canvas({
      'id': "top-canvas",
      'className': 'game-display-canvas',
      "height": "${window.innerHeight * .9}",
      "width": "${window.innerHeight}"
    }, []);

    return react.div({
      'className': 'game-display-area'
    }, [
      react.div({'className': 'game-content'}, _gameContent()),
    ]);
  }
}
