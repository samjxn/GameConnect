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
      print("Connecting to websocket");

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
        print('Websocket closed');
      });

      _socket.onError.listen((e) {
        print("Error connecting to ws");
        scheduleReconnect();
      });

      _socket.onMessage.listen((MessageEvent e) {
//        print("MESSAGE:  "+e.data);
        MessageReceivedStrategy m = _delegator.delegateReceivedMessage(e);
        m.executeStrategy();
      });
    }

    initWebSocket();
  }

  bool sendHighScore(String clientId, int score) {

    Map<String, dynamic> _messageJson = {};

    _messageJson['sourceType'] = "pc-client";
    _messageJson['messageType'] = "score";
    _messageJson['content'] = {'clientId': clientId, 'score': "$score"};

    if(_socket.readyState == 1) {
      _socket.send(JSON.encode(_messageJson));
      return true;
    }

    return false;
  }

  bool requestGroupingCode() {

    Map<String, dynamic> _messageJson = {};

    _messageJson['groupId'] = null;
    _messageJson['sourceType'] = "pc-client";
    _messageJson['messageType'] = "open-new-group";
    _messageJson['content'] = null;

    if(_socket.readyState == 1) {
      _socket.send(JSON.encode(_messageJson));
      return true;
    }

    return false;
  }

}