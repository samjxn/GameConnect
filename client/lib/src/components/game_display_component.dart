part of game_connect_client.src.game_connect_client_component;


var gameDisplayComponent = react.registerComponent(()=> new _GameDisplayComponent());

class _GameDisplayComponent extends flux.FluxComponent<GameConnectClientActions, GameConnectClientStores>{

  redrawOn() => [store.gameConnectClientStore, store.gameDisplayStore];


  render() => react.div({'className':'game-display-area'}, [
    react.div({'className':'game-content'}, [
      store.gameDisplayStore.activeGameId
    ]),
  ]);
}
