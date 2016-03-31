part of game_connect_client.src.models;

abstract class MessageReceivedStrategy {

  List<flux.Action> _actionsToComplete = [];
  Map<flux.Action, dynamic> _payloads = {};

  dynamic executeStrategy(){
    _actionsToComplete.forEach((flux.Action action) =>
        action.call(_payloads[action]));

    return;
  }
}

class GroupCodeReceivedStrategy extends MessageReceivedStrategy {
  GroupCodeReceivedStrategy(GameConnectClientActions _actions, Map jsonData) {
    _actionsToComplete.add(_actions.groupingCodeReceived);
    _payloads[_actions.groupingCodeReceived] = jsonData['content']['groupingCode'];
  }
}

class GroupingAcceptedStrategy extends MessageReceivedStrategy {
  GroupingAcceptedStrategy(GameConnectClientActions _actions, Map jsonData) {
    _actionsToComplete.add(_actions.setCurrentComponent);
    _payloads[_actions.setCurrentComponent] = Screens.LEVEL_SELECT_SCREEN;
  }
}

class DoNothingStrategy extends MessageReceivedStrategy {

  DoNothingStrategy(GameConnectClientActions _actions, Map jsonData) {
    _actionsToComplete = [];
    _payloads = {};
  }
}