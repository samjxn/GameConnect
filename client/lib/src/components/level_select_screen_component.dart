part of game_connect_client.src.game_connect_client_component;

var leveSelectScreenComponent = react.registerComponent(()=> new _LevelSelectComponent());

class _LevelSelectComponent extends flux.FluxComponent<GameConnectClientActions, GameConnectClientStores> {

  List<flux.Store> redrawOn() => [store.levelSelectStore];


  render() {
    return react.div({}, [
      react.button({'onClick': (_){
        actions.onQuit('groupingScreenComponent');
      }}, "Simulate Disconnect"),
      react.button({'onClick': (_){
        actions.setCurrentComponent(Screens.GAME_DISPLAY);
        actions.setActiveGame(GameIds.SNAKE);
      }}, "Simulate Game Selected"),
    ]);
  }
}
