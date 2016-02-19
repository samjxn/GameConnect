part of game_connect_client.src.models;


/**
 * Returns a strategy for what to do when receiving a message
 */

class WebSocketMessageDelegator {

  GameConnectClientActions _actions;

  WebSocketMessageDelegator(this._actions);

  MessageReceivedStrategy delegateReceivedMessage(MessageEvent e, {fakeData: null}){

    String toDecode = fakeData ?? e.data;

    Map jsonData = JSON.decode(toDecode);

    if (jsonData['pair_code'] != null){
      return new PairCodeReceivedStrategy(_actions, jsonData);
    }

    return null;

  }

}