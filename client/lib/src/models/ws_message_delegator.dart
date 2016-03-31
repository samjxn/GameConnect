part of game_connect_client.src.models;

/**
 * Returns a strategy for what to do when receiving a message
 */

class WebSocketMessageDelegator {
  GameConnectClientActions _actions;

  WebSocketMessageDelegator(this._actions);

  MessageReceivedStrategy delegateReceivedMessage(MessageEvent e,
      {fakeData: null}) {
    String toDecode = fakeData ?? e.data;

    Map jsonData;
    try {
      jsonData = JSON.decode(toDecode);
    } catch (Exception) {
      return new DoNothingStrategy(_actions, jsonData);
    }

    switch(jsonData['messageType']) {
      
    }

    if (jsonData['content']['groupingCode'] != null) {
      return new GroupCodeReceivedStrategy(_actions, jsonData);
    }

    if (jsonData['content']['groupingApproved'] != null) {
      return new GroupingAcceptedStrategy(_actions, jsonData);
    }

    return null;
  }
}
