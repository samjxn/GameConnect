part of game_connect_client.src.models;

class PairCode {


  int _pairCodeInt;
  String _code;

  int get pairCodeInt => _pairCodeInt;
  String get code => _code;


  PairCode(String this._code) {

    _pairCodeInt = int.parse(_code);

    var _codeList = _code.split('');
    for (int i = 5 - _codeList.length; i > 0; i--){
      _code = '0' + _code;
    }
  }


}