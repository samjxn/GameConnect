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


    if (jsonData['content']['groupingCode'] != null) {
      return new GroupCodeReceivedStrategy(_actions, jsonData);
    }

    if (jsonData['content']['groupingApproved'] != null) {
      return new GroupingAcceptedStrategy(_actions, jsonData);
    }

    if (jsonData['messageType'] == "context-selected") {
      return new GameSelectedStrategy(_actions, jsonData);
    }

    //{"content":{},"groupId":"0","sourceType":"backend","messageType":"disconnect"}
    if (jsonData['messageType'] == "disconnect") {
      return new DisconnectStrategy(_actions);
    }

//{groupId: 7, clientId: , ping: null, sourceType: controller, messageType: controller-snapshot, content: {d-pad-input: 3, a-pressed: false, b-pressed: false}}
   if (jsonData['messageType'] == "controller-snapshot" && jsonData['content'] != null) {
     return new ControllerInputReceivedStrategy(_actions, jsonData);
   }

    print("COULD NOT CREATE MESSAGE STRATEGY");
    print("${jsonData.toString()}");

    return new DoNothingStrategy(_actions, jsonData);
  }
}
