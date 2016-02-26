part of game_connect_client.src.models;

class GroupCode {


  int _groupCodeInt;
  String _code;

  int get groupCodeInt => _groupCodeInt;
  String get code => _code;


  GroupCode(String this._code) {

    _groupCodeInt = int.parse(_code);

    var _codeList = _code.split('');
    for (int i = 5 - _codeList.length; i > 0; i--){
      _code = '0' + _code;
    }
  }


}