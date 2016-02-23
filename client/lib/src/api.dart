library game_connect_client.src.api;

import 'dart:async';
import 'dart:math';
import 'dart:html';
import 'dart:convert';
import 'package:client/src/game_connect_client_models.dart';
import 'package:client/src/game_connect_actions.dart';

class GameConnectClientApi {

  WebSocket _socket;
  GameConnectClientActions _actions;
  WebSocketMessageDelegator _delegator;

  GameConnectClientApi(this._actions){

    _delegator = new WebSocketMessageDelegator(_actions);

    void initWebSocket([int retrySeconds = 2]) {
      var reconnectScheduled = false;
      outputMsg("Connecting to websocket");

      // TODO:  Change address when we have a working backend
      _socket = new WebSocket('ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/gameconnect');

      void scheduleReconnect() {
        if (!reconnectScheduled) {
          new Timer(new Duration(milliseconds: 1000 * retrySeconds), () => initWebSocket(retrySeconds * 2));
        }
        reconnectScheduled = true;
      }

      _socket.onOpen.listen((e) {
        _actions.onSocketConnect();
      });

      _socket.onClose.listen((e) {
        outputMsg('Websocket closed');
      });

      _socket.onError.listen((e) {
        outputMsg("Error connecting to ws");
        scheduleReconnect();
      });

      _socket.onMessage.listen((MessageEvent e) {
        print("MESSAGE:  "+e.data);
        MessageReceivedStrategy m = _delegator.delegateReceivedMessage(e);
        m.executeStrategy();
      });
    }

    initWebSocket();
  }

  void outputMsg(String msg){
    print(msg);
  }

  bool requestPairCode() {

    Map<String, dynamic> _messageJson = {};

    _messageJson['groupId'] = null;
    _messageJson['sourceType'] = "pc-client";
    _messageJson['messageType'] = "pairing-request";
    _messageJson['content'] = null;

//    _socketJson['client_id'] = 'MY_ID';
//    _socketJson['requesting_room'] = true;

    String _jsonStr = JSON.encode(_messageJson);

    if(_socket.readyState == 1) {
      _socket.send(_jsonStr);
      return true;
    }

    return false;

//     TODO:  remove when backend communication works
//    Random r = new Random();
////    _actions.pairCodeReceived(r.nextInt(100000).toString());
//    String pretendJsonStr = '{"pair_code":"${r.nextInt(100000).toString()}"}';
//    MessageReceivedStrategy m = _delegator.delegateReceivedMessage(null, fakeData:pretendJsonStr);
//    m.executeStrategy();
  }

}