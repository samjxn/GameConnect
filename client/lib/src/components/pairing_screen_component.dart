part of game_connect_client.src.game_connect_client_component;

/**
 *
 */

var pairingScreenComponent  = react.registerComponent(() => new _PairingScreenComponent());

class _PairingScreenComponent extends flux.FluxComponent<GameConnectClientActions, GameConnectClientStores> {

  List<flux.Store> redrawOn() => [store.pairingScreenStore];


  String pairCode() => store.pairingScreenStore.pairCode?.code;

  render() {

    var code = pairCode() ?? '00000';

    return react.div({'onClick': (_){
      print(store.pairingScreenStore.pairCode);
    }}, code);
  }
}