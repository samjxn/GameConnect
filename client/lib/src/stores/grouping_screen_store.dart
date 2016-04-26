part of game_connect_client.src.stores;

class GroupingScreenStore extends flux.Store {

  GameConnectClientActions _actions;
  GameConnectClientApi _api;
  GroupCode _groupCode = null;
  static bool _groupCodeRequestMade = false;

  String get groupCode {
    return _groupCode?.code ?? '00000';
  }

  //NOTE:  Cannot make asynchronous calls from the constructor!
  //  Grouping code will be loaded after instantiation
  GroupingScreenStore(this._actions, this._api) {
    // listen for actions:  instantiate listeners
    _actions.onSocketConnect.listen(_onWebsocketConnect);
    _actions.groupingCodeReceived.listen(_onGroupCodeReceived);
    _actions.setCurrentComponent.listen(_onSetComponent);
    _actions.onQuit.listen(_onQuit);
  }

  void _onWebsocketConnect(_) {
    if (!_groupCodeRequestMade) {
      _groupCodeRequestMade = _api.requestGroupingCode();
    }
  }

  void _onQuit(_) {
    _onSetComponent(Screens.GROUPING_SCREEN);
  }

  void _onGroupCodeReceived(String code) {
    _groupCode = new GroupCode(code);
    trigger();
  }

  void _onSetComponent(String componentName) {
  if (componentName != Screens.GROUPING_SCREEN) {
    return;
  }


  if (!_groupCodeRequestMade) {
      _groupCodeRequestMade = true;
      _groupCodeRequestMade = _api.requestGroupingCode();
    }else {
      _groupCodeRequestMade = false;
      _groupCode = null;
    }
  }
}