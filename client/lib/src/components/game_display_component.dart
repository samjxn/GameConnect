part of game_connect_client.src.game_connect_client_component;


var gameDisplayComponent = react.registerComponent(()=> new _GameDisplayComponent());

class _GameDisplayComponent extends flux.FluxComponent<GameConnectClientActions, GameConnectClientStores>{

  song1() {
//    return react.audio({}, "test");
    return "test";
  }

  redrawOn() => [store.gameConnectClientStore];

  render() => react.div({'className':'game-display-area'}, [
    react.button({
      'onClick':
          (_) {
            actions.onQuit.call();
          }
    }, "Simulate disconnect grouping."),
//    react.div(song)
    react.div({}, react.audio({'controls':false, 'autoPlay':true, 'src':'./nyan.ogg'}, react.source({'src':'./nyan.ogg', 'type':'/audio/ogg'}))),
  ]);
}
