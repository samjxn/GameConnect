part of game_connect_client.src.stores;

class GroupingScreenStore extends flux.Store {

  GameConnectClientActions _actions;
  GameConnectClientApi _api;
  GroupCode _groupCode = null;
  static bool _groupCodeRequestMade = false;
  static bool _groupScreenActive = false;

  String get groupCode {
    return _groupCode?.code ?? '00000';
  }

  //NOTE:  Cannot make asynchronous calls from the constructor!
  //  Grouping code will be loaded after instantiation
  GroupingScreenStore(this._actions, this._api) {
    // listen for actions:  instantiate listeners
    _actions.onSocketConnect.listen(_onWebsocketConnect);
    _actions.groupingCodeReceived.listen(_onGroupCodeReceived);
    _actions.requestGroupCode.listen(_onRequestGroupCode);
    _actions.setCurrentComponent.listen(_onSetComponent);
    _actions.onQuit.listen(_onQuit);
  }

  void _onWebsocketConnect(_) {
    if (!_groupCodeRequestMade) {
      _groupCodeRequestMade = _api.requestGroupingCode();
    }
  }

  void _onQuit(_) {
    _onSetComponent("groupingScreenComponent");
  }

  // TODO:  Delete?
  void _onRequestGroupCode(_){

  }

  void _onGroupCodeReceived(String code) {
    _groupCode = new GroupCode(code);
    trigger();
  }

  void _onSetComponent(String component) {
  if (component == 'groupingScreenComponent' && !_groupScreenActive) {
    _groupScreenActive = true;
    if (!_groupCodeRequestMade) {
      _groupCodeRequestMade = _api.requestGroupingCode();
    }
  } else if (_groupScreenActive && component != 'groupingScreenComponent') {
      _groupScreenActive = false;
      _groupCodeRequestMade = false;
      _groupCode = null;
    }
  }
}