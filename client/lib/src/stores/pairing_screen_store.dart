part of game_connect_client.src.stores;

class PairingScreenStore extends flux.Store {

  GameConnectClientActions _actions;
  GameConnectClientApi _api;
  PairCode _pairCode = null;

  String get pairCode => _pairCode?.code ?? '00000';

  //NOTE:  Cannot make asynchronous calls from the constructor!
  //  Pairing code will be loaded after instantiation
  PairingScreenStore(this._actions, this._api) {
    // listen for actions:  instantiate listeners
    _actions.onSocketConnect.listen(_onLoadStore);
    _actions.pairCodeReceived.listen(_onPairCodeReceived);
  }

  void _onLoadStore(dynamic thereHasToBeSomeArgument) {
    _api.requestPairCode();
  }

  void _onPairCodeReceived(String code) {
    _pairCode = new PairCode(code);
    trigger();
  }

}