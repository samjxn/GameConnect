part of game_connect_client.src.models;


class ControllerSnapshot {

  String _dpadInput;
  bool _aPressed;
  bool _bPressed;
  String _senderId;
  int _accelX;
  int _accelY;
  int _accelZ;

  String get dpadInput => _dpadInput;
  bool get aPressed => _aPressed;
  bool get bPressed => _bPressed;
  String get senderId => _senderId;
  int get tilt => _accelY;

  ControllerSnapshot.fromJsonMap(Map jsonData) {
    var jsonDataContent = jsonData['content'];
    _senderId = jsonData['clientId'];
    _dpadInput = jsonDataContent['d-pad-input'];
    _aPressed = jsonDataContent['a-pressed'];
    _bPressed = jsonDataContent['b-pressed'];
    _accelX = jsonDataContent['acceleration-x'];
    _accelY = jsonDataContent['acceleration-y'];
    _accelZ = jsonDataContent['acceleration-z'];
  }


  toString(){
    return "[Snapshot] D-Pad: $_dpadInput, A: $_aPressed, B: $_bPressed";
  }

}