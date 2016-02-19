import 'dart:html';
import 'dart:async';
import 'package:hello_world/src/hello_world_actions.dart';

class HelloWorldApi {

  /**
   * Handles data for websocket
   */

  WebSocket ws;
  HelloWorldActions _actions;


  HelloWorldApi(this._actions);

  void outputMsg(String msg) {
    _actions.chatRoomMessageReceived.call(msg);
  }

  void initWebSocket([int retrySeconds = 2]) {
    var reconnectScheduled = false;

    outputMsg("Connecting to websocket");
//    ws = new WebSocket('ws://dbosch-pc.student.iastate.edu:8080/WebSocketTests/chat');
    ws = new WebSocket('ws://echo.websocket.org');


    void scheduleReconnect() {
      if (!reconnectScheduled) {
        new Timer(new Duration(milliseconds: 1000 * retrySeconds), () => initWebSocket(retrySeconds * 2));
      }
      reconnectScheduled = true;
    }

    ws.onOpen.listen((e) {
      outputMsg('Connected');
    });

    ws.onClose.listen((e) {
      outputMsg('Websocket closed');
    });

    ws.onError.listen((e) {
      outputMsg("Error connecting to ws");
      scheduleReconnect();
    });

    ws.onMessage.listen((MessageEvent e) {
      outputMsg(e.data);
    });
  }

  void sendMessage(String message){
    ws.send(message);
  }

  void closeSocket() {
    ws.close();
  }

}