part of hello_world;

var helloWorldComponent = registerComponent(() => new HelloWorldComponent());

class HelloWorldComponent extends Component {

  static HelloWorldActions _actions = new HelloWorldActions();
  static HelloWorldApi _api = new HelloWorldApi(_actions);
  static HelloWorldStores _stores = new HelloWorldStores(_actions, _api);

  HelloWorldComponent(){

  }

  render() => div({'className':'content-area'}, [
    greetingComponent({'store': _stores.greetingDisplayStore}),
    inputComponent({'store': _stores.greetingDisplayStore, 'actions': _actions}),
    chatRoomComponent({'store': _stores.chatRoomStore, 'actions': _actions})
  ]);

}