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
      return new DoNothingStrategy();
    }

    MessageReceivedStrategy strategy;

    String messageType = jsonData['messageType'];


    switch(messageType){
      case MessageTypes.GROUP_CODE_RESPONSE:
        strategy = new GroupCodeReceivedStrategy(_actions, jsonData);
        break;
      case MessageTypes.GROUPING_ACCEPTED:
        strategy = new GroupingAcceptedStrategy(_actions, jsonData);
        break;
      case MessageTypes.SET_PC_CLIENT_ID:
        strategy = new DoNothingStrategy();
        break;
      case MessageTypes.CLIENT_DISCONNECT:
        strategy = new DisconnectStrategy(_actions);
        break;
      case MessageTypes.CONTEXT_SELECTED:
        strategy = new GameSelectedStrategy(_actions, jsonData);
        break;
      case MessageTypes.CONTROLLER_SNAPSHOT:
        strategy = new ControllerInputReceivedStrategy(_actions, jsonData);
        break;
      case MessageTypes.SOFT_DISCONNECT:
        strategy = new SoftDisconnectStrategy(_actions, jsonData);
        break;
      default:
        print("COULD NOT CREATE MESSAGE STRATEGY:  ${jsonData.toString()}");
        strategy = new DoNothingStrategy();
    }

    return strategy;
  }
}
