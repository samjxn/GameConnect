import 'package:hello_world/src/hello_world_actions.dart';
import 'greeting_display_store.dart';
export 'greeting_display_store.dart';

class HelloWorldStores {

  GreetingDisplayStore greetingDisplayStore;

  HelloWorldStores(HelloWorldActions actions){
    greetingDisplayStore = new GreetingDisplayStore(actions);
  }
}