import 'package:hello_world/src/hello_world_actions.dart';
import 'greeting_display_store.dart';
import 'chat_room_store.dart';
import 'package:hello_world/src/api.dart';

export 'greeting_display_store.dart';
export 'chat_room_store.dart';

class HelloWorldStores {

  GreetingDisplayStore greetingDisplayStore;
  ChatRoomStore chatRoomStore;

  HelloWorldStores(HelloWorldActions actions, HelloWorldApi api){
    greetingDisplayStore = new GreetingDisplayStore(actions);
    chatRoomStore = new ChatRoomStore(actions, api);
  }

}