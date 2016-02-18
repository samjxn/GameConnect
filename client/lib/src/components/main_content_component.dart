part of game_connect_client.src.game_connect_client_component;

var mainContentComponent =
    react.registerComponent(() => new _MainContentComponent());

class _MainContentComponent
  extends flux.FluxComponent<GameConnectClientActions, GameConnectClientStores> {

  List <flux.Store> redrawOn() => [store.gameConnectClientStore];

  render() => react.div({'className': 'pairing-screen-container'}, pairingScreenComponent({'actions': actions, 'store': store}));
}
