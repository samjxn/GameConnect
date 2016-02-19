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
      _socket = new WebSocket('ws://echo.websocket.org');

      void scheduleReconnect() {
        if (!reconnectScheduled) {
          new Timer(new Duration(milliseconds: 1000 * retrySeconds), () => initWebSocket(retrySeconds * 2));
        }
        reconnectScheduled = true;
      }

      _socket.onOpen.listen((e) {
        outputMsg('Connected');
        _actions.onSocketConnect(null);
      });

      _socket.onClose.listen((e) {
        outputMsg('Websocket closed');
      });

      _socket.onError.listen((e) {
        outputMsg("Error connecting to ws");
        scheduleReconnect();
      });

      _socket.onMessage.listen((MessageEvent e) {
        MessageReceivedStrategy m = _delegator.delegateReceivedMessage(e);
        m.executeStrategy();
      });
    }

    initWebSocket();
  }

  void outputMsg(String msg){}

  void requestPairCode() {

    Map<String, dynamic> _socketJson = {};

    _socketJson['client_type'] = 'pc-client';
    _socketJson['client_id'] = 'MY_ID';
    _socketJson['requesting_room'] = true;

    String _jsonStr = JSON.encode(_socketJson);

    // TODO:  Enable when we can talk with the backend
//    _socket.send(_jsonStr);

    // TODO:  remove when _delegateReceivedMessageEvent works
    Random r = new Random();
//    _actions.pairCodeReceived(r.nextInt(100000).toString());
    String pretendJsonStr = '{"pair_code":"${r.nextInt(100000).toString()}"}';
    MessageReceivedStrategy m = _delegator.delegateReceivedMessage(null, fakeData:pretendJsonStr);
    m.executeStrategy();
  }

}