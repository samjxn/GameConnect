part of game_connect_client.src.stores;

class PairingScreenStore extends flux.Store {

  GameConnectClientActions _actions;
  GameConnectClientApi _api;
  PairCode _pairCode = null;
  bool _pairCodeRequestMade = false;

  String get pairCode {
    if (_pairCode == null && !_pairCodeRequestMade) {
      _pairCodeRequestMade = true;
      _api.requestPairCode();
    }
    return _pairCode?.code ?? '00000';
  }

  bool get hasPairCode => _pairCode != null;

  //NOTE:  Cannot make asynchronous calls from the constructor!
  //  Pairing code will be loaded after instantiation
  PairingScreenStore(this._actions, this._api) {
    // listen for actions:  instantiate listeners
    _actions.onSocketConnect.listen(_onLoadStore);
    _actions.pairCodeReceived.listen(_onPairCodeReceived);
    _actions.requestPairCode.listen(_onRequestPairCode);
    _actions.setCurrentComponent.listen(_onSetComponent);
  }

  void _onLoadStore(_) {
//    _api.requestPairCode();
  }

  _onRequestPairCode(_){
    if (!_pairCodeRequestMade) {
      _api.requestPairCode();
    }
  }

  void _onPairCodeReceived(String code) {
    _pairCode = new PairCode(code);
    _pairCodeRequestMade = false;
    trigger();
  }

  void _onSetComponent(String component) {
    if (component != 'pairingScreenComponent'){
      _pairCode = null;
    } else {
      if (!_pairCodeRequestMade) {
        _api.requestPairCode();
      }
    }
  }

}