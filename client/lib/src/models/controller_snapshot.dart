part of game_connect_client.src.models;


class ControllerSnapshot {

  String _dpadInput;
  bool _aPressed;
  bool _bPressed;
  String _senderId;

  String get dpadInput => _dpadInput;
  bool get aPressed => _aPressed;
  bool get bPressed => _bPressed;
  String get senderId => _senderId;

  //{"clientId":"f407fe13-4699-42da-9b80-6b113a2cff65","groupId":"1","sourceType":"controller","messageType":"controller-snapshot","content":{"d-pad-input":"2","a-pressed":false,"b-pressed":false}}

  ControllerSnapshot.fromJsonMap(Map jsonData) {
    var jsonDataContent = jsonData['content'];
    _senderId = jsonData['clientId'];
    _dpadInput = jsonDataContent['d-pad-input'];
    _aPressed = jsonDataContent['a-pressed'];
    _bPressed = jsonDataContent['b-pressed'];
  }


  toString(){
    return "[Snapshot] D-Pad: $_dpadInput, A: $_aPressed, B: $_bPressed";
  }

}