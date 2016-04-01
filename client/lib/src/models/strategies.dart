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

class GameSelectedStrategy extends MessageReceivedStrategy {

  GameSelectedStrategy(GameConnectClientActions _actions, Map jsonData) {
    _actionsToComplete.add(_actions.setCurrentComponent);
    _actionsToComplete.add(_actions.setActiveGame);
    _payloads[_actions.setCurrentComponent] = Screens.GAME_DISPLAY;
    _payloads[_actions.setActiveGame] = jsonData['content']['contextName'];
  }
}

class DisconnectStrategy extends MessageReceivedStrategy {
  DisconnectStrategy(GameConnectClientActions _actions) {
    _actionsToComplete.add(_actions.onQuit);
  }
}

class DoNothingStrategy extends MessageReceivedStrategy {

  DoNothingStrategy(GameConnectClientActions _actions, Map jsonData) {
    _actionsToComplete = [];
    _payloads = {};
  }
}

class ControllerInputReceivedStrategy extends MessageReceivedStrategy {

  ControllerInputReceivedStrategy(GameConnectClientActions _actions, Map jsonData) {

    ControllerSnapshot snapshot = new ControllerSnapshot.fromJsonMap(jsonData['content']);

    _actionsToComplete.add(_actions.controllerSnapshotReceived);
    _payloads[_actions.controllerSnapshotReceived] = snapshot;

  }
}