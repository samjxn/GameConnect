part of game_connect_client.src.game_connect_client_component;


var gameDisplayComponent = react.registerComponent(()=> new _GameDisplayComponent());

class _GameDisplayComponent extends flux.FluxComponent<GameConnectClientActions, GameConnectClientStores>{


  redrawOn() => [store.gameConnectClientStore, store.gameDisplayStore];

  var canvas;
  SnakeGame _game;

  _GameDisplayComponent(){
    _game = new SnakeGame();
  }

  void componentDidMount(rootNode) {
    store.gameDisplayStore.forwarder.registerListener(_game);
    _game.onDidMount(store.gameConnectClientStore.players);
    _game.run();
  }

  render() {
    // don't remake the canvas
    canvas ??= react.canvas({'id':"snake-canvas", "height": "${window.innerHeight}", "width": "${window.outerHeight}"},[]);

    return react.div({'className':'game-display-area'}, [
      react.div({'className':'game-content'}, [
        canvas
      ]),
    ]);
  }
}


