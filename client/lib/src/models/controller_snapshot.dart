part of game_connect_client.src.models;


class ControllerSnapshot {

  int _dpadInput;
  bool _aPressed;
  bool _bPressed;

  int get dpadInput => _dpadInput;
  bool get aPressed => _aPressed;
  bool get bPressed => _bPressed;

  ControllerSnapshot.fromJsonMap(Map jsonData) {
    _dpadInput = jsonData['d-pad-input'];
    _aPressed = jsonData['a-pressed'];
    _bPressed = jsonData['b-pressed'];
  }


  toString(){
    return "[Snapshot] D-Pad: $_dpadInput, A: $_aPressed, B: $_bPressed";
  }

}