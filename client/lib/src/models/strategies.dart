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
  GroupCodeReceivedStrategy.GroupingCodeReceivedStrategy(GameConnectClientActions _actions, Map jsonData) {
    _actionsToComplete.add(_actions.groupingCodeReceived);
    _payloads[_actions.groupingCodeReceived] = jsonData['content']['groupingCode'];
  }
}

class DoNothingStrategy extends MessageReceivedStrategy {

  DoNothingStrategy(GameConnectClientActions _actions, Map jsonData) {
    _actionsToComplete = [];
    _payloads = {};
  }
}