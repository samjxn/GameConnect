part of hello_world;

var greetingComponent = registerComponent(() => new GreetingComponent());

class GreetingComponent extends FluxComponent<HelloWorldActions, GreetingDisplayStore> {

  redrawOn() => [store];

  render() => div({'className':'greeting'}, store.greeting);
}