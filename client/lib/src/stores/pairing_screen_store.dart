part of game_connect_client.src.stores;

class PairingScreenStore extends flux.Store {

  GameConnectClientActions _actions;
  GameConnectClientApi _api;
  PairCode _pairCode = null;
  static bool _pairCodeRequestMade = false;
  static bool _pairScreenActive = false;

  String get pairCode {
    return _pairCode?.code ?? '00000';
  }

  bool get hasPairCode => _pairCode != null;

  //NOTE:  Cannot make asynchronous calls from the constructor!
  //  Pairing code will be loaded after instantiation
  PairingScreenStore(this._actions, this._api) {
    // listen for actions:  instantiate listeners
    _actions.onSocketConnect.listen(_onWebsocketConnect);
    _actions.pairCodeReceived.listen(_onPairCodeReceived);
    _actions.requestPairCode.listen(_onRequestPairCode);
    _actions.setCurrentComponent.listen(_onSetComponent);
    _actions.onQuit.listen(_onQuit);
  }

  void _onWebsocketConnect(_) {
    if (!_pairCodeRequestMade) {
      _pairCodeRequestMade = _api.requestPairCode();
    }
  }

  void _onQuit(_) {
    _onSetComponent("pairingScreenComponent");
  }

  _onRequestPairCode(_){
//    if (!_pairCodeRequestMade) {
//      _api.requestPairCode();
//    }
  }

  void _onPairCodeReceived(String code) {
    _pairCode = new PairCode(code);
    trigger();
  }

  void _onSetComponent(String component) {
  if (component == 'pairingScreenComponent' && !_pairScreenActive) {
    _pairScreenActive = true;
    if (!_pairCodeRequestMade) {
      _pairCodeRequestMade = _api.requestPairCode();
    }
  } else if (_pairScreenActive && component != 'pairingScreenComponent') {
      _pairScreenActive = false;
      _pairCodeRequestMade = false;
      _pairCode = null;
    }
  }
}